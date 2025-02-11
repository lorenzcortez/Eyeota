public class SegmentBriefTrackingTriggerHandler {
    
    public static void onBeforeInsertUpdate(List<Segment_Brief_Tracking__c> segmentBriefList) {
        
        //Create a Set of all Opportunities to be Uploaded
        Set<Id> OpportunityIDs = new Set<Id>();
        
        //Create a Set of all the Segment Names to be Uploaded
        Set<String> SegmentNames = new Set<String>();

        //Map Segment Name for Upload to Segment Taxonomy Name
        Map<String,Segment_Category_Mapping__c> mastersheet = new Map<String,Segment_Category_Mapping__c>();

        for(Segment_Brief_Tracking__c segbrieftrack : segmentBriefList) {
            OpportunityIDs.add(segbrieftrack.Opportunity_ID__c);

            if(String.isNotBlank(segbrieftrack.Segment_Name_For_Upload__c)){
                SegmentNames.add(segbrieftrack.Segment_Name_For_Upload__c);
            }
        }

        //Query and Map Opportunity
        Map<Id,Opportunity> Opportunities = new Map<Id,Opportunity>([Select Id, 
                                                                            Advertiser_Account_Name__c, 
                                                                            AccountID from Opportunity 
                                                                            where Id in : OpportunityIDs]);

        for(Segment_Category_Mapping__c objSegmentCM : [Select Id, 
                                                                Segment_Name__c FROM Segment_Category_Mapping__c 
                                                                WHERE Segment_Name__c IN :SegmentNames]) {
            mastersheet.put(objSegmentCM.Segment_Name__c, objSegmentCM);
        }

        //Set Opportunity, Buyer Account and Advertiser Account
        //Add Segment Category Mapping ID to Segment Brief Tracking Record
        for(Segment_Brief_Tracking__c segbrieftrack : segmentBriefList) {
            
            if(!Opportunities.isEmpty() && Opportunities.containsKey(segbrieftrack.Opportunity_ID__c)) {
                segbrieftrack.Opportunity__c = Opportunities.get(segbrieftrack.Opportunity_ID__c)?.Id;
                segbrieftrack.Buyer_Account__c = Opportunities.get(segbrieftrack.Opportunity_ID__c)?.AccountID;
                segbrieftrack.Advertiser_Account__c = Opportunities.get(segbrieftrack.Opportunity_ID__c)?.Advertiser_Account_Name__c;
            }

            if(segbrieftrack.Segment_Name_For_Upload__c!=null && segbrieftrack.Segment_Name_For_Upload__c != '' && 
                (!mastersheet.isEmpty() && mastersheet.containsKey(segbrieftrack.Segment_Name_For_Upload__c))) {
                segbrieftrack.Segment_Name__c = mastersheet.get(segbrieftrack.Segment_Name_For_Upload__c)?.Id;
            }
            else {
                segbrieftrack.Segment_Name__c = null;
                segbrieftrack.Segment_Error__c='This segment does not exist.';
            }
        }
    }
}