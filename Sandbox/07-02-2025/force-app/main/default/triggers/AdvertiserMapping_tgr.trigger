trigger AdvertiserMapping_tgr on Advertiser_Mapping__c (before insert,before update) {
//Create Set of values to be mapped
Set<String> AdvNames = new Set<String>();
    
//Variable declaration
    for (Advertiser_Mapping__c AdvMapping : Trigger.new){
        if(AdvMapping.Advertiser_Name__c!=''){
            AdvNames.add(AdvMapping.Advertiser_Name__c);
        }
    }

//Create List of Mapping Keys
Map<String,Account> AdvertiserAccountName = new Map<String,Account>();
Set<String> AdvertiserNamefromAccount = new Set<String>();
List<Account> lstAdvertiserAccountName = [Select ID,Name FROM Account WHERE Name IN :AdvNames AND RecordType.Name='Advertiser'];    

    for(Account objAccount : lstAdvertiserAccountName){
        AdvertiserAccountName.put(objAccount.Name, objAccount);
        AdvertiserNamefromAccount.add(objAccount.Name);
    }    
    
//Map values
    for (Advertiser_Mapping__c AdvMapping : Trigger.new){
        if(AdvMapping.Advertiser_Name__c!=null&&AdvMapping.Advertiser_Name__c!=''&&AdvertiserNamefromAccount.contains(AdvMapping.Advertiser_Name__c)&&AdvMapping.Advertiser_Account__c==null){
            AdvMapping.Advertiser_Account__c=AdvertiserAccountName.get(AdvMapping.Advertiser_Name__c).Id;
            AdvMapping.Advertiser_Error__c=null;}
            
    }

}