public with sharing class AdjustmentController {
    public static void createAdjustment(){
        DateTime today = System.now().addMonths(1);

        Adjustment__c adjustment = new Adjustment__c(
            Month__c = today.format('MMMM'),
            Year__c = String.valueOf(today.year())
        );
        
        insert adjustment;
    }

    @AuraEnabled
    public static string createAdjustmentAndTypes(String month, String year){
        try {
            List<Adjustment__c> adjustments = [SELECT Id, (SELECT Amount__c, Type__c, CurrencyIsoCode FROM Adjustment_Types__r) FROM Adjustment__c ORDER BY CreatedDate DESC LIMIT 1];

            Adjustment__c newAdjustment = new Adjustment__c(
                Month__c = month,
                Year__c = year
            );
            
            insert newAdjustment;

            List<Adjustment_Type__c> adjustmentTypes = new List<Adjustment_Type__c>();

            System.debug( 'adjustments adjustments' + adjustments);


            if(adjustments.size() > 0){
                for(Adjustment__c adjustment : adjustments){
                    System.debug( 'adjustmentadjustment.Adjustment_Types__r' + adjustment.Adjustment_Types__r);
                    if(adjustment.Adjustment_Types__r.size() > 0 ){
                        for( Adjustment_Type__c adjustmentType : adjustment.Adjustment_Types__r ){

                            Adjustment_Type__c newAdjustmentType  = adjustmentType.clone(false, false, false, false);
                            newAdjustmentType.Adjustment__c = newAdjustment.Id;

                            System.debug( 'newAdjustmentType newAdjustmentType' + newAdjustmentType);

                            adjustmentTypes.add(newAdjustmentType);
                        }
                    }
                }
            }

            System.debug('adjustmentTypes adjustmentTypes adjustmentTypes' + adjustmentTypes);

            if(adjustmentTypes.size() > 0){
                insert adjustmentTypes;
            }

            return newAdjustment.Id;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}