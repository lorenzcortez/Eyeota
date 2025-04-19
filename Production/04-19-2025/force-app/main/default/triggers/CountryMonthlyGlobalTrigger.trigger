trigger CountryMonthlyGlobalTrigger on Country_Monthly_Global__c (before insert, before update) {
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        CountryMonthlyGlobalTriggerHandler.onBeforeInsertUpdate(Trigger.new);
    } 
}