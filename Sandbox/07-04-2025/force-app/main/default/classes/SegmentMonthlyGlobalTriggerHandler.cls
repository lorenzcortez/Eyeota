public class SegmentMonthlyGlobalTriggerHandler {
    
    public static void onBeforeInsertUpdate(List<Segment_Monthly_Global__c> smgList) {
        
        Set<String> segmentReachList = new Set<String>();
        Set<String> segmentRawList = new Set<String>();
        Map<String,Segment_Category_Mapping__c> msmMap = new Map<String,Segment_Category_Mapping__c>();
        Map<String,Segment_Mapping__c> segMap = new map<String,Segment_Mapping__c>();
        Map<String,String> mapSegMapSegCats = new Map<String,String>(); 

        Date tempOctDt = Date.newInstance(2016, 10, 01);

        for(Segment_Monthly_Global__c smg : smgList) {
            
            System.debug('tempOctDt---@@'+tempOctDt);
            //  If Date < 1/10/2016
            if(String.isNotBlank(smg.Segment_Name_Supply_Raw__c) && smg.Date__c < tempOctDt) {
                smg.Segment_Name_Supply_Raw__c = smg.Segment_Name_Supply_Raw_Original__c.toUpperCase();
                segmentReachList.add(smg.Segment_Name_Supply_Raw__c);
            }
            //IF Date >= 1/10/2016 
            else if(String.isNotBlank(smg.Segment_Key_Raw__c) && smg.Date__c >= tempOctDt){
                smg.Segment_Name_Supply_Raw__c = smg.Segment_Key_Raw__c;
                segmentReachList.add(smg.Segment_Key_Raw__c);            
            }
        }  
        // End..Create Segment Name or Segment Key Maps based on Date Range - < or >= 10th Oct 2016.....
        System.debug('segmentReachList----@@'+segmentReachList);
        // Start..Create Segment Mapping and Category Mapping Master records Maps based on the available input records......
        for(Segment_Mapping__c sm : [SELECT Id,
                                            Segment_Name__c,
                                            Segment_Name_Supply_Raw__c FROM Segment_Mapping__c 
                                            WHERE Segment_Name_Supply_Raw__c IN : segmentReachList]) {
            segMap.put(sm.Segment_Name_Supply_Raw__c,sm);
            segmentRawList.add(sm.Segment_Name__c);
            mapSegMapSegCats.put(sm.Segment_Name_Supply_Raw__c,sm.Segment_Name__c);
        }  
        
        for(Segment_Category_Mapping__c msm : [SELECT Id,
                                                        Name,
                                                        Segment_Name__c FROM Segment_Category_Mapping__c 
                                                        WHERE Segment_Name__c IN : segmentRawList]){
            msmMap.put(msm.Segment_Name__c,msm);
        }
        // End..Create Segment Mapping and Category Mapping Master records Maps based on the available input records......

        // Start Populate the Segment Mapping and Category Mapping Lookups into the Segment Monthly Global Records..
        for(Segment_Monthly_Global__c smg : smgList) {
            if(!segMap.isEmpty() && segMap.containsKey(smg.Segment_Name_Supply_Raw__c)) {
                //  If Date < 1/10/2016
                if(smg.Segment_Name_Supply_Raw__c != null && smg.Segment_Name_Supply_Raw__c != '' && 
                segMap.get(smg.Segment_Name_Supply_Raw__c) != null && smg.Date__c < tempOctDt) {
                    smg.Segment_Mapping__c = segMap.get(smg.Segment_Name_Supply_Raw__c).Id; 
                    String segName = mapSegMapSegCats.get(smg.Segment_Name_Supply_Raw__c);
                    smg.Segment_Category_Mapping__c = msmMap.get(segName).Id;    
                }
                //IF Date >= 1/10/2016
                else if(String.isNotBlank(smg.Segment_Key_Raw__c) && segMap.get(smg.Segment_Key_Raw__c) != null && smg.Date__c >= tempOctDt){
                    smg.Segment_Mapping__c = segMap.get(smg.Segment_Key_Raw__c).Id; 
                    String segName = mapSegMapSegCats.get(smg.Segment_Key_Raw__c);
                    smg.Segment_Category_Mapping__c = msmMap.get(segName) != null ? msmMap.get(segName).Id : null; 
                }
            }
        }
    }

    public static void onAfterInsertUpdate(Map<Id, Segment_Monthly_Global__c> newMap, Map<Id, Segment_Monthly_Global__c> oldMap) {
        
        if(!TriggerUtility.inFutureContext1) {
            
            //Set<String> segmentName = new Set<String>();
            Set<Date> month = new Set<Date>();
            Set<String> setSegCats = new Set<String>();

            List<Segment_Monthly_Global__c> dsl2Update = new List<Segment_Monthly_Global__c>(); 
            
            Map<String, List<Sales_Database__c>> salesDatabaseMap = new Map<String, List<Sales_Database__c>>();

            for(Segment_Monthly_Global__c smg2 : newMap.values()){
                /*if(smg2.Segment_Name__c != null) {
                    segmentName.add(smg2.Segment_Name__c);
                }*/
                if(smg2.Date__c != null) {
                    month.add(smg2.Date__c);
                }
                if(smg2.Segment_Category_Mapping__c != null) {
                    setSegCats.add(smg2.Segment_Category_Mapping__c); 
                }
            }        
                     
            //Query all possible matching Sales Database Records. 
            System.debug('setSegCats---@@'+setSegCats);
            System.debug('month---@@'+month);

            for(Sales_Database__c sd : [SELECT Id,
                                                Name,
                                                Target_Country_Raw__c,
                                                Segment_Name__c,
                                                Revenue__c,
                                                Date__c,
                                                Segment_Category_Mapping__c 
                                                FROM Sales_Database__c 
                                                WHERE Segment_Category_Mapping__c IN:setSegCats 
                                                AND Date__c IN: month 
                                                AND IsDeleted = false]) {

                if(sd.Segment_Category_Mapping__c != null) {                                    
                    if(!salesDatabaseMap.containsKey(sd.Segment_Category_Mapping__c)) {
                        salesDatabaseMap.put(sd.Segment_Category_Mapping__c, new List<Sales_Database__c>{sd});
                    }
                    else {
                        salesDatabaseMap.get(sd.Segment_Category_Mapping__c).add(sd);
                    }
                }
            }

            //Start Loop all incoming Segment Monthly Global records and loop through the relevant Sales Database records and aggregate Revenue and stamp.                                             
            for(Segment_Monthly_Global__c pm : [SELECT Id,
                                                        Segment_Name__c,
                                                        Date__c,
                                                        Country_Raw__c,
                                                        Revenue__c,
                                                        Segment_Category_Mapping__c 
                                                        FROM Segment_Monthly_Global__c 
                                                        WHERE Id IN: newMap.keyset()]) { 
                Double revenues = 0.0;

                if(!salesDatabaseMap.isEmpty() && salesDatabaseMap.containsKey(pm.Segment_Category_Mapping__c)) {
                    for(Sales_Database__c sd : salesDatabaseMap.get(pm.Segment_Category_Mapping__c)) {
                        if('Global'.equalsignorecase(pm.Country_Raw__c) || pm.Country_Raw__c == '' || pm.Country_Raw__c == null) {
                            if(pm.Date__c == sd.Date__c) {
                                revenues += sd.Revenue__c != null?sd.Revenue__c:0.0;                        
                            }
                        }
                        else {
                            if(pm.Date__c == sd.Date__c && pm.Country_Raw__c == sd.Target_Country_Raw__c) { 
                                revenues += sd.Revenue__c != null?sd.Revenue__c:0.0;                        
                            }
                        }
                    }
                    pm.Revenue__c = revenues;
                    dsl2Update.add(pm);
                }
            }
             //End Loop all incoming Segment Monthly Global records and loop through the relevant Sales Database records and aggregate Revenue and stamp
    
            TriggerUtility.inFutureContext1 = true;
            if(!dsl2Update.isEmpty()) update dsl2Update;     // Update all the inserted and updated SMG records. 
        }
    }
}