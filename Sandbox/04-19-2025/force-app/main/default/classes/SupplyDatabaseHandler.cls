public with sharing class SupplyDatabaseHandler {
    public static void onBeforeInsertUpdate( List<Supply_Database__c> supplyDatabases ){
        List<Segment_Revenue_Transaction__c> stToInsertList = new List<Segment_Revenue_Transaction__c>();
        List<String> existingAccName = new List<String>();
        List<Account> existAcc = new List<Account>();
        List<String> listSegmentNames = new List<String>();

        Set<String> segMcodes = new Set<String>();
        Set<String> accNames = new Set<String>();
        Set<String> country= new Set<String>();
        Set<Date> sddate = new Set<Date>();
        Set<String> sccode = new Set<String>();
        Set<String> supplier = new Set<String>();
        Set<String> segNamesNew = new Set<String>();
        Set<String> segRevTransaction = new Set<String>();

        Map<String,String> mapSegMapSegCats = new Map<String,String>(); 
        Map<String,String> assignAccountAfterCreate = new Map<String,String>();
        Map<String,Account> toCreateAccounts = new Map<String,Account>();
        Map<String,String> mapField = new Map<String,String>();
        Map<String,String> segMap = new Map<String,String>();
        Map<String,Account> nameAndIdMap = new Map<String,Account>();
        Map<String,String> segTrans = new Map<String,String>();
        Map<String,String> countryMap = new Map<String,String>();
        Map<String,String> mapSegCategories = new Map<String,String>();
        Map<String,String> mapSegCatsNew = new Map<String,String>();
        Map<String,Account> toCreateAccountsMap = new Map<String,Account>();
        Map<String,Account> toInsert1 = new Map<String,Account>();
        Map<String,Account> allAcc = new Map<String,Account>();

        String segmentName = null;

        Map<String,Data_Supplier_Mapping__c> DataSuppMap = new Map<String,Data_Supplier_Mapping__c>();
        Map<String,Exchange_Rate__c> exchangRateMap = new Map<String,Exchange_Rate__c>();

        for(Supply_Database__c supplyDB : supplyDatabases){ 
            if(supplyDB.Data_Supplier_Raw_Original__c != null && supplyDB.Data_Supplier_Raw_Original__c != ''){
                supplyDB.Data_Supplier_Raw__c = supplyDB.Data_Supplier_Raw_Original__c.toUpperCase();
                supplier.add(supplyDB.Data_Supplier_Raw__c);                 
            }
            
            Date tempOctDt = Date.newInstance(2016, 10, 01);            
            if(supplyDB.Segment_Name_Supply_Raw_Original__c != null && supplyDB.Segment_Name_Supply_Raw_Original__c != '' && supplyDB.Date__c < tempOctDt){ 
                supplyDB.Segment_Name_Supply_Raw__c= supplyDB.Segment_Name_Supply_Raw_Original__c.toUpperCase();                
            }
            
            if(supplyDB.Segment_Key_Raw__c != null && supplyDB.Segment_Key_Raw__c != '' && supplyDB.Date__c >= tempOctDt){
                supplyDB.Segment_Name_Supply_Raw__c= supplyDB.Segment_Key_Raw__c.toUpperCase();                
            }
            
            segMcodes.add(supplyDB.Segment_Name_Supply_Raw__c);  
            
            if(supplyDB.Target_Country_Raw__c != null && supplyDB.Target_Country_Raw__c != ''){
                supplyDB.Target_Country_Raw__c = supplyDB.Target_Country_Raw__c.toUpperCase();
                country.add(supplyDB.Target_Country_Raw__c);
                System.debug('Country abc +' + supplyDB.Target_Country_Raw__c ); 
            }

            if(supplyDB.Date__c != null){
                sddate.add(supplyDB.Date__c);
            }    
                
            if(Trigger.isInsert || supplyDB.Currency_Code__c == NULL){
				supplyDB.Currency_Code__c = 'USD';                
            }
            // supplyDB.Exchange_Rate__c = 1;      
            supplyDB.Currency_Code_Error__c = '';      
        } 

        List<Data_Supplier_Mapping__c> dataSupplierMappings = [Select Name, Id, Data_Supplier_Raw__c, Data_Supplier__c, Currency_Code__c From Data_Supplier_Mapping__c WHERE Data_Supplier_Raw__c IN:supplier];

        for(Data_Supplier_Mapping__c ds : dataSupplierMappings){              
            accNames.add(ds.Data_Supplier__c);
            mapField.put(ds.Data_Supplier_Raw__c,ds.Data_Supplier__c);   
            DataSuppMap.put(ds.Data_Supplier_Raw__c,ds);        
        }   

        for(Account a:[SELECT Id, OwnerId,Name,Owner.Name FROM Account WHERE Name IN: accNames]){   
            nameAndIdMap.put(a.Name,a);             
        }

        if(country != null){   
            for(Country__c c:[SELECT Id,Name,Master_Geography_Code__c FROM Country__c WHERE Master_Geography_Code__c IN:country]){ 
                countryMap.put(c.Master_Geography_Code__c , c.Id);
            }       
        }

        for(Segment_Mapping__c sm:[SELECT Id, Segment_Name__c , Segment_Name_Supply_Raw__c FROM Segment_Mapping__c WHERE Segment_Name_Supply_Raw__c IN:segMcodes]){  
            if(sm.Segment_Name__c != null && sm.Segment_Name__c != ''){
                segMap.put(sm.Segment_Name_Supply_Raw__c,sm.Id);
                listSegmentNames.add(sm.Segment_Name__c);
                mapSegMapSegCats.put(sm.Segment_Name_Supply_Raw__c,sm.Segment_Name__c);               
            }
        }
       
        for(Segment_Category_Mapping__c sm:[SELECT Segment_Name__c,Id FROM Segment_Category_Mapping__c WHERE Segment_Name__c IN:listSegmentNames]){
            if(sm.Segment_Name__c != null && sm.Segment_Name__c != ''){
                mapSegCategories.put(sm.Segment_Name__c,sm.Id);
                mapSegCatsNew.put(sm.Id,sm.Segment_Name__c);                
            }
        }

        Set<String> currenCodeSet = new Set<String>();
        Set<Date> dtSet = new Set<Date>();
        
        for(Supply_Database__c supplyDB : supplyDatabases ){ 
            if(supplyDB.Segment_Name_Supply_Raw__c != null && supplyDB.Segment_Name_Supply_Raw__c != '' && segMap.containsKey(supplyDB.Segment_Name_Supply_Raw__c)){
                segmentName = mapSegMapSegCats.get(supplyDB.Segment_Name_Supply_Raw__c);
                sccode.add(mapSegCategories.get(segmentName)); 
                
            }
            if(DataSuppMap.containsKey(supplyDB.Data_Supplier_Raw__c) && DataSuppMap.get(supplyDB.Data_Supplier_Raw__c).Currency_Code__c != null){
                supplyDB.Currency_Code__c = DataSuppMap.get(supplyDB.Data_Supplier_Raw__c).Currency_Code__c; 
            }    

            currenCodeSet.add(supplyDB.Currency_Code__c); 

            if(supplyDB.Date__c != null) dtSet.add(supplyDB.Date__c); 
        }

        for(Exchange_Rate__c exR : [SELECT Id,Date_Invoiced__c,Billing_Currency_Code__c,Exchange_Rate__c FROM Exchange_Rate__c WHERE Billing_Currency_Code__c IN: currenCodeSet AND Date_Invoiced__c IN:dtSet AND Exchange_Rate__c > 0]){
            exchangRateMap.put(exR.Billing_Currency_Code__c+exr.Date_Invoiced__c, exR); 
        }
        
        // if(sddate != null && country != null && sccode != null){
        //     list<Segment_Revenue_Transaction__c> trx = [SELECT Id,Country_Code__c,Date__c,Segment_Category_Mapping__c 
        //                                                             FROM Segment_Revenue_Transaction__c 
        //                                                             WHERE Date__c IN:sddate  AND 
        //                                                                Country_Code__c IN:country AND 
        //                                                                Segment_Category_Mapping__c IN:sccode ];
                                                                       
        //     for(Segment_Revenue_Transaction__c st12:trx){
        //         segTrans.put(st12.Country_Code__c+st12.Date__c+st12.Segment_Category_Mapping__c,st12.Id);                             
        //     }
        // } 

        for(Supply_Database__c supplyDB : supplyDatabases){ 
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

            /*if(supplyDB.Currency_Code__c != 'USD'){
                String mapKey = supplyDB.Currency_Code__c + supplyDB.Date__c;

                if(exchangRateMap.containsKey(mapKey)){                
                    supplyDB.Exchange_Rate__c = exchangRateMap.get(mapKey).Exchange_Rate__c; 
                    supplyDB.Currency_Code_Error__c = '';
                } else {
                    supplyDB.Currency_Code__c = 'USD';
                    supplyDB.Exchange_Rate__c=1;
                }
            }*/

            String mapKey = supplyDB.Currency_Code__c + supplyDB.Date__c;

            if(exchangRateMap.containsKey(mapKey)){                
                supplyDB.Exchange_Rate__c = exchangRateMap.get(mapKey).Exchange_Rate__c; 
                supplyDB.Currency_Code_Error__c = '';
            }
         
            if(supplyDB.Segment_Name_Supply_Raw__c != null && supplyDB.Segment_Name_Supply_Raw__c != '' && mapSegMapSegCats.get(supplyDB.Segment_Name_Supply_Raw__c) != null ) { 
                segmentName = mapSegMapSegCats.get(supplyDB.Segment_Name_Supply_Raw__c);
                supplyDB.Segment_Mapping__c = segMap.get(supplyDB.Segment_Name_Supply_Raw__c);
                supplyDB.Segment_Category_Mapping__c = mapSegCategories.get(segmentName);
                supplyDB.Segment_Name_Error__c = '';
                
                // System.debug('segTrans segTrans segTrans' + segTrans);
                // System.debug('Test' + segTrans.get(supplyDB.Target_Country_Raw__c + supplyDB.Date__c + mapSegCategories.get(segmentName )));
                // System.debug( '<><><><>' + supplyDB.Target_Country_Raw__c + supplyDB.Date__c + mapSegCategories.get(segmentName ));
                // supplyDB.Segment_Revenue_Transaction__c = segTrans.get(supplyDB.Target_Country_Raw__c + supplyDB.Date__c + mapSegCategories.get(segmentName ));
                
                // if( !Test.isRunningTest() ){
                //     if(String.isNotEmpty(supplyDB.Segment_Revenue_Transaction__c)){
                //         segRevTransaction.add(supplyDB.Target_Country_Raw__c+'_'+supplyDB.Date__c+'_'+mapSegCategories.get(segmentName));
                //     }
                // } else {
                //     segRevTransaction.add(supplyDB.Target_Country_Raw__c+'_'+supplyDB.Date__c+'_'+mapSegCategories.get(segmentName));
                // }
               
            }                       
            
            if(supplyDB.Target_Country_Raw__c!= null && supplyDB.Target_Country_Raw__c!= ''){
                supplyDB.Country_Code_Mapping_Key__c= countryMap.get(supplyDB.Target_Country_Raw__c);
                supplyDB.Country_Error__c = '';
            }
        }

        // if(!segRevTransaction.isEmpty()){                   

        //     for(String combkey: segRevTransaction )
        //     {
        //         try{
        //             Segment_Revenue_Transaction__c st = new Segment_Revenue_Transaction__c();
        //             String[] keys = combkey.split('\\_');
        //             st.Country_Code__c = keys[0];
        //             st.Date__c = Date.valueOf(keys[1]);
        //             if (keys[2] != null) {
        //                 st.Segment_Category_Mapping__c = keys[2];
        //                 stToInsertList.add (st);
        //             }     
        //         }catch(Exception e){}               
        //     }

        //     if (stToInsertList.size() > 0 ) insert stToInsertList;

        //     for(Supply_Database__c supplyDB : supplyDatabases){
        //         segmentName =   mapSegMapSegCats.get(supplyDB.Segment_Name_Supply_Raw__c);
        //         for(Segment_Revenue_Transaction__c segRevTrans:stToInsertList) { 
        //             if(supplyDB.Date__c == segRevTrans.Date__c && segRevTrans.Country_Code__c == supplyDB.Target_Country_Raw__c && segRevTrans.Segment_Category_Mapping__c == mapSegCategories.get(segmentName))
        //             { 
        //                 supplyDB.Segment_Revenue_Transaction__c = segRevTrans.Id; 
        //             }
        //         }
        //     }
        // }

        for(Account acc:[SELECT Id, Name,Account_Type__c,New_Flag__c FROM Account WHERE Name IN: accNames]){
            toCreateAccountsMap.put(acc.Name,acc);
        }
        
        if(!toCreateAccounts.isEmpty()){            
            for(Account acc1:toCreateAccounts.values())
            {
                if(!toCreateAccountsMap.containsKey(acc1.Name)){
                    toInsert1.put(acc1.Name,acc1);
                }
            }

            if(!toInsert1.isEmpty()) insert toInsert1.values();
        }


        for(Account a1:[SELECT Id, Name,Account_Type__c,New_Flag__c FROM Account WHERE Name IN: toCreateAccountsMap.keySet() OR Name IN: toInsert1.keySet()]){
            allAcc.put(a1.Name,a1);
        }       

        for(Supply_Database__c supplyDB : supplyDatabases){
            for(Account acc:allAcc.values()){
                if(allAcc.containsKey(mapField.get(supplyDB.Data_Supplier_Raw__c))){
                    supplyDB.Data_Supplier__c = allAcc.get(mapField.get(supplyDB.Data_Supplier_Raw__c)).Id;
                    supplyDB.Data_Supplier_Error__c = ''; 
                }                  
            } 
        }

        List<String> dataSupplier = new List<String>();
        List<String> dataSupplierNames = new List<String>();
        List<String> segment = new List<String>(); 

        Map<String,String> mapFieldRevShare = new Map<String,String>();
        Map<String,Revenue_Share_Mapping__c> revShareMappingMap = new Map<string,Revenue_Share_Mapping__c>();
               
        for(Supply_Database__c supplyDB : supplyDatabases){ 
            if(supplyDB.Data_Supplier__c == null){
                supplyDB.Data_Supplier_Error__c = 'Error :- Data Supplier Mapping Not Found';
                supplyDB.Data_Supplier__c = null;
            } else {
                dataSupplier.add(supplyDB.Data_Supplier__c);
                System.debug('DS1' + supplyDB.Data_Supplier__c);
            }

            if(supplyDB.Country_Code_Mapping_Key__c == null){
                supplyDB.Country_Error__c = 'Error :- Country Mapping Not Found';
                supplyDB.Country_Code_Mapping_Key__c = null;
            }

            if(supplyDB.Segment_Category_Mapping__c == null){
                supplyDB.Segment_Name_Error__c = 'Error :- Segment Mapping Not Found';
                supplyDB.Segment_Category_Mapping__c = null;
            }

            if(supplyDB.Segment_Name__c != null && supplyDB.Segment_Name__c != ''){
                segment.add(supplyDB.Segment_Name__c);                
            } else if ( supplyDB.Segment_Name_Error__c == ''){
                 segment.add(mapSegCatsNew.get(supplyDB.Segment_Category_Mapping__c));                 
            } 
        }

        Map<String,String> dataSupplierMaps = new Map<String,String>();

        for(Account dsmaps:[Select Id,Name from Account where Id IN :dataSupplier]){
            dataSupplierNames.add(dsmaps.Name);
            dataSupplierMaps.put(dsmaps.Id,dsmaps.Name);
        }
     

        for(Revenue_Share_Mapping__c rs:[SELECT Data_Supplier__c,Country__c,Segment_Name__c,Revenue_Share__c,Id FROM Revenue_Share_Mapping__c 
                                              WHERE Country__c IN:country AND Data_Supplier__c IN:dataSupplierNames AND Segment_Name__c IN:segment]){
            mapFieldRevShare.put(rs.Data_Supplier__c+rs.Country__c+rs.Segment_Name__c+';share',rs.Revenue_Share__c+';share');
            revShareMappingMap.put(rs.Data_Supplier__c+rs.Country__c+rs.Segment_Name__c+';share',rs);            
        }   

        String DataSupplier_Name; 
       
        for(Supply_Database__c sd1 : supplyDatabases){
            DataSupplier_Name = dataSupplierMaps.get(sd1.Data_Supplier__c);
            String comb;
            
            If (sd1.Supplier_Revenue_Share__c == null || sd1.Supplier_Revenue_Share__c == 0) sd1.Supplier_Revenue_Share__c = 50; 
            
            if( DataSupplier_Name != '' && DataSupplier_Name != null && sd1.Target_Country_Raw__c != ''  && sd1.Target_Country_Raw__c != null && sd1.Segment_Name_Error__c == '' ){
                comb = DataSupplier_Name+sd1.Target_Country_Raw__c.toUpperCase()+mapSegCatsNew.get(sd1.Segment_Category_Mapping__c)+';share';
                
                if(mapFieldRevShare.containsKey(comb))
                {
                      if(null != revShareMappingMap.get(comb)) sd1.Supplier_Revenue_Share__c = revShareMappingMap.get(comb).Revenue_Share__c;
                }                
            }
        }
    }

    public static void onAfterInsertUpdate( List<Supply_Database__c> supplyDatabases ){
        Set<Id> sdIds = new Set<Id>();
        list<Segment_Revenue_Transaction__c> toUpdateUnique = new list<Segment_Revenue_Transaction__c>();
       
        for(Supply_Database__c supplyDB : supplyDatabases){ 
            sdIds.add(supplyDB.Segment_Revenue_Transaction__c);
        } 

        List<Segment_Revenue_Transaction__c> srts = [Select Uniques_RollUp__c, Segment_Category_Mapping__c, Date__c, Country_Code__c, (Select Name,Date__c, Segment_Category_Mapping__c,Target_Country_Raw__c, Uniques__c,IsDeleted From Supply_Databases__r) From Segment_Revenue_Transaction__c WHERE Id IN:sdIds FOR UPDATE];
       
        if( srts.size() > 0 ){
            for(Segment_Revenue_Transaction__c segRevTrans : srts){
                Decimal unique = 0;
                for(Supply_Database__c supplyDB: segRevTrans.Supply_Databases__r){
                    if(supplyDB.Date__c == segRevTrans.Date__c && segRevTrans.Country_Code__c == supplyDB.Target_Country_Raw__c && segRevTrans.Segment_Category_Mapping__c == supplyDB.Segment_Category_Mapping__c && supplyDB.Uniques__c != null){
                        unique += supplyDB.Uniques__c;
                    }
                }
    
                toUpdateUnique.add(new Segment_Revenue_Transaction__c(
                    Id = segRevTrans.Id,
                    Uniques_RollUp__c = unique
                ));
            }
        }
       
        if(!toUpdateUnique.isEmpty()){
            update toUpdateUnique;
        } 
    }

    public static void onBeforeDelete( List<Supply_Database__c> supplyDatabases ){
        Set<Id> setOfSupplyDatabase = new Set<Id>();
        for(Supply_Database__c supplyDB : supplyDatabases) { 
            setOfSupplyDatabase.add(supplyDB.Id);
        } 
       
        if(setOfSupplyDatabase.size() > 0){
            List<Adjustment_Transaction__c> toDelete = [SELECT Id FROM Adjustment_Transaction__c WHERE Supply_Database__c IN :setOfSupplyDatabase];
            if( toDelete.size() > 0 ){
                Database.deleteResult[] srList = Database.delete(toDelete, false);
            }
        }
        
    }

    public static void onDelete( List<Supply_Database__c> supplyDatabases ){
        Set<Id> sdIdDels = new Set<Id>();
        list<Segment_Revenue_Transaction__c> toDelRevs = new list<Segment_Revenue_Transaction__c>();
      
        for(Supply_Database__c supplyDB : supplyDatabases) { 
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

    public static void onUndelete( List<Supply_Database__c> supplyDatabases ){
        Set<Id> sdIdUnDels = new Set<Id>();
        List<Segment_Revenue_Transaction__c> toUnDelRevs = new List<Segment_Revenue_Transaction__c>();
      
        for(Supply_Database__c supplyDB : supplyDatabases){ 
            sdIdUnDels.add(supplyDB.Segment_Revenue_Transaction__c);
        } 
       
        for(Segment_Revenue_Transaction__c segRevTranstoUnDel:[Select Uniques_RollUp__c From Segment_Revenue_Transaction__c WHERE Id IN:sdIdUnDels]){
            decimal uniques3 = 0;

            for(Supply_Database__c supplyDB: segRevTranstoUnDel.Supply_Databases__r){
                if(segRevTranstoUnDel.Id == supplyDB.Segment_Revenue_Transaction__c ){
                    uniques3 += (supplyDB.Uniques__c != null)?supplyDB.Uniques__c:0.0;
                }
            }

            segRevTranstoUnDel.Uniques_RollUp__c = uniques3;
            toUnDelRevs.add(segRevTranstoUnDel);
        }
       
        if(!toUnDelRevs.isEmpty()) update toUnDelRevs; 
    }
}