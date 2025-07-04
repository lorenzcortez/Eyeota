@isTest
public class SupplyDatabaseSegmentRevenueAssignmTest {
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
            sd.Update_Segment_Revenue_Transaction__c = true;
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

    @isTest
    static void scenario() {
        List<Supply_Database__c> supplyDatabases = createSupplyDatabases(5);
        insert supplyDatabases;

        List<Supply_Database__c> suppDatabases = [SELECT Id, Update_Segment_Revenue_Transaction__c, Date__c, Segment_Name_Supply_Raw__c, Target_Country_Raw__c FROM Supply_Database__c WHERE Update_Segment_Revenue_Transaction__c = true];
        System.debug( 'suppDatabases' + suppDatabases );
        if( suppDatabases.size() > 0 ){
            List<String> ids = new List<String>();
            for( Supply_Database__c supplyDatabase : suppDatabases ){
                ids.add(supplyDatabase.Id);
            }
            
            Test.startTest();
            Database.executeBatch(new SupplyDatabaseSegmentRevenueAssignment(new List<String>(ids)), 100);
            Test.stopTest();
        }
    }

}