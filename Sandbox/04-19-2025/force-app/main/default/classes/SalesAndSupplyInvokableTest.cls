@isTest
public class SalesAndSupplyInvokableTest {
    // Utility method to create test data for Supply_Database__c
    private static List<Supply_Database__c> createSupplyDatabases(Integer count) {
        List<Supply_Database__c> supplyDatabases = new List<Supply_Database__c>();
        List<Segment_Mapping__c> segmentMapping = new List<Segment_Mapping__c>();
        List<Data_Supplier_Mapping__c> dataSupMapping = new List<Data_Supplier_Mapping__c>();
        
        for (Integer i = 0; i < count; i++) {
            Supply_Database__c sd = new Supply_Database__c();
            sd.Data_Supplier_Raw_Original__c = 'SUPPLIER ' + i;
            sd.Segment_Key_Raw__c = 'SEGMENTMAPSUPPLY' + (i+1);
            sd.Segment_Name_Supply_Raw_Original__c = 'SEGMENTMAPSUPPLY' + (i+1);
            sd.Target_Country_Raw__c = 'Country ' + i;
            sd.Date__c = Date.today();
            sd.Currency_Code__c = 'USD';
            sd.Update_Segment_Revenue_Transaction__c = true;
            supplyDatabases.add(sd);
        }
        
        Segment_Category_Mapping__c sCM = new Segment_Category_Mapping__c();
        sCM.Segment_Name__c='Test SCM';
        insert sCM;
        
        for (Integer i = 0; i < count; i++) {
            Segment_Mapping__c sm = new Segment_Mapping__c();
            sm.Segment_Name_Sales_Raw__c = 'SEGMENTMAPSALES' + (i+1);
            sm.Segment_Name_Supply_Raw__c = 'SEGMENTMAPSUPPLY' + (i+1);
            sm.Segment_Category_Mapping__c = sCM.Id;
            segmentMapping.add(sm);
        }
        
        Account acc = new Account(
            Name = 'Test Account ',
            Currency_Code__c = 'USD'
        );
        
        insert acc;
        
        for (Integer i = 0; i < count; i++) {
            Data_Supplier_Mapping__c dSM = new Data_Supplier_Mapping__c();
            dSM.Data_Supplier_Raw__c = 'SUPPLIER ' + i;
            dSM.Data_Supplier_Account__c = acc.Id;
            dataSupMapping.add(dSM);
        }
        
        insert dataSupMapping;
        insert segmentMapping;
        
        return supplyDatabases;
    }
    
