trigger SegmentMonthlyGlobalTrigger on Segment_Monthly_Global__c (before insert, before update, after insert, after update) {
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        SegmentMonthlyGlobalTriggerHandler.onBeforeInsertUpdate(Trigger.new);
    } 
    else if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        SegmentMonthlyGlobalTriggerHandler.onAfterInsertUpdate(Trigger.newMap, Trigger.oldMap);
    }
}