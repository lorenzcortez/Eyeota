global class ProcessSupplyDatabaseScriptBatch implements Database.Batchable<sObject>{
    
    global Date selDate;
    global String objName;
    
    public ProcessSupplyDatabaseScriptBatch(date selDate,String objName){
    
    this.selDate = selDate;
        this.objName = objName;

    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){

       String query   = 'select Id,Data_Supplier_Raw__c,Segment_Name_Supply_Raw__c,Target_Country_Raw__c ';
               query += 'from Supply_Database__c Where Date__c >=: selDate AND Date__c <= TODAY';
        return Database.getQueryLocator(query);

    }
    
    global void execute(Database.BatchableContext BC, List<Supply_Database__c> scope){

        if(scope.size()>0)
            update scope;
        
    }

    global void finish(Database.BatchableContext BC){

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

    //Add emails from custom setting
        Map<String,Mapping_Dashboard_Emails__c> mcs = Mapping_Dashboard_Emails__c.getall();
              
        for(Mapping_Dashboard_Emails__c emailList:mcs.values()){    

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new list<string>{emailList.Email_Address__c}); 
            mail.setSubject(objName+' Update Information');
            String body = 'Dear '+ emailList.Name +', ';
            body += '<br/> <br/>';
            body += objName +' Records successfully Updated';
            body += '<br/> <br/>';
            body += 'Thanks';
        
            mail.setHtmlBody(body);
            //Add email to the master list
            mails.add(mail);
    }

        //Send all emails in the master list
        Messaging.sendEmail(mails);

    }
     
}