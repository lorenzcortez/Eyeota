/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/

@isTest
private class CMG_Revenue_Calculater_btch_Test {
    static testMethod void myUnitTest() {     
        
        Country__c c = new Country__c();
        c.name='United States';
        insert c;    
        
        List<Country_Monthly_Global__c> cmgList=new List<Country_Monthly_Global__c>();
        Country_Monthly_Global__c con1 = new Country_Monthly_Global__c();
        con1.Country_Name__c= 'United States';
        con1.Country__c=c.id;
        con1.Revenue__c=20000;
        con1.Master_Geography_Code__c = 'US';
        con1.Date__c=date.today();
        //insert con1;  
        cmgList.add(con1);   
        
        Country_Monthly_Global__c con = new Country_Monthly_Global__c();
        con.Country_Name__c= 'United States';
        con.Country__c=c.id;
        con.Revenue__c=20000;
        con.Master_Geography_Code__c = 'ABC';
        
        con.Date__c=date.today();
        cmgList.add(con);  
        insert cmgList;     
        
        Sales_Database__c s = new Sales_Database__c();
        s.Target_Country_Raw__c=con.Master_Geography_Code__c;
        s.Segment_Name_Sales_Raw__c ='UniCode';
        s.Buyer_Country_Raw__c='abc';
        s.Buyer_Raw__c='Roger';
        s.Advertiser_Raw__c='JBL';
        s.Platform_Raw_Original__c='APPNEXUS';
        s.Revenue__c=16.42;
        s.Date__c=date.today();
        insert s;
            
        Test.StartTest();
        CMG_Revenue_Calculater_btch obj=new CMG_Revenue_Calculater_btch();
        obj.execute(null, cmgList);
        Database.executeBatch(obj);
        Test.StopTest(); 
        
        //System.AssertNotEquals(null,batchprocessid);
    }
}