public with sharing class AdvertiserController {
    @AuraEnabled
    public static List<Item> getRecords( String dateFrom, String dateTo, String countryCode, String platform ){
        try {
            List<Item> items = new List<Item>();
            // List<Sales_Database__c> salesDatabases = [ SELECT Name, Advertiser_Raw__c  FROM Sales_Database__c WHERE Weekly_Report_Flag__c = false AND Platform__r.Name = 'DBM' AND Target_Country_Raw__c = 'US' AND Advertiser_Raw__c != NULL AND Advertiser_Raw__c != 'TABOOLA' AND Advertiser_Raw__c != 'LOTAME' AND Advertiser_Raw__c != '--' AND Advertiser_Raw__c != 'XAXIS' AND Advertiser_Raw__c != '0' AND Advertiser_Raw__c != '(BLANK)' AND  Advertiser_Raw__c != 'BLANK' AND  Advertiser_Raw__c != 'UNKNOWN' AND (NOT (Platform_Raw__c LIKE '%dnb%')) ORDER BY Advertiser_Raw__c ASC LIMIT 200];

            String salesQuery = ' SELECT Name, Advertiser_Raw__c FROM Sales_Database__c WHERE Advertiser_Raw__c != null AND Advertiser_Raw__c != \'0\' AND Advertiser_Raw__c != \'BLANK\' AND Advertiser_Raw__c != \'(BLANK)\'';

            if( String.isNotEmpty(dateFrom) && String.isNotEmpty(dateTo) ){
                Date fromD = Date.valueOf(dateFrom);
                Date toD = Date.valueOf(dateTo);
                System.debug('fromD fromD fromD' + fromD);
                System.debug('toD toD toD' + toD);
                salesQuery += ' AND Date_Invoiced__c >= :fromD AND Date_Invoiced__c <= :toD';
            } else if(String.isNotEmpty(dateFrom) && String.isEmpty(dateTo) ){
                Date fromD = Date.valueOf(dateFrom);
                System.debug('fromD fromD fromD' + fromD);
                salesQuery += ' AND Date_Invoiced__c >= :fromD';
            }  else if(String.isEmpty(dateFrom) && String.isNotEmpty(dateTo) ){
                Date toD = Date.valueOf(dateTo);
                System.debug('toD toD toD' + toD);
                salesQuery += ' AND Date_Invoiced__c <= :toD';
            }

            if( String.isNotEmpty(countryCode) ){
                salesQuery += ' AND Target_Country_Raw__c = :countryCode';
            }

            if( String.isNotEmpty(platform) ){
                salesQuery += ' AND Platform__r.Name = :platform';
            }

            salesQuery += ' ORDER BY Advertiser_Raw__c ASC LIMIT 200';
            System.debug('salesQuery salesQuery salesQuery' + salesQuery);

            List<Sales_Database__c> salesDatabases = Database.query(salesQuery);

            System.debug('salesDatabases salesDatabases salesDatabases' + salesDatabases);

            if( salesDatabases.size() > 0 ){
                Set<String> setOfNames = new Set<String>();
                Map<String, List<ItemMatching>> mapOfAdverterMappings = new Map<String, List<ItemMatching>>();
                Map<String, List<ItemMatching>> mapOfAccounts = new Map<String, List<ItemMatching>>();
                
                for( Sales_Database__c salesDatabase : salesDatabases ){
                    setOfNames.add(salesDatabase.Advertiser_Raw__c);
                }
                System.debug('setOfNames setOfNames setOfNames' + setOfNames);
                List<Advertiser_Mapping__c> advertiserMappings = [SELECT Id, Advertiser_Name__c FROM Advertiser_Mapping__c WHERE Advertiser_Name__c IN :setOfNames];

                if(advertiserMappings.size() > 0){
                    for( Advertiser_Mapping__c advertiserMapping : advertiserMappings ){
                        if( mapOfAdverterMappings.containsKey(advertiserMapping.Advertiser_Name__c) ){
                            mapOfAdverterMappings.get(advertiserMapping.Advertiser_Name__c).add(new ItemMatching(advertiserMapping.Id, advertiserMapping.Advertiser_Name__c));
                        } else {
                            List<ItemMatching> listOfItems = new List<ItemMatching>();
                            listOfItems.add(new ItemMatching(advertiserMapping.Id, advertiserMapping.Advertiser_Name__c));
                            mapOfAdverterMappings.put(advertiserMapping.Advertiser_Name__c, listOfItems);
                        }
                    }
                }

                String accountQuery = 'SELECT Id, Name FROM Account WHERE Name != null';
                for( String name : setOfNames ){
                    accountQuery += ' OR Name LIKE \'%' + name +'%\'';
                }
                
                System.debug('accountQuery accountQuery accountQuery' + accountQuery);

                List<Account> accounts = Database.query(accountQuery);
                if(accounts.size() > 0){
                    for( Account account : accounts ){
                        if( mapOfAccounts.containsKey(account.Name) ){
                            mapOfAccounts.get(account.Name).add(new ItemMatching(account.Id, account.Name));
                        } else {
                            List<ItemMatching> listOfItems = new List<ItemMatching>();
                            listOfItems.add(new ItemMatching(account.Id, account.Name));
                            mapOfAccounts.put(account.Name, listOfItems);
                        }
                    }
                }

                for( String setOfName : setOfNames ){
                    List<ItemMatching> itemMatchingsAdverterMappings = new List<ItemMatching>();
                    if(mapOfAdverterMappings.containsKey(setOfName)){
                        itemMatchingsAdverterMappings = mapOfAdverterMappings.get(setOfName);
                    }

                    List<ItemMatching> itemMatchingsAccounts = new List<ItemMatching>();
                    if(mapOfAccounts.containsKey(setOfName)){
                        itemMatchingsAccounts = mapOfAccounts.get(setOfName);
                    }

                    items.add(new Item(setOfName, new ItemAdvertiserMapping(itemMatchingsAdverterMappings), new ItemAccount(itemMatchingsAccounts)));
                }
            }

            return items;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    public static Boolean execute( String jsonData ){
        try {
            System.debug('jsonData jsonData jsonData' + jsonData);
            List<Params> data = (List<Params>)JSON.deserialize(jsonData, List<Params>.class);
            System.debug('data data data' + data);
            
            if( data.size() > 0 ){
                Set<String> setOfNames = new Set<String>();
                Map<String, Account> mapOfAccounts  = new Map<String, Account>();
                Map<String, String> mapOfAccountIds = new Map<String, String>();

                Id advertiserRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Advertiser').getRecordTypeId();
                for( Params param : data ){
                    setOfNames.add( param.name );
                    if( String.isEmpty( param.accountId ) ){
                        mapOfAccounts.put(param.name, new Account(
                            Name = param.name,
                            RecordTypeId = advertiserRecordTypeId
                        ));
                    } else {
                        mapOfAccountIds.put(param.name, param.accountId);
                    }
                }

                Database.SaveResult[] saveResultList = Database.insert(mapOfAccounts.values(), false);
                List<String> listOffAccountKeys = new List<String>(mapOfAccounts.keySet());
                Integer index = 0;
                
                for (Database.SaveResult sr : saveResultList) {
                    if (sr.isSuccess()) {
                        mapOfAccountIds.put(listOffAccountKeys[index], sr.getId());
                    }
                    index++;
                }

                Map<String, Advertiser_Mapping__c> mapOfAdvertiserMappings  = new Map<String, Advertiser_Mapping__c>();
                for( Params param : data ){
                    Advertiser_Mapping__c advMapping = new Advertiser_Mapping__c();
                    advMapping.Id = String.isNotEmpty( param.mappingId) ? param.mappingId : null;
                    advMapping.Advertiser_Name__c       = param.name;
                    advMapping.Advertiser_Account__c    = mapOfAccountIds.containsKey( param.name) ? mapOfAccountIds.get(param.name) : null;
                    mapOfAdvertiserMappings.put(param.name, advMapping);
                }

                upsert mapOfAdvertiserMappings.values();

                List<Sales_Database__c> salesDatabases = [SELECT Id FROM Sales_Database__c WHERE Advertiser_Raw__c IN :setOfNames];
                System.debug('salesDatabases salesDatabases salesDatabases' + salesDatabases.size());
                update salesDatabases;
            }

            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    public class Item {
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public ItemadvertiserMapping itemadvertiserMapping {get; set;}
        @AuraEnabled
        public ItemAccount itemAccount {get; set;}
        public Item(String name, ItemadvertiserMapping itemadvertiserMapping, ItemAccount itemAccount){
            this.name = name;
            this.itemadvertiserMapping = itemadvertiserMapping;
            this.itemAccount = itemAccount;
        }
    }

    public class ItemAdvertiserMapping {
        @AuraEnabled
        public Boolean hasAdvertisingMapping {get; set;}
        @AuraEnabled
        public List<ItemMatching> itemMatching {get; set;}
        public ItemAdvertiserMapping(List<ItemMatching> itemMatching){
            this.hasAdvertisingMapping  = itemMatching.size() > 0;       
            this.itemMatching           = itemMatching;   
        }
    }

    public class ItemAccount {
        @AuraEnabled
        public Boolean hasAccount {get; set;}
        @AuraEnabled
        public List<ItemMatching> itemMatching {get; set;}
        public ItemAccount(List<ItemMatching> itemMatching){
            this.hasAccount     = itemMatching.size() > 0;       
            this.itemMatching   = itemMatching;   
        }
    }

    public class ItemMatching {
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String refname {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String redirectUrl {get; set;}
        public ItemMatching(String id, String name){
            this.id = id;       
            this.name = name;   
            this.redirectUrl = '/' + id;     
        }
    }

    public class Params {
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String accountId {get; set;}
        @AuraEnabled
        public String mappingId {get; set;}
    }
}