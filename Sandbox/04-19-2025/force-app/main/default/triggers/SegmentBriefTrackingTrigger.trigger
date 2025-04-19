trigger SegmentBriefTrackingTrigger on Segment_Brief_Tracking__c (before insert, before update) {
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        SegmentBriefTrackingTriggerHandler.onBeforeInsertUpdate(Trigger.new);
    } 
}