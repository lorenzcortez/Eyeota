trigger SalesDatabaseTrigger on Sales_Database__c (before insert, before update, after insert, after update, after delete, after undelete) {
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        SalesDatabaseTriggerHandler.onBeforeInsertUpdate(Trigger.new);
    } else if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        SalesDatabaseTriggerHandler.onAfterInsertUpdate(Trigger.new, Trigger.oldMap);
    } else if(Trigger.isDelete){
        SalesDatabaseTriggerHandler.onDelete(Trigger.old);
    } else if(Trigger.isUndelete){
        SalesDatabaseTriggerHandler.onUndelete(Trigger.new);
    }
}