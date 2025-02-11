trigger SupplyDBTrigger on Supply_Database__c (after update) {
    SupplyDatabaseTriggerDisable__c triggerSetting = SupplyDatabaseTriggerDisable__c.getOrgDefaults();
    if(!triggerSetting.IsDisable__c){
        SupplyDBHandler.onAfterUpdate(Trigger.New, Trigger.oldMap);
    }
}