global class CongaDateFilterBatch implements Database.Batchable<sObject> {

    private String qryStr;
    private Date startDate;
    private Date endDate;

    public CongaDateFilterBatch(Date startDate, Date endDate) {
		String whereStr = ' WHERE (RecordType.DeveloperName = \'Data_Supplier_Parent_Accout\' OR RecordType.DeveloperName = \'Data_Supplier_Holding_Group\')';
        this.qryStr = 'SELECT Id, Start_Date__c, End_Date__c FROM Account' + whereStr;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(qryStr);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<sObject> sObjectToUpdate = new List<sObject>();
        for(sObject sdb : scope) {
            sdb.put('Start_Date__c', startDate);
            sdb.put('End_Date__c', endDate);
            sObjectToUpdate.add(sdb);
        }
        if(sObjectToUpdate != null) {
            Database.update(sObjectToUpdate, false);
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }    
}