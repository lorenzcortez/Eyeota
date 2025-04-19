@isTest
private class AudienceReportTest {
static testMethod void AudienceReportTest() {
 
        
        //create Country Mapping Record for mapping
        Country__c Country = new Country__c(Master_Geography_Code__c='TEST', Name='Test Country');
        Insert Country;
        
        
        // create Segment Category Mapping Record for mapping
        Segment_Category_Mapping__c SegCatMap = new Segment_Category_Mapping__c(Segment_Name__c='Test Segment', Segment_Code__c='Test Segment Key', Segment_Description__c='Test Description', Keywords__c='Test Keywords');
        Insert SegCatMap;
        
        //create Data Supplier Account for mapping
        Account Acc = new Account (Name='Test Account');
        Insert Acc;
        
        //create Data Supplier Mapping Record for mapping
        Data_Supplier_Mapping__c DataSupMap = new Data_Supplier_Mapping__c(Data_Supplier_Raw__c='TEST RAW DATA SUPPLIER', Data_Supplier_Account__c=Acc.id);
        Insert DataSupMap;


        // add Audience Report entries to be inserted
        Audience_Report__c AR = new Audience_Report__c (Data_Supplier_Raw_Original__c='Test Raw Data Supplier', Segment_Key__c='Test Segment Key', Country_Raw__c='TEST');
        Insert AR;
        Audience_Report__c ARExceptions = new Audience_Report__c (Data_Supplier_Raw_Original__c='Test Raw Data Supplier Error', Segment_Key__c='Test Segment Key Error', Country_Raw__c='TEST ERROR');
        Insert ARExceptions;

       }
    }