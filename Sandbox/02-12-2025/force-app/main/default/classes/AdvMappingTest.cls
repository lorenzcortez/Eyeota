@isTest
private class AdvMappingTest {
static testMethod void AdvMappingTest() {
 

        //create Advertiser Account for mapping
        Account Acc = new Account (Name='Test Account', RecordTypeId='01290000000iUro');
        Insert Acc;
       
       //create Advertiser Mapping Record for mapping
        Advertiser_Mapping__c AdvMapping = new Advertiser_Mapping__c (Advertiser_Raw__c='TEST', Advertiser_Name__c='Test Account');
        Insert AdvMapping;
        Advertiser_Mapping__c AdvMappingException = new Advertiser_Mapping__c (Advertiser_Raw__c='TESTEXCEPTION', Advertiser_Name__c='Test Advertiser Exception');
        Insert AdvMappingException;
       }
    }