global with sharing class SupplyDatabaseSegmentRevenueAssignment implements Database.Batchable <sObject>, Database.Stateful, Schedulable {
    public List<String> supplyDBIds {get; set;}
    
    global SupplyDatabaseSegmentRevenueAssignment(List<String> supplyDBIds) {
        this.supplyDBIds = supplyDBIds;
    }

    global Database.Querylocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Date__c, Segment_Name_Supply_Raw__c, Target_Country_Raw__c FROM Supply_Database__c WHERE Update_Segment_Revenue_Transaction__c = true';

        if( supplyDBIds.size() > 0 ){
            query += ' AND Id IN :supplyDBIds';
        }

        return Database.getQuerylocator(query);
    } 

    global void execute(Database.batchableContext bc, List<Supply_Database__c> supplyDatabases) {
        List<Segment_Revenue_Transaction__c> stToInsertList = new List<Segment_Revenue_Transaction__c>();

        Set<Date> sddate    = new Set<Date>();
        Set<String> country = new Set<String>();
        Set<String> sccode  = new Set<String>();
        Set<String> segMcodes = new Set<String>();
        Set<String> segRevTransaction = new Set<String>();

        Map<String,String> segMap = new Map<String,String>();
        Map<String,String> mapSegMapSegCats = new Map<String,String>();
        Map<String,String> mapSegCategories = new Map<String,String>();
        Map<String,String> segTrans = new Map<String,String>();

        String segmentName = null;

        for(Supply_Database__c supplyDatabase : supplyDatabases){
            if(supplyDatabase.Date__c != null){ 
                sddate.add(supplyDatabase.Date__c);
            }

            if(String.isNotEmpty(supplyDatabase.Target_Country_Raw__c)){
                supplyDatabase.Target_Country_Raw__c = supplyDatabase.Target_Country_Raw__c.toUpperCase();
                country.add(supplyDatabase.Target_Country_Raw__c);
            }

            segMcodes.add(supplyDatabase.Segment_Name_Supply_Raw__c);  
        }

        for(Segment_Mapping__c sm:[SELECT Id, Segment_Name__c , Segment_Name_Supply_Raw__c FROM Segment_Mapping__c WHERE Segment_Name_Supply_Raw__c IN:segMcodes]){  
            if(sm.Segment_Name__c != null && sm.Segment_Name__c != ''){
                segMap.put(sm.Segment_Name_Supply_Raw__c,sm.Id);
                mapSegMapSegCats.put(sm.Segment_Name_Supply_Raw__c,sm.Segment_Name__c);               
            }
        }

        for(Supply_Database__c supplyDatabase : supplyDatabases){
            if(String.isNotEmpty(supplyDatabase.Segment_Name_Supply_Raw__c) && segMap.containsKey(supplyDatabase.Segment_Name_Supply_Raw__c)){
                segmentName = mapSegMapSegCats.get(supplyDatabase.Segment_Name_Supply_Raw__c);
                sccode.add(mapSegCategories.get(segmentName)); 
                
            }
        }

        if(sddate != null && country != null && sccode != null){
            list<Segment_Revenue_Transaction__c> trx = [SELECT Id,Country_Code__c,Date__c,Segment_Category_Mapping__c FROM Segment_Revenue_Transaction__c WHERE Date__c IN:sddate AND Country_Code__c IN:country AND Segment_Category_Mapping__c IN:sccode ];
                                                                       
            for(Segment_Revenue_Transaction__c st12:trx){
                segTrans.put(st12.Country_Code__c+st12.Date__c+st12.Segment_Category_Mapping__c,st12.Id);                             
            }
        } 

        for(Supply_Database__c supplyDB : supplyDatabases){ 
            if(String.isNotEmpty(supplyDB.Segment_Name_Supply_Raw__c) && mapSegMapSegCats.get(supplyDB.Segment_Name_Supply_Raw__c) != null ) { 
                segmentName = mapSegMapSegCats.get(supplyDB.Segment_Name_Supply_Raw__c);
                supplyDB.Segment_Revenue_Transaction__c = segTrans.get(supplyDB.Target_Country_Raw__c + supplyDB.Date__c + mapSegCategories.get(segmentName ));
                supplyDB.Update_Segment_Revenue_Transaction__c = false; 
                if( supplyDB.Segment_Revenue_Transaction__c == null ){
                    segRevTransaction.add(supplyDB.Target_Country_Raw__c+'_'+supplyDB.Date__c+'_'+mapSegCategories.get(segmentName));
                }
            }
        }

        if(!segRevTransaction.isEmpty()){                   
            for(String combkey: segRevTransaction ){
                try{
                    Segment_Revenue_Transaction__c st = new Segment_Revenue_Transaction__c();
                    String[] keys = combkey.split('\\_');
                    st.Country_Code__c = keys[0];
                    st.Date__c = Date.valueOf(keys[1]);
                    if (keys[2] != null) {
                        st.Segment_Category_Mapping__c = keys[2];
                        stToInsertList.add (st);
                    }     
                }catch(Exception e){}               
            }

            if (stToInsertList.size() > 0 ) insert stToInsertList;

            for(Supply_Database__c supplyDB : supplyDatabases){
                segmentName =   mapSegMapSegCats.get(supplyDB.Segment_Name_Supply_Raw__c);
                for(Segment_Revenue_Transaction__c segRevTrans:stToInsertList) { 
                    if(supplyDB.Date__c == segRevTrans.Date__c && segRevTrans.Country_Code__c == supplyDB.Target_Country_Raw__c && segRevTrans.Segment_Category_Mapping__c == mapSegCategories.get(segmentName))
                    { 
                        supplyDB.Segment_Revenue_Transaction__c = segRevTrans.Id; 
                    }
                }
            }
        }

        System.debug('supplyDatabases' + supplyDatabases);
        update supplyDatabases;
    }

    global void finish(Database.BatchableContext bc) {
        //Finish
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new SupplyDatabaseSegmentRevenueAssignment(new List<String>()), 100);
    }
}