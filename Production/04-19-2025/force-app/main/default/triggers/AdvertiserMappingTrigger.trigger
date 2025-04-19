trigger AdvertiserMappingTrigger on Advertiser_Mapping__c (before insert, before update) {
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        AdvertiserMappingTriggerHandler.onBeforeInsertUpdate(Trigger.new);
    } 
}