global with sharing class UpdateSegmentTotalAdjustment implements Database.Batchable<sObject> {
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

    public UpdateSegmentTotalAdjustment(String recordId){
       this.adjustment = [SELECT Id, Year__c, Month__c, Monthly_Rev__c FROM Adjustment__c WHERE Id =:recordId LIMIT 1];
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Integer year            = Integer.valueOf(adjustment.Year__c);
        Integer month           = mapOfYears.get(adjustment.Month__c);
        Integer lastDay         = Date.daysInMonth(year, month);
        Date firstDayOfMonth    = Date.newInstance(year, month, 1);
        Date lastDayOfMonth     = Date.newInstance(year, month, lastDay);

        String query = 'SELECT Id, Segment_Revenue_Transaction__c FROM Supply_Database__c WHERE Date__c >= :firstDayOfMonth AND Date__c <= :lastDayOfMonth';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Supply_Database__c> records){

        System.debug('records' + records);

        Set<Id> segmentRevenueTransactionIds = new Set<Id>();
        for(Supply_Database__c record : records){
            segmentRevenueTransactionIds.add(record.Segment_Revenue_Transaction__c);
        }

        List<AggregateResult> results =  [SELECT Segment_Revenue_Transaction__c, SUM(Total_Adjustments__c) totalAdjustments, SUM(Total_Adjustments_NEW__c) totalAdjustmentsNew FROM Supply_Database__c WHERE Segment_Revenue_Transaction__c IN :segmentRevenueTransactionIds GROUP BY Segment_Revenue_Transaction__c];

        if(results.size() > 0){
            List<Segment_Revenue_Transaction__c> segments = new List<Segment_Revenue_Transaction__c>();
            for (AggregateResult result : results){
                Segment_Revenue_Transaction__c segment = new Segment_Revenue_Transaction__c(
                    Id = (Id) result.get('Segment_Revenue_Transaction__c'),
                    Total_Adjustments__c = (Double) result.get('totalAdjustments'),
                    Total_Adjustments_NEW__c = (Double) result.get('totalAdjustmentsNew')
                    //Total_Adjustments_NEW__c = (-1 * (Double) result.get('totalAdjustmentsNew'))
                );
                segments.add(segment);
            }
    
            System.debug('segments segments segments' + segments);
    
            if( segments.size() > 0 ){  
                update segments;
            }
        }
    }   

    global void finish(Database.BatchableContext bc){
        //Finish
    }    
}