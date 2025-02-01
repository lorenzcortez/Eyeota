public with sharing Class TriggerUtility{

    public static boolean inFutureContext = false;
    public static boolean inFutureContext1 = false;
 
    public static Segment_Revenue_Transaction__c toCreateSG(Date objDate, String objCountry, String objSegmentCode){
    
        System.debug(' st.Country_Code__c  ' + objCountry );
        Segment_Revenue_Transaction__c st = new Segment_Revenue_Transaction__c();
        st.Date__c = objDate;
        st.Country_Code__c = objCountry;
        st.Segment_Category_Mapping__c = objSegmentCode;
        return st; 
    }
    
    public static Account toCreateAccount(String accName,String accountType){
        Account acc = new Account();
        acc.Name = accName;
        acc.Account_Type__c = accountType;
        acc.New_Flag__c = true;
        return acc;
    }    
}