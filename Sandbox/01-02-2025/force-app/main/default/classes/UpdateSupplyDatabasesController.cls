public with sharing class UpdateSupplyDatabasesController {
    @AuraEnabled
    public static Boolean executeBatch(String recordId){
        Database.executeBatch(new UpdateSupplyDatabaseBatch(recordId), 200);
        return true;
    }
}