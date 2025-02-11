public class CountryMonthlyGlobalTriggerHandler {
    
    public static void onBeforeInsertUpdate(List<Country_Monthly_Global__c> countryMonthlyList) {
        
        Set<String> cmgCountryCodes = new Set<String>();
        //Set<String> cmgCountryCodes2 = new Set<String>();
        //Set<String> countryLookup = new Set<String>();
        //Set<Date> cmgDate = new Set<Date>();
        Set<Date> cmgDate1 = new Set<Date>();
        Map<String, Country__c> countryMap = new Map<String, Country__c>();

        for(Country_Monthly_Global__c cmg : countryMonthlyList) {
            if(cmg.Country_Name__c != null && cmg.Country_Name__c != '') {
                cmgCountryCodes.add(cmg.Country_Name__c);
            }
            if(cmg.Date__c != null) {
                cmgDate1.add(cmg.Date__c);                
            }
        }
        System.debug('cmgCountryCodes-------->'+cmgCountryCodes);
        for(Country__c c:[SELECT Id, Name, Country_Code_2__c FROM Country__c WHERE Name IN : cmgCountryCodes]) {
            countryMap.put(c.Name.toUpperCase() , c);
        }

        for(Country_Monthly_Global__c cmg : countryMonthlyList) {
            if(cmg.Country_Name__c != null && cmg.Country_Name__c != '' && 
            (!countryMap.isEmpty() && countryMap.containsKey(cmg.Country_Name__c.toUpperCase()))) {
                
                cmg.Country__c = countryMap.get(cmg.Country_Name__c.toUpperCase())?.Id;
                cmg.Master_Geography_Code__c = countryMap.get(cmg.Country_Name__c.toUpperCase())?.Country_Code_2__c;
     
                //Commented this out because it doesn't do anything - June 13 2024
                /*if(cmg1.Date__c != null){
                    cmgDate.add(cmg1.Date__c);
                }
                System.debug('cmg1.country----@@'+cmg1.Country__c);
                if(cmg1.Country__c != null){
                    countryLookup.add(cmg1.Country__c);
                }
                System.debug('cmg1.Master_Geography_Code__c----@@'+cmg1.Master_Geography_Code__c);
                if(cmg1.Master_Geography_Code__c != null && cmg1.Master_Geography_Code__c!= ''){
                    cmgCountryCodes2.add(cmg1.Master_Geography_Code__c);
                }*/          
            }
        }
    }
}