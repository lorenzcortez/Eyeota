global class UpdateSupplyDatabaseBatch implements Database.Batchable<sObject> {
    public final Adjustment__c adjustment {get; set;}
    public Map<String, Adjustment_Type__c> mapOfAdjustmentTypes {get; set;}
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
    
    public UpdateSupplyDatabaseBatch(String recordId){
        this.adjustment = [SELECT Id, Year__c, Month__c, Monthly_Rev__c FROM Adjustment__c WHERE Id =:recordId LIMIT 1];
        this.mapOfAdjustmentTypes = new Map<String, Adjustment_Type__c>();
        List<Adjustment_Type__c> adjustmentTypes = [SELECT Id, Amount__c, Type__c, Month_Revenue_Percent__c FROM Adjustment_Type__c WHERE Adjustment__c =: adjustment.Id];
        System.debug('adjustmentTypes adjustmentTypes adjustmentTypes' + adjustmentTypes);
        if( adjustmentTypes.size() > 0 ){
            for(Adjustment_Type__c adjustmentType : adjustmentTypes){
                this.mapOfAdjustmentTypes.put(adjustmentType.Type__c, adjustmentType);
            }
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Integer year            = Integer.valueOf(adjustment.Year__c);
        Integer month           = mapOfYears.get(adjustment.Month__c);
        Integer lastDay         = Date.daysInMonth(year, month);
        Date firstDayOfMonth    = Date.newInstance(year, month, 1);
        Date lastDayOfMonth     = Date.newInstance(year, month, lastDay);
        
        String query = 'SELECT Id, Gross_Earnings_Calc_USD_For_Export__c FROM Supply_Database__c WHERE Date__c >= :firstDayOfMonth AND Date__c <= :lastDayOfMonth';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Supply_Database__c> records){
        System.debug('mapOfAdjustmentTypes mapOfAdjustmentTypes mapOfAdjustmentTypes' + mapOfAdjustmentTypes);
        for(Supply_Database__c record : records){

            Double monthlyEarningsPercentage = (record.Gross_Earnings_Calc_USD_For_Export__c / adjustment.Monthly_Rev__c);
            //Double newCalculation = (record.Gross_Earnings_Calc_USD_For_Export__c / 0.02);

            if(mapOfAdjustmentTypes.containsKey('33Across')){
                //record.X33Across_Adjustment_USD__c = mapOfAdjustmentTypes.get('33Across').Amount__c * monthlyEarningsPercentage;
                //record.X33Across_Adjustment_USD_NEW__c = (mapOfAdjustmentTypes.get('33Across').Month_Revenue_Percent__c / 100) * newCalculation;
            	record.X33Across_Adjustment_USD_NEW__c = mapOfAdjustmentTypes.get('33Across').Amount__c * monthlyEarningsPercentage;
            }

            if(mapOfAdjustmentTypes.containsKey('Digital Envoy')){
                //record.Supplier_Gross_Earnings_Retrospective__c  = mapOfAdjustmentTypes.get('Digital Envoy').Amount__c * monthlyEarningsPercentage;
                //record.Digital_Envoy_Adjustment_USD_NEW__c  = (mapOfAdjustmentTypes.get('Digital Envoy').Month_Revenue_Percent__c / 100) * newCalculation;
            	record.Digital_Envoy_Adjustment_USD_NEW__c  = mapOfAdjustmentTypes.get('Digital Envoy').Amount__c * monthlyEarningsPercentage;
            }
            
            if(mapOfAdjustmentTypes.containsKey('ID Graph')){
                //record.ID_Graph_Adjustment_USD__c = mapOfAdjustmentTypes.get('ID Graph').Amount__c * monthlyEarningsPercentage;
                //record.ID_Graph_Adjustment_USD_NEW__c = (mapOfAdjustmentTypes.get('ID Graph').Month_Revenue_Percent__c / 100) * newCalculation;
            	record.ID_Graph_Adjustment_USD_NEW__c = mapOfAdjustmentTypes.get('ID Graph').Amount__c * monthlyEarningsPercentage;
            }

            if(mapOfAdjustmentTypes.containsKey('ShareThis')){
                //record.ShareThis_Adjustment_USD__c = mapOfAdjustmentTypes.get('ShareThis').Amount__c * monthlyEarningsPercentage;
                //record.ShareThis_Adjustment_USD_NEW__c = (mapOfAdjustmentTypes.get('ShareThis').Month_Revenue_Percent__c / 100) * newCalculation;
            	record.ShareThis_Adjustment_USD_NEW__c = mapOfAdjustmentTypes.get('ShareThis').Amount__c * monthlyEarningsPercentage;
            }

            if(mapOfAdjustmentTypes.containsKey('TapAd')){
                //record.TapAd_Adjustment_USD__c = mapOfAdjustmentTypes.get('TapAd').Amount__c * monthlyEarningsPercentage;
                //record.TapAd_Adjustment_USD_NEW__c = (mapOfAdjustmentTypes.get('TapAd').Month_Revenue_Percent__c / 100) * newCalculation;
            	record.TapAd_Adjustment_USD_NEW__c = mapOfAdjustmentTypes.get('TapAd').Amount__c * monthlyEarningsPercentage;
            }

            if(mapOfAdjustmentTypes.containsKey('Tech Cost')){
                //record.Tech_Cost_Adjustment_USD__c = mapOfAdjustmentTypes.get('Tech Cost').Amount__c * monthlyEarningsPercentage;
                //record.Tech_Cost_Adjustment_USD_NEW__c = (mapOfAdjustmentTypes.get('Tech Cost').Month_Revenue_Percent__c / 100) * newCalculation;
            	record.Tech_Cost_Adjustment_USD_NEW__c = mapOfAdjustmentTypes.get('Tech Cost').Amount__c * monthlyEarningsPercentage;
            }
			
            /*
            if(mapOfAdjustmentTypes.containsKey('Other')){
                record.ComScore_Adjustment_USD__c = mapOfAdjustmentTypes.get('Other').Amount__c * monthlyEarningsPercentage;
            }
			*/

            if(mapOfAdjustmentTypes.containsKey('Other 1')){
                //record.Other_1_Adjustment_USD_NEW__c = (mapOfAdjustmentTypes.get('Other 1').Month_Revenue_Percent__c / 100) * newCalculation;
            	record.Other_1_Adjustment_USD_NEW__c = mapOfAdjustmentTypes.get('Other 1').Amount__c * monthlyEarningsPercentage;
            }

            if(mapOfAdjustmentTypes.containsKey('Other 2')){
                //record.Other_2_Adjustment_USD_NEW__c = (mapOfAdjustmentTypes.get('Other 2').Month_Revenue_Percent__c / 100) * newCalculation;
                record.Other_2_Adjustment_USD_NEW__c = mapOfAdjustmentTypes.get('Other 2').Amount__c * monthlyEarningsPercentage;
            }
        }
        
        System.debug('records records records' + records);
        update records;
    }   

    global void finish(Database.BatchableContext bc){
        //Finish
    }    
}