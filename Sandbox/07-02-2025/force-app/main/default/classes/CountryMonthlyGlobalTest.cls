@isTest
public class CountryMonthlyGlobalTest
{
    static testmethod void myTest1(){
        
        country__c cont=new country__c();
        cont.name='India';
        insert cont;
        
        Country_Monthly_Global__c con = new Country_Monthly_Global__c();
        con.Country_Name__c= 'India';
        con.Date__c=date.today();
        con.Master_Geography_Code__c='ABC';
        con.Country__c=cont.Id;
        insert con;
        
        
        
    }
    /*static testmethod void CountryMonthlyGlobalTest(){
        try{
            Country_Monthly_Global__c con = new Country_Monthly_Global__c();
        con.Country_Name__c= 'India';
        insert con;}catch(Exception e){}
    }*/
}