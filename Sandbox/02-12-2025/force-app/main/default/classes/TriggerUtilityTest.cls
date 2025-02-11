@isTest
public class TriggerUtilityTest {
    Static testmethod void TriggerUtilityTest(){
        Account acc=new Account();
        acc.Name='Heritage';
        acc.Region__c='EMEA';
        acc.Account_Type__c='Employee';
        acc.New_Flag__c=true;
        insert acc;
        Segment_Category_Mapping__c scm=new Segment_Category_Mapping__c();
        scm.Segment_Category_Picklist__c='Custom';
        scm.Segment_Code__c='1234';
        insert scm;
        Segment_Revenue_Transaction__c st = new Segment_Revenue_Transaction__c();
        st.Date__c = date.today();
        st.Country_Code__c = 'test code';
        st.Segment_Category_Mapping__c = scm.Id;
        insert st;
        
        TriggerUtility obj=new TriggerUtility();
        TriggerUtility.toCreateSG(date.today(), 'India', scm.Name);
        TriggerUtility.toCreateAccount('testacc', 'mobile');
    }
}