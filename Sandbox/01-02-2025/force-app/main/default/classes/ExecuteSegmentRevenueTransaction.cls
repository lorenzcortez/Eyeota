public with sharing class ExecuteSegmentRevenueTransaction {
    @AuraEnabled
    public static void execute(Integer batchSize){
        System.debug('batchSize' + batchSize);
        Database.executeBatch(new SalesDBSegmentRevenueAssignment(new List<String>()), batchSize);
    }

    @AuraEnabled
    public static void executeSupplyDatabase(Integer batchSize){
        System.debug('batchSize' + batchSize);
        Database.executeBatch(new SupplyDatabaseSegmentRevenueAssignment(new List<String>()), batchSize);
    }
}