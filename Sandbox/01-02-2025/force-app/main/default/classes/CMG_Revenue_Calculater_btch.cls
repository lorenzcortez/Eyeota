/*
Object Name      : Country Monthly Global Batch
Purpose          : To calculate the total revenue in Sales Database against the Date and Country combinations on CMG records available on the database. 
Created By       : Mohammad Usman / TechMatrix Consulting Pte Ltd. 
Modified By      : Antony Jerald / TechMatrix Consulting Pte Ltd.
Last Modified Date    : 30th May 2017
Last Modified Purpose : Adding Documentation, Removing debug statements for better readability.  
*
*/

global class CMG_Revenue_Calculater_btch implements Database.Batchable<sObject>{   

   global Database.QueryLocator start(Database.BatchableContext BC){

       // Initialize Batch Query with all the current CMG records.    
      return Database.getQueryLocator([SELECT Id ,Master_Geography_Code__c,Date__c FROM Country_Monthly_Global__c]);                                        

   }

   global void execute(Database.BatchableContext BC, List<Country_Monthly_Global__c> scope){

      list<Country_Monthly_Global__c> toUpdate = new list<Country_Monthly_Global__c>();
    
      for(Country_Monthly_Global__c s : scope){  // Loop through the current scope i.e all the CMG Records in the Database. 
       System.debug('s.Master_Geography_Code__c----@@'+s.Master_Geography_Code__c);
          System.debug('s.Date__c'+s.Date__c);
         // .. Start loop into all matching Sales Database records matching Country and Date combination of the 
          // ..   current CMG records in the database.   
         for(AggregateResult ssd:[SELECT sum(Revenue__c),Target_Country_Raw__c,Date__c from Sales_Database__c  
                                  WHERE  Target_Country_Raw__c =:s.Master_Geography_Code__c AND
                                  Date__c =:s.Date__c AND Target_Country_Raw__c != null  
                                  Group by Target_Country_Raw__c,Date__c]){

            if(ssd.get('Target_Country_Raw__c')!= null && ssd.get('Date__c')!= null){
                
                Country_Monthly_Global__c obj = s;
                obj.Revenue__c = double.valueOf(ssd.get('expr0'));  // Assign the aggregated Sales DB Revenue in the corresponding CMG record.
                
                toUpdate.add(obj); // Mark the CMG record for update operations post the loops in bulk. 
            } 

        }
        // .. End loop into all matching Sales Database records matching Country and Date combination of the 
           
      }    // End For Loop --  the current scope i.e all the CMG Records in the Database. 

      if(!toUpdate.isEmpty())  update toUpdate;  // If there are records to update , update those CMG Records 
                                                 // with the aggregate revenue populated in the For Loop  above.

   }

   global void finish(Database.BatchableContext BC){

   }
}