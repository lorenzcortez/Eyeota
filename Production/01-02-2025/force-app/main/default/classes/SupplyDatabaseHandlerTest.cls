@isTest
public class SupplyDatabaseHandlerTest {
    
    // Utility method to create test data for Supply_Database__c
    private static List<Supply_Database__c> createSupplyDatabases(Integer count) {
        List<Supply_Database__c> supplyDatabases = new List<Supply_Database__c>();
        List<Segment_Mapping__c> segmentMapping = new List<Segment_Mapping__c>();
        List<Data_Supplier_Mapping__c> dataSupMapping = new List<Data_Supplier_Mapping__c>();
        
        for (Integer i = 0; i < count; i++) {
            Supply_Database__c sd = new Supply_Database__c();
            sd.Data_Supplier_Raw_Original__c = 'SUPPLIER ' + i;
            sd.Segment_Key_Raw__c = 'SEGMENTMAPSUPPLY' + (i+1);
            sd.Segment_Name_Supply_Raw_Original__c = 'SEGMENTMAPSUPPLY' + (i+1);
            sd.Target_Country_Raw__c = 'Country ' + i;
            sd.Date__c = Date.today();
            sd.Currency_Code__c = 'USD';
            supplyDatabases.add(sd);
        }
        
        Segment_Category_Mapping__c sCM = new Segment_Category_Mapping__c();
        sCM.Segment_Name__c='Test SCM';
        insert sCM;
        
        for (Integer i = 0; i < count; i++) {
            Segment_Mapping__c sm = new Segment_Mapping__c();
            sm.Segment_Name_Sales_Raw__c = 'SEGMENTMAPSALES' + (i+1);
            sm.Segment_Name_Supply_Raw__c = 'SEGMENTMAPSUPPLY' + (i+1);
            sm.Segment_Category_Mapping__c = sCM.Id;
            segmentMapping.add(sm);
        }
        
        Account acc = new Account(
                Name = 'Test Account ',
            	Currency_Code__c = 'USD'
        );
        
        insert acc;
        
        for (Integer i = 0; i < count; i++) {
            Data_Supplier_Mapping__c dSM = new Data_Supplier_Mapping__c();
            dSM.Data_Supplier_Raw__c = 'SUPPLIER ' + i;
            dSM.Data_Supplier_Account__c = acc.Id;
            dataSupMapping.add(dSM);
        }
        
        insert dataSupMapping;
        insert segmentMapping;
        
        return supplyDatabases;
    }
    
    // Test method for before update
    @isTest
    static void testBeforeUpdate() {
        List<Supply_Database__c> supplyDatabases = createSupplyDatabases(5);
        insert supplyDatabases;
        
        Map<Id, Supply_Database__c> supplyDatabasesMap = new Map<Id, Supply_Database__c>(supplyDatabases);
        
        for (Supply_Database__c sd : supplyDatabases) {
            sd.Data_Supplier_Raw_Original__c = 'UPDATED SUPPLIER ' + supplyDatabases.indexOf(sd);
        }
        
        Test.startTest();
        update supplyDatabases;
        Test.stopTest();
        
        // Assert that data has been updated correctly
        for (Supply_Database__c sd : [SELECT Id, Data_Supplier_Raw__c FROM Supply_Database__c WHERE Id IN: supplyDatabasesMap.keySet() ORDER BY Data_Supplier_Raw__c]) {
            System.assertEquals(sd.Data_Supplier_Raw__c.contains('UPDATED SUPPLIER '), TRUE);
        }
    }
    
    // Test method for after insert/update
    @isTest
    static void testAfterInsertUpdate() {
        List<Supply_Database__c> supplyDatabases = createSupplyDatabases(5);
        
        Test.startTest();
        insert supplyDatabases;
        Test.stopTest();
        
        Map<Id, Supply_Database__c> supplyDatabasesMap = new Map<Id, Supply_Database__c>(supplyDatabases);
        
        // Perform assertions as needed
        for (Supply_Database__c sd : [SELECT Id, Segment_Revenue_Transaction__c FROM Supply_Database__c WHERE Id IN: supplyDatabasesMap.keySet()]) {
            // Example assertion: Ensure the Segment_Revenue_Transaction__c field is set correctly
            System.assertNotEquals(null, sd.Segment_Revenue_Transaction__c);
        }
    }
    
    
    // Test method for after delete
    @isTest
    static void testAfterDelete() {
        List<Supply_Database__c> supplyDatabases = createSupplyDatabases(5);
        insert supplyDatabases;
        
        Map<Id, Supply_Database__c> supplyDatabasesMap = new Map<Id, Supply_Database__c>(supplyDatabases);
        Set<Id> segmentRecTransactionIds = new Set<Id>();
        
        for(Supply_Database__c suppDatabase : [SELECT Id, Segment_Revenue_Transaction__c FROM Supply_Database__c WHERE Id IN: supplyDatabasesMap.keySet()]){
            segmentRecTransactionIds.add(suppDatabase.Segment_Revenue_Transaction__c);
        }
        
        Test.startTest();
        delete supplyDatabases;
        Test.stopTest();
        
        // Perform assertions as needed
        for (Segment_Revenue_Transaction__c segmentRevTransaction : [SELECT Id, Uniques_RollUp__c FROM Segment_Revenue_Transaction__c WHERE Id = :segmentRecTransactionIds]) {
            System.assertEquals(segmentRevTransaction.Uniques_RollUp__c, 0);
            
        }
        
        
    }
    
    // Test method for undelete
    @isTest
    static void testUndelete() {
        List<Supply_Database__c> supplyDatabases = createSupplyDatabases(5);
        insert supplyDatabases;
        
        Map<Id, Supply_Database__c> supplyDatabasesMap = new Map<Id, Supply_Database__c>(supplyDatabases);
        Set<Id> segmentRecTransactionIds = new Set<Id>();
        
        for(Supply_Database__c suppDatabase : [SELECT Id, Segment_Revenue_Transaction__c FROM Supply_Database__c WHERE Id IN: supplyDatabasesMap.keySet()]){
            segmentRecTransactionIds.add(suppDatabase.Segment_Revenue_Transaction__c);
        }
        
        delete supplyDatabases;
        
        Test.startTest();
        Undelete supplyDatabases;
        Test.stopTest();
        
        // Perform assertions as needed
        for (Segment_Revenue_Transaction__c segmentRevTransaction : [SELECT Id, Uniques_RollUp__c FROM Segment_Revenue_Transaction__c WHERE Id = :segmentRecTransactionIds]) {
            System.assertNotEquals(null, segmentRevTransaction.Uniques_RollUp__c);
            
        }
    }
}