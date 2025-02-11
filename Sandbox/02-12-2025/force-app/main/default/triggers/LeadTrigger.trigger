trigger LeadTrigger on Lead (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            LeadTriggerHandler.beforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            LeadTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}