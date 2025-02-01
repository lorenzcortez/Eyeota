public class PublisherMonthlyGlobalTriggerHandler {

    public static void onAfterInsertUpdate(Map<Id, Publisher_Monthly_Global__c> newMap, Map<Id, Publisher_Monthly_Global__c> oldMap) {
        
        if(!TriggerUtility.inFutureContext1) {

            Set<Date> supplierDate = new Set<Date>();
            Set<String> sdmSet = new Set<String>();
            Set<String> setDataSupplier = new Set<String>(); 
            //Map<String,String> dataSuplierLookapMap = new Map<String,String>();         
            Map<String,String> MapField = new Map<String,String>();   
            Map<String,Account> toCreateAccountsMap = new Map<String,Account>();
            Map<String,Account> existingAccount = new Map<String,Account>();
            Map<String,Account> accMap = new Map<String,Account>();
            Map<String,Account> allAcc = new Map<String,Account>();
            Map<String,double> globalRevMap = new Map<String,double>();
            Map<String,double> revMap = new Map<String,double>();
            List<Publisher_Monthly_Global__c> pmgToUpdate = new List<Publisher_Monthly_Global__c>();

            for(Publisher_Monthly_Global__c smg : newMap.values()) {
                if(smg.Data_Supplier_Raw_Original__c != null && smg.Data_Supplier_Raw_Original__c != ''){
                    sdmSet.add(smg.Data_Supplier_Raw_Original__c.toUpperCase());
                }
                if(smg.Date__c != null){
                    supplierDate.add(smg.Date__c);
                }
            }

            System.debug('sdmSet sdmSet sdmSet' +  sdmSet);

             List<Data_Supplier_Mapping__c> samples = [Select Name, Id, Data_Supplier_Raw__c, Data_Supplier__c From Data_Supplier_Mapping__c];
			 System.debug('samples samples samples' +  samples);
            
            //Query matching Data Supplier records into Map
            List<Data_Supplier_Mapping__c> dataSupplierMappings = [Select Name, Id, Data_Supplier_Raw__c, Data_Supplier__c From Data_Supplier_Mapping__c WHERE Data_Supplier_Raw__c IN : sdmSet];

            System.debug('dataSupplierMappings dataSupplierMappings dataSupplierMappings' +  dataSupplierMappings);

            //Query matching Data Supplier records into Map
            for(Data_Supplier_Mapping__c ds : dataSupplierMappings) {            
                if(ds.Data_Supplier__c != null && ds.Data_Supplier__c != '') {
                    mapField.put(ds.Data_Supplier_Raw__c,ds.Data_Supplier__c);
                }           
            }

            //Query Accounts from Account Master matching to Data Supplier Mapped records.  
            for(Account acc1:[SELECT Id, 
                                        Name,
                                        Account_Type__c,
                                        New_Flag__c FROM Account 
                                        WHERE Name IN: mapField.values()]) {                    
                accMap.put(acc1.Name,acc1);
            }

            //Query / Create Accounts in case of Matching Data Supplier records without actual Account records.         
            for(String an : mapField.values()) {
                if(accMap.containsKey(an)) {
                    existingAccount.put(an, accMap.get(an));
                }
                else {
                    toCreateAccountsMap.put(an, TriggerUtility.toCreateAccount(an,'Data Supplier'));
                }
            }

            //Insert Accounts created if needed as part of previous step
            if(!toCreateAccountsMap.isEmpty()) insert toCreateAccountsMap.values();  

            for(Account acc : [SELECT Id, 
                                        Name, 
                                        Account_Type__c,
                                        New_Flag__c FROM Account 
                                        WHERE Name IN: existingAccount.keySet() 
                                        OR Name IN: toCreateAccountsMap.keySet()]) {
                allAcc.put(acc.Name,acc);
            } //End, Add newly created Accounts into the Maps for subsequent steps.


            // Populate the DataSupplier Lookup into the PMG records as mapped above.          
            for(Publisher_Monthly_Global__c smg1 : newMap.values()) {
                if(!mapField.isEmpty() && !allAcc.isEmpty()) {
                    if(smg1.Data_Supplier_Raw__c != null && smg1.Data_Supplier_Raw__c != '' && 
                    mapField.containsKey(smg1.Data_Supplier_Raw__c) && allAcc.containsKey(mapField.get(smg1.Data_Supplier_Raw__c))){
                        smg1.Data_Supplier__c = allAcc.get(mapField.get(smg1.Data_Supplier_Raw__c))?.Id;
                        setDataSupplier.add(smg1.Data_Supplier__c);
                        //dataSuplierLookapMap.put(smg1.Data_Supplier_Raw__c, allAcc.get(mapField.get(smg1.Data_Supplier_Raw__c))?.Id);
                    }
                }
            }
            System.debug('setDataSupplier-------@@'+setDataSupplier);
            // Create a Aggregated ( Supplier Gross Earnings aggregation) Map of the Data Supplier  / Date combination.     
            for(AggregateResult ssd : [SELECT sum(Supplier_Gross_Earnings__c),
                                                Date__c,
                                                Data_Supplier__c FROM Supply_Database__c 
                                                WHERE Data_Supplier__c IN :setDataSupplier 
                                                AND Date__c IN :supplierDate 
                                                AND IsDeleted=false 
                                                group by Data_Supplier__c, Date__c]) {
                if(ssd.get('Data_Supplier__c')!= null && ssd.get('Date__c') != null) {
                    globalRevMap.put(ssd.get('Data_Supplier__c')+''+ssd.get('Date__c'), double.valueOf(ssd.get('expr0')));
                }
            }
        
            // Create a Aggregated ( Supplier Gross Earnings aggregation) Map of the Data Supplier  / Country / Date combination.      
            for(AggregateResult ssd : [SELECT sum(Supplier_Gross_Earnings__c),
                                                Date__c,
                                                Data_Supplier__c,
                                                Target_Country_Raw__c FROM Supply_Database__c 
                                                WHERE Data_Supplier__c IN :setDataSupplier 
                                                AND Date__c IN :supplierDate AND IsDeleted=false 
                                                group by Data_Supplier__c, Date__c, Target_Country_Raw__c]){
                if(ssd.get('Data_Supplier__c')!= null && ssd.get('Date__c') != null && ssd.get('Target_Country_Raw__c') != null) {
                    revMap.put(ssd.get('Data_Supplier__c')+''+ssd.get('Date__c')+''+ssd.get('Target_Country_Raw__c'), double.valueOf(ssd.get('expr0')));
                }
            }
            
            List<Publisher_Monthly_Global__c> globals = [SELECT Id, Data_Supplier__c, Country_Raw__c, Date__c FROM Publisher_Monthly_Global__c WHERE Id IN :newMap.keySet()];
            // Start - Populate the PMG records with the aggregated result based on if the record has a specific Country or needs Global Earnings data.
            for(Publisher_Monthly_Global__c pm : globals) {
                Double revenues = 0.0;
                if('Global'.equalsignorecase(pm.Country_Raw__c) || pm.Country_Raw__c == '' || pm.Country_Raw__c == null) {
                    pm.Revenue__c = globalRevMap.get(pm.Data_Supplier__c+''+pm.Date__c);
                }
                else {
                    pm.Revenue__c = revMap.get(pm.Data_Supplier__c+''+pm.Date__c+''+pm.Country_Raw__c);
                }
                // pmgToUpdate.add(pm);            
            }

            if(!globals.isEmpty()) {
                TriggerUtility.inFutureContext1 = true;
                update globals;
            }
        }
    }
}