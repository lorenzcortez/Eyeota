trigger AudienceReportTrigger on Audience_Report__c (before insert, before update) {
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        AudienceReportTriggerHandler.onBeforeInsertUpdate(Trigger.new);
    } 
}