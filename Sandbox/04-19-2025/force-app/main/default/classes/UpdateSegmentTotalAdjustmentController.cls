public with sharing class UpdateSegmentTotalAdjustmentController {
    @AuraEnabled
    public static Boolean executeBatch(String recordId){
        Database.executeBatch(new UpdateSegmentTotalAdjustment(new Set<Id>{recordId}), 200);
        return true;
    }
}