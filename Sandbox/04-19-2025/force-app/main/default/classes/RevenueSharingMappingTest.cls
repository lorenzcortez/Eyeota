@isTest 
    public with sharing class RevenueSharingMappingTest {
        Static testmethod void RevenueSharingMappingTest(){
            
            Supply_Database__c Sup = new Supply_Database__c();
            Sup.Segment_Name_Supply_Raw_Original__c = 'Richard';
            Sup.Data_Supplier_Raw__c ='Gear';
            insert Sup;
            
            Supply_Database__c S = new Supply_Database__c();
            S.Data_Supplier_Raw__c = 'Richard';
            S.Segment_Name_Supply_Raw_Original__c ='ABC';
            insert S;
            
            Revenue_Share_Mapping__c rev = new Revenue_Share_Mapping__c();
            rev.Data_Supplier__c='Earned';
            rev.Country__c='India';
        }
}