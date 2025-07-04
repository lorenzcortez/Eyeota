@isTest
private class CMG_Revenue_Calculater_Sch_Test {
    
    static testMethod void myUnitTest() {
        Test.startTest();
        
        String jobId = System.schedule('CMG_Revenue_Calculater_Sch_Test',
                                       '0 0 0 3 9 ? 2022', new CMG_Revenue_Calculater_Sch()); 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals('0 0 0 3 9 ? 2022', ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered); 
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
    
}