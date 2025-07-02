@isTest
    public class SegmentMonthlyGlobalTest {
        Static testmethod void SegmentMonthlyGlobalTest(){
            
            Segment_Category_Mapping__c Seg = new Segment_Category_Mapping__c ();
            Seg.Segment_Name__c ='Today';
            insert Seg;
            
            Segment_Mapping__c sm=new Segment_Mapping__c();
            sm.Segment_Category_Mapping__c=seg.Id;
            sm.Segment_Name_Supply_Raw__c='TEST SEGMENT';
            insert sm;
			
            
            
            
            Segment_Category_Mapping__c SegGlobal = new Segment_Category_Mapping__c ();
            SegGlobal.Segment_Name__c = 'India';
            insert SegGlobal;
            
            Segment_Monthly_Global__c smg = new Segment_Monthly_Global__c ();
            
            smg.Segment_Name_Supply_Raw_Original__c='test segment';
            smg.Segment_Name_Supply_Raw__c='TEST SEGMENT';
            smg.Date__c=Date.newInstance(2016, 9, 1);
            smg.Segment_Name_Supply_Raw__c='test raw';
            smg.Segment_Key_Raw__c='test raw';
            smg.Segment_Category_Mapping__c=Seg.Id;
            insert smg;
            smg.Date__c=Date.newInstance(2016, 10, 01);
            smg.Segment_Key_Raw__c='TEST SEGMENT';
            smg.Segment_Name_Supply_Raw__c='TEST SEGMENT';
            update smg;
            
            Sales_Database__c sdb=new Sales_Database__c();
            sdb.Date__c=smg.Date__c;
            sdb.Segment_Category_Mapping__c=Seg.Id;
            insert sdb;
            
                        
            
            
        }
}