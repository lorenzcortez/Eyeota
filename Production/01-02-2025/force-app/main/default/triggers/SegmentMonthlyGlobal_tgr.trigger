/*
Object Name      : Segment Monthly Global Trigger
Purpose          : To map Raw Fields to Mapped Segment Master Records and 
                    to calculate the total revenue in Sales Database against the Segment , Date and Country combination
Created By       : Mohammad Usman / TechMatrix Consulting Pte Ltd. 
Modified By      : Antony Jerald / TechMatrix Consulting Pte Ltd.
Last Modified Date    : 30th May 2017
Last Modified Purpose : Adding Documentation, Removing debug statements for better readability.  
*
*/

trigger SegmentMonthlyGlobal_tgr on Segment_Monthly_Global__c (before insert, before update,after insert, after update) {

    set<String> segmentReachList = new set<String>();
    set<String> segmentRawList = new set<String>();
    map<String,Segment_Category_Mapping__c> msmMap = new map<String,Segment_Category_Mapping__c>();
    set<String> segmentName = new set<String>();
    map<string,Segment_Mapping__c> segMap = new map<String,Segment_Mapping__c>();
    map<String,String> mapSegMapSegCats = new map <String,String>(); 
    set<Date> month = new set<Date>();
    set<String> setSegCats = new Set<String>(); 
    list<Segment_Monthly_Global__c> dsl2Update = new list<Segment_Monthly_Global__c>();    

if((trigger.isBefore && trigger.isInsert) || (trigger.isBefore && trigger.isUpdate)){

    // Start..Create Segment Name or Segment Key Maps based on Date Range - < or >= 10th Oct 2016.....
    for(Segment_Monthly_Global__c smg:trigger.new){        
        
        Date tempOctDt = Date.newInstance(2016, 10, 01);
        System.debug('tempOctDt---@@'+tempOctDt);
        //  If Date < 1/10/2016
        if(String.isNotBlank(smg.Segment_Name_Supply_Raw__c) && smg.Date__c < tempOctDt){
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
    for(Segment_Mapping__c sm:[SELECT Id,Segment_Name__c,Segment_Name_Supply_Raw__c FROM Segment_Mapping__c WHERE Segment_Name_Supply_Raw__c IN:segmentReachList]){
        segMap.put(sm.Segment_Name_Supply_Raw__c,sm);
        segmentRawList.add(sm.Segment_Name__c);
        mapSegMapSegCats.put(sm.Segment_Name_Supply_Raw__c,sm.Segment_Name__c);
    }  
    
    for(Segment_Category_Mapping__c msm:[SELECT Id,Name,Segment_Name__c FROM Segment_Category_Mapping__c WHERE Segment_Name__c IN:segmentRawList]){
        msmMap.put(msm.Segment_Name__c,msm);
    }
    // End..Create Segment Mapping and Category Mapping Master records Maps based on the available input records......


    // Start .. Populate the Segment Mapping and Category Mapping Lookups into the Segment Monthly Global Records..
    for(Segment_Monthly_Global__c smg:trigger.new){
        Date tempOctDt = Date.newInstance(2016, 10, 01);
        //  If Date < 1/10/2016
        if(smg.Segment_Name_Supply_Raw__c != null && smg.Segment_Name_Supply_Raw__c != '' && segMap.get(smg.Segment_Name_Supply_Raw__c) != null && smg.Date__c < tempOctDt){
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
    // End .. Populate the Segment Mapping and Category Mapping Lookups into the Segment Monthly Global Records..

} // End Trigger - Before Insert & Update

// Start .. After Trigger to calculate Revenue from Matching Sales DB Records .. in Future Context for Performance Reasons..
if(!TriggerUtility.inFutureContext1 && ((trigger.isAfter && trigger.isInsert) || (trigger.isAfter && trigger.isUpdate))){
        
        // Create Maps to Bulk Query corresponding Sales Database Records.
        for(Segment_Monthly_Global__c smg2:trigger.new){
            if(smg2.Segment_Name__c != null){
                segmentName.add(smg2.Segment_Name__c);
            }
            if(smg2.Date__c != null){
                month.add(smg2.Date__c);
            }
            if(smg2.Segment_Category_Mapping__c != null ){
                setSegCats.add(smg2.Segment_Category_Mapping__c); 
            }
        }        

                 
        //Query all possible matching Sales Database Records. 
        list<Sales_Database__c> objSD = [SELECT id,Name,Target_Country_Raw__c,Segment_Name__c,Revenue__c,Date__c, Segment_Category_Mapping__c FROM Sales_Database__c 
                                        WHERE Segment_Category_Mapping__c IN:setSegCats  AND 
                                        Date__c IN: month AND IsDeleted=false];  
		System.debug('setSegCats---@@'+setSegCats);
		System.debug('objSD----@@'+objSD);
    	System.debug('month---@@'+month);
        //.. Start Loop all incoming Segment Monthly Global records and loop through the relevant Sales Database records and aggregate Revenue and stamp.                                 
        list<Segment_Monthly_Global__c> dsl = [SELECT id,Segment_Name__c,Date__c,Country_Raw__c,Revenue__c, Segment_Category_Mapping__c FROM  Segment_Monthly_Global__c 
                                                WHERE ID IN: trigger.newMap.keyset()];                                 
        
        for(Segment_Monthly_Global__c pm:dsl){ 
            
            double revenues = 0.0;
            
            for(Sales_Database__c sd:objSD){             

                if('Global'.equalsignorecase(pm.Country_Raw__c) || pm.Country_Raw__c == '' || pm.Country_Raw__c == null){
                    if(pm.Segment_Category_Mapping__c == sd.Segment_Category_Mapping__c && pm.Date__c == sd.Date__c){
                        revenues += sd.Revenue__c != null?sd.Revenue__c:0.0;                        
                    }
                }else{
                    if(pm.Segment_Category_Mapping__c == sd.Segment_Category_Mapping__c && pm.Date__c == sd.Date__c && pm.Country_Raw__c == sd.Target_Country_Raw__c){ 
                        revenues += sd.Revenue__c != null?sd.Revenue__c:0.0;                        
                    }
                }
            }
            pm.Revenue__c = revenues;
            dsl2Update.add(pm);
        }
         //.. End Loop all incoming Segment Monthly Global records and loop through the relevant Sales Database records and aggregate Revenue and stamp.   

        TriggerUtility.inFutureContext1 = true;
        if(!dsl2Update.isEmpty()) update dsl2Update;     // Update all the inserted and updated SMG records. 
    }

}