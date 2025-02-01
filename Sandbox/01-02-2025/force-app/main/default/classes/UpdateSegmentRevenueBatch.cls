global class UpdateSegmentRevenueBatch implements Database.Batchable<sObject> {

    private String sObjectName;
    private String dateField;
    private String qryStr;

    public UpdateSegmentRevenueBatch(String sObjectName, String dateField, Date startDate, Date endDate) {
        this.sObjectName = sObjectName;
        this.dateField = dateField;
        DateTime startDt = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);
        DateTime endDt = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);
        String whereStr = ' WHERE Update_Segment_Revenue_Transaction__c = false AND '+dateField+' != null AND ('+dateField+' >= '+startDate+' AND '+dateField+' <= '+endDate+')';
        System.debug('whereStr '+whereStr);
        this.qryStr = 'SELECT Id, Update_Segment_Revenue_Transaction__c FROM ' + sObjectName + whereStr;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('this.qryStr '+qryStr);
        return Database.getQueryLocator(qryStr.replaceAll('00:00:00',''));
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<sObject> sObjectToUpdate = new List<sObject>();
        for(sObject sdb : scope) {
            sdb.put('Update_Segment_Revenue_Transaction__c', true);
            sObjectToUpdate.add(sdb);
        }
        if(sObjectToUpdate != null) {
            Database.update(sObjectToUpdate, false);
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }    
}