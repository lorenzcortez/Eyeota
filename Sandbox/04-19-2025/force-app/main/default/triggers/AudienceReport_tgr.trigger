trigger AudienceReport_tgr on Audience_Report__c (before insert, before update) {

    //Create Sets of all values to be mapped

    Set<String> SegmentKeys = new Set<String>();
    Set<String> Countries = new Set<String>();
    Set<String> DataSupplierRaw = new Set<String>();

    //Variable declaration
    for (Audience_Report__c audiencereport : Trigger.new){
        if(audiencereport.Segment_Key__c!=''){
            SegmentKeys.add(audiencereport.Segment_Key__c);
        }
        if(audiencereport.Country_Raw__c!=''){
            Countries.add(audiencereport.Country_Raw__c);
        }
        if(audiencereport.Data_Supplier_Raw_Original__c!=''){
            audiencereport.Data_Supplier_RAW_UPPER__c=audiencereport.Data_Supplier_Raw_Original__c.toUpperCase().trim();
            DataSupplierRaw.add(audiencereport.Data_Supplier_RAW_UPPER__c);
        }
    }
     
    //Create Lists of all mapping keys
    Map<String,Segment_Category_Mapping__c> mastersheet = new Map<String,Segment_Category_Mapping__c>();
    Map<String,Country__c> mastercountries = new Map<String,Country__c>();
    Map<String,Data_Supplier_Mapping__c> masterdatasuppliers = new Map<String,Data_Supplier_Mapping__c>();
    
    Set<String> SegmentKeysfromSCM = new Set<String>();
    Set<String> CountryCodesfromCountries = new Set<String>();
    Set<String> DataSupplierRawfromKey = new Set<String>();
    
    List<Segment_Category_Mapping__c> lstSegmentCM = [Select Id, Segment_Name__c, Segment_Code__c, Segment_Description__c, Keywords__c FROM Segment_Category_Mapping__c WHERE Segment_Code__c IN :SegmentKeys];
    List<Country__c> lstCountries = [Select Id, Master_Geography_Code__c, Name FROM Country__c WHERE Master_Geography_Code__c IN :Countries];
    List<Data_Supplier_Mapping__c> lstDataSupplierMapping = [Select Id, Data_Supplier_Account__c,Data_Supplier_Raw__c FROM Data_Supplier_Mapping__c WHERE Data_Supplier_Raw__c IN : DataSupplierRaw];

    for(Segment_Category_Mapping__c objSegmentCM : lstSegmentCM){
        mastersheet.put(objSegmentCM.Segment_Code__c, objSegmentCM);
        SegmentKeysfromSCM.add(objSegmentCM.Segment_Code__c);
    }
    for(Country__c objCountry : lstCountries) {
        mastercountries.put(objCountry.Master_Geography_Code__c,objCountry);
        CountryCodesfromCountries.add(objCountry.Master_Geography_Code__c);
    }
    for(Data_Supplier_Mapping__c objdatasuppliermappings : lstDataSupplierMapping) {
        masterdatasuppliers.put(objdatasuppliermappings.Data_Supplier_Raw__c, objdatasuppliermappings);
        DataSupplierRawfromKey.add(objdatasuppliermappings.Data_Supplier_Raw__c);
    }
    
    

    //Map values
    for (Audience_Report__c audiencereport : Trigger.new){
    {
    if(audiencereport.Segment_Key__c!=null&&audiencereport.Segment_Key__c!=''&&SegmentKeysfromSCM.contains(audiencereport.Segment_Key__c)){
    audiencereport.Segment_Name__c=mastersheet.get(audiencereport.Segment_Key__c).Id;
    audiencereport.Segment_Description__c=mastersheet.get(audiencereport.Segment_Key__c).Segment_Description__c;
    audiencereport.Keywords__c=mastersheet.get(audiencereport.Segment_Key__c).Keywords__c;
    audiencereport.Segment_Error__c=null;}
    else {audiencereport.Segment_Error__c='Error: Segment Category Mapping not found.';
    audiencereport.Segment_Name__c=null;
    audiencereport.Segment_Description__c=null;
    audiencereport.Keywords__c=null;}
    }
    {
    if (audiencereport.Country_Raw__c!=null&&audiencereport.Country_Raw__c!=''&&CountryCodesfromCountries.contains(audiencereport.Country_Raw__c)){
    audiencereport.Country__c=mastercountries.get(audiencereport.Country_Raw__c).Id;
    audiencereport.Country_Error__c=null;}
    else {audiencereport.Country_Error__c='Error: Country mapping not found.';
    audiencereport.Country__c=null;}
    }
    {
    if(audiencereport.Data_Supplier_Raw_Original__c!=null&&audiencereport.Data_Supplier_Raw_Original__c!=''&&DataSupplierRawfromKey.contains(audiencereport.Data_Supplier_RAW_UPPER__c)){
    audiencereport.Data_Supplier__c=masterdatasuppliers.get(audiencereport.Data_Supplier_RAW_UPPER__c).Data_Supplier_Account__c;
    audiencereport.Data_Supplier_Error__c=null;}
    else {audiencereport.Data_Supplier_Error__c='Error: Data Supplier Mapping not found.';
    audiencereport.Data_Supplier__c=null;}
    }
    }
        
    
}