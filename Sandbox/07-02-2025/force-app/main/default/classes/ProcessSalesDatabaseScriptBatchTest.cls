@isTest
public class ProcessSalesDatabaseScriptBatchTest {
    
    static testmethod void test1(){
        Sales_Database__c sd=new Sales_Database__c();
        sd.Date__c=date.today();
        insert sd;
        
        Mapping_Dashboard_Emails__c mappDash = new Mapping_Dashboard_Emails__c(name='test1',Email_Address__c='test@gmail.com');
        insert mappDash;
        
        ProcessSalesDatabaseScriptBatch obj=new ProcessSalesDatabaseScriptBatch(date.today(),date.today(),'test');
        test.startTest();
            DataBase.executeBatch(obj);
        test.stopTest();
    }
    static testmethod void test2(){
        Sales_Database__c sd=new Sales_Database__c();
        sd.Date__c=date.today();
        insert sd;
        
        ProcessSalesDatabaseScriptBatch obj=new ProcessSalesDatabaseScriptBatch(null,date.today(),'test');
        test.startTest();
        DataBase.executeBatch(obj);
        test.stopTest();
    }
    static testmethod void test3(){
        Sales_Database__c sd=new Sales_Database__c();
        sd.Date__c=date.today();
        insert sd;
        
        ProcessSalesDatabaseScriptBatch obj=new ProcessSalesDatabaseScriptBatch(date.today(),null,'test');
        test.startTest();
        DataBase.executeBatch(obj);
        test.stopTest();
    }
}