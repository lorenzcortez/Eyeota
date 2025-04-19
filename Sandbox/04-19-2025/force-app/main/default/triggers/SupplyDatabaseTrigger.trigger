trigger SupplyDatabaseTrigger on Supply_Database__c (before update, before insert, after insert, after update, after delete, before delete, after undelete) {
    SupplyDatabaseTriggerDisable__c triggerSetting = SupplyDatabaseTriggerDisable__c.getOrgDefaults();
    if(!triggerSetting.IsDisable__c){
        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
            SupplyDatabaseHandler.onBeforeInsertUpdate(Trigger.New);
        }
        
        if((Trigger.IsAfter && Trigger.isInsert) || (Trigger.IsAfter && Trigger.IsUpdate)){
            SupplyDatabaseHandler.onAfterInsertUpdate(Trigger.New);
        }
        
        if(Trigger.IsDelete){
            
            if(Trigger.IsBefore) {
                SupplyDatabaseHandler.onBeforeDelete(Trigger.Old);
            }else if( Trigger.IsAfter ){
                SupplyDatabaseHandler.onDelete(Trigger.Old);
            }
        }   
        
        if(Trigger.IsUndelete){
            SupplyDatabaseHandler.onUndelete(Trigger.New);
        }  
    }
}