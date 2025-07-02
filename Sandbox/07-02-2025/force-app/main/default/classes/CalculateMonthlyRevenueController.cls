public with sharing class CalculateMonthlyRevenueController {
    @AuraEnabled
    public static Boolean executeBatch(String recordId){
        Database.executeBatch(new AdjTransactionCreationBatch(recordId), 200);
        return true;
    }
}