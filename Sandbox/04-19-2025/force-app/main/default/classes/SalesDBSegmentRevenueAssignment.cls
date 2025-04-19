global with sharing class SalesDBSegmentRevenueAssignment implements Database.Batchable <sObject>, Database.Stateful, Schedulable {
    public List<String> salesDBIds {get; set;}
    
    global SalesDBSegmentRevenueAssignment(List<String> salesDBIds) {
        this.salesDBIds = salesDBIds;
    }

    global Database.Querylocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Date_Invoiced__c, Segment_Category_Mapping__c, Target_Country_Raw__c, Segment_Name_Sales_Raw__c FROM Sales_Database__c WHERE Update_Segment_Revenue_Transaction__c = true';

        if( salesDBIds.size() > 0 ){
            query += ' AND Id IN :salesDBIds';
        }

        return Database.getQuerylocator(query);
    } 

    global void execute(Database.batchableContext bc, List<Sales_Database__c> salesDatabases) {
        List<Segment_Revenue_Transaction__c> listSegmentTransactionInsert = new List<Segment_Revenue_Transaction__c>();

        Set<Date> setDates              = new Set<Date>(); 
        Set<String> setTargetcountry    = new Set<String>();
        Set<String> setSegNames         = new Set<String>();
        Set<String> setPlatCodes        = new Set<String>();
        Set<String> segRevTransaction   = new Set<String>();
        set<String> setSegCatIDs        = new set<String>();

        Map<String,String> mapPlatCodeSegmentCode   = new Map<String,String>();
        Map<String, String> mapSegCodeSegCatId      = new Map<String, String>();

        for(Sales_Database__c salesDatabase : salesDatabases){
            if(salesDatabase.Date_Invoiced__c != null){ 
                setDates.add(salesDatabase.Date_Invoiced__c);
            }

            if(String.isNotEmpty(salesDatabase.Target_Country_Raw__c)){
                setTargetcountry.add(salesDatabase.Target_Country_Raw__c.toUpperCase()); 
            }

            if(String.isNotEmpty(salesDatabase.Segment_Name_Sales_Raw__c)){
                setPlatCodes.add(salesDatabase.Segment_Name_Sales_Raw__c);
            }
        }

        List<Segment_Mapping__c> smList = [SELECT Id,Segment_Name_Sales_Raw__c,Segment_Name__c FROM Segment_Mapping__c WHERE Segment_Name_Sales_Raw__c IN:setPlatCodes];
        System.debug('smList' + smList);
        for (Segment_Mapping__c segmentMapping:smList){
            mapPlatCodeSegmentCode.put(segmentMapping.Segment_Name_Sales_Raw__c ,segmentMapping.Segment_Name__c); 
            setSegNames.add(segmentMapping.Segment_Name__c);
        }

        List<Segment_Category_Mapping__c> scmList = [SELECT Segment_Name__c,Id FROM Segment_Category_Mapping__c WHERE Segment_Name__c IN:setSegNames];
        System.debug('scmList' + scmList);
        for(Segment_Category_Mapping__c segmentCategory : scmList) {
            if( String.isNotEmpty(segmentCategory.Segment_Name__c) ) {
                mapSegCodeSegCatId.put(segmentCategory.Segment_Name__c,segmentCategory.Id);                                                
            }

        }    

        for(Sales_Database__c salesDatabase : salesDatabases){
            String segmentName = mapPlatCodeSegmentCode.get(salesDatabase.Segment_Name_Sales_Raw__c);
            if(segmentName != null && segmentName != ''){
                setSegCatIDs.add(mapSegCodeSegCatId.get(segmentName));       
            }
        }

        Map<String,String> mapExstngSegTransIDs         = new Map<String,String>();
        List<Segment_Revenue_Transaction__c> srtList    = [SELECT Id,Country_Code__c,Date__c,Segment_Category_Mapping__c FROM Segment_Revenue_Transaction__c WHERE Date__c IN:setDates AND Country_Code__c IN:setTargetcountry AND Segment_Category_Mapping__c IN:setSegCatIDs];
        
        System.debug('srtList' + srtList);

        for (Segment_Revenue_Transaction__c segTrans : srtList){
            mapExstngSegTransIDs.put(segTrans.Country_Code__c.toUpperCase()+segTrans.Date__c+segTrans.Segment_Category_Mapping__c,segTrans.Id); 
        }
  
        for(Sales_Database__c salesDatabase : salesDatabases){
            String segmentName = mapPlatCodeSegmentCode.get(salesDatabase.Segment_Name_Sales_Raw__c);
            salesDatabase.Segment_Revenue_Transaction__c = mapExstngSegTransIDs.get(salesDatabase.Target_Country_Raw__c + salesDatabase.Date_Invoiced__c + mapSegCodeSegCatId.get(segmentName)); 
            salesDatabase.Update_Segment_Revenue_Transaction__c = false;  
            if (salesDatabase.Segment_Revenue_Transaction__c == null) {
                segRevTransaction.add(salesDatabase.Target_Country_Raw__c+'_'+salesDatabase.Date_Invoiced__c+'_'+mapSegCodeSegCatId.get(segmentName));
            }
        }
        
        if(!segRevTransaction.isEmpty()){                    
            for(String combkey : segRevTransaction ){  
                System.debug('combkey' + combkey); 
                Segment_Revenue_Transaction__c st = new Segment_Revenue_Transaction__c();
                String[] keys = combkey.split('\\_');
                st.Country_Code__c = keys[0];
                if( keys[1] != null || keys[1] != 'null' ){
                    st.Date__c = Date.valueOf(keys[1]);
                }
                
                if (keys[2] != null) {
                    st.Segment_Category_Mapping__c = keys[2];
                    listSegmentTransactionInsert.add (st);
                }  
            }

            If (listSegmentTransactionInsert.size() > 0) {
                insert listSegmentTransactionInsert;
            }

            for(Sales_Database__c salesDatabase : salesDatabases){
                for(Segment_Revenue_Transaction__c segTrans : listSegmentTransactionInsert) {
                    if(salesDatabase.Date_Invoiced__c == segTrans.Date__c && salesDatabase.Target_Country_Raw__c.toUpperCase() == segTrans.Country_Code__c && salesDatabase.Segment_Category_Mapping__c == segTrans.Segment_Category_Mapping__c  ){
                        salesDatabase.Segment_Revenue_Transaction__c = segTrans.Id;
                    }                              
                }
            }
        }

        System.debug('salesDatabases' + salesDatabases);
        update salesDatabases;

    }
    global void finish(Database.BatchableContext bc) {
        //Finish
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new SalesDBSegmentRevenutAssignment(new List<String>()), 100);
    }
}