/*
Object Name      : Supply Database Joins Trigger
Purpose          : To map Raw Fields to Mapped Accounts and to run the Joins to Sales Database. 
Created By       : Mohammad Usman / TechMatrix Consulting Pte Ltd. 
Modified By      : Antony Jerald / TechMatrix Consulting Pte Ltd.
Last Modified Date    : 4th Jan 2016
Last Modified Purpose : Revise the Code, with new Field / Object Names from Eyeota, and removed unwanted old fields.  
Last Modified Date    : 10th Jan 2016
Last Modified Purpose : Revise the Code with new Fields from Jessie

Modified By      : Rajesh Sahu / TechMatrix Consulting Pte Ltd.
Last Modified Date    : 28th Feb 2016
Last Modified Purpose : Populates 'Currency Code','Gross Earnings' and 'Net Earnings' field values

Modified By      : Saifullah saifi / TechMatrix Consulting Pte Ltd.
Last Modified Date    : 23rd Mar 2017
Last Modified Purpose : set the  'Currency Code= USD','Exchange Rate=1'  in else condition line 211

Modified By      : Antony 
Last Modified Date    : 18 May 2017
Last Modified Purpose : Adding Comments as per Eyeota's request to the extent feasible on an Apex Trigger. 
*/

trigger Supply_Database_tgr on Supply_Database__c (before update, before insert, after insert, after update, after delete, after undelete) {   

/***************************** Start  - Before Trigger Logic ************************************************************************/

    If((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){

/******************* Start - Variable Declarations  ***************************************************************************************/

        list<Segment_Revenue_Transaction__c> stToInsertList = new list<Segment_Revenue_Transaction__c>();
        list<String> existingAccName = new list<String>();
        list<Account> existAcc = new list<Account>();
        list<String> listSegmentNames = new list<String>();
        
        set<String> segMcodes = new set<String>();
        set<String> accNames = new set<String>();
        set<String> country= new set<String>();
        set<Date> sddate = new set<Date>();
        set<String> sccode = new set<String>();
        set<String> supplier = new set<String>();
        set<String> segNamesNew = new set<String>();
        set<String> segRevTransaction = new set<String>();
        
        map<String,String> mapSegMapSegCats = new map<String,String>(); 
        map<String,String> assignAccountAfterCreate = new map<String,String>();
        map<String,Account> toCreateAccounts = new map<String,Account>();
        map<String,String> mapField = new map<String,String>();
        map<String,String> segMap = new map<String,String>();
        map<String,Account> nameAndIdMap = new map<String,Account>();
        map<String,String> segTrans = new map<String,String>();
        map<String,String> countryMap = new map<String,String>();
        map<String,String> mapSegCategories = new map<String,String>();
        map<String,String> mapSegCatsNew = new map<String,String>();
        map<String,Account> toCreateAccountsMap = new map<String,Account>();
        map<String,Account> toInsert1 = new map<String,Account>();
        map<String,Account> allAcc = new map<String,Account>();

        String segmentName = null;
        
        map<String,Data_Supplier_Mapping__c> DataSuppMap = new map<String,Data_Supplier_Mapping__c>();
        map<String,Exchange_Rate__c> exchangRateMap = new map<String,Exchange_Rate__c>();
        
/******************* End - Variable Declarations  ***************************************************************************************/

/******************* Start - Collect Mapping Keys in Collections for Modified Records ***************************************************/

        for(Supply_Database__c supplyDB:Trigger.New)
        { 
            if(supplyDB.Data_Supplier_Raw_Original__c != null && supplyDB.Data_Supplier_Raw_Original__c != '')
            {
                supplyDB.Data_Supplier_Raw__c = supplyDB.Data_Supplier_Raw_Original__c.toUpperCase();
                supplier.add(supplyDB.Data_Supplier_Raw__c);                 
            }
            
            Date tempOctDt = Date.newInstance(2016, 10, 01);            
            if(supplyDB.Segment_Name_Supply_Raw_Original__c != null && supplyDB.Segment_Name_Supply_Raw_Original__c != '' && supplyDB.Date__c < tempOctDt)
            { //  If Date < 1/10/2016 
                supplyDB.Segment_Name_Supply_Raw__c= supplyDB.Segment_Name_Supply_Raw_Original__c.toUpperCase();                
            }
            
            if(supplyDB.Segment_Key_Raw__c != null && supplyDB.Segment_Key_Raw__c != '' && supplyDB.Date__c >= tempOctDt)
            { // If Date >= 1/10/2016
                supplyDB.Segment_Name_Supply_Raw__c= supplyDB.Segment_Key_Raw__c.toUpperCase();                
            }
            
            segMcodes.add(supplyDB.Segment_Name_Supply_Raw__c);  
            
            if(supplyDB.Target_Country_Raw__c != null && supplyDB.Target_Country_Raw__c != '')
            {
                supplyDB.Target_Country_Raw__c = supplyDB.Target_Country_Raw__c.toUpperCase();
                country.add(supplyDB.Target_Country_Raw__c);
                System.debug('Country abc +' + supplyDB.Target_Country_Raw__c ); 
            }

            if(supplyDB.Date__c != null)
            {
                sddate.add(supplyDB.Date__c);
            }    
            
            //Setup Default Values.        
            supplyDB.Currency_Code__c = 'USD';
            supplyDB.Exchange_Rate__c = 1;      
            supplyDB.Currency_Code_Error__c = '';      
        } 

/******************* End - Collect Mapping Keys in Collections for Modified Records ***************************************************/

/********** Start - Collect Mapping Keys/Master Record Ids in Collections from Master Tables ( Mapping Tables) ************************/


        for(Data_Supplier_Mapping__c ds:[Select Name, Id, Data_Supplier_Raw__c, Data_Supplier__c, Currency_Code__c From Data_Supplier_Mapping__c WHERE Data_Supplier_Raw__c IN:supplier])
        {    
        // Get matching Data Supplier Records for the modified Supply DB Data Supplier Raw combinations.            
            accNames.add(ds.Data_Supplier__c);
            mapField.put(ds.Data_Supplier_Raw__c,ds.Data_Supplier__c);   
            DataSuppMap.put(ds.Data_Supplier_Raw__c,ds);        
        }   
       
        for(Account a:[SELECT Id, OwnerId,Name,Owner.Name FROM Account WHERE Name IN: accNames])
        { 
        // Get the Supplier Accounts matching to the Data Supplier Records queried in the previous step.  
            nameAndIdMap.put(a.Name,a);             
        }

        if(country != null)
        {   
        // Get the Master Country Records matching to the input Country Raw Fields.
        
            for(Country__c c:[SELECT Id,Name,Master_Geography_Code__c FROM Country__c WHERE Master_Geography_Code__c IN:country])
            { 
                countryMap.put(c.Master_Geography_Code__c , c.Id);
            }       
        }

        for(Segment_Mapping__c sm:[SELECT Id, Segment_Name__c , Segment_Name_Supply_Raw__c FROM Segment_Mapping__c WHERE Segment_Name_Supply_Raw__c IN:segMcodes])
        {
        // Get the List of Segment Mapping Records matching to the Segment Key and Segment Name Original fields ( < Oct 2016 )    
            if(sm.Segment_Name__c != null && sm.Segment_Name__c != '')
            {
                segMap.put(sm.Segment_Name_Supply_Raw__c,sm.Id);
                listSegmentNames.add(sm.Segment_Name__c);
                mapSegMapSegCats.put(sm.Segment_Name_Supply_Raw__c,sm.Segment_Name__c);               
            }
        }
       
        for(Segment_Category_Mapping__c sm:[SELECT Segment_Name__c,Id FROM Segment_Category_Mapping__c WHERE Segment_Name__c IN:listSegmentNames])
        {
        // Get the list of Segment Category (Master Segments) for the corresponding Matching Segment Mapping Records found in the previous step.   
            if(sm.Segment_Name__c != null && sm.Segment_Name__c != '')
            {
                mapSegCategories.put(sm.Segment_Name__c,sm.Id);
                mapSegCatsNew.put(sm.Id,sm.Segment_Name__c);                
            }
        }

/********** End - Collect Mapping Keys/Master Record Ids in Collections from Master Tables ( Mapping Tables) ************************/
        
        //Sets for currencyCode and date initialized to null.
        Set<String> currenCodeSet = new Set<String>();
        Set<Date> dtSet = new Set<Date>();
        
        for(Supply_Database__c supplyDB:Trigger.New)
        { 

            if(supplyDB.Segment_Name_Supply_Raw__c != null && supplyDB.Segment_Name_Supply_Raw__c != '' && segMap.containsKey(supplyDB.Segment_Name_Supply_Raw__c))
            {
                //Get the corresponding Segment Categories Mapping of the records Insert / Updation.
                segmentName = mapSegMapSegCats.get(supplyDB.Segment_Name_Supply_Raw__c);
                sccode.add(mapSegCategories.get(segmentName)); 
                
            }
            
            //Populate the right Currency Code from Data Supplier Collections on the Supply DB Record
            if(DataSuppMap.containsKey(supplyDB.Data_Supplier_Raw__c) && DataSuppMap.get(supplyDB.Data_Supplier_Raw__c).Currency_Code__c != null){
                supplyDB.Currency_Code__c = DataSuppMap.get(supplyDB.Data_Supplier_Raw__c).Currency_Code__c; 
            }    

            currenCodeSet.add(supplyDB.Currency_Code__c); 

            if(supplyDB.Date__c != null) dtSet.add(supplyDB.Date__c); 
        }
        
        //Fetch Exchange rate for the Currency Code and populate into Maps
        for(Exchange_Rate__c exR : [SELECT Id,Date_Invoiced__c,Billing_Currency_Code__c,Exchange_Rate__c FROM Exchange_Rate__c WHERE Billing_Currency_Code__c IN: currenCodeSet AND Date_Invoiced__c IN:dtSet AND Exchange_Rate__c > 0]){
            exchangRateMap.put(exR.Billing_Currency_Code__c+exr.Date_Invoiced__c, exR); 
        }
        
/****Start - Populate existing Segment Revenue Transactions mapped to Records in non-Insert mode in the Trigger into Map.*/
        if(sddate != null && country != null && sccode != null)
        {
            list<Segment_Revenue_Transaction__c> trx = [SELECT Id,Country_Code__c,Date__c,Segment_Category_Mapping__c 
                                                                    FROM Segment_Revenue_Transaction__c 
                                                                    WHERE Date__c IN:sddate  AND 
                                                                       Country_Code__c IN:country AND 
                                                                       Segment_Category_Mapping__c IN:sccode ];
                                                                       
            for(Segment_Revenue_Transaction__c st12:trx)
            {
                segTrans.put(st12.Country_Code__c+st12.Date__c+st12.Segment_Category_Mapping__c,st12.Id);                             
            }
        } 
/**** End- Populate existing Segment Revenue Transactions mapped to Records in non-Insert mode in the Trigger into Map.  */   



/****Start - Populate Mapped Lookups on Supply Database from the Maps as per the Mapping***************************************/

        for(Supply_Database__c supplyDB:Trigger.New)
        { 
            
            /****Start - Populate Data Supplier Account Lookups on Supply Database from the Maps as per the Mapping*************/
            if(mapField.containsKey(supplyDB.Data_Supplier_Raw__c))
            {
                if(nameAndIdMap.containsKey(mapField.get(supplyDB.Data_Supplier_Raw__c)))
                {
                    supplyDB.Data_Supplier__c = nameAndIdMap.get(mapField.get(supplyDB.Data_Supplier_Raw__c)).Id;
                    supplyDB.Data_Supplier_Error__c = '';
                }else
                {   
                    if(mapField.get(supplyDB.Data_Supplier_Raw__c) != null && mapField.get(supplyDB.Data_Supplier_Raw__c) != ''){            
                        toCreateAccounts.put(mapField.get(supplyDB.Data_Supplier_Raw__c),TriggerUtility.toCreateAccount(''+mapField.get(supplyDB.Data_Supplier_Raw__c),'Data Supplier'));
                        existingAccName.add(mapField.get(supplyDB.Data_Supplier_Raw__c)); 
                        assignAccountAfterCreate.put(supplyDB.Id,supplyDB.Data_Supplier_Raw__c);
                    }
                    
                }
                if(supplyDB.Data_Supplier__c == null)
                {
                    supplyDB.Data_Supplier_Error__c = 'Error :- Data Supplier Mapping Not Found';
                }
            }
            /****End - Populate Data Supplier Account Lookups on Supply Database from the Maps as per the Mapping*************/

            /****Start - Populate Exchange Rate on Supply Database from the Maps as per the Mapping**************************/
            if(supplyDB.Currency_Code__c != 'USD')
            {
                String mapKey = supplyDB.Currency_Code__c + supplyDB.Date__c;

                if(exchangRateMap.containsKey(mapKey))
                {                
                    supplyDB.Exchange_Rate__c = exchangRateMap.get(mapKey).Exchange_Rate__c; 
                    supplyDB.Currency_Code_Error__c = '';
                }else
                {
                    supplyDB.Currency_Code__c = 'USD';
                    supplyDB.Exchange_Rate__c=1;
                }

            }
            /****End - Populate Exchange Rate on Supply Database from the Maps as per the Mapping**************************/
            
            /****Start - Populate the Segment Mapping and Master Category records on the Supply Database as per the Maps***/
            if(supplyDB.Segment_Name_Supply_Raw__c != null && supplyDB.Segment_Name_Supply_Raw__c != '' && mapSegMapSegCats.get(supplyDB.Segment_Name_Supply_Raw__c) != null ) // && supplyDB.Date__c < tempOctDt) Commented by Antony 2-May-2017
            { 
                segmentName = mapSegMapSegCats.get(supplyDB.Segment_Name_Supply_Raw__c);
                supplyDB.Segment_Mapping__c = segMap.get(supplyDB.Segment_Name_Supply_Raw__c);
                supplyDB.Segment_Category_Mapping__c = mapSegCategories.get(segmentName);
                supplyDB.Segment_Name_Error__c = '';

                try
                {
                
                    supplyDB.Segment_Revenue_Transaction__c = segTrans.get(supplyDB.Target_Country_Raw__c + supplyDB.Date__c + mapSegCategories.get(segmentName ));
                    
                    if(supplyDB.Segment_Revenue_Transaction__c == null || supplyDB.Segment_Revenue_Transaction__c == '')
                    {
                       segRevTransaction.add(supplyDB.Target_Country_Raw__c+'_'+supplyDB.Date__c+'_'+mapSegCategories.get(segmentName));
                    }
                
                }
                catch(Exception e)
                {
                    System.debug('>>Error:'+e.getMessage());
                }
            }
            /****End - Populate the Segment Mapping and Master Category records on the Supply Database as per the Maps***/                        
            
            if(supplyDB.Target_Country_Raw__c!= null && supplyDB.Target_Country_Raw__c!= '')
            {
                supplyDB.Country_Code_Mapping_Key__c= countryMap.get(supplyDB.Target_Country_Raw__c);
                supplyDB.Country_Error__c = '';
                /****Populate the Target Country Master Lookup as per the Mapping into the Supply Database Record **********************************/
            }

        }

/****End - Populate Mapped Lookups on Supply Database from the Maps as per the Mapping***************************************/

/****Start - If New Seg Reve Transactions are to be created Insert and associate with the Supply DB ***************************************/


        if(!segRevTransaction.isEmpty())
        {                   

            for(String combkey: segRevTransaction )
            {
                try{
                    Segment_Revenue_Transaction__c st = new Segment_Revenue_Transaction__c();
                    String[] keys = combkey.split('\\_');
                    st.Country_Code__c = keys[0];
                    st.Date__c = Date.valueOf(keys[1]);
                    if (keys[2] != null) {
                        st.Segment_Category_Mapping__c = keys[2];
                        stToInsertList.add (st);
                    }     
                }catch(Exception e){}               
            }

            if (stToInsertList.size() > 0 ) insert stToInsertList;

            for(Supply_Database__c supplyDB:Trigger.New)
            {
                segmentName =   mapSegMapSegCats.get(supplyDB.Segment_Name_Supply_Raw__c);

                for(Segment_Revenue_Transaction__c segRevTrans:stToInsertList) 
                { 
                    try
                    {
                        if(supplyDB.Date__c == segRevTrans.Date__c && segRevTrans.Country_Code__c == supplyDB.Target_Country_Raw__c && segRevTrans.Segment_Category_Mapping__c == mapSegCategories.get(segmentName))
                        { 
                            supplyDB.Segment_Revenue_Transaction__c = segRevTrans.Id; 
                        }
                    }
                    catch(Exception e)
                    {
                       System.debug('>>Error:'+e.getMessage());
                    }
                }
            }
        }

/****End - If New Seg Reve Transactions are to be created Insert and associate with the Supply DB ***************************************/

/****Start - On Data Supplier Accounts not found, script to create New Supplier Accounts*************************************************/
        
        for(Account acc:[SELECT Id, Name,Account_Type__c,New_Flag__c FROM Account WHERE Name IN: accNames])
        {
            toCreateAccountsMap.put(acc.Name,acc);
        }
        
        if(!toCreateAccounts.isEmpty())
        {            
            for(Account acc1:toCreateAccounts.values())
            {
                if(!toCreateAccountsMap.containsKey(acc1.Name)){
                    toInsert1.put(acc1.Name,acc1);
                }
            }

            if(!toInsert1.isEmpty()) insert toInsert1.values();
        }


        for(Account a1:[SELECT Id, Name,Account_Type__c,New_Flag__c FROM Account WHERE Name IN: toCreateAccountsMap.keySet() OR Name IN: toInsert1.keySet()])
        {
            allAcc.put(a1.Name,a1);
        }       

/****End - On Data Supplier Accounts not found, script to create New Supplier Accounts*******************************************************/

/****Start - Re-Associate Account Record to Data Supplier Lookups ***************************************************************************/
        
        for(Supply_Database__c supplyDB:Trigger.New)
        {
            for(Account acc:allAcc.values())
            {
                if(allAcc.containsKey(mapField.get(supplyDB.Data_Supplier_Raw__c)))
                {
                    supplyDB.Data_Supplier__c = allAcc.get(mapField.get(supplyDB.Data_Supplier_Raw__c)).Id;
                    supplyDB.Data_Supplier_Error__c = ''; 
                }                  
            } 
        }

/****End - Re-Associate Account Record to Data Supplier Lookups ***************************************************************************/

/****Start - Populate Final Exceptions on the Supply Database Record**********************************************************************/

        list<String> dataSupplier = new list<String>();
        list<String> dataSupplierNames = new list<String>();
        list<String> segment = new list<String>(); 

        map<String,String> mapFieldRevShare = new map<String,String>();
        map<String,Revenue_Share_Mapping__c> revShareMappingMap = new map<string,Revenue_Share_Mapping__c>();
               
        for(Supply_Database__c supplyDB:Trigger.New)
        { 
            if(supplyDB.Data_Supplier__c == null)
            {
                supplyDB.Data_Supplier_Error__c = 'Error :- Data Supplier Mapping Not Found';
                supplyDB.Data_Supplier__c = null;
            }else{
                dataSupplier.add(supplyDB.Data_Supplier__c);
                System.debug('DS1' + supplyDB.Data_Supplier__c);
            }

            if(supplyDB.Country_Code_Mapping_Key__c == null)
            {
                supplyDB.Country_Error__c = 'Error :- Country Mapping Not Found';
                supplyDB.Country_Code_Mapping_Key__c = null;
            }

            if(supplyDB.Segment_Category_Mapping__c == null)
            {
                supplyDB.Segment_Name_Error__c = 'Error :- Segment Mapping Not Found';
                supplyDB.Segment_Category_Mapping__c = null;
            }

            if(supplyDB.Segment_Name__c != null && supplyDB.Segment_Name__c != '')
            {
                segment.add(supplyDB.Segment_Name__c);                
            }
            else if ( supplyDB.Segment_Name_Error__c == '')
            {
                 segment.add(mapSegCatsNew.get(supplyDB.Segment_Category_Mapping__c));                 
            } 
        }

/****End - Populate Final Exceptions on the Supply Database Record ***************************************************************************/

/*************** Start ----Adding Revenue Share Trigger into the Main Trigger ***************************************************************/

        map<String,String> dataSupplierMaps = new map<String,String>();

        for(Account dsmaps:[Select Id,Name from Account where Id IN :dataSupplier]) 
        {
                dataSupplierNames.add(dsmaps.Name);
                dataSupplierMaps.put(dsmaps.Id,dsmaps.Name);
        }
     

        for(Revenue_Share_Mapping__c rs:[SELECT Data_Supplier__c,Country__c,Segment_Name__c,Revenue_Share__c,Id FROM Revenue_Share_Mapping__c 
                                              WHERE Country__c IN:country AND Data_Supplier__c IN:dataSupplierNames AND Segment_Name__c IN:segment])
        {
            mapFieldRevShare.put(rs.Data_Supplier__c+rs.Country__c+rs.Segment_Name__c+';share',rs.Revenue_Share__c+';share');
            revShareMappingMap.put(rs.Data_Supplier__c+rs.Country__c+rs.Segment_Name__c+';share',rs);            
        }   

        String DataSupplier_Name; 
       
        for(Supply_Database__c sd1:Trigger.New)
        {

            DataSupplier_Name = dataSupplierMaps.get(sd1.Data_Supplier__c);
            
            String comb;
            
            If (sd1.Supplier_Revenue_Share__c == null || sd1.Supplier_Revenue_Share__c == 0) sd1.Supplier_Revenue_Share__c = 50; 

            
            if( DataSupplier_Name != '' && DataSupplier_Name != null && sd1.Target_Country_Raw__c != ''  && sd1.Target_Country_Raw__c != null && sd1.Segment_Name_Error__c == '' )
            {
                comb = DataSupplier_Name+sd1.Target_Country_Raw__c.toUpperCase()+mapSegCatsNew.get(sd1.Segment_Category_Mapping__c)+';share';
                
                if(mapFieldRevShare.containsKey(comb))
                {
                      if(null != revShareMappingMap.get(comb)) sd1.Supplier_Revenue_Share__c = revShareMappingMap.get(comb).Revenue_Share__c;
                }                
            }
        }
                 
   
/**************End ----Adding Revenue Share *****************************************************************************************************/


    }

/***************************** End  - Before Trigger Logic ************************************************************************/



//********************************************************Start - Manage Seg Rev Transactions Uniques Rollup after Insert / Update Operations ******************************************************************************* 
       
    if((Trigger.IsAfter && Trigger.isInsert) || (Trigger.IsAfter && Trigger.IsUpdate))
    {        
        set<Id> sdIds = new set<Id>();
        list<Segment_Revenue_Transaction__c> toUpdateUnique = new list<Segment_Revenue_Transaction__c>();
       
        for(Supply_Database__c supplyDB:Trigger.New)
        { 
            sdIds.add(supplyDB.Segment_Revenue_Transaction__c);
        } 
       
        for(Segment_Revenue_Transaction__c segRevTrans:[Select Uniques_RollUp__c, Segment_Category_Mapping__c, Date__c, Country_Code__c, (Select Name,Date__c, Segment_Category_Mapping__c,Target_Country_Raw__c, Uniques__c,IsDeleted From Supply_Databases__r) From Segment_Revenue_Transaction__c WHERE Id IN:sdIds])
        {
            decimal unique = 0;

            for(Supply_Database__c supplyDB: segRevTrans.Supply_Databases__r)
            {
                if(supplyDB.Date__c == segRevTrans.Date__c && segRevTrans.Country_Code__c == supplyDB.Target_Country_Raw__c && segRevTrans.Segment_Category_Mapping__c == supplyDB.Segment_Category_Mapping__c)
                {
                    unique += (supplyDB.Uniques__c != null)?supplyDB.Uniques__c:0.0;
                }
            }

            segRevTrans.Uniques_RollUp__c = unique;
            toUpdateUnique.add(segRevTrans);
        }
       
        if(!toUpdateUnique.isEmpty()) update toUpdateUnique; 
    }
  
//********************************************************End - Manage Seg Rev Transactions Uniques Rollup after Insert / Update Operations ******************************************************************************* 

//********************************************************Start - Manage Seg Rev Transactions Uniques Rollup after Deletion Operation  ******************************************************************************************* 
    
    if(Trigger.IsDelete)
    {        
      
        set<Id> sdIdDels = new set<Id>();
        list<Segment_Revenue_Transaction__c> toDelRevs = new list<Segment_Revenue_Transaction__c>();
      
        for(Supply_Database__c supplyDB:Trigger.old) 
        { 
            sdIdDels.add(supplyDB.Segment_Revenue_Transaction__c);
        } 
       
        for(Segment_Revenue_Transaction__c segRevTranstoDel:[Select Uniques_RollUp__c From Segment_Revenue_Transaction__c WHERE Id IN:sdIdDels])
        {
            decimal uniques2 = 0;

            for(Supply_Database__c supplyDB:segRevTranstoDel.Supply_Databases__r)
            {
                if(segRevTranstoDel.Id == supplyDB.Segment_Revenue_Transaction__c)
                {
                    uniques2 += (supplyDB.Uniques__c != null)?supplyDB.Uniques__c:0.0;
                }
            }

            segRevTranstoDel.Uniques_RollUp__c = uniques2;
            toDelRevs.add(segRevTranstoDel);
        }
       
        if(!toDelRevs.isEmpty()) update toDelRevs; 
    }
    
//********************************************************End - Manage Seg Rev Transactions Uniques Rollup after Deletion Operation  ******************************************************************************************* 

//********************************************************Start - Manage Seg Rev Transactions Uniques Rollup after Un-Deletion Operation  ******************************************************************************************* 
 
    if(Trigger.IsUndelete){

        set<Id> sdIdUnDels = new set<Id>();
        list<Segment_Revenue_Transaction__c> toUnDelRevs = new list<Segment_Revenue_Transaction__c>();
      
        for(Supply_Database__c supplyDB:Trigger.New)
        { 
            sdIdUnDels.add(supplyDB.Segment_Revenue_Transaction__c);
        } 
       
        for(Segment_Revenue_Transaction__c segRevTranstoUnDel:[Select Uniques_RollUp__c From Segment_Revenue_Transaction__c WHERE Id IN:sdIdUnDels])
        {
            decimal uniques3 = 0;

            for(Supply_Database__c supplyDB: segRevTranstoUnDel.Supply_Databases__r)
            {
                if(segRevTranstoUnDel.Id == supplyDB.Segment_Revenue_Transaction__c )
                {
                    uniques3 += (supplyDB.Uniques__c != null)?supplyDB.Uniques__c:0.0;
                }
            }

            segRevTranstoUnDel.Uniques_RollUp__c = uniques3;
            toUnDelRevs.add(segRevTranstoUnDel);
        }
       
        if(!toUnDelRevs.isEmpty()) update toUnDelRevs; 
    }
    
//********************************************************End - Manage Seg Rev Transactions Uniques Rollup after Un-Deletion Operation  ******************************************************************************************* 
   
}