@isTest
public class SalesDatabaseTest {
    Static testmethod void SalesDatabaseTest(){
        
        
        
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
        //s.Eyeota_Segment_Code__c='dem.infinc.low';
        s.Date__c=date.today();
        s.Date_Invoiced__c=date.today()+5;
        s.Campaign_Raw_Original__c='for testing';
        s.Impressions__c=10;
        s.Segment_Revenue_Transaction__c=SegTran.Id;
        insert s;
        delete s;
        undelete s;
        
        Buyer_Mapping__c BuyMap = new Buyer_Mapping__c();
        //BuyMap.Team_Member_Id__c='123';
        //BuyMap.Global_Buyer_Name__c='Microsoft';
        BuyMap.Buyer_Country_Raw__c='INDIA';
        BuyMap.Buyer_Raw__c='ROGER';
        BuyMap.Platform__c='HARMON';
        BuyMap.PDT_Member__c='Mark';
        insert BuyMap;
        
        /*Buyer_Mapping__c BuyMap1 = new Buyer_Mapping__c();
//BuyMap1.Name='Mork';
//BuyMap.Team_Member_Id__c='123';
//BuyMap1.Global_Buyer_Name__c='Microsoft';
BuyMap1.Buyer_Country_Raw__c= s.Buyer_Country__c;
BuyMap1.Buyer_Raw__c=s.Buyer_Raw__c;
BuyMap1.Platform__c=s.Platform_Raw__c;
BuyMap1.PDT_Member__c='MarkTeo';
insert BuyMap1;*/
        
        Account aa=new Account();
        aa.name='Campaign Classified';
        aa.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Advertiser').RecordTypeId;
        insert aa;
        
        Advertiser_Mapping__c AdvMap = new Advertiser_Mapping__c();
        //AdvMap.Advertiser__c='Raspberry Pi';
        AdvMap.Advertiser_Raw__c='JBL';
        AdvMap.Advertiser_Account__c =aa.id;
        insert AdvMap;
        
        Advertiser_Mapping__c AdvMap1 = new Advertiser_Mapping__c();
        //AdvMap1.Advertiser__c='advertiser';
        AdvMap1.Advertiser_Raw__c='JBL';
        
        insert AdvMap1;
        
        
        Platform_Mapping__c PlatMap = new Platform_Mapping__c();
        //PlatMap.Platform_Account_Name__c='IOS';
        PlatMap.Platform_Raw__c='HARMON';
        insert PlatMap;
        
        Platform_Mapping__c PlatMap1 = new Platform_Mapping__c();
        //PlatMap1.Platform_Account_Name__c='platform';
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
        s1.Advertiser_Raw__c='JBL';
        s1.Segment_Name_Sales_Raw_Original__c='testing';
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
}