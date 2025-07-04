public with sharing class SupplyDBHandler {
    public static void onAfterUpdate(List<Supply_Database__c> supplyDatabases, Map<Id,Supply_Database__c> oldSupplyDatabases){
        List<Id> segmentRevenueTransactionIds = new List<Id>();
        for(Supply_Database__c supplyDatabase : supplyDatabases){
            if( supplyDatabase.X33Across_Adjustment_USD__c != oldSupplyDatabases.get(supplyDatabase.Id).X33Across_Adjustment_USD__c || 
                supplyDatabase.Supplier_Gross_Earnings_Retrospective__c != oldSupplyDatabases.get(supplyDatabase.Id).Supplier_Gross_Earnings_Retrospective__c || 
                supplyDatabase.ID_Graph_Adjustment_USD__c  != oldSupplyDatabases.get(supplyDatabase.Id).ID_Graph_Adjustment_USD__c || 
                supplyDatabase.ShareThis_Adjustment_USD__c  != oldSupplyDatabases.get(supplyDatabase.Id).ShareThis_Adjustment_USD__c || 
                supplyDatabase.TapAd_Adjustment_USD__c  != oldSupplyDatabases.get(supplyDatabase.Id).TapAd_Adjustment_USD__c || 
                supplyDatabase.Tech_Cost_Adjustment_USD__c  != oldSupplyDatabases.get(supplyDatabase.Id).Tech_Cost_Adjustment_USD__c ||
                supplyDatabase.ComScore_Adjustment_USD__c != oldSupplyDatabases.get(supplyDatabase.Id).ComScore_Adjustment_USD__c || 
                supplyDatabase.X33Across_Adjustment_USD_NEW__c != oldSupplyDatabases.get(supplyDatabase.Id).X33Across_Adjustment_USD_NEW__c || 
                supplyDatabase.Digital_Envoy_Adjustment_USD_NEW__c != oldSupplyDatabases.get(supplyDatabase.Id).Digital_Envoy_Adjustment_USD_NEW__c || 
                supplyDatabase.ID_Graph_Adjustment_USD_NEW__c  != oldSupplyDatabases.get(supplyDatabase.Id).ID_Graph_Adjustment_USD_NEW__c || 
                supplyDatabase.ShareThis_Adjustment_USD_NEW__c  != oldSupplyDatabases.get(supplyDatabase.Id).ShareThis_Adjustment_USD_NEW__c || 
                supplyDatabase.TapAd_Adjustment_USD_NEW__c  != oldSupplyDatabases.get(supplyDatabase.Id).TapAd_Adjustment_USD_NEW__c || 
                supplyDatabase.Tech_Cost_Adjustment_USD_NEW__c  != oldSupplyDatabases.get(supplyDatabase.Id).Tech_Cost_Adjustment_USD_NEW__c ||
                supplyDatabase.Other_1_Adjustment_USD_NEW__c != oldSupplyDatabases.get(supplyDatabase.Id).Other_1_Adjustment_USD_NEW__c ||
                supplyDatabase.Other_2_Adjustment_USD_NEW__c != oldSupplyDatabases.get(supplyDatabase.Id).Other_2_Adjustment_USD_NEW__c ){
                    
                // Double X33AcrossAdjustmentUSD = supplyDatabase.X33Across_Adjustment_USD__c != null ? supplyDatabase.X33Across_Adjustment_USD__c : 0;
                // Double SupplierGrossEarningsRetrospective = supplyDatabase.Supplier_Gross_Earnings_Retrospective__c != null ? supplyDatabase.Supplier_Gross_Earnings_Retrospective__c : 0;
                // Double IDGraphAdjustmentUSD = supplyDatabase.ID_Graph_Adjustment_USD__c != null ? supplyDatabase.ID_Graph_Adjustment_USD__c : 0;
                // Double ShareThisAdjustmentUSD = supplyDatabase.ShareThis_Adjustment_USD__c != null ? supplyDatabase.ShareThis_Adjustment_USD__c : 0;
                // Double TapAdAdjustmentUSD = supplyDatabase.TapAd_Adjustment_USD__c != null ? supplyDatabase.TapAd_Adjustment_USD__c : 0;
                // Double TechCostAdjustmentUSD = supplyDatabase.Tech_Cost_Adjustment_USD__c != null ? supplyDatabase.Tech_Cost_Adjustment_USD__c : 0;
                // Double ComScoreAdjustmentUSD = supplyDatabase.ComScore_Adjustment_USD__c != null ? supplyDatabase.ComScore_Adjustment_USD__c : 0;

                // totalAdjustments = X33AcrossAdjustmentUSD + SupplierGrossEarningsRetrospective + IDGraphAdjustmentUSD + ShareThisAdjustmentUSD + TapAdAdjustmentUSD + TechCostAdjustmentUSD + ComScoreAdjustmentUSD;

                if( !segmentRevenueTransactionIds.contains(supplyDatabase.Segment_Revenue_Transaction__c) ){
                    segmentRevenueTransactionIds.add(supplyDatabase.Segment_Revenue_Transaction__c);
                }
            }

            // if( supplyDatabase.X33Across_Adjustment_USD_NEW__c != oldSupplyDatabases.get(supplyDatabase.Id).X33Across_Adjustment_USD_NEW__c || 
            //     supplyDatabase.Digital_Envoy_Adjustment_USD_NEW__c != oldSupplyDatabases.get(supplyDatabase.Id).Digital_Envoy_Adjustment_USD_NEW__c || 
            //     supplyDatabase.ID_Graph_Adjustment_USD_NEW__c  != oldSupplyDatabases.get(supplyDatabase.Id).ID_Graph_Adjustment_USD_NEW__c || 
            //     supplyDatabase.ShareThis_Adjustment_USD_NEW__c  != oldSupplyDatabases.get(supplyDatabase.Id).ShareThis_Adjustment_USD_NEW__c || 
            //     supplyDatabase.TapAd_Adjustment_USD_NEW__c  != oldSupplyDatabases.get(supplyDatabase.Id).TapAd_Adjustment_USD_NEW__c || 
            //     supplyDatabase.Tech_Cost_Adjustment_USD_NEW__c  != oldSupplyDatabases.get(supplyDatabase.Id).Tech_Cost_Adjustment_USD_NEW__c ||
            //     supplyDatabase.Other_1_Adjustment_USD_NEW__c != oldSupplyDatabases.get(supplyDatabase.Id).Other_1_Adjustment_USD_NEW__c ||
            //     supplyDatabase.Other_2_Adjustment_USD_NEW__c != oldSupplyDatabases.get(supplyDatabase.Id).Other_2_Adjustment_USD_NEW__c ){
            
            //     Double X33AcrossAdjustmentUSDNEW = supplyDatabase.X33Across_Adjustment_USD_NEW__c != null ? supplyDatabase.X33Across_Adjustment_USD_NEW__c : 0;
            //     Double DigitalEnvoyAdjustmentUSDNEW = supplyDatabase.Digital_Envoy_Adjustment_USD_NEW__c != null ? supplyDatabase.Digital_Envoy_Adjustment_USD_NEW__c : 0;
            //     Double IDGraphAdjustmentUSDNEW = supplyDatabase.ID_Graph_Adjustment_USD_NEW__c != null ? supplyDatabase.ID_Graph_Adjustment_USD_NEW__c : 0;
            //     Double ShareThisAdjustmentUSDNEW = supplyDatabase.ShareThis_Adjustment_USD_NEW__c != null ? supplyDatabase.ShareThis_Adjustment_USD_NEW__c : 0;
            //     Double TapAdAdjustmentUSDNEW = supplyDatabase.TapAd_Adjustment_USD_NEW__c != null ? supplyDatabase.TapAd_Adjustment_USD_NEW__c : 0;
            //     Double TechCostAdjustmentUSDNEW = supplyDatabase.Tech_Cost_Adjustment_USD_NEW__c != null ? supplyDatabase.Tech_Cost_Adjustment_USD_NEW__c : 0;
            //     Double Other1AdjustmentUSDNEW = supplyDatabase.Other_1_Adjustment_USD_NEW__c != null ? supplyDatabase.Other_1_Adjustment_USD_NEW__c : 0;
            //     Double Other2AdjustmentUSDNEW = supplyDatabase.Other_2_Adjustment_USD_NEW__c != null ? supplyDatabase.Other_2_Adjustment_USD_NEW__c : 0;

            //     totalAdjustmentsNew = X33AcrossAdjustmentUSDNEW + DigitalEnvoyAdjustmentUSDNEW + IDGraphAdjustmentUSDNEW + ShareThisAdjustmentUSDNEW + TapAdAdjustmentUSDNEW + TechCostAdjustmentUSDNEW + Other1AdjustmentUSDNEW + Other2AdjustmentUSDNEW;
            
            // }

            if(segmentRevenueTransactionIds.size() > 0){
                List<AggregateResult> results =  [SELECT Segment_Revenue_Transaction__c, SUM(Total_Adjustments__c) totalAdjustments, SUM(Total_Adjustments_NEW__c) totalAdjustmentsNew FROM Supply_Database__c WHERE Segment_Revenue_Transaction__c IN :segmentRevenueTransactionIds GROUP BY Segment_Revenue_Transaction__c];
                List<Segment_Revenue_Transaction__c> segments = new List<Segment_Revenue_Transaction__c>();
                for (AggregateResult result : results){
                    Segment_Revenue_Transaction__c segment = new Segment_Revenue_Transaction__c(
                        Id = (Id) result.get('Segment_Revenue_Transaction__c'),
                        Total_Adjustments__c = (Double) result.get('totalAdjustments'),
                        Total_Adjustments_NEW__c = (Double) result.get('totalAdjustmentsNew')
                    );
                    segments.add(segment);
                }

                System.debug('segments segments segments' + segments);

                if( segments.size() > 0 ){  
                    update segments;
                }
            }
        }
    }
}