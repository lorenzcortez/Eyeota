public class AudienceReportTriggerHandler {

    public static void onBeforeInsertUpdate(List<Audience_Report__c> audienceReportList) {

        //Create Sets of all values to be mapped
        Set<String> SegmentKeys = new Set<String>();
        Set<String> Countries = new Set<String>();
        Set<String> DataSupplierRaw = new Set<String>();

        //Create Lists of all mapping keys
        Map<String,Segment_Category_Mapping__c> mastersheet = new Map<String,Segment_Category_Mapping__c>();
        Map<String,Country__c> mastercountries = new Map<String,Country__c>();
        Map<String,Data_Supplier_Mapping__c> masterdatasuppliers = new Map<String,Data_Supplier_Mapping__c>();

        for(Audience_Report__c audiencereport : audienceReportList) {
            if(audiencereport.Segment_Key__c != ''){
                SegmentKeys.add(audiencereport.Segment_Key__c);
            }
            if(audiencereport.Country_Raw__c != ''){
                Countries.add(audiencereport.Country_Raw__c);
            }
            if(audiencereport.Data_Supplier_Raw_Original__c != ''){
                audiencereport.Data_Supplier_RAW_UPPER__c = audiencereport.Data_Supplier_Raw_Original__c.toUpperCase().trim();
                DataSupplierRaw.add(audiencereport.Data_Supplier_RAW_UPPER__c);
            }
        }

        for(Segment_Category_Mapping__c objSegmentCM : [Select Id, 
                                                                Segment_Name__c, 
                                                                Segment_Code__c, 
                                                                Segment_Description__c, 
                                                                Keywords__c FROM Segment_Category_Mapping__c 
                                                                WHERE Segment_Code__c IN :SegmentKeys]){
            mastersheet.put(objSegmentCM.Segment_Code__c, objSegmentCM);
        }

        for(Country__c objCountry : [Select Id, 
                                            Master_Geography_Code__c, 
                                            Name FROM Country__c 
                                            WHERE Master_Geography_Code__c IN :Countries]) {
            mastercountries.put(objCountry.Master_Geography_Code__c,objCountry);
        }

        for(Data_Supplier_Mapping__c objdatasuppliermappings : [Select Id, 
                                                                        Data_Supplier_Account__c,
                                                                        Data_Supplier_Raw__c FROM Data_Supplier_Mapping__c 
                                                                        WHERE Data_Supplier_Raw__c IN : DataSupplierRaw]) {
            masterdatasuppliers.put(objdatasuppliermappings.Data_Supplier_Raw__c, objdatasuppliermappings);
        }

        for(Audience_Report__c audiencereport : audienceReportList) {
            
            if(audiencereport.Segment_Key__c!=null && audiencereport.Segment_Key__c!= '' && 
            (!mastersheet.isEmpty() && mastersheet.containsKey(audiencereport.Segment_Key__c))) {
                audiencereport.Segment_Name__c = mastersheet.get(audiencereport.Segment_Key__c)?.Id;
                audiencereport.Segment_Description__c = mastersheet.get(audiencereport.Segment_Key__c)?.Segment_Description__c;
                audiencereport.Keywords__c = mastersheet.get(audiencereport.Segment_Key__c)?.Keywords__c;
                audiencereport.Segment_Error__c = null;
            }
            else {
                audiencereport.Segment_Error__c = 'Error: Segment Category Mapping not found.';
                audiencereport.Segment_Name__c = null;
                audiencereport.Segment_Description__c = null;
                audiencereport.Keywords__c = null;
            }

            if (audiencereport.Country_Raw__c != null && audiencereport.Country_Raw__c != '' && 
                (!mastercountries.isEmpty() && mastercountries.containsKey(audiencereport.Country_Raw__c))) {
                    audiencereport.Country__c = mastercountries.get(audiencereport.Country_Raw__c)?.Id;
                    audiencereport.Country_Error__c = null;
            }
            else {
                audiencereport.Country_Error__c = 'Error: Country mapping not found.';
                audiencereport.Country__c = null;
            }

            if(audiencereport.Data_Supplier_Raw_Original__c != null && audiencereport.Data_Supplier_Raw_Original__c != '' && 
                (!masterdatasuppliers.isEmpty() && masterdatasuppliers.containsKey(audiencereport.Data_Supplier_RAW_UPPER__c))) {
                audiencereport.Data_Supplier__c = masterdatasuppliers.get(audiencereport.Data_Supplier_RAW_UPPER__c).Data_Supplier_Account__c;
                audiencereport.Data_Supplier_Error__c = null;
            }
            else {
                audiencereport.Data_Supplier_Error__c = 'Error: Data Supplier Mapping not found.';
                audiencereport.Data_Supplier__c = null;
            }
        }
    }
}