public with sharing class CreateAdjustment {
    public static void createAdjustment(){
        DateTime today = System.now().addMonths(1);

        Adjustment__c adjustment = new Adjustment__c(
            Month__c = today.format('MMMM'),
            Year__c = String.valueOf(today.year())
        );
        
        insert adjustment;
    }
}