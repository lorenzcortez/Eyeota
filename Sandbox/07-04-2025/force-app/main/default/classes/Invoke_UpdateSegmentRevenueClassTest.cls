@isTest
public with sharing class Invoke_UpdateSegmentRevenueClassTest {

    @TestSetup
    static void makeData(){
        Sales_Database__c sd = new Sales_Database__c();
        sd.Buyer_Error__c ='acd';
        sd.Buyer_Raw__c = 'abc';
        sd.Buyer_Country_Raw__c ='abc';
        sd.Platform_Raw_Original__c ='abc';
        sd.Date__c = System.today();
        sd.Date_Invoiced__c = System.today();
        sd.Segment_Name_Error__c ='abc';
        sd.Segment_Name_Sales_Raw__c='abc';
        sd.Revenue__c = 1;
        sd.Advertiser_Error__c ='abc';
        sd.Advertiser_Raw__c ='abc';
        
        insert sd;
        
        Segment_Category_Mapping__c sc = new Segment_Category_Mapping__c();
        sc.Segment_Name__c = 'abc';
        insert sc;
        
        Supply_Database__c   sdd = new Supply_Database__c ();
        sdd.Data_Supplier_Error__c = 'abc';
        sdd.Date__c = Date.valueOf('2024-10-01');
        sdd.Segment_Name_Error__c ='abc';
        sdd.Data_Supplier_Raw__c = 'adc';
        sdd.Segment_Name_Supply_Raw__c='abc';
        sdd.Segment_Category_Mapping__c = sc.id;
        //sdd.Segment_Name__c ='abc';
        insert sdd;
    }

    @isTest
    static void scenario(){

        List<Invoke_UpdateSegmentRevenueClass.FlowInput> inputs = new  List<Invoke_UpdateSegmentRevenueClass.FlowInput>();
        Invoke_UpdateSegmentRevenueClass.FlowInput input = new Invoke_UpdateSegmentRevenueClass.FlowInput();
        input.objectName    = 'Supply_Database__c';
        input.dateField     = 'Date__c';
        input.startDate     = Date.valueOf('2024-01-01');
        input.endDate       = Date.valueOf('2024-12-29');
        inputs.add(input);
        Test.startTest();
        Invoke_UpdateSegmentRevenueClass.runBatch(inputs);
        Test.stopTest();
    }
}