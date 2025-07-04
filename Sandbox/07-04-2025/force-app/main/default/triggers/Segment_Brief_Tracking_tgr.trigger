trigger Segment_Brief_Tracking_tgr on Segment_Brief_Tracking__c (before insert, before update) {

    //Create a Set of all Opportunities to be Uploaded
    Set<id> OpportunityIDs = new Set<id>();
    for (Segment_Brief_Tracking__c segbrieftrack : Trigger.new){
    OpportunityIDs.add(segbrieftrack.Opportunity_ID__c);}
    
    //Query and Map Opportunity
    Map<id,Opportunity> Opportunities = new Map<id,Opportunity>
    ([Select Id, Advertiser_Account_Name__c, AccountID from Opportunity where Id in : OpportunityIDs]);
    
    //Set Opportunity, Buyer Account and Advertiser Account
    for (Segment_Brief_Tracking__c segbrieftrack: Trigger.new){
    segbrieftrack.Opportunity__c=Opportunities.get(segbrieftrack.Opportunity_ID__c).Id;
    segbrieftrack.Buyer_Account__c=Opportunities.get(segbrieftrack.Opportunity_ID__c).AccountID;
    segbrieftrack.Advertiser_Account__c=Opportunities.get(segbrieftrack.Opportunity_ID__c).Advertiser_Account_Name__c;
    }
    
    //Create a Set of all the Segment Names to be Uploaded

    Set<String> SegmentNames = new Set<String>();

    //Variable declaration

    for (Segment_Brief_Tracking__c segbrieftrack : Trigger.new){
        if(segbrieftrack.Segment_Name_For_Upload__c!=''){
            SegmentNames.add(segbrieftrack.Segment_Name_For_Upload__c);
        }
    }
    //Map Segment Name for Upload to Segment Taxonomy Name

    Map<String,Segment_Category_Mapping__c> mastersheet = new Map<String,Segment_Category_Mapping__c>();
    
    Set<String> SegmentNamesfromSCM = new Set<String>();
    
    List<Segment_Category_Mapping__c> lstSegmentCM = [Select Id, Segment_Name__c FROM Segment_Category_Mapping__c WHERE Segment_Name__c IN :SegmentNames];
    
    for(Segment_Category_Mapping__c objSegmentCM : lstSegmentCM){
        mastersheet.put(objSegmentCM.Segment_Name__c, objSegmentCM);
        SegmentNamesfromSCM.add(objSegmentCM.Segment_Name__c);
    }

    //Add Segment Category Mapping ID to Segment Brief Tracking Record

    for (Segment_Brief_Tracking__c segbrieftrack : Trigger.new)
    {
    if(segbrieftrack.Segment_Name_For_Upload__c!=null&&segbrieftrack.Segment_Name_For_Upload__c!=''&&SegmentNamesfromSCM.contains(segbrieftrack.Segment_Name_For_Upload__c)){
    segbrieftrack.Segment_Name__c=mastersheet.get(segbrieftrack.Segment_Name_For_Upload__c).Id;}
    else{segbrieftrack.Segment_Name__c=null;
    segbrieftrack.Segment_Error__c='This segment does not exist.';}
    }
    
   
}