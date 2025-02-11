@isTest
public class PublisherMonthlyGlobalTest
{
        static testmethod void PublisherMonthlyGlobalTest(){   
            Account acc = new Account();
            acc.Name='ABC';
            acc.Account_Type__c='Data Supplier';
            insert acc; 
            
            Data_Supplier_Mapping__c dataSupplierMappings = new Data_Supplier_Mapping__c();
            dataSupplierMappings.Data_Supplier_Raw__c ='TEST DATA SUPPLIER';
            dataSupplierMappings.Data_Supplier_Account__c=acc.Id;
            insert dataSupplierMappings;
            
             List<Data_Supplier_Mapping__c> samples = [Select Name, Id, Data_Supplier_Raw__c, Data_Supplier__c From Data_Supplier_Mapping__c WHERE Id = :dataSupplierMappings.Id];
			 System.debug('samples samples samples' +  samples);
            
            Publisher_Monthly_Global__c Pb1 = new Publisher_Monthly_Global__c();
            Pb1.Name='Booksworth';
            Pb1.Date__c=date.today();
            Pb1.Country_Raw__c='Australian';
            Pb1.Revenue__c=50.50;
            pb1.Data_Supplier__c=acc.Id;
            pb1.Data_Supplier_Raw_Original__c='test data supplier';
            pb1.Data_Supplier_Raw__c=pb1.Data_Supplier_Raw_Original__c;
            insert Pb1;

            Supply_Database__c Sup = new Supply_Database__c();
            Sup.Target_Country_Raw__c='New Mexico';
            Sup.Uniques__c=5000;
            Sup.Data_Supplier_Raw__c='';
            Sup.Date__c=Pb1.Date__c;
            Insert sup;
        }
}