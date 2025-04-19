global class AdjTransactionUpdatedBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Supply_Database__r.Gross_Earnings_Calc_USD_For_Export__c FROM Adjustment_Transaction__c WHERE Is_Updated__c = false';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Adjustment_Transaction__c> scope){
        for( Adjustment_Transaction__c record : scope ){
            record.Revenue_Amount__c = record.Supply_Database__r.Gross_Earnings_Calc_USD_For_Export__c;
        }
        update scope;
    }   

    global void finish(Database.BatchableContext bc){
        //Finish
    }    
}