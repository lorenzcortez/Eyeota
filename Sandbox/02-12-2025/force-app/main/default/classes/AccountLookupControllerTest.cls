/*
    Name     : AccountLookupControllerTest
    Date     : 15 March, 2016
    Author   : 
    Description : this test class use for testing to the account lookup page which is used into dashboard mapping class
*/

@isTest
public class AccountLookupControllerTest{
    @isTest
    private static void testUnit(){
       id rcTypeId = [select id from recordType where sobjectType='account' and developername = 'Buyer_Holding_Group' limit 1].id;
       system.assertNotEquals(rcTypeId,null); 
        account acc = new account(name='test acc', recordTypeId = rcTypeId);
        insert acc;
        //---------------------------Edited on 8/8/2017 to made corrections------------
        //-----------------------Edited by Mohd Anas------------------------
        AccountLookupController accLookupObj = new AccountLookupController();
        
        Test.setCurrentPageReference(new PageReference('Page.AccountLookup')); 
		System.currentPageReference().getParameters().put('srchTxt','%abcxyz');   
        
        AccountLookupController accLookupObj1 = new AccountLookupController();
        
        Test.setCurrentPageReference(new PageReference('Page.AccountLookup')); 
		System.currentPageReference().getParameters().put('srchTxt','abcxyz');   
        
        AccountLookupController accLookupObj2 = new AccountLookupController();
        
        
        //accLookupObj.filterText='abc*x%yz';
		 
}
}