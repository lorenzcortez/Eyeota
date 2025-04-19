@isTest
private class Segment_Brief_TrackingTest {
static testMethod void Segment_Brief_TrackingTest() {
 
        
        //create Opportunity for mapping
        Opportunity Opp = new Opportunity(Name='Test Opportunity', StageName='Closed Won', CloseDate=Date.parse('01/01/2016'), Deal_Type__c='DSP CPM', Opportunity_Source__c='Data Desk');
        Insert Opp;
        
        
        // create Segment Category Mapping Records for mapping
        Segment_Category_Mapping__c SegCatMap = new Segment_Category_Mapping__c();
        SegCatMap.Segment_Name__c='Test Account';
        Insert SegCatMap;


        // add 200 Segment Brief Tracking to the list to be inserted
        Segment_Brief_Tracking__c SegBriefUpload = new Segment_Brief_Tracking__c(Segment_Name_For_Upload__c='Test Account',
        Opportunity_ID__c=Opp.Id);
        Insert SegBriefUpload;
        Segment_Brief_Tracking__c SegBriefUploadError = new Segment_Brief_Tracking__c(Segment_Name_For_Upload__c='Test Account Error',
        Opportunity_ID__c=Opp.Id);
        Insert SegBriefUploadError;

       }
    }