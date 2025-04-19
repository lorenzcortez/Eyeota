public with sharing class SalesDatabaseTriggerHandler {
    public static void onBeforeInsertUpdate(List<Sales_Database__c> newList){
        /******************* Start - Variable Declarations  ***************************************************************************************/

        list<Segment_Revenue_Transaction__c> listSegmentTransactionInsert = new list<Segment_Revenue_Transaction__c>();
        list<Account> listCreateAccount = new list<Account>();
        list<String> listBuyerCountry = new list<String>();
        list<String> listPlatformRaw = new list<String>();
        list<String> listBuyerRaw = new list<String>();
        list<String> listAdvertiserRaw = new list<String>();
        list<String> listCampaign = new list<String>();
        list<String> listTargetCountry = new list<String>();

        map<string,string> mapRawVsField = new map<string,string>();
        map<String,String> mapSegCodeSegMapId = new map<String,String>();
        map<String, String> mapSegCodeSegCatId = new map<String, String>();        
        map<String,String> mapPlatCodeSegmentCode = new map<String,String>();
        map<String,String> mapAssignAccount = new map<String,String>();
        map<String,String> fieldAccMap = new map<String,String>();
        map<String,String> fieldAccMapwoSpaces = new map<String,String>();

        map<String,String> mapAllAccounts = new map<String,String>();
        map<String,String> mapAllAccountswoSpaces = new map<String,String>();

        map<String,Buyer_Mapping__c> mapBuyerAccounts4SalesTeam = new map<string,Buyer_Mapping__c>();

        map<String,String> mapCountryIDs = new map<String,String>();
        map<String,Account> mapNameAndIDs = new map<String,Account>();
        map<String,Account> mapNameAndIDswoSpaces = new map<String,Account>();

        map<String,String> mapExstngSegTransIDs = new map<String,String>();

        map<String,Account> mapCreateAccountDups = new map<String,Account>();
        map<String,Account> mapToInsertUniqueAccnts = new map<String,Account>();
        map<String,Account> mapAllNewAccnts = new map<String,Account>();

        set<String> setPlatCodes = new set<String>();
        set<String> setSegCatIDs = new set<String>();
        set<String> setSegNames = new set<String>();
        set<String> setTargetcountry = new set<String>();
        set<Date>   setDates = new set<Date>(); 
        set<String> setCampaign = new set<String>(); 
        set<String> segRevTransaction = new set<String>();
        String segmentName;
        String accountName;


        /******************* End - Variable Declarations  ***************************************************************************************/

        /******************* Get All Raw Values from Sales Database to Prepare the Joins - Start ************************************************/

        for(Sales_Database__c salesDB: newList){

            if(salesDB.Segment_Name_Sales_Raw_Original__c != null && salesDB.Segment_Name_Sales_Raw_Original__c != ''){
                salesDB.Segment_Name_Sales_Raw__c = salesDB.Segment_Name_Sales_Raw_Original__c.toUpperCase();
                setPlatCodes.add(salesDB.Segment_Name_Sales_Raw__c);
            }
            if(salesDB.Buyer_Country_Raw__c != null && salesDB.Buyer_Country_Raw__c != ''){
                salesDB.Buyer_Country_Raw__c = salesDB.Buyer_Country_Raw__c.toUpperCase().trim();
                listBuyerCountry.add(salesDB.Buyer_Country_Raw__c);                
            }
            if(salesDB.Buyer_Original_Raw__c != null && salesDB.Buyer_Original_Raw__c != ''){
                salesDB.Buyer_Raw__c = salesDB.Buyer_Original_Raw__c.toUpperCase();
                listBuyerRaw.add(salesDB.Buyer_Raw__c);
            }
            if(salesDB.Target_Country_Raw__c != null && salesDB.Target_Country_Raw__c != ''){
                salesDB.Target_Country_Raw__c = salesDB.Target_Country_Raw__c.toUpperCase().trim();
                setTargetcountry.add(salesDB.Target_Country_Raw__c.toUpperCase()); 
                listTargetCountry.add(salesDB.Target_Country_Raw__c);
            }
            if(salesDB.Date_Invoiced__c != null){ 
                setDates.add(salesDB.Date_Invoiced__c);
            }
            if(salesDB.Platform_Raw_Original__c != null && salesDB.Platform_Raw_Original__c != ''){
                salesDB.Platform_Raw__c = salesDB.Platform_Raw_Original__c.toUpperCase();
                listPlatformRaw.add(salesDB.Platform_Raw__c);
            }
            if(salesDB.Advertiser_Raw_Original__c  != null && salesDB.Advertiser_Raw_Original__c  != ''){
                salesDB.Advertiser_Raw__c = salesDB.Advertiser_Raw_Original__c .toUpperCase();
                listAdvertiserRaw.add(salesDB.Advertiser_Raw__c);
            }                       
            if(salesDB.Campaign_Raw_Original__c != null && salesDB.Campaign_Raw_Original__c != ''){
                salesDB.Campaign__c = salesDB.Campaign_Raw_Original__c.toUpperCase();               
            } 
        } 


        /******************* End - Get All Raw Values from Sales Database to Prepare the Joins *************************************************/

        /******************* Start - Populate All the related Master Mapping data into Collections for comparison and updates ******************/


        List<Buyer_Mapping__c> bmList = [SELECT PDT_Member__c, Buyer_and_Buyer_Country__c,Buyer_Country_Raw__c,Buyer_Raw__c, Platform__c,Id 
                                        FROM Buyer_Mapping__c 
                                        WHERE Buyer_Country_Raw__c IN:listBuyerCountry AND 
                                        Buyer_Raw__c IN:listBuyerRaw AND 
                                        Platform__c IN:listPlatformRaw];
        for(Buyer_Mapping__c bm : bmList) 
        {           
            
            mapAllAccounts.put(bm.Buyer_Country_Raw__c+bm.Buyer_Raw__c+bm.Platform__c+';buyer',bm.Buyer_and_Buyer_Country__c+';buyer'); 
            fieldAccMap.put(bm.Buyer_and_Buyer_Country__c,'buyer'); 
            fieldAccMapwoSpaces.put(bm.Buyer_and_Buyer_Country__c.deleteWhitespace(),'buyer');

            String buyerString = bm.Buyer_Country_Raw__c+bm.Buyer_Raw__c+bm.Platform__c;  
            mapAllAccountswoSpaces.put(buyerString.deleteWhitespace()+';buyer',bm.Buyer_and_Buyer_Country__c.deleteWhitespace()+';buyer');

            mapBuyerAccounts4SalesTeam.put(bm.Buyer_Country_Raw__c+bm.Buyer_Raw__c+bm.Platform__c+';buyer',bm);            
        }        

        List<Platform_Mapping__c> pmList = [SELECT Platform__c,Platform_Raw__c,Id 
                                            FROM Platform_Mapping__c 
                                            WHERE Platform_Raw__c IN:listPlatformRaw];
        for(Platform_Mapping__c pm: pmList)
        {                            
            mapAllAccounts.put(pm.Platform_Raw__c+';platform',pm.Platform__c+';platform');
            fieldAccMap.put(pm.Platform__c,'platform');            
        }    

        List<Country__c> countryList = [SELECT Id,Name,Master_Geography_Code__c
                                        FROM Country__c 
                                        WHERE Master_Geography_Code__c IN:listBuyerCountry];
        for(Country__c c : countryList)
            mapCountryIDs.put(c.Master_Geography_Code__c , c.Id);

        List<Country__c> countryList1 = [SELECT Id,Name,Master_Geography_Code__c
                                        FROM Country__c 
                                        WHERE Master_Geography_Code__c IN:listTargetCountry];
        for(Country__c c : countryList1)
        {    
            if (!mapCountryIDs.containsKey(c.Master_Geography_Code__c))  mapCountryIDs.put(c.Master_Geography_Code__c , c.Id);            
        }    

        List<Advertiser_Mapping__c> amList = [SELECT Advertiser__c,Advertiser_Raw__c,Id 
                                            FROM Advertiser_Mapping__c 
                                            WHERE Advertiser_Raw__c IN:listAdvertiserRaw];
        for(Advertiser_Mapping__c am : amList)
        {                              
            if ( am.Advertiser__c == 'Campaign Classified' ) {
                setCampaign.add(am.Advertiser_Raw__c);
            }else {
                mapAllAccounts.put(am.Advertiser_Raw__c+';advertiser',am.Advertiser__c+';advertiser');
                fieldAccMap.put(am.Advertiser__c,'advertiser');              
            }
        } 

        List<Segment_Mapping__c> smList = [SELECT Id,Segment_Name_Sales_Raw__c,Segment_Name__c 
                                        FROM Segment_Mapping__c 
                                        WHERE Segment_Name_Sales_Raw__c IN:setPlatCodes];
        for (Segment_Mapping__c segmentMapping:smList)
        {
            System.debug('segmentMapping.Segment_Name__c-----@@'+segmentMapping.Segment_Name__c);
            mapSegCodeSegMapId.put(segmentMapping.Segment_Name_Sales_Raw__c ,segmentMapping.Id);
            mapPlatCodeSegmentCode.put(segmentMapping.Segment_Name_Sales_Raw__c ,segmentMapping.Segment_Name__c); 
            setSegNames.add(segmentMapping.Segment_Name__c);
        }
        System.debug('mapPlatCodeSegmentCode----@@'+mapPlatCodeSegmentCode);
        List<Segment_Category_Mapping__c> scmList = [SELECT Segment_Name__c,Id FROM Segment_Category_Mapping__c WHERE Segment_Name__c IN:setSegNames];
        for(Segment_Category_Mapping__c segmentCategory : scmList) {
            if(segmentCategory.Segment_Name__c != null && segmentCategory.Segment_Name__c != '') 
            {
                    mapSegCodeSegCatId.put(segmentCategory.Segment_Name__c,segmentCategory.Id);                                                
            }

        }     

        /******************* End - Start - Populate All the related Master Mapping data into Collections for comparison and updates************/

        /******************* Start - Populate Segment Mapping IDs and Segment Category IDs and Campaign Maps************************************/                                        

        for(Sales_Database__c salesDB: newList)
        {
            
            segmentName = mapPlatCodeSegmentCode.get(salesDB.Segment_Name_Sales_Raw__c);
            System.debug('segmentName---@@'+segmentName);
            if(segmentName != null && segmentName != '')
            {
                setSegCatIDs.add(mapSegCodeSegCatId.get(segmentName));       
            }

            if (setCampaign.contains (salesDB.Advertiser_Raw__c)) 
            {
                listCampaign.add(salesDB.Campaign__c);
                salesDB.Campaign_Classified_Error__c = 'Campaign Classified Advertiser Mapping.';
            }else salesDB.Campaign_Classified_Error__c = '';
        }
        System.debug('listCampaign------@@@'+listCampaign);
        If (! listCampaign.isEmpty()) 
        {    
            List<Campaign_Mapping__c> cmList = [SELECT Advertiser__c,Campaign_Raw__c,Id 
                                                FROM Campaign_Mapping__c
                                                WHERE Campaign_Raw__c IN:listCampaign];
            for(Campaign_Mapping__c cm:cmList)
            {                              
                mapAllAccounts.put(cm.Campaign_Raw__c+';advertiser',cm.Advertiser__c+';advertiser');
                fieldAccMap.put(cm.Advertiser__c,'advertiser'); 
            }
        }

        /******************* End - Populate Segment Mapping IDs and Segment Category IDs and Campaign Maps************************************/          

        /****************************** Create an additional Account Master Map without spaces***************/ 
        List<Account> accList = [SELECT Id, Name,Ultimate_Parent_Account__c FROM Account ];
        for(Account a: accList) {

            mapNameAndIDs.put(a.Name.toUpperCase(),a);  
            mapNameAndIDswoSpaces.put(a.Name.toUpperCase().deleteWhitespace(),a);                
        }    


        /******************* Start - Populate Existing Segment Transaction IDs Maps ** Join between Sales and Supply Database for Revenue Calculations***/

        System.debug('setDates setDates setDates' + setDates);
        System.debug('setTargetcountry setTargetcountry setTargetcountry' + setTargetcountry);
        System.debug('setSegCatIDs setSegCatIDs setSegCatIDs' + setSegCatIDs);

        // List<Segment_Revenue_Transaction__c> srtList = [SELECT Id,Country_Code__c,Date__c,Segment_Category_Mapping__c 
        //                                                     FROM Segment_Revenue_Transaction__c 
        //                                                 WHERE Date__c IN:setDates   AND 
        //                                                 Country_Code__c IN:setTargetcountry AND 
        //                                                 Segment_Category_Mapping__c IN:setSegCatIDs];
        // for (Segment_Revenue_Transaction__c segTrans : srtList)
        //     mapExstngSegTransIDs.put(segTrans.Country_Code__c.toUpperCase()+segTrans.Date__c+segTrans.Segment_Category_Mapping__c,segTrans.Id); 
                
        /******************* End - Populate Existing Segment Transaction IDs Maps **Join between Sales and Supply Database for Revenue Calculations******/ 


        //******************Maps Creation is over till here, Sales DB Lookups Population ......Starts Here.....******************************

        /******************* Start - Populate Existing Accounts matching to Sales DB Lookups ***********************************************************/
        //*******************Existing Accounts => Buyer / Advertisers / Platform *************************************

        for (Sales_Database__c salesDB:newList)
        {

            
            if (salesDB.Platform_Raw_Original__c != null && salesDB.Platform_Raw_Original__c != '' && 
                salesDB.Buyer_Original_Raw__c != null && salesDB.Buyer_Original_Raw__c != '' && 
                salesDB.Buyer_Country_Raw__c != null && salesDB.Buyer_Country_Raw__c != '')
            {

                string strCombKeyTargetCntry = salesDB.Buyer_Country_Raw__c.toUpperCase()+salesDB.Buyer_Original_Raw__c.toUpperCase()+salesDB.Platform_Raw_Original__c.toUpperCase()+';buyer'; 

                if(salesDB.Date__c!= null && salesDB.Date__c.addMonths(2) >= system.today())
                {
                    
                    if(null != mapBuyerAccounts4SalesTeam.get(strCombKeyTargetCntry))
                    {                         
                        salesDB.PDT_Member__c = mapBuyerAccounts4SalesTeam.get(strCombKeyTargetCntry).PDT_Member__c;
                    }
                    else salesDB.PDT_Member__c = '';
                }            
            
                String strCombKeyBuyerCntry = salesDB.Buyer_Country_Raw__c.toUpperCase()+salesDB.Buyer_Original_Raw__c.toUpperCase()+
                                                                            salesDB.Platform_Raw_Original__c.toUpperCase()+';buyer'; 

                String strCombKeyBuyerCntrywoSpaces = strCombKeyBuyerCntry.deleteWhitespace();                                                              

                if(mapAllAccountswoSpaces.containsKey(strCombKeyBuyerCntrywoSpaces))
                {

                    string n = mapAllAccountswoSpaces.get(strCombKeyBuyerCntrywoSpaces);

                    list<String> val = n.split(';');
                    
                    if(val[1] == 'buyer' && val[0] != null && val[0] != '') 
                    {
                        accountName =   val[0].toUpperCase();

                        System.debug('accountName =' + accountName );

                        if(mapNameAndIDswoSpaces.get(accountName) != null)
                        {
                            salesDB.Buyer_and_Buyer_Country__c = mapNameAndIDswoSpaces.get(accountName).Id;
                            salesDB.Buyer_Holding_Group__c = mapNameAndIDswoSpaces.get(accountName).Ultimate_Parent_Account__c;
                            salesDB.Buyer_Error__c = '';                            
                        }else{ 

                            n = mapAllAccounts.get(strCombKeyBuyerCntry);

                            val = n.split(';');

                            listCreateAccount.add(TriggerUtility.toCreateAccount(val[0],'Data Buyer'));
                            mapAssignAccount.put(salesDB.Id+'buyer','buyer_@_'+val[0]);                            
                        }
                    }
                }else{
                    salesDB.Buyer_Error__c = 'Error :- Buyer Account Mapping Not Found';
                    salesDB.Buyer_and_Buyer_Country__c = null; 
                }                                                           
                                    
            }
            

            if(  salesDB.Advertiser_Raw__c != null && salesDB.Advertiser_Raw__c != '') 
            {
                if(mapAllAccounts.containsKey(salesDB.Advertiser_Raw__c+';advertiser') && salesDB.Campaign_Classified_Error__c != 'Campaign Classified Advertiser Mapping.'  )
                { 

                    string n = mapAllAccounts.get(salesDB.Advertiser_Raw__c+';advertiser');
                    list<String> val = n.split(';');
                    accountName = val[0].toUpperCase();

                    if(val[1] == 'advertiser' && val[0] != null && val[0] != '')
                    {
                        if(mapNameAndIDs.get(accountName) != null){
                            salesDB.Advertiser__c = mapNameAndIDs.get(accountName).Id;                            
                            salesDB.Advertiser_Error__c = '';
                        }else{ 
                            listCreateAccount.add(TriggerUtility.toCreateAccount(val[0],'Advertiser'));
                            mapAssignAccount.put(salesDB.Id+'advertiser','advertiser_@_'+val[0]);
                        }
                    }
                }else if ( salesDB.Campaign__c != null && salesDB.Campaign__c != '' && 
                    salesDB.Campaign_Classified_Error__c == 'Campaign Classified Advertiser Mapping.' ) {

                    if(mapAllAccounts.containsKey(salesDB.Campaign__c+';advertiser')){

                            string n = mapAllAccounts.get(salesDB.Campaign__c+';advertiser');
                            list<String> val = n.split(';');
                            accountName = val[0].toUpperCase();

                            if(val[1] == 'advertiser' && val[0] != null && val[0] != '')
                            {

                                if(mapNameAndIDs.get(accountName) != null){
                                    salesDB.Advertiser__c = mapNameAndIDs.get(accountName).Id;                            
                                    salesDB.Advertiser_Error__c = '';
                                }else{ 
                                    listCreateAccount.add(TriggerUtility.toCreateAccount(val[0],'Advertiser'));
                                    mapAssignAccount.put(salesDB.Id+'advertiser','advertiser_@_'+val[0]);
                                }
                            }
                        }else {
                            salesDB.Campaign_Classified_Error__c = 'Campaign Mapping Not Found.';
                            salesDB.Advertiser__c  = null;
                        }    
                }else {
                    salesDB.Advertiser_Error__c = 'Error :- Advertiser Account Mapping Not Found';
                    salesDB.Advertiser__c = null; 
                }
            }

            if(salesDB.Platform_Raw__c != null && salesDB.Platform_Raw__c != '')
            {
                if(mapAllAccounts.containsKey(salesDB.Platform_Raw__c.toUpperCase()+';platform'))
                {
                    string n = mapAllAccounts.get(salesDB.Platform_Raw__c.toUpperCase()+';platform');
                    list<String> val = n.split(';');
                    accountName = val[0].toUpperCase();
                    
                    if(val[1] == 'platform' && val[0] != null && val[0] != ''){
                        
                        if(mapNameAndIDs.get(accountName) != null){
                            salesDB.Platform__c = mapNameAndIDs.get(accountName).Id;
                            salesDB.Platform_Error__c = '';
                        }else{ 
                            listCreateAccount.add(TriggerUtility.toCreateAccount(val[0],'DSP'));
                            mapAssignAccount.put(salesDB.Id+'platform','platform_@_'+val[0]);
                        }
                    }
                }else{
                    salesDB.Platform_Error__c = 'Error :- Platform Account Mapping Not Found';
                    salesDB.Platform__c = null; 
                }
            } 

        /******************* End - Populate Existing Accounts matching to Sales DB Lookups ***********************************************************/

        /******************* Start - Populate Segment Mapping / Category Mapping and Revenue Transaction in Sales DB Lookups *****************************************/

            if(salesDB.Segment_Name_Sales_Raw__c != null && salesDB.Segment_Name_Sales_Raw__c != '')
            {
                salesDB.Segment_Mapping__c =  mapSegCodeSegMapId.get(salesDB.Segment_Name_Sales_Raw__c);
                salesDB.Segment_Category_Mapping__c = mapSegCodeSegCatId.get(mapPlatCodeSegmentCode.get(salesDB.Segment_Name_Sales_Raw__c));                 
                salesDB.Segment_Name_Error__c = '';

                try
                {   
                    segmentName = mapPlatCodeSegmentCode.get(salesDB.Segment_Name_Sales_Raw__c); 

                    // salesDB.Segment_Revenue_Transaction__c = mapExstngSegTransIDs.get(salesDB.Target_Country_Raw__c+
                    //                                                     salesDB.Date_Invoiced__c+
                    //                                                     mapSegCodeSegCatId.get(segmentName));  
                                                    
                    if (salesDB.Segment_Revenue_Transaction__c == null)
                    {
                    segRevTransaction.add(salesDB.Target_Country_Raw__c+'_'+salesDB.Date_Invoiced__c+'_'+mapSegCodeSegCatId.get(segmentName));
                    }
                }catch(Exception e)
                {
                    System.debug('>>Error:'+e.getMessage());
                }
            }else
            {
                salesDB.Segment_Name_Error__c = 'Error :- Segment Mapping Not Found';
            }

        /******************* End - Populate Segment Mapping / Category Mapping and Revenue Transaction in Sales DB Lookups *****************************************/     

        /******************* Start - Populate Buyer and Target Country Master Ids in Sales DB Lookups *****************************************/         

            salesDB.Buyer_Country_Error__c = null;
            salesDB.Target_Country_Error__c = null; 

            if(salesDB.Buyer_Country_Raw__c != null && salesDB.Buyer_Country_Raw__c != '')
                            salesDB.Buyer_Country__c = mapCountryIDs.get(salesDB.Buyer_Country_Raw__c);
                        
            if(salesDB.Target_Country_Raw__c != null && salesDB.Target_Country_Raw__c != '')
                            salesDB.Target_Country__c= mapCountryIDs.get(salesDB.Target_Country_Raw__c);

        /******************* End - Populate Buyer and Target Country Master Ids in Sales DB Lookups *****************************************/                            
        }   

        //****************** Sales DB Lookups Population ......Ends Here....For all Master Maps. Below is the Join Table population....******************************

        /******************* Start - Populate Segment Trans Id in Sales Database ************************************************************/

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
                        listSegmentTransactionInsert.add (st);
                    }
                }catch(Exception e){}    
            }

            If (!listSegmentTransactionInsert.isEmpty()) insert listSegmentTransactionInsert;

            for(Sales_Database__c salesDB:newList)
            {
                for(Segment_Revenue_Transaction__c segTrans:listSegmentTransactionInsert)
                {
                    try
                    {
                        if(salesDB.Date_Invoiced__c == segTrans.Date__c && salesDB.Target_Country_Raw__c.toUpperCase() == segTrans.Country_Code__c   && 
                            salesDB.Segment_Category_Mapping__c == segTrans.Segment_Category_Mapping__c  )
                                                                salesDB.Segment_Revenue_Transaction__c = segTrans.Id;                        
                    }
                    catch(Exception e)
                    {
                        System.debug('>>Error:'+e.getMessage());
                    }
                }
            }
        }

        /******************* End - Populate Segment Trans Id in Sales Database *************************************************************/   

        /******************* Start  - Accounts Creation where needed ************************************************************************/        

        if(!listCreateAccount.isEmpty())
        {

            for(Account accnt:listCreateAccount) mapCreateAccountDups.put(accnt.Name,accnt);
            
            list<Account> accAllSOQL = [SELECT Id, Name,Account_Type__c,New_Flag__c FROM Account WHERE Name IN: mapCreateAccountDups.keySet()]; 

            for(String accntNames:mapCreateAccountDups.keySet())
            {
                if(accAllSOQL != null && accAllSOQL.size() > 0)
                {
                    boolean flag = false;
                
                    for(Account accntLocal:accAllSOQL)  if(accntNames == accntLocal.Name) flag = true;
                        
                    if(!flag) mapToInsertUniqueAccnts.put(accntNames,mapCreateAccountDups.get(accntNames));                                        
                }
                else mapToInsertUniqueAccnts.put(accntNames,mapCreateAccountDups.get(accntNames));
            }
            
            if(!mapToInsertUniqueAccnts.isEmpty()) insert mapToInsertUniqueAccnts.values();
            
            List<Account> acList = [SELECT Id,parentId, Owner.Name,OwnerId,Name,Account_Type__c,New_Flag__c ,Ultimate_Parent_Account__c
                                    FROM Account 
                                    WHERE Name IN: mapToInsertUniqueAccnts.keySet() ];
            for(Account accnt : acList)
                mapAllNewAccnts.put(accnt.Name,accnt);
            
            for(Sales_Database__c salesDB:newList)
            { 
                for(Account acc:mapAllNewAccnts.values())
                {
                    if(mapAssignAccount.containsKey(salesDB.Id+'buyer'))
                    {
                        list<String> vl = mapAssignAccount.get(salesDB.Id+'buyer').split('_@_');
                        if(vl.get(0) == 'buyer' && acc.Name.trim().equalsIgnoreCase(vl.get(1)))
                        {
                            salesDB.Buyer_and_Buyer_Country__c = acc.Id;
                            salesDB.Buyer_Holding_Group__c = acc.Ultimate_Parent_Account__c;                 
                            salesDB.Buyer_Error__c = '';
                        }
                    }

                    if(mapAssignAccount.containsKey(salesDB.Id+'platform'))
                    {
                        list<String> vl = mapAssignAccount.get(salesDB.Id+'platform').split('_@_');
                        if(vl.get(0) == 'platform' && acc.Name.trim().equalsIgnoreCase(vl.get(1)))
                        {
                            salesDB.Platform__c = acc.Id;
                            salesDB.Platform_Error__c = '';
                        }
                    }
                    
                    if(mapAssignAccount.containsKey(salesDB.Id+'advertiser'))
                    {
                        list<String> vl = mapAssignAccount.get(salesDB.Id+'advertiser').split('_@_');
                    
                        if(vl.get(0) == 'advertiser' && acc.Name.trim().equalsIgnoreCase(vl.get(1)))
                        {
                            salesDB.Advertiser__c = acc.Id;
                            salesDB.Advertiser_Error__c = '';
                        }
                    }
                }               
            }
        }

        /******************* End  - Accounts Creation where needed ************************************************************************/         

        /******************* Start  - Finalize Exception Messages ************************************************************************/         

        for(Sales_Database__c salesDB:newList)
        {
            if(salesDB.Segment_Category_Mapping__c == null)  salesDB.Segment_Name_Error__c = 'Error :- Segment Mapping Not Found';
            if(salesDB.Platform__c == null)          salesDB.Platform_Error__c = 'Error :- Platform Account Mapping Not Found';
            if(salesDB.Advertiser__c == null && salesDB.Campaign_Classified_Error__c == '') salesDB.Advertiser_Error__c = 'Error :- Advertiser Account Mapping Not Found';
            if(salesDB.Buyer_and_Buyer_Country__c == null)  salesDB.Buyer_Error__c = 'Error :- Buyer Account Mapping Not Found';      
            if(salesDB.Target_Country__c == null)  salesDB.Target_Country_Error__c = 'Error :- Target Country Mapping Not Found';  
            if(salesDB.Buyer_Country__c == null)  salesDB.Buyer_Country_Error__c = 'Error :- Buyer Country Mapping Not Found';        
        }

        /******************* End  - Finalize Exception Messages  **************************************************************************/         

    }

    public static void onAfterInsertUpdate(List<Sales_Database__c> newList, Map<Id, Sales_Database__c> oldMap){

        Set<Id> segmentRevTxnIds = new Set<Id>();
        for(Sales_Database__c newSalesDb : newList){
            if(newSalesDb.Segment_Revenue_Transaction__c != null){
                segmentRevTxnIds.add(newSalesDb.Segment_Revenue_Transaction__c);
            }
        }

        List<Segment_Revenue_Transaction__c> updatedSegRevTxns = new List<Segment_Revenue_Transaction__c>();

        for(aggregateresult ag : [SELECT Segment_Revenue_Transaction__c ,SUM(Impressions__c) IMP,SUM(Revenue__c) REV,count(Id) cc FROM Sales_Database__c 
                                  WHERE Segment_Revenue_Transaction__c IN:segmentRevTxnIds GROUP BY Segment_Revenue_Transaction__c]){
            
            System.debug('segRevTxn ID: '+ag.get('Segment_Revenue_Transaction__c'));
                                      if(ag.get('Segment_Revenue_Transaction__c') != NULL){
                                          Segment_Revenue_Transaction__c updatedSegRevTxn = new Segment_Revenue_Transaction__c();
                                          updatedSegRevTxn.Id = String.valueOf(ag.get('Segment_Revenue_Transaction__c'));
                                          if(String.valueOf(ag.get('IMP')) != NULL){
                                              updatedSegRevTxn.Impressions_RollUp__c = Decimal.valueof(String.valueOf(ag.get('IMP')));
                                                  }else{
                                                      updatedSegRevTxn.Impressions_RollUp__c = 0;
                                                  }
                                          if(String.valueOf(ag.get('REV')) != NULL){
                                              updatedSegRevTxn.Sales_Revenue_RollUp__c = Decimal.valueof(String.valueOf(ag.get('REV')));
                                                  }else{
                                                      updatedSegRevTxn.Sales_Revenue_RollUp__c = 0; 
                                                  }
                                        updatedSegRevTxns.add(updatedSegRevTxn);
                                      }//if not null
                                      
        }//FOR

        if(!updatedSegRevTxns.isEmpty()){
            update updatedSegRevTxns;
        }

        /*Map<Id, Segment_Revenue_Transaction__c> mapSegmentRevTxns = new Map<Id, Segment_Revenue_Transaction__c>([SELECT Id, Impressions_RollUp__c, Sales_Revenue_RollUp__c FROM Segment_Revenue_Transaction__c WHERE Id IN :segmentRevTxnIds]);

        for(Sales_Database__c newSalesDb : newList){
            Sales_Database__c oldSalesDb = Trigger.isUpdate ? oldMap.get(newSalesDb.Id) : null;

            if(newSalesDb.Segment_Revenue_Transaction__c != null && mapSegmentRevTxns.containsKey(newSalesDb.Segment_Revenue_Transaction__c)){
                Segment_Revenue_Transaction__c segmentRevTxn = mapSegmentRevTxns.get(newSalesDb.Segment_Revenue_Transaction__c);
                Decimal impressionRollup = segmentRevTxn.Impressions_RollUp__c != null ? segmentRevTxn.Impressions_RollUp__c : 0;
                Decimal salesRevRollup = segmentRevTxn.Sales_Revenue_RollUp__c != null ? segmentRevTxn.Sales_Revenue_RollUp__c : 0;

                if(oldSalesDb != null && oldSalesDb.Impressions__c != null){
                    impressionRollup -= oldSalesDb.Impressions__c;
                }
                if(oldSalesDb != null && oldSalesDb.Revenue__c != null){
                    salesRevRollup -= oldSalesDb.Revenue__c;
                }

                if(newSalesDb.Impressions__c != null){
                    impressionRollup += newSalesDb.Impressions__c;
                }
                if(newSalesDb.Revenue__c != null){
                    salesRevRollup += newSalesDb.Revenue__c;
                }

                segmentRevTxn.Impressions_RollUp__c = impressionRollup;
                segmentRevTxn.Sales_Revenue_RollUp__c = salesRevRollup;

                mapSegmentRevTxns.put(segmentRevTxn.Id, segmentRevTxn);
            }
        }

        if(!mapSegmentRevTxns.isEmpty()){
            update mapSegmentRevTxns.values();
        }*/
    }

    public static void onDelete(List<Sales_Database__c> oldList){
        set<Id> sdIdDels = new set<Id>();
        list<Segment_Revenue_Transaction__c> toDelRevs = new list<Segment_Revenue_Transaction__c>();
        
        for(Sales_Database__c salesDB:oldList)
        { 
            sdIdDels.add(salesDB.Segment_Revenue_Transaction__c);
        } 
       System.debug('sdIdDels------@@'+sdIdDels);
        List<Segment_Revenue_Transaction__c> srtList = [Select  Sales_Revenue_RollUp__c ,Impressions_RollUp__c From Segment_Revenue_Transaction__c WHERE Id IN:sdIdDels];
        for(Segment_Revenue_Transaction__c segRevTranstoDel : srtList)
        {
            decimal impression2 = 0;
            decimal revenue2 = 0;

            for(Sales_Database__c salesDB: segRevTranstoDel.Sales_Databases__r)
            {
                if(segRevTranstoDel.Id == salesDB.Segment_Revenue_Transaction__c)
                {
                    impression2 += (salesDB.Impressions__c != null)?salesDB.Impressions__c:0.0;
                    revenue2 += (salesDB.Revenue__c != null)?salesDB.Revenue__c:0.0;
                }
            }

            segRevTranstoDel.Impressions_RollUp__c = impression2;
            segRevTranstoDel.Sales_Revenue_RollUp__c = revenue2;
            toDelRevs.add(segRevTranstoDel);
        }
       
        if(!toDelRevs.isEmpty()) update toDelRevs; 
    }

    public static void onUndelete(List<Sales_Database__c> newList){
        set<Id> sdIdUnDels = new set<Id>();
        list<Segment_Revenue_Transaction__c> toUnDelRevs = new list<Segment_Revenue_Transaction__c>();
      
        for(Sales_Database__c salesDB:newList)
        { 
            sdIdUnDels.add(salesDB.Segment_Revenue_Transaction__c);
        } 
       
        List<Segment_Revenue_Transaction__c> srtList = [Select  Sales_Revenue_RollUp__c ,Impressions_RollUp__c From Segment_Revenue_Transaction__c WHERE Id IN:sdIdUnDels];
        
        for(Segment_Revenue_Transaction__c segRevTranstoUnDel : srtList)
        {
            decimal impression3 = 0;
            decimal revenue3 = 0;

            for(Sales_Database__c salesDB: segRevTranstoUnDel.Sales_Databases__r )
            {
                if(segRevTranstoUnDel.Id == salesDB.Segment_Revenue_Transaction__c)
                {
                    impression3 += (salesDB.Impressions__c != null)?salesDB.Impressions__c:0.0;
                    revenue3 += (salesDB.Revenue__c != null)?salesDB.Revenue__c:0.0;
                }
            }

            segRevTranstoUnDel.Impressions_RollUp__c = impression3;
            segRevTranstoUnDel.Sales_Revenue_RollUp__c = revenue3;
            toUnDelRevs.add(segRevTranstoUnDel);
        }
       
        if(!toUnDelRevs.isEmpty()) update toUnDelRevs; 
    }

}