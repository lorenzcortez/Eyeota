public class AdvertiserMappingTriggerHandler {

    public static void onBeforeInsertUpdate(List<Advertiser_Mapping__c> advMappingList) {

        Set<String> AdvNames = new Set<String>();
        Map<String,Account> AdvertiserAccountName = new Map<String,Account>(); 

        for(Advertiser_Mapping__c AdvMapping : advMappingList) {

            if(String.isNotBlank(AdvMapping.Advertiser_Name__c)) {
                AdvNames.add(AdvMapping.Advertiser_Name__c);
            }
        }

        if(!AdvNames.isEmpty()) {
            
            for(Account objAccount : [Select ID,Name FROM Account WHERE Name IN : AdvNames AND RecordType.Name='Advertiser']) {
                AdvertiserAccountName.put(objAccount.Name, objAccount);
            }  

            for(Advertiser_Mapping__c AdvMapping : advMappingList) {

                if(String.isNotBlank(AdvMapping.Advertiser_Name__c) && 
                (!AdvertiserAccountName.isEmpty() && AdvertiserAccountName.containsKey(AdvMapping.Advertiser_Name__c)) && 
                AdvMapping.Advertiser_Account__c == null) {
                    AdvMapping.Advertiser_Account__c = AdvertiserAccountName.get(AdvMapping.Advertiser_Name__c)?.Id;
                    AdvMapping.Advertiser_Error__c = null;
                }
            }
        }
    }
}