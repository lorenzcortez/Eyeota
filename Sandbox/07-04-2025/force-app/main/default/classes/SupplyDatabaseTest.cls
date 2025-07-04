@isTest
public class SupplyDatabaseTest {
    static testmethod void SupplyDatabaseTest()     
    {
        Account ac=new Account();
        ac.Name='test ac';
        ac.Currency_Code__c='USD';
        insert ac;
        
        Data_Supplier_Mapping__c Dat= new Data_Supplier_Mapping__c();
        //Dat.Data_Supplier_Account_Name__c='AD PLUS';
        Dat.Data_Supplier_Raw__c ='AC PLUS';
        dat.Data_Supplier_Account__c=ac.id;
        insert Dat;
        
        Account acc= new Account();
        //acc.Account_Type__c='Advertiser';
        //acc.New_Flag__c=true;
        acc.Name='AC PLUS';
        //acc.Currency_Code__c='USD';
        Insert acc;
        
        Country__c cc = new Country__c();
        cc.Master_Geography_Code__c = 'AO PLUS';
        insert cc;
        
        Segment_Category_Mapping__c sg = new Segment_Category_Mapping__c();
        sg.Segment_Name__c='Test sgg';
        insert sg;
        system.debug('2===>' +sg);
        
        Segment_Mapping__c Seg = new Segment_Mapping__c();
        seg.Segment_Category_Mapping__c=sg.id;
        Seg.Segment_Name_Sales_Raw__c='Bruce';
        Seg.Segment_Name_Supply_Raw__c='1234';
        
        insert Seg;
        
        Supply_Database__c Sup = new Supply_Database__c();
        Sup.Data_Supplier_Raw__c = 'AD PLUS';
        sup.Segment_Key_Raw__c = '1234';
        SUp.Data_Supplier_Raw_Original__c='AC PLUS';
        sup.Segment_Name_Supply_Raw_Original__c='AA PLUS';
        sup.Segment_Name_Supply_Raw__c='AB BGFDRT';
        sup.Target_Country_Raw__c='AO PLUS';
        sup.Date__c=date.today();
        sup.Data_Supplier__c=null;
        sup.Currency_Code__c='USD';
        insert Sup;
        
        Supply_Database__c Sup1 = new Supply_Database__c();
        Sup1.Data_Supplier_Raw__c = 'AD PLUS';
        sup1.Segment_Key_Raw__c = '1234';
        SUp1.Data_Supplier_Raw_Original__c='AC PLUS';
        sup1.Segment_Name_Supply_Raw_Original__c='AA PLUS';
        sup1.Segment_Name_Supply_Raw__c='AB BGFDRT1';
        sup1.Target_Country_Raw__c='AO PLUS';
        sup1.Date__c=date.today();
        sup1.Data_Supplier__c=null;
        sup1.Currency_Code__c='EUR';
        insert Sup1;
        delete sup1;
        undelete sup1;
        system.debug('1====>' +sup1);
        
        system.debug('3===>' + seg.Segment_Name__c);
        
        Segment_Revenue_Transaction__c SegTran = new Segment_Revenue_Transaction__c();
        SegTran.Country_Code__c='AD';
        insert SegTran;
        
        Country__c c = new Country__c();
        c.name='India';
        insert c;
        
        // Saifullah 24th March 2017
        Exchange_Rate__c exR=new Exchange_Rate__c();
        exR.Date_Invoiced__c=sup.Date__c;
        exR.Billing_Currency_Code__c='USD';
        exR.Exchange_Rate__c=2;
        insert exR;
    }
    
    /*static testmethod void test2(){
        Supply_Database__c Sup = new Supply_Database__c();
        Sup.Data_Supplier_Raw__c = 'AD PLUS';
        sup.Segment_Key_Raw__c = '1234';
        SUp.Data_Supplier_Raw_Original__c='AC PLUS';
        sup.Segment_Name_Supply_Raw_Original__c='AA PLUS';
        sup.Segment_Name_Supply_Raw__c='AB BGFDRT';
        sup.Target_Country_Raw__c='AO PLUS';
        sup.Date__c=date.today();
        sup.Data_Supplier__c=null;
        sup.Currency_Code__c='EUR';
        insert Sup;
    }*/
}