    @TestSetup
    static void makeData(){
        Segment_Category_Mapping__c segCat1=new Segment_Category_Mapping__c();
        segCat1.Segment_Name__c='TESTING';
        insert segCat1;
        
        Segment_Mapping__c Seg = new Segment_Mapping__c();
        Seg.Segment_Name_Sales_Raw__c='TESTING';
        Seg.Segment_Name_Supply_Raw__c='Wayne';
        Seg.Segment_Category_Mapping__c=segCat1.Id;
        insert Seg;
        
        Segment_Revenue_Transaction__c SegTran = new Segment_Revenue_Transaction__c();
        SegTran.Country_Code__c='AD'; 
        
        insert SegTran;
        
        Country__c c = new Country__c();
        c.name='India';
        insert c;
        
        Campaign_Mapping__c cm1=new Campaign_Mapping__c();
        cm1.Campaign_Raw__c='test camp';
        insert cm1;
        
        Sales_Database__c s = new Sales_Database__c();
        s.Segment_Name_Sales_Raw__c='UniCode';
        s.Buyer_Country_Raw__c='India';
        s.Buyer_Original_Raw__c='Roger';
        s.Target_Country_Raw__c='India';
        s.Advertiser_Raw_Original__c ='JBL';
        s.Platform_Raw_Original__c='Harmon';
        s.Platform_Raw__c='JBL';
        s.Revenue__c=16.42;
        s.Buyer_Raw__c='Intel';
        s.Segment_Name_Sales_Raw_Original__c='testing';
        s.Advertiser_Raw__c='test Raw';
        s.Campaign__c='test camp';
        s.Date__c=date.today();
        s.Date_Invoiced__c=date.today()+5;
        s.Campaign_Raw_Original__c='for testing';
        s.Impressions__c=10;
        s.Segment_Revenue_Transaction__c=SegTran.Id;
        insert s;
        delete s;
        undelete s;
        
        Buyer_Mapping__c BuyMap = new Buyer_Mapping__c();
        BuyMap.Buyer_Country_Raw__c='INDIA';
        BuyMap.Buyer_Raw__c='ROGER';
        BuyMap.Platform__c='HARMON';
        BuyMap.PDT_Member__c='Mark';
        insert BuyMap;
        
        Account aa=new Account();
        aa.name='Campaign Classified';
        aa.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Advertiser').RecordTypeId;
        insert aa;
        
        Advertiser_Mapping__c AdvMap = new Advertiser_Mapping__c();
        AdvMap.Advertiser_Raw__c='JBL';
        AdvMap.Advertiser_Account__c =aa.id;
        insert AdvMap;
        
        Advertiser_Mapping__c AdvMap1 = new Advertiser_Mapping__c();
        AdvMap1.Advertiser_Raw__c='JBL';
        
        insert AdvMap1;
        
        Platform_Mapping__c PlatMap = new Platform_Mapping__c();
        PlatMap.Platform_Raw__c='HARMON';
        insert PlatMap;
        
        Platform_Mapping__c PlatMap1 = new Platform_Mapping__c();
        PlatMap1.Platform_Raw__c=s.Platform_Raw__c;
        insert PlatMap1;
        
        Country__c c1= new Country__c();
        c1.Name='India';
        c1.Master_Geography_Code__c='INDIA';
        c1.Country_Code_2__c='AR';
        insert c1;
        
        
        Segment_Revenue_Transaction__c SegTran1 = new Segment_Revenue_Transaction__c();
        SegTran1.Country_Code__c='AD';
        insert SegTran1;
        
        account a = new account();
        a.Name='Adam';
        
        a.account_Type__c='Ad Network';
        a.Region__c='APAC';
        a.New_Flag__c=False;
        insert a;
        
        contact con = new contact();
        
        con.LastName='Hill';
        con.Preferred_Name_Used_in_Email__c='Mr.';
        insert con;
        
        Segment_Category_Mapping__c segCat=new Segment_Category_Mapping__c();
        segCat.Segment_Name__c='TESTING01';
        insert segCat;
        
        Segment_Mapping__c Seg1 = new Segment_Mapping__c();
        seg1.Segment_Category_Mapping__c=segCat.Id;
        Seg1.Segment_Name_Sales_Raw__c='TESTING';
        Seg1.Segment_Name_Supply_Raw__c='Wayne';
        insert Seg1;
        
        Sales_Database__c s1 = new Sales_Database__c();
        s1.Campaign__c='test camp';
        s1.Segment_Name_Sales_Raw__c='UniCode';
        s1.Buyer_Country_Raw__c='INDIA';
        s1.Buyer_Original_Raw__c='Roger';
        s1.Target_Country_Raw__c='India';
        s1.Advertiser_Raw_Original__c ='JBL';
        s1.Platform_Raw_Original__c='Harmon';
        s1.Revenue__c=16.42;
        s1.Date__c=System.today();
        s1.Date_Invoiced__c =System.today();
        s1.Advertiser_Raw__c='JBL';
        s1.Segment_Name_Sales_Raw_Original__c='testing';
        s1.Update_Segment_Revenue_Transaction__c  = true;
        s1.Impressions__c=10;
        
        s1.Segment_Revenue_Transaction__c=SegTran.Id;
        insert s1;
        
        Campaign_Mapping__c cm=new Campaign_Mapping__c();
        cm.Campaign_Raw__c='test camp';
        insert cm;
        
        Supply_Database__c Sup1 = new Supply_Database__c();
        Sup1.Data_Supplier_Raw__c = 'Richard';
        insert Sup1;
        
        Segment_Revenue_Transaction__c SegTran2 = new Segment_Revenue_Transaction__c();
        SegTran2.Country_Code__c='AD';
        insert SegTran2;
    }
    
    @isTest
    static void scenario() {
        List<Supply_Database__c> supplyDatabases = createSupplyDatabases(5);
        insert supplyDatabases;
        
        List<Supply_Database__c> suppDatabases = [SELECT Id, Update_Segment_Revenue_Transaction__c, Date__c, Segment_Name_Supply_Raw__c, Target_Country_Raw__c FROM Supply_Database__c LIMIT 1];
        System.debug( 'suppDatabases' + suppDatabases );
        if( suppDatabases.size() > 0 ){
            List<String> ids = new List<String>();
            for( Supply_Database__c supplyDatabase : suppDatabases ){
                ids.add(supplyDatabase.Id);
            }
            
            Test.startTest();
            //SupplyDBSegmentRevAssignmentInvokable ink = new SupplyDBSegmentRevAssignmentInvokable();
            //ink.processSupplyDataBase(ids);
            //
            List<SupplyDBSegmentRevAssignmentInvokable.SupplyDBResult> results = SupplyDBSegmentRevAssignmentInvokable.processSupplyDataBase(ids);
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void scenario2(){
        List<Sales_Database__c> salesDatabases = [SELECT Id, Update_Segment_Revenue_Transaction__c  FROM Sales_Database__c LIMIT 1];
        System.debug( 'salesDatabases' + salesDatabases );
        if( salesDatabases.size() > 0 ){
            List<String> ids = new List<String>();
            for( Sales_Database__c salesDatabase : salesDatabases ){
                ids.add(salesDatabase.Id);
            }
            
            Test.startTest();
            	List<SalesDBSegmentRevenueAssignmentInvokable.SupplyDBResult> results = SalesDBSegmentRevenueAssignmentInvokable.processSalesDataBase(ids);
            
            Test.stopTest();
        }
        
    }
    
}