trigger PublisherMonthlyGlobalTrigger on Publisher_Monthly_Global__c (after insert, after update) {
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        PublisherMonthlyGlobalTriggerHandler.onAfterInsertUpdate(Trigger.newMap, Trigger.oldMap);    
    }
}