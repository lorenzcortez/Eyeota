/*
Object Name      : Publisher Monthly Global Trigger
Purpose          : To map Raw Fields to Mapped Data Supplier Master Records and 
                    to calculate the total Supplier Gross Earnings in the Supply Database on the Date and Country for every Data Supplier combination
Created By       : Mohammad Usman / TechMatrix Consulting Pte Ltd. 
Modified By      : Antony Jerald / TechMatrix Consulting Pte Ltd.
Last Modified Date    : 30th May 2017
Last Modified Purpose : Adding Documentation, Removing debug statements for better readability.  
*
*/

trigger PublisherMonthlyGlobal_tgr on Publisher_Monthly_Global__c (before insert, before update,after insert, after update) {
    
        set<Date> supplierDate = new set<Date>();
        set<String> sdmSet = new set<String>();
        map<String,String> dataSuplierLookapMap = new map<String,String>();         
        map<String,String> mapField = new map<String,String>();   
        map<String,Account> toCreateAccountsMap = new map<String,Account>();
        map<String,Account> existingAccount = new map<String,Account>();
        map<String,Account> accMap = new map<String,Account>();
        map<String,Account> allAcc = new map<String,Account>();
        map<String,double> globalRevMap = new map<String,double>();
        map<String,double> revMap = new map<String,double>();
        set<String> setDataSupplier = new set<String>(); 

    if((trigger.isBefore && trigger.isInsert) || (trigger.isBefore && trigger.isUpdate)){  
        
        // Start..Master Data Maps for subsequent Bulk Queries
        for(Publisher_Monthly_Global__c smg:trigger.new){
            if(smg.Data_Supplier_Raw_Original__c != null && smg.Data_Supplier_Raw_Original__c != ''){
                smg.Data_Supplier_Raw__c = smg.Data_Supplier_Raw_Original__c.toUpperCase(); 
                sdmSet.add(smg.Data_Supplier_Raw__c);
            }
            if(smg.Date__c != null){
                supplierDate.add(smg.Date__c);
            }
        }
        // End..Master Data Maps for subsequent Bulk Queries

        // Query matching Data Supplier records into Map
        System.debug('sdmSet----@@'+sdmSet);
        for(Data_Supplier_Mapping__c ds:[Select Name, Id, Data_Supplier_Raw__c, Data_Supplier__c From Data_Supplier_Mapping__c WHERE Data_Supplier_Raw__c IN:sdmSet]){            
            if(ds.Data_Supplier__c != null && ds.Data_Supplier__c != ''){
                mapField.put(ds.Data_Supplier_Raw__c,ds.Data_Supplier__c);
            }           
        }
    
        // Query Accounts from Account Master matching to Data Supplier Mapped records.  
        for(Account acc1:[SELECT Id, Name,Account_Type__c,New_Flag__c FROM Account WHERE Name IN: mapField.values()]){
            accMap.put(acc1.Name,acc1);
        }

        // Query / Create Accounts in case of Matching Data Supplier records without actual Account records.         
        for(String an:mapField.values()){
            if(accMap.containsKey(an)){
                existingAccount.put(an,accMap.get(an));
            }else{
                toCreateAccountsMap.put(an,TriggerUtility.toCreateAccount(an,'Data Supplier'));
            }
        }
        
        if(!toCreateAccountsMap.isEmpty()) insert toCreateAccountsMap.values();  // Insert Accounts created if needed as part of previous step..
        
        for(Account acc:[SELECT Id, Name,Account_Type__c,New_Flag__c FROM Account WHERE Name IN: existingAccount.keySet() OR  Name IN: toCreateAccountsMap.keySet()]){
            allAcc.put(acc.Name,acc);
        } // End, Add newly created Accounts into the Maps for subsequent steps.


        // Populate the DataSupplier Lookup into the PMG records as mapped above.          
        for(Publisher_Monthly_Global__c smg1:trigger.new){
            if(smg1.Data_Supplier_Raw__c != null && smg1.Data_Supplier_Raw__c != '' && mapField.containsKey(smg1.Data_Supplier_Raw__c) && allAcc.containsKey(mapField.get(smg1.Data_Supplier_Raw__c))){
                smg1.Data_Supplier__c = allAcc.get(mapField.get(smg1.Data_Supplier_Raw__c)).Id;
                setDataSupplier.add(smg1.Data_Supplier__c);
                dataSuplierLookapMap.put(smg1.Data_Supplier_Raw__c,allAcc.get(mapField.get(smg1.Data_Supplier_Raw__c)).Id);
            }
        }
        System.debug('setDataSupplier-------@@'+setDataSupplier);
        // Create a Aggregated ( Supplier Gross Earnings aggregation) Map of the Data Supplier  / Date combination.     
        for(AggregateResult ssd:[SELECT sum(Supplier_Gross_Earnings__c),Date__c,Data_Supplier__c FROM Supply_Database__c WHERE Data_Supplier__c IN :setDataSupplier AND Date__c IN :supplierDate AND IsDeleted=false group by Data_Supplier__c , Date__c ]){
            if(ssd.get('Data_Supplier__c')!= null && ssd.get('Date__c') != null){
                globalRevMap.put(ssd.get('Data_Supplier__c')+''+ssd.get('Date__c'),double.valueOf(ssd.get('expr0')));
            }
        }
    
        // Create a Aggregated ( Supplier Gross Earnings aggregation) Map of the Data Supplier  / Country / Date combination.      
        for(AggregateResult ssd:[SELECT sum(Supplier_Gross_Earnings__c),Date__c,Data_Supplier__c,Target_Country_Raw__c FROM Supply_Database__c WHERE Data_Supplier__c IN :setDataSupplier AND Date__c IN :supplierDate AND IsDeleted=false  group by Data_Supplier__c , Date__c ,Target_Country_Raw__c]){
            if(ssd.get('Data_Supplier__c')!= null && ssd.get('Date__c') != null && ssd.get('Target_Country_Raw__c') != null){
                revMap.put(ssd.get('Data_Supplier__c')+''+ssd.get('Date__c')+''+ssd.get('Target_Country_Raw__c'),double.valueOf(ssd.get('expr0')));
            }
        }
        
        // Start - Populate the PMG records with the aggregated result based on if the record has a specific Country or needs Global Earnings data.
        for(Publisher_Monthly_Global__c pm:trigger.new){
            double revenues = 0.0;
            
            if('Global'.equalsignorecase(pm.Country_Raw__c) || pm.Country_Raw__c == '' || pm.Country_Raw__c == null){
                    pm.Revenue__c = globalRevMap.get(pm.Data_Supplier__c+''+pm.Date__c);
            }else{
                    pm.Revenue__c = revMap.get(pm.Data_Supplier__c+''+pm.Date__c+''+pm.Country_Raw__c);
            }            
        }
        // End - Populate the PMG records with the aggregated result based on if the record has a specific Country or needs Global Earnings data.
    }
}