global with sharing class UpdateSegmentTotalAdjustment implements Database.Batchable<sObject> {
    public Set<Id> setOfIds {get; set;}
    public UpdateSegmentTotalAdjustment(Set<Id> setOfIds){
       this.setOfIds = setOfIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Segment_Revenue_Transaction__c';

        if(setOfIds.size() > 0){
            query += ' WHERE Id IN :setOfIds';
        }

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Segment_Revenue_Transaction__c> records){
        Set<Id> segmentRevenueTransactionIds = new Set<Id>();
        for(Segment_Revenue_Transaction__c record : records){
            segmentRevenueTransactionIds.add(record.Id);
        }

        List<AggregateResult> results =  [SELECT Segment_Revenue_Transaction__c, SUM(Total_Adjustments__c) totalAdjustments, SUM(Total_Adjustments_NEW__c) totalAdjustmentsNew FROM Supply_Database__c WHERE Segment_Revenue_Transaction__c IN :segmentRevenueTransactionIds GROUP BY Segment_Revenue_Transaction__c];

        if(results.size() > 0){
            List<Segment_Revenue_Transaction__c> segments = new List<Segment_Revenue_Transaction__c>();
            for (AggregateResult result : results){
                Segment_Revenue_Transaction__c segment = new Segment_Revenue_Transaction__c(
                    Id = (Id) result.get('Segment_Revenue_Transaction__c'),
                    Total_Adjustments__c = (Double) result.get('totalAdjustments'),
                    Total_Adjustments_NEW__c = (-1 * (Double) result.get('totalAdjustmentsNew'))
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