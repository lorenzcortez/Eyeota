/*
Object Name      : Country Monthly Global Trigger
Purpose          : To map Raw Fields to Country Master
Created By       : Mohammad Usman / TechMatrix Consulting Pte Ltd. 
Modified By      : Antony Jerald / TechMatrix Consulting Pte Ltd.
*/

trigger CountryMonthlyGlobal_tgr on Country_Monthly_Global__c (before insert, before update) {
    
    set<String> cmgCountryCodes = new set<String>();
    set<String> cmgCountryCodes2 = new set<String>();
    set<String> countryLookup = new set<String>();
    set<Date> cmgDate = new set<Date>();
    set<Date> cmgDate1 = new set<Date>();
    map<String,Country__c> countryMap = new map<String,Country__c>();

    for(Country_Monthly_Global__c cmg:Trigger.new){
            if(cmg.Country_Name__c != null && cmg.Country_Name__c!=''){
                cmgCountryCodes.add(cmg.Country_Name__c);
            }
            if(cmg.Date__c != null){
                cmgDate1.add(cmg.Date__c);                
            }            
    }
    System.debug('cmgCountryCodes-------->'+cmgCountryCodes);
    for(Country__c c:[SELECT Id,Name,Country_Code_2__c FROM Country__c WHERE Name IN:cmgCountryCodes]){
            countryMap.put(c.Name.toUpperCase() , c);
    }
    
    for(Country_Monthly_Global__c cmg1:Trigger.new){
     
            if(cmg1.Country_Name__c != null && cmg1.Country_Name__c != '' && countryMap.containsKey(cmg1.Country_Name__c.toUpperCase())){
                
                cmg1.Country__c = countryMap.get(cmg1.Country_Name__c.toUpperCase()).Id;
                cmg1.Master_Geography_Code__c = countryMap.get(cmg1.Country_Name__c.toUpperCase()).Country_Code_2__c;
     
                if(cmg1.Date__c != null){
                    cmgDate.add(cmg1.Date__c);
                }
     			System.debug('cmg1.country----@@'+cmg1.Country__c);
                if(cmg1.Country__c != null){
                    countryLookup.add(cmg1.Country__c);
                }
     			System.debug('cmg1.Master_Geography_Code__c----@@'+cmg1.Master_Geography_Code__c);
                if(cmg1.Master_Geography_Code__c != null && cmg1.Master_Geography_Code__c!= ''){
                    cmgCountryCodes2.add(cmg1.Master_Geography_Code__c);
                }                
            }
    }       
}