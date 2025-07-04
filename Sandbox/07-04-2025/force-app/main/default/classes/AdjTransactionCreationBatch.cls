global class AdjTransactionCreationBatch implements Database.Batchable<sObject> {
    public final Adjustment__c adjustment {get; set;}
    public final Map<String, Integer> mapOfYears = new Map<String, Integer>{
        'January' => 1,
        'February' => 2,
        'March' => 3,
        'April' => 4,
        'May' => 5,
        'June' => 6,
        'July' => 7,
        'August' => 8,
        'September' => 9,
        'October' => 10,
        'November' => 11,
        'December' => 12
    };

    public AdjTransactionCreationBatch(String recordId){
        System.debug('recordId' + recordId);
        this.adjustment = [SELECT Id, Year__c, Month__c, Monthly_Rev__c FROM Adjustment__c WHERE Id =:recordId LIMIT 1];
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(' this.adjustment' +  adjustment);
        Integer year            = Integer.valueOf(adjustment.Year__c);
        Integer month           = mapOfYears.get(adjustment.Month__c);

        System.debug('year year' + year);
        System.debug('month month' + month);

        Integer lastDay         = Date.daysInMonth(year, month);
        Date firstDayOfMonth    = Date.newInstance(year, month, 1);
        Date secondDayOfMonth    = Date.newInstance(year, month, 2);
        Date lastDayOfMonth     = Date.newInstance(year, month, lastDay);
        
        //old query
        //String query = 'SELECT Id, Gross_Earnings_Calc_USD_For_Export__c, Branded_Adjustment_Amount__c,Segment_Supplier_Category__c FROM Supply_Database__c WHERE Date__c >= :firstDayOfMonth AND Date__c <= :lastDayOfMonth';
        String query = 'SELECT Id, Gross_Earnings_Calc_USD_For_Export__c, Branded_Adjustment_Amount__c,Segment_Supplier_Category__c FROM Supply_Database__c WHERE Date__c >= :firstDayOfMonth AND Date__c <= :secondDayOfMonth';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Supply_Database__c> records){
        
        if(records.size() > 0){
            List<Adjustment_Transaction__c> adjustmentTransactions = new List<Adjustment_Transaction__c>();
            
            for( Supply_Database__c record : records ){
                                
                Adjustment_Transaction__c adjustmentTransaction = new Adjustment_Transaction__c(
                    Supply_Database__c = record.Id,
                    Year__c = adjustment.Year__c,
                    Month__c = adjustment.Month__c,
                    Adjustment__c = adjustment.Id,
                    Revenue_Amount__c = record.Gross_Earnings_Calc_USD_For_Export__c,
                    //Revenue_Amount__c = (record.Segment_Supplier_Category__c != 'Branded') ?  record.Gross_Earnings_Calc_USD_For_Export__c: 0,
                    Segment_Category__c = record.Segment_Supplier_Category__c,
                    //Branded_Adjustment_Amount__c = record.Branded_Adjustment_Amount__c
                    Branded_Adjustment_Amount__c = (record.Segment_Supplier_Category__c == 'Branded') ?  record.Branded_Adjustment_Amount__c: 0
                );
                
                adjustmentTransactions.add(adjustmentTransaction);
            }
            
            System.debug('adjustmentTransactions adjustmentTransactions adjustmentTransactions' + adjustmentTransactions);
            
            if( adjustmentTransactions.size() > 0 ){
                try {
                    insert adjustmentTransactions;
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
        }
        
    }   
    
    global void finish(Database.BatchableContext bc){
        //Finish
    }    
}