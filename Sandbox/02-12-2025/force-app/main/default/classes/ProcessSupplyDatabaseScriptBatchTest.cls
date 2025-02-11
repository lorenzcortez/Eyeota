@isTest
public class ProcessSupplyDatabaseScriptBatchTest {
    static testmethod void testMethod1(){
        Supply_Database__c sd=new Supply_Database__c();
        sd.Date__c=date.today();
        insert sd;
        ProcessSupplyDatabaseScriptBatch obj=new ProcessSupplyDatabaseScriptBatch(date.today(),'test obj');
        test.startTest();
        DataBase.executeBatch(obj);
        test.stopTest();
    }
}