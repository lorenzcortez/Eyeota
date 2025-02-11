@isTest
public class MappingDashboardControllerTest{
    @isTest
    private static void testUnit(){
        account acc = new account(name='test acc');
        acc.Advertiser_Sector_1__c='Retail';
        acc.Advertiser_Sector_2__c='F&B';
        insert acc;
        
        Campaign_Mapping__c cm = new Campaign_Mapping__c();
        cm.Campaign_Raw__c ='abc';
        cm.Created_From_Exception__c = true;
        cm.Advertiser_Account__c =acc.id;
        insert cm;
        
        
        Platform_Mapping__c pm = new Platform_Mapping__c();
        pm.Platform_Raw__c ='test';
        pm.Platform_Account__c  = acc.id;
        insert pm;
        
        Sales_Database__c sd = new Sales_Database__c();
        sd.Buyer_Error__c ='acd';
        sd.Buyer_Raw__c = 'abc';
        sd.Buyer_Country_Raw__c ='abc';
        sd.Platform_Raw_Original__c ='abc';
        sd.Date__c = system.today();
        sd.Date_Invoiced__c = system.today();
        sd.Segment_Name_Error__c ='abc';
        sd.Segment_Name_Sales_Raw__c='abc';
        sd.Revenue__c = 1;
        sd.Advertiser_Error__c ='abc';
        sd.Advertiser_Raw__c ='abc';
        
        insert sd;
        
        Segment_Category_Mapping__c sc = new Segment_Category_Mapping__c();
        sc.Segment_Name__c = 'abc';
        insert sc;
        
        Supply_Database__c   sdd = new Supply_Database__c ();
        sdd.Data_Supplier_Error__c = 'abc';
        sdd.Date__c =system.today();
        sdd.Segment_Name_Error__c ='abc';
        sdd.Data_Supplier_Raw__c = 'adc';
        sdd.Segment_Name_Supply_Raw__c='abc';
        sdd.Segment_Category_Mapping__c = sc.id;
        //sdd.Segment_Name__c ='abc';
        insert sdd;
        
        Advertiser_Mapping__c advmap = new Advertiser_Mapping__c();
        //advmap.account = acc.id;
        advmap.Created_From_Exception__c = false;
        advmap.Advertiser_Raw__c = 'abc';
        insert advmap;        
        // ----------------------------- Campaign mapping records section ------------
        list<Campaign_Mapping__c > cmList = new list<Campaign_Mapping__c >();
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));//record per page 20 added by saifullah 27th mar
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        cmList.add(getCMRecords(acc.id));
        insert CmList;
        
        // ----------------------------- Buyer mapping records section ------------
        list<Buyer_Mapping__c> bmList = new list<Buyer_Mapping__c>();
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());//record per page 20 added by saifullah 27th mar
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        bmList.add(getBMRecords());
        
        insert bmList;
        // ----------------------------- Advertiser mapping records section ------------
        list<Advertiser_Mapping__c > amList = new list<Advertiser_Mapping__c >();
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));//record per page 20 added by saifullah 27th mar
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        amList.add(getAMRecords(acc.id));
        
        insert amList;
        // ----------------------------- Data Supplier mapping records section ------------
        list<Data_Supplier_Mapping__c > dsmList = new list<Data_Supplier_Mapping__c >();
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));//record per page 20 added by saifullah 27th mar
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        dsmList.add(getDSMRecords(acc.id));
        
        insert dsmList;
        // ----------------------------- Platform mapping records section ------------
        list<Platform_Mapping__c > pmList = new list<Platform_Mapping__c >();
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords()); //record per page 20 added by saifullah 24th mar
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        pmList.add(getPMRecords());
        
        insert pmList; 
        // ----------------------------- Revenue share mapping records section ------------
        list<Revenue_Share_Mapping__c > rsmList = new list<Revenue_Share_Mapping__c>();
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        rsmList.add(getRSMRecords());
        
        insert rsmList; 
        // ----------------------------- segment mapping records section ------------
        list<Segment_Mapping__c > smList = new list<Segment_Mapping__c>();
        smList.add(getSMRecords('12345','12345'));
        smList.add(getSMRecords('12346','12346'));
        smList.add(getSMRecords('12347','12347'));
        smList.add(getSMRecords('12348','12348'));
        smList.add(getSMRecords('12349','12349'));
        smList.add(getSMRecords('12359','12359'));
        smList.add(getSMRecords('12345','12345'));
        smList.add(getSMRecords('12346','12346'));
        smList.add(getSMRecords('12347','12347'));
        smList.add(getSMRecords('12348','12348'));
        smList.add(getSMRecords('12349','12349'));
        smList.add(getSMRecords('12359','12359'));
        smList.add(getSMRecords('12345','12345'));
        smList.add(getSMRecords('12346','12346'));
        smList.add(getSMRecords('12347','12347'));
        smList.add(getSMRecords('12348','12348'));
        smList.add(getSMRecords('12349','12349'));
        smList.add(getSMRecords('12359','12359'));
        smList.add(getSMRecords('12349','12349'));
        smList.add(getSMRecords('12359','12359'));
        smList.add(getSMRecords('12349','12349'));
        smList.add(getSMRecords('12359','12359'));
        smList.add(getSMRecords('12349','12349'));
        smList.add(getSMRecords('12359','12359'));
        insert smList;
        
        MappingDashboardController MappDashboardObj = new MappingDashboardController();
        MappDashboardObj.selRecId = MappDashboardObj.buyerList.get(0).bm.Id;
        MappDashboardObj.nextPage(); 
        MappDashboardObj.saveRecord();
        MappDashboardObj.lookupValueChanged();
        MappDashboardObj.SaveAndExecuteMapping();
        MappDashboardObj.createNewRecords();
        MappDashboardObj.deleteMappingRecords();
        MappDashboardObj.isExpChk = True;
        MappDashboardObj.searchExceptionRecord();
        MappDashboardObj.isExpChk = False;
        
        MappDashboardObj.selOptn ='AM';
        MappDashboardObj.fetchRecords();
        MappDashboardObj.nextPage();
        MappDashboardObj.prevPage();
        MappDashboardObj.gotoIndex = '1';
        MappDashboardObj.goToPage();
        MappDashboardObj.selRecId = MappDashboardObj.advertiserList.get(0).am.Id;
        MappDashboardObj.lookupValueChanged();
        MappDashboardObj.saveRecord();
        MappDashboardObj.SaveAndExecuteMapping();
        MappDashboardObj.createNewRecords();
        MappDashboardObj.deleteMappingRecords();
        MappDashboardObj.isExpChk = True;
        MappDashboardObj.searchExceptionRecord();
        MappDashboardObj.isExpChk = False;
        
        MappDashboardObj.selOptn ='DM';
        MappDashboardObj.fetchRecords();
        MappDashboardObj.nextPage();
        MappDashboardObj.selRecId = MappDashboardObj.dataSupplierList.get(0).dsm.Id; 
        MappDashboardObj.lookupValueChanged();
        MappDashboardObj.saveRecord();
        MappDashboardObj.SaveAndExecuteMapping();
        MappDashboardObj.createNewRecords();
        MappDashboardObj.deleteMappingRecords();
        MappDashboardObj.isExpChk = True;
        MappDashboardObj.searchExceptionRecord();
        MappDashboardObj.isExpChk = False;
        
        MappDashboardObj.selOptn ='RM';
        MappDashboardObj.fetchRecords();
        MappDashboardObj.nextPage();
        MappDashboardObj.selRecId = MappDashboardObj.revenueList.get(0).rsm.Id; 
        MappDashboardObj.saveRecord();
        MappDashboardObj.lookupValueChanged();
        MappDashboardObj.SaveAndExecuteMapping();
        MappDashboardObj.createNewRecords();
        MappDashboardObj.deleteMappingRecords();
        MappDashboardObj.isExpChk = True;
        MappDashboardObj.searchExceptionRecord();
        MappDashboardObj.isExpChk = False;
        
        MappDashboardObj.selOptn ='PM';
        MappDashboardObj.fetchRecords();
        MappDashboardObj.nextPage();
        MappDashboardObj.selRecId = MappDashboardObj.platformList.get(0).pm.Id; 
        MappDashboardObj.lookupValueChanged();
        MappDashboardObj.saveRecord();
        MappDashboardObj.SaveAndExecuteMapping();
        MappDashboardObj.createNewRecords();
        MappDashboardObj.deleteMappingRecords();
        MappDashboardObj.isExpChk = True;
        MappDashboardObj.searchExceptionRecord();
        MappDashboardObj.isExpChk = False;
        
        MappDashboardObj.selOptn ='SM';
        MappDashboardObj.fetchRecords();
        MappDashboardObj.nextPage();
        MappDashboardObj.selRecId = MappDashboardObj.segmentList.get(0).sm.Id; 
        MappDashboardObj.lookupValueChanged();
        MappDashboardObj.saveRecord();
        MappDashboardObj.SaveAndExecuteMapping();
        MappDashboardObj.createNewRecords();
        MappDashboardObj.deleteMappingRecords();
        MappDashboardObj.isExpChk = True;
        MappDashboardObj.searchExceptionRecord();
        MappDashboardObj.isExpChk = False;
        
        MappDashboardObj.selOptn ='CM';
        MappDashboardObj.fetchRecords();
        MappDashboardObj.nextPage();
        MappDashboardObj.selRecId = MappDashboardObj.campaignList.get(0).cm.Id; 
        MappDashboardObj.lookupValueChanged();
        MappDashboardObj.saveRecord();
        MappDashboardObj.SaveAndExecuteMapping();
        MappDashboardObj.createNewRecords();
        MappDashboardObj.deleteMappingRecords();
        MappDashboardObj.isExpChk = True;
        MappDashboardObj.searchExceptionRecord();
        MappDashboardObj.isExpChk = False;
       /* 
        // creating controller obj
        MappingDashboardController MappDashboardObj = new MappingDashboardController();
               
        
        //system.assertEquals(MappDashboardObj.fltrOptn.size(),6);
        MappDashboardObj.whatId='12345abcd';
        MappDashboardObj.selSector1Val='for Testing';
        MappDashboardObj.selSector2Val='testing value';
        MappDashboardObj.publisherSiteType='test type';
        MappDashboardObj.publisherVert='testing ';
        MappDashboardObj.publisherDataType='new data';
        MappDashboardObj.whatName='testing';
        MappDashboardObj.count2=10;
        MappDashboardObj.curC='US';
        
        // fetching adveritser mapping records section
        MappDashboardObj.selOptn = MappDashboardObj.fltrOptn[0].getValue();
        system.assertEquals(MappDashboardObj.selOptn,'AM');  
        MappDashboardObj.fetchRecords();
        MappDashboardObj.nextPage();
        MappDashboardObj.prevPage();
        MappDashboardObj.currentPage=1;
        MappDashboardObj.gotoIndex ='1' ;
        MappDashboardObj.goToPage();
        MappDashboardObj.selOptn ='CM';
        MappDashboardObj.goToPage();
        MappDashboardObj.selOptn ='DM';
        MappDashboardObj.goToPage();
        MappDashboardObj.selOptn ='RM';
        MappDashboardObj.goToPage();
        MappDashboardObj.selOptn ='PM';
        MappDashboardObj.goToPage();
        MappDashboardObj.selOptn ='SM';
        MappDashboardObj.goToPage();
        MappDashboardObj.advertiserMapObj = getAMRecords(acc.id);
        //MappDashboardObj.selDate=date.newInstance(2017, 7, 4) ;
        MappDashboardObj.selOptn ='AM'; 
        // assigning values to advertiser instance object record
        MappDashboardObj.createNewRecords();
        
        
        MappDashboardObj.selOptn ='SM';
        MappDashboardObj.createNewRecords();                                      // calling save method for insert new records
        MappDashboardObj.selId = MappDashboardObj.advertiserMapObj.id;
        MappDashboardObj.selOptn ='SM';
        MappDashboardObj.deleteMappingRecords(); 
        //MappDashboardObj.selOptn ='DM';
        MappDashboardObj.selOptn ='AM';
        MappDashboardObj.deleteMappingRecords();
        MappDashboardObj.SaveAndExecuteMapping(); 
        MappDashboardObj.selOptn='RM'; 
        MappDashboardObj.selOptn ='DM';// calling delete method for delete raw and advertiser record from database
        MappDashboardObj.SaveAndExecuteMapping();                            // save and excute method calling for save records in database
        
        // fetching buyer mapping records section
        MappDashboardObj.selOptn = MappDashboardObj.fltrOptn[1].getValue();
        system.assertEquals(MappDashboardObj.selOptn,'BM');
        MappDashboardObj.fetchRecords();
        MappDashboardObj.nextPage();
        MappDashboardObj.prevPage();
        
        MappDashboardObj.buyerMapObj = getBMRecords();                             // assigning values to buyer instance object record
        MappDashboardObj.createNewRecords();                                     // calling save method for insert new records
        MappDashboardObj.selId = MappDashboardObj.buyerMapObj.id;
        MappDashboardObj.deleteMappingRecords();                                 // calling delete method for delete raw and advertiser record from database
        MappDashboardObj.SaveAndExecuteMapping();                            // save and excute method calling for save records in database
        
        // fetching data supplier mapping records
        MappDashboardObj.selOptn = MappDashboardObj.fltrOptn[2].getValue();
        //system.assertEquals(MappDashboardObj.selOptn,'DM');
        MappDashboardObj.fetchRecords();
        MappDashboardObj.nextPage();
        MappDashboardObj.prevPage();
        
        MappDashboardObj.dataSupplierMapObj = getDSMRecords(acc.id);             // assigning values to data supplier mapping instance object record
        MappDashboardObj.createNewRecords();                                     // calling save method for insert new records
        MappDashboardObj.selId = MappDashboardObj.dataSupplierMapObj.id;
        MappDashboardObj.deleteMappingRecords();                                // calling delete method for delete raw and database supplier record from database
        MappDashboardObj.SaveAndExecuteMapping();  
        MappDashboardObj.selOptn = 'RM';  
        MappDashboardObj.searchExceptionRecord();
        MappDashboardObj.selOptn = 'PM';  
        MappDashboardObj.searchExceptionRecord();
        MappDashboardObj.selOptn = 'DM';  
        MappDashboardObj.searchExceptionRecord();
        MappDashboardObj.selOptn = 'AM';  
        MappDashboardObj.searchExceptionRecord();
        MappDashboardObj.selOptn = 'CM';  
        MappDashboardObj.searchExceptionRecord();
        MappDashboardObj.selOptn = 'BM';  
        MappDashboardObj.searchExceptionRecord();
        MappDashboardObj.selOptn = 'SM';  
        MappDashboardObj.searchExceptionRecord();// save and excute method calling for save records in database
        
        // fetching platform mapping records
        MappDashboardObj.selOptn = MappDashboardObj.fltrOptn[3].getValue();
        //system.assertEquals(MappDashboardObj.selOptn,'PM');
        MappDashboardObj.fetchRecords();
        MappDashboardObj.nextPage();
        MappDashboardObj.prevPage();
        MappDashboardObj.platformMapObj = getPMRecords();                     // assigning values to platform mapping instance object record
        MappDashboardObj.createNewRecords();                                 // calling save method for insert new records
        MappDashboardObj.selId = MappDashboardObj.platformMapObj.id;
        MappDashboardObj.deleteMappingRecords();
        MappDashboardObj.selOptn = 'SM'; 
        MappDashboardObj.selRecId = amList.get(0).Id;
        MappDashboardObj.lookupValueChanged();
        MappDashboardObj.selRecId = amList.get(0).Id;
        MappDashboardObj.selOptn = 'DM';          
        MappDashboardObj.lookupValueChanged();
        MappDashboardObj.selOptn = 'CM';          
        MappDashboardObj.lookupValueChanged();
        MappDashboardObj.selOptn = 'AM'; 
        
        MappDashboardObj.lookupValueChanged(); // calling delete method for delete raw and platform mapping record from database
        MappDashboardObj.SaveAndExecuteMapping();    
        //MappDashboardObj.createBuyingMapForExceptions();// save and excute method calling for save records in database
        
        // fetching revenue share mapping records section
        MappDashboardObj.selOptn = MappDashboardObj.fltrOptn[4].getValue();
        //system.assertEquals(MappDashboardObj.selOptn,'RM');
        MappDashboardObj.fetchRecords();
        MappDashboardObj.nextPage();
        MappDashboardObj.prevPage();
        
        MappDashboardObj.fetchPlatforms();
        MappDashboardObj.revenueShareMapObj = getRSMRecords();                // assigning values to revenue share map object record
        MappDashboardObj.createNewRecords();                                  // calling save method for insert new records
        MappDashboardObj.selId = MappDashboardObj.dataSupplierMapObj.id;
        MappDashboardObj.deleteMappingRecords();                              // calling delete method for delete raw and revenue supplier record from database
        MappDashboardObj.SaveAndExecuteMapping();                            // save and excute method calling for save records in database
        //MappDashboardObj.fetchSegments();
        // fetching segment mapping records
        MappDashboardObj.selOptn = MappDashboardObj.fltrOptn[5].getValue();
        //system.assertEquals(MappDashboardObj.selOptn,'SM');
        MappDashboardObj.fetchRecords();
        MappDashboardObj.nextPage();
        MappDashboardObj.prevPage();
        //MappDashboardObj.createSegmentMapForExceptions();
        // MappDashboardObj.createPlatformMapForExceptions();
        MappDashboardObj.segmentMapObj = getSMRecords('54315','12455');        // assigning values to segment map object record
        MappDashboardObj.createNewRecords();                                  // calling save method for insert new records
        MappDashboardObj.selId = MappDashboardObj.segmentMapObj.id;
        MappDashboardObj.deleteMappingRecords(); 
        MappDashboardObj.selOptn = 'SM';                                                 // calling delete method for delete raw and segment record from database
        MappDashboardObj.SaveAndExecuteMapping();                            // save and excute method calling for save records in database
        MappDashboardObj.selRecId= MappDashboardObj.segmentMapObj.id;
        
        MappDashboardObj.selOptn ='BM';
        MappDashboardObj.isExpChk = true;
        //MappDashboardObj.selDate  = null;
        //MappDashboardObj.selInvDate=null;
        
        MappDashboardObj.searchExceptionRecord();
        //MappDashboardObj.isExpChk = true;
        MappDashboardObj.selOptn ='AM';
        // MappDashboardObj.selDate  = system.today() + 1;
        
        MappDashboardObj.searchExceptionRecord();
        
        MappDashboardObj.selOptn ='CM';
        MappDashboardObj.searchExceptionRecord();
        
        MappDashboardObj.selOptn ='DM';
        MappDashboardObj.searchExceptionRecord();
        
        MappDashboardObj.selOptn ='RM';
        MappDashboardObj.searchExceptionRecord();
        
        MappDashboardObj.selOptn ='PM';
        MappDashboardObj.searchExceptionRecord();
        
        MappDashboardObj.selOptn ='SM';
        MappDashboardObj.searchExceptionRecord();
        
        test.startTest ();
        MappDashboardObj.selOptn ='AM';
        MappDashboardObj.selRecId = amList.get(0).Id;
        MappDashboardObj.saveRecord();
        MappDashboardObj.selOptn ='CM';
        MappDashboardObj.selRecId = amList.get(0).Id;
        MappDashboardObj.saveRecord();
        MappDashboardObj.selOptn ='DM';
        MappDashboardObj.selRecId = amList.get(0).Id;
        MappDashboardObj.saveRecord();
        MappDashboardObj.selOptn ='RM';
        MappDashboardObj.selRecId = amList.get(0).Id;
        MappDashboardObj.saveRecord();
        MappDashboardObj.selOptn ='PM';
        MappDashboardObj.selRecId = amList.get(0).Id;
        MappDashboardObj.saveRecord();
        MappDashboardObj.selOptn ='SM';
        MappDashboardObj.selRecId = amList.get(0).Id;
        MappDashboardObj.saveRecord();
        MappDashboardObj.selOptn ='BM';
        MappDashboardObj.selRecId = amList.get(0).Id;
        MappDashboardObj.isErr= false;
        
        MappDashboardObj.saveRecord();
        test.stopTest ();
        //MappingDashboardController MappDashboardObj2  = new MappingDashboardController();
        //MappDashboardObj2.selDate  =Null;
        //MappDashboardObj2.selInvDate=Null; 
        //MappDashboardObj.campaignMapObj= cm; 
        //MappDashboardObj2.fetchAdvertisers();
        //MappDashboardObj2.fetchCampaign();
        
        */
    }   
    
    
    // ----------------------- utillity methods ---------------
    
    
    //-- ----- get buyer mapping records
    private static Buyer_Mapping__c getBMRecords(){
        return new Buyer_Mapping__c(Buyer_Country_Raw__c='Raw test',Buyer_Raw__c='test',PDT_Member__c='test',
                                    Platform__c = 'test');
    }  
    
    //-- ----- get advertiser mapping records
    private static Advertiser_Mapping__c getAMRecords(id accId){
        return new Advertiser_Mapping__c(Advertiser_Raw__c = 'raw test', Advertiser_Account__c = accId);
    } 
    
    //-- ----- get campaign mapping records added by saifullah 23/03/2017
    private static Campaign_Mapping__c getCMRecords(id accId){
        return new Campaign_Mapping__c(Campaign_Raw__c = 'raw test', Advertiser_Account__c = accId);
    } 
    
    //-- ----- get data supplier mapping records
    private static Data_Supplier_Mapping__c getDSMRecords(id accId){
        return new Data_Supplier_Mapping__c(Data_Supplier_Raw__c= 'raw supplier test', Data_Supplier_Account__c = accId);
    } 
    
    //-- ----- get platform mapping records
    private static Platform_Mapping__c getPMRecords(){
        return new Platform_Mapping__c(Platform_Raw__c = 'raw test');
    }
    
    //-- ----- get revenue share mapping records
    private static Revenue_Share_Mapping__c getRSMRecords(){
        return new Revenue_Share_Mapping__c(Data_Supplier__c = 'test supplier', Segment_Name__c = 'raw test',Country__c ='India',Revenue_Share__c =1.0);
    }
    
    //-- ----- get segment mapping records
    private static Segment_Mapping__c getSMRecords(string salesRaw , string supplyRaw){
        return new Segment_Mapping__c(Segment_Name_Sales_Raw__c = salesRaw , Segment_Name_Supply_Raw__c = supplyRaw);
    } 
    
    
    
}