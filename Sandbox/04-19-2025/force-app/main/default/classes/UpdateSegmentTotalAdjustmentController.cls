public with sharing class UpdateSegmentTotalAdjustmentController {
    @AuraEnabled
    public static Boolean executeBatch(String recordId){
        Database.executeBatch(new UpdateSegmentTotalAdjustment(recordId), 200);
        return true;
    }
    
    public void runBatch(String recordId){
        Database.executeBatch(new UpdateSegmentTotalAdjustment(recordId), 200);
    }
}