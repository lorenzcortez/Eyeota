public class MappingDashboardController{
    
    public List<SelectOption> fltrOptn {get;set;}
    public String  selOptn   {get;set;}
    public Boolean isExpChk  {get;set;}
    public Date    selDate   {get;set;}
    public integer index     {get;set;}    
    public String  selId     {get;set;}
    public String  selRecId  {get;set;}    
    public String  dlgTitle  {get;set;} // For show title bar name ...
    
    public Buyer_Mapping__c      buyerMapObj      {get;set;} // For buyer mapping ...   
    public List<BuyerModel>      buyerList        {get;set;}     
    public Platform_Mapping__c   platformMapObj   {get;set;} // For platform mapping...    
    public List<PlatformModel>   platformList     {get;set;}    
    public Advertiser_Mapping__c advertiserMapObj {get;set;} // for Advertiser mapping...   
    public List<AdvertiserModel> advertiserList   {get;set;}
    
    public Campaign_Mapping__c campaignMapObj {get;set;}   // // for Campaign mapping... 
    public List<CampaignModel> campaignList {get;set;}
    
    public Segment_Mapping__c    segmentMapObj    {get;set;} // for segment mapping...
    public List<SegmentModel>    segmentList      {get;set;}
    
    public Data_Supplier_Mapping__c dataSupplierMapObj  {get;set;} // for data supplier mapping...   
    public List<DataSupplierModel>  dataSupplierList    {get;set;}
    
    public Revenue_Share_Mapping__c revenueShareMapObj  {get;set;} // For revenue share mapping ...   
    public List<RevenueShareModel>  revenueList         {get;set;}    
    
    
    public String compareField  {get;set;} // For sorting...
    public String sortOrder     {get;set;}
    public Boolean hasNext      {get;set;} // For pagination ...
    public Boolean hasPrev      {get;set;} 
    public Integer maxPageSize  {get;set;}
    public Integer currentPage  {get;set;}    
    public String whatId        {get;set;} // For custom lookup ... 
    public String whatName      {get;set;}
    public Boolean isErr        {get;set;}
    public Integer count2       {get;set;} // added by ishan on 12th april
    public String selSector2Val {get;set;}
    public String selSector1Val {get;set;}
    public String publisherSiteType {get;set;}
    public String publisherVert {get;set;}
    public String publisherDataType {get;set;}
    public String  curC {get;set;}    //CurrencyCode field added by saifullah 23rd Mar 2017
    
    //Added at 24th Feb 2017
    public String gotoIndex{get;set;}
    public Date   selInvDate{get;set;}
    
    private Integer recordsPerPage = 20;     
    private Map<String,Account> accMap;    
    
    public MappingDashboardController(){
        isExpChk = false;
        inIt();
        sortOrder    = 'asc';
        selDate = system.Today(); 
        selInvDate = system.Today(); 
        getFilterOptions();        
        fetchRecords();
    }
    
    // --------------------------------- Initialization --------------------------------
    private void inIt(){
        // for pagination set default
        hasNext = hasPrev =  isErr = false;
        index = 0;        
        
        // to buyer mapping
        buyerMapObj = new Buyer_Mapping__c();    
        buyerList = new List<BuyerModel>();
        
        // to revenue share mapping
        revenueShareMapObj = new Revenue_Share_Mapping__c();     
        revenueList  = new List<RevenueShareModel>();
        
        // to platform mapping
        platformMapObj = new Platform_Mapping__c();   
        platformList = new List<PlatformModel>();
        
        // to Advertiser mapping
        advertiserMapObj = new Advertiser_Mapping__c ();
        advertiserList = new List<AdvertiserModel>();
        
        // to Campaign mapping
        campaignMapObj = new Campaign_Mapping__c ();
        campaignList = new List<CampaignModel>();
        
        // to data supplier mapping
        dataSupplierMapObj = new Data_Supplier_Mapping__c();
        dataSupplierList = new List<DataSupplierModel>();
        
        // to segment mapping
        segmentMapObj = new Segment_Mapping__c(); 
        segmentList = new List<SegmentModel>();
    }
    
    // getting the filter list ...
    private void getFilterOptions(){    
        fltrOptn = new List<SelectOption>();
        selOptn = 'BM'; 
        fltrOptn.add(new SelectOption('BM','Buyer Mapping'));
        fltrOptn.add(new SelectOption('AM','Advertiser Mapping'));
        fltrOptn.add(new SelectOption('DM','Data Supplier Mapping'));
        fltrOptn.add(new SelectOption('RM','Revenue Share Mapping'));
        fltrOptn.add(new SelectOption('SM','Segment Mapping'));
        fltrOptn.add(new SelectOption('PM','Platform Mapping'));
        fltrOptn.add(new SelectOption('CM','Campaign Mapping'));
        fltrOptn.sort();
    }
    
    // getting the records ...
    public void fetchRecords(){
        if(string.isNotBlank(selOptn)){
            if(selOptn =='AM'){
                dlgTitle = 'New Advertiser';
                compareField  = 'Advertiser_Raw__c';
                fetchAdvertisers();
            }else if(selOptn =='DM'){
                dlgTitle = 'New Data Supplier';
                compareField  = 'Data_Supplier_Raw__c';
                fetchDataSuppliers();
            }else if(selOptn =='RM'){
                dlgTitle = 'New Revenue Share';
                compareField  = 'Data_Supplier__c';
                fetchRevenueShares();
            }else if(selOptn =='PM'){
                dlgTitle = 'New Platform';
                compareField  = 'Platform_Raw__c';
                fetchPlatforms();
            }else if(selOptn == 'SM'){
                dlgTitle = 'New Segment';
                compareField  = 'Segment_Name_Sales_Raw__c';
                fetchSegments();
            }else if(selOptn == 'CM'){
                dlgTitle = 'New Segment';
                compareField  = 'Campaign_Raw__c';
                fetchCampaign();
            }else{
                dlgTitle = 'New Buyer';
                compareField = 'Buyer_Raw__c';
                fetchBuyers();
            }
        }  
    }
    
    //--------------------------------- Buyer Mapping Section ----------------------------------
    public void fetchBuyers(){
        Map<Integer,List<BuyerModel>> buyerMap = getBuyerMappings();
        if(buyerMap.containsKey(1)){
            buyerList.addAll(buyerMap.get(1));
            currentPage = 1;
        }
        hasNext = buyerMap.size() > 1 ? true : false;
        maxPageSize = buyerMap.size();
    }
    
    // getting the buyers records ...
    private Map<Integer,List<BuyerModel>> getBuyerMappings(){
        inIt();
        Map<Integer,List<BuyerModel>> buyerMap = new Map<Integer,List<BuyerModel>>();
        String qry = 'select Id,Buyer_Global__c, OwnerId,Buyer_and_Buyer_Country__c, Owner.Name,Buyer_Country_Raw__c,Buyer_Account__c,Buyer_Account__r.Name, ';
        qry += 'Buyer_Raw__c, PDT_Member__c, Platform__c, Created_From_Exception__c from Buyer_Mapping__c Where Created_From_Exception__c=';  
        qry += isExpChk ? 'true' : 'false';
        qry +=' order by '+compareField+' '+ sortOrder + ' NULLS ' + (sortOrder == 'asc' ? 'LAST' : 'FIRST');
        
        List<BuyerModel> templst = new List<BuyerModel>();
        for(Buyer_Mapping__c bm : DataBase.Query(qry)){
            templst.add(new BuyerModel(bm));
            if(templst.size() == recordsPerPage){
                buyerMap.put(buyerMap.size() + 1, templst);
                templst = new List<BuyerModel>();
            }
        }
        
        // fatching the remaining records ...
        if(!templst.isEmpty()){
            buyerMap.put(buyerMap.size() + 1, templst);            
        }
        
        return buyerMap;
    }
    
    // --------------------------- fetching Revenue Share records ----------------------------
    public void fetchRevenueShares(){
        Map<integer,list<RevenueShareModel>> revenueMap = getRevenueShareMapping();
        if(revenueMap.containsKey(1)){
            revenueList.addAll(revenueMap.get(1));
            currentPage = 1;
        }
        hasNext = revenueMap.size() > 1 ? true : false;
        maxPageSize = revenueMap.size();
    }
    
    private Map<integer,list<RevenueShareModel>> getRevenueShareMapping(){
        inIt();
        Map<integer,list<RevenueShareModel>> revenueMap = new map<integer,list<RevenueShareModel>>();
        String qry = 'select Id, OwnerId, Owner.Name, Data_Supplier__c, Revenue_Share__c, Created_From_Exception__c, ';
        qry += 'Segment_Name__c, Country__c from Revenue_Share_Mapping__c Where Created_From_Exception__c=';  
        qry += isExpChk ? 'true' : 'false'; 
        qry +=' order by '+compareField+' '+ sortOrder + ' NULLS ' + (sortOrder == 'asc' ? 'LAST' : 'FIRST');
        
        List<RevenueShareModel> templst = new List<RevenueShareModel>();
        for(sObject sobj : DataBase.Query(qry)){
            templst.add(new RevenueShareModel((Revenue_Share_Mapping__c)sobj));
            if(templst.size() == recordsPerPage){
                revenueMap.put(revenueMap.size() + 1, templst);
                templst = new List<RevenueShareModel>();
            }
        }
        // fatching the remaining records ...
        if(!templst.isEmpty()){
            revenueMap.put(revenueMap.size() + 1, templst); 
        }           
        return revenueMap;
    }
    
    // --------------------------- fetching platform records ----------------------------
    public void fetchPlatforms(){
        Map<integer,list<PlatformModel>> platformMap = getPlatformMapping();
        if(platformMap.containsKey(1)){
            platformList.addAll(platformMap.get(1));
            currentPage = 1;
        }
        hasNext = platformMap.size() > 1 ? true : false;
        maxPageSize = platformMap.size();
    }
    
    private Map<integer,list<PlatformModel>> getPlatformMapping(){
        inIt();
        Map<integer,list<PlatformModel>> platformMap = new Map<integer,list<PlatformModel>>();
        String qry = 'select Id, OwnerId, Owner.Name, Platform_Raw__c, Platform_Account__c, Created_From_Exception__c,Platform__c,Platform_Account__r.Name  from Platform_Mapping__c Where Created_From_Exception__c=';  
        qry += isExpChk ? 'true' : 'false';  
        qry +=' order by '+compareField+' '+ sortOrder + ' NULLS ' + (sortOrder == 'asc' ? 'LAST' : 'FIRST');
        
        List<PlatformModel> templst = new List<PlatformModel>();
        for(sObject sobj : DataBase.Query(qry)){
            templst.add(new PlatformModel((Platform_Mapping__c)sobj));
            if(templst.size() == recordsPerPage){
                platformMap.put(platformMap.size() + 1, templst);
                templst = new List<PlatformModel>();
            }
        }
        // fatching the remaining records ...
        if(!templst.isEmpty()){
            platformMap.put(platformMap.size() + 1, templst);            
        }
        return platformMap;
    }
    
    // --------------------------- fetching Advertisers records ----------------------------
    public void fetchAdvertisers(){
        Map<integer,list<AdvertiserModel>> advertiserMap = getAdvertiserMapping();
        if(advertiserMap.containsKey(1)){
            advertiserList.addAll(advertiserMap.get(1));
            currentPage = 1;
            
            //Calculating sales database revenue, added at 1st March 2017
            fetchSalesReve(advertiserList);
        }
        hasNext = advertiserMap.size() > 1 ? true : false;
        maxPageSize = advertiserMap.size();
    }
    
    private Map<integer,list<AdvertiserModel>> getAdvertiserMapping(){
        inIt();
        Map<integer,list<AdvertiserModel>> advertiserMap = new Map<integer,list<AdvertiserModel>>();
        String qry  = 'select Id, OwnerId, Owner.Name, Advertiser_Raw__c, Advertiser_Account__c, Advertiser_Account__r.Name, Advertiser_Account__r.Advertiser_Sector_1__c, ';
        qry +='Advertiser_Account__r.Advertiser_Sector_2_New__c , Created_From_Exception__c from Advertiser_Mapping__c WHERE Created_From_Exception__c=';  
        qry += isExpChk ? 'true' : 'false';  
        qry +=' order by '+compareField+' '+ sortOrder + ' NULLS ' + (sortOrder == 'asc' ? 'LAST' : 'FIRST');
        
        List<AdvertiserModel> templst = new List<AdvertiserModel>();        
        for(Advertiser_Mapping__c sobj : DataBase.Query(qry)){
            templst.add(new AdvertiserModel(sobj));
            if(templst.size() == recordsPerPage){
                advertiserMap.put(advertiserMap.size() + 1, templst);
                templst = new List<AdvertiserModel>();
            }
        }       
        // fatching the remaining records ...
        if(!templst.isEmpty()){
            advertiserMap.put(advertiserMap.size() + 1, templst);  
        }           
        return advertiserMap;
    }
    
    //This function is used to rollup sales revenue bases of advertiser mapping, added on 1st March 2017
    // Again editted for Searching from both dates 20th July 2017
    private void fetchSalesReve(list<AdvertiserModel> adverModLst){
        map<String,Decimal> adverRowMap = new map<String,Decimal>();
        for(AdvertiserModel adMod : adverModLst){
            if(adMod.am.Advertiser_Raw__c != null)
                adverRowMap.put(adMod.am.Advertiser_Raw__c,0);
        }
        
        if(adverRowMap.size() > 0){        
            if(selDate == null && selInvDate == null){
                for(AggregateResult ar : [select Advertiser_Raw__c advRaw,sum(Revenue__c) totRev from Sales_Database__c where Advertiser_Raw__c IN:adverRowMap.keySet() AND Revenue__c != null  group by Advertiser_Raw__c])  {
                    String advRaw = String.valueOf(ar.get('advRaw'));
                    Decimal salRevenueTot = ((Decimal)ar.get('totRev')).setScale(3);
                    adverRowMap.put(advRaw,salRevenueTot);
                }
            }else if(selDate != null && selInvDate != null){
                for(AggregateResult ar : [select Advertiser_Raw__c advRaw,sum(Revenue__c) totRev from Sales_Database__c where Advertiser_Raw__c IN:adverRowMap.keySet() AND Revenue__c != null AND ((CALENDAR_MONTH(Date__c) =: selDate.month() AND CALENDAR_YEAR(Date__c) =: selDate.Year()) OR (CALENDAR_MONTH(Date_Invoiced__c) =: selInvDate.month() AND CALENDAR_YEAR(Date_Invoiced__c) =: selInvDate.Year())) group by Advertiser_Raw__c]){
                    String advRaw = String.valueOf(ar.get('advRaw'));
                    Decimal salRevenueTot = ((Decimal)ar.get('totRev')).setScale(3);
                    adverRowMap.put(advRaw,salRevenueTot);
                }
            }else if(selDate != Null && selInvDate == null){
                for(AggregateResult ar : [select Advertiser_Raw__c advRaw,sum(Revenue__c) totRev from Sales_Database__c where Advertiser_Raw__c IN:adverRowMap.keySet() AND Revenue__c != null AND (CALENDAR_MONTH(Date__c) =: selDate.month() AND CALENDAR_YEAR(Date__c) =: selDate.Year()) group by Advertiser_Raw__c]){
                    String advRaw = String.valueOf(ar.get('advRaw'));
                    Decimal salRevenueTot = ((Decimal)ar.get('totRev')).setScale(3);
                    adverRowMap.put(advRaw,salRevenueTot);
                }
            }
            else if(selDate == Null && selInvDate != null){
                for(AggregateResult ar : [select Advertiser_Raw__c advRaw,sum(Revenue__c) totRev from Sales_Database__c where Advertiser_Raw__c IN:adverRowMap.keySet() AND Revenue__c != null AND (CALENDAR_MONTH(Date_Invoiced__c) =: selInvDate.month() AND CALENDAR_YEAR(Date_Invoiced__c) =: selInvDate.Year()) group by Advertiser_Raw__c]){
                    String advRaw = String.valueOf(ar.get('advRaw'));
                    Decimal salRevenueTot = ((Decimal)ar.get('totRev')).setScale(3);
                    adverRowMap.put(advRaw,salRevenueTot);
                }
            }
        }
        
        
        for(AdvertiserModel adMod : adverModLst){
            if(adMod.am.Advertiser_Raw__c != null){
                adMod.salesDBRevenue = adverRowMap.get(adMod.am.Advertiser_Raw__c);
            }
        }
    }
    
    // --------------------------- fetching Campaign records ----------------------------
    public void fetchCampaign(){
        Map<integer,list<CampaignModel>> CampaignMap = getCampaignMapping();
        if(CampaignMap.containsKey(1)){
            campaignList.addAll(CampaignMap.get(1));
            currentPage = 1;
        }
        hasNext = CampaignMap.size() > 1 ? true : false;
        maxPageSize = CampaignMap.size();
    }    
    private Map<integer,list<CampaignModel>> getCampaignMapping(){
        inIt();
        Map<integer,list<CampaignModel>> CampaignMap = new Map<integer,list<CampaignModel>>();
        String qry  = 'select Id, OwnerId, Owner.Name, Campaign_Raw__c, Advertiser_Account__c, Advertiser_Account__r.Name, Advertiser_Account__r.Advertiser_Sector_1__c, ';
        qry +='Advertiser_Account__r.Advertiser_Sector_2_New__c , Created_From_Exception__c from Campaign_Mapping__c WHERE Created_From_Exception__c=';  
        qry += isExpChk ? 'true' : 'false';  
        qry +=' order by '+compareField+' '+ sortOrder + ' NULLS ' + (sortOrder == 'asc' ? 'LAST' : 'FIRST');
        
        List<CampaignModel> templst = new List<CampaignModel>();        
        for(Campaign_Mapping__c sobj : DataBase.Query(qry)){
            templst.add(new CampaignModel(sobj));
            if(templst.size() == recordsPerPage){
                CampaignMap.put(CampaignMap.size() + 1, templst);
                templst = new List<CampaignModel>();
            }
        }
        
        // fatching the remaining records ...
        if(!templst.isEmpty()){
            CampaignMap.put(CampaignMap.size() + 1, templst);  
        }           
        return CampaignMap;
    }
    
    // --------------------------- fetching Data Supplier records ----------------------------  
    public void fetchDataSuppliers(){
        Map<integer,list<DataSupplierModel>> dataSupplierMap = getDataSupplierMapping();
        if(dataSupplierMap.containsKey(1)){
            dataSupplierList.addAll(dataSupplierMap.get(1));
            currentPage = 1;
        }
        hasNext = dataSupplierMap.size() > 1 ? true : false;
        maxPageSize = dataSupplierMap.size();
    }
    
    private Map<integer,list<DataSupplierModel>> getDataSupplierMapping(){
        inIt();
        Map<integer,list<DataSupplierModel>> dataSupplierMap = new Map<integer,list<DataSupplierModel>>();
        String qry = 'select Id, OwnerId, Owner.Name, Data_Supplier_Raw__c, Data_Supplier_Account__r.Name, Data_Supplier_Account__c,Data_Supplier_Account__r.Publisher_Data_Type__c, ';
        qry += 'Data_Supplier_Account__r.Publisher_Site_Type__c,Data_Supplier_Account__r.Publisher_Site_Vertical__c,Data_Supplier_Account__r.Currency_Code__c, Created_From_Exception__c from Data_Supplier_Mapping__c WHERE Created_From_Exception__c='; 
        qry += isExpChk ? 'true' : 'false';   
        qry +=' order by '+compareField+' '+ sortOrder + ' NULLS ' + (sortOrder == 'asc' ? 'LAST' : 'FIRST');
        
        List<DataSupplierModel> templst = new List<DataSupplierModel>();
        
        for(Data_Supplier_Mapping__c sobj : DataBase.Query(qry)){
            templst.add(new DataSupplierModel(sobj));
            if(templst.size() == recordsPerPage){
                dataSupplierMap.put(dataSupplierMap.size() + 1, templst);
                templst = new List<DataSupplierModel>();
            }
        }
        
        // fatching the remaining records ...
        if(!templst.isEmpty()){
            dataSupplierMap.put(dataSupplierMap.size() + 1, templst);
        }
        return dataSupplierMap;
    }
    
    // --------------------------- fetching segment records ----------------------------
    public void fetchSegments(){
        Map<integer,list<SegmentModel>> segmentMap = getSegmentsMapping();
        if(segmentMap.containsKey(1)){
            segmentList.addAll(segmentMap.get(1));
            currentPage = 1;
        }
        hasNext     = segmentMap.size() > 1 ? true : false;
        maxPageSize = segmentMap.size();
    }
    
    private Map<integer,list<SegmentModel>> getSegmentsMapping(){
        inIt();
        Map<integer,list<SegmentModel>> segmentMap = new Map<integer,list<SegmentModel>>();
        String qry = 'select Id, Segment_Name__c, Segment_Name_Sales_Raw__c, Segment_Category_Mapping__r.Name,Segment_Name_Supply_Raw__c, Segment_Category_Mapping__c, ';
        qry += 'Segment_Category_Mapping__r.Segment_Name__c, Segment_Category_Mapping__r.Segment_Category__c, ';
        qry += 'Segment_Category_Mapping__r.Segment_Code__c, Segment_Category_Mapping__r.Rate_Card_CPM__c, Created_From_Exception__c from Segment_Mapping__c Where Created_From_Exception__c=';  
        qry += isExpChk ? 'true' : 'false';  
        qry +=' order by '+compareField+' '+ sortOrder + ' NULLS ' + (sortOrder == 'asc' ? 'LAST' : 'FIRST') + ' LIMIT 50000';
        
        List<SegmentModel> templst = new List<SegmentModel>();
        
        for(Segment_Mapping__c sobj : DataBase.Query(qry)){
            templst.add(new SegmentModel(sobj));
            if(templst.size() == recordsPerPage){
                segmentMap.put(segmentMap.size() + 1, templst);
                templst = new List<SegmentModel>();
            }
        }
        
        // fatching the remaining records ...
        if(!templst.isEmpty()){
            segmentMap.put(segmentMap.size() + 1, templst);
        }
        return segmentMap;
    }
    
    
    //------------------------------- Pagination Methods --------------------------------------------
    public void nextPage(){
        if(currentPage != null && hasNext && String.isNotBlank(selOptn)){           
            getNextOrPrevRecords(currentPage + 1);
        }            
    }
    
    // redirecting to previous page ...
    public void prevPage(){
        if(currentPage != null && hasPrev && String.isNotBlank(selOptn)){           
            getNextOrPrevRecords(currentPage - 1);
        }
    }
    
    // Go to functionality.. Added on 24th Feb 2017
    public void goToPage(){
        if(String.isNotBlank(gotoIndex)){
            Integer tempCurrPg = currentPage; 
            try{
                currentPage = Integer.valueOf(gotoIndex);
                if(currentPage != null && String.isNotBlank(selOptn)){           
                    getNextOrPrevRecords(currentPage);
                }
            }catch(Exception e){
                currentPage = tempCurrPg; 
            }
        }
    }
    
    private void getNextOrPrevRecords(Integer nextIndx){
        if(selOptn == 'AM'){
            Map<integer,list<AdvertiserModel>> advertiserMap = getAdvertiserMapping();
            if(advertiserMap.containsKey(nextIndx)){
                advertiserList.clear();
                advertiserList.addAll(advertiserMap.get(nextIndx));
                currentPage = nextIndx;
                hasPrev = currentPage == 1 ? false : true;
                hasNext = advertiserMap.size() > currentPage ? true : false;
                
                //Calculating sales database revenue, added on 1st March 2017
                fetchSalesReve(advertiserList);
            }
        }else if(selOptn == 'CM'){
            Map<integer,list<CampaignModel>> CampaignMap = getCampaignMapping();
            if(CampaignMap.containsKey(nextIndx)){
                campaignList.clear();
                campaignList.addAll(CampaignMap.get(nextIndx));
                currentPage = nextIndx;
                hasPrev = currentPage == 1 ? false : true;
                hasNext = CampaignMap.size() > currentPage ? true : false;
            }                
        }else if(selOptn == 'DM'){
            Map<integer,list<DataSupplierModel>> dataSupplierMap = getDataSupplierMapping();
            if(dataSupplierMap.containsKey(nextIndx)){
                dataSupplierList.clear();
                dataSupplierList.addAll(dataSupplierMap.get(nextIndx));
                currentPage = nextIndx;
                hasPrev = currentPage == 1 ? false : true;
                hasNext = dataSupplierMap.size() > currentPage ? true : false;
            }                
        }else if(selOptn == 'RM'){
            Map<integer,list<RevenueShareModel>> revenueMap = getRevenueShareMapping();
            if(revenueMap.containsKey(nextIndx)){
                revenueList.clear();
                revenueList.addAll(revenueMap.get(nextIndx));
                currentPage = nextIndx;
                hasPrev = currentPage == 1 ? false : true;
                hasNext = revenueMap.size() > currentPage ? true : false;
            }
        }else if(selOptn == 'PM'){
            
            Map<integer,list<PlatformModel>> platformMap = getPlatformMapping();
            if(platformMap.containsKey(nextIndx)){
                platformList.clear();
                platformList.addAll(platformMap.get(nextIndx));
                currentPage = nextIndx;
                hasPrev = currentPage == 1 ? false : true;
                hasNext = platformMap.size() > currentPage ? true : false;
            }
        }else if(selOptn == 'SM'){
            Map<integer,list<SegmentModel>> segmentMap = getSegmentsMapping();
            if(segmentMap.containsKey(nextIndx)){
                segmentList.clear();
                segmentList.addAll(segmentMap.get(nextIndx));
                currentPage = nextIndx;
                hasPrev = currentPage == 1 ? false : true;
                hasNext = segmentMap.size() > currentPage ? true : false;
            }
        }else{
            Map<Integer,List<BuyerModel>> buyerMap = getBuyerMappings();
            if(buyerMap.containsKey(nextIndx)){
                buyerList.clear();
                buyerList.addAll(buyerMap.get(nextIndx));
                currentPage = nextIndx;
                hasPrev = currentPage == 1 ? false : true;
                hasNext = buyerMap.size() > currentPage ? true : false;
            }
        }  
    }
    
    //---------------------------------- creating New Records ----------------------------------------    
    // for creating new buyer record ...    
    private void createNewBuyer(){        
        if(string.isNotBlank(buyerMapObj.Buyer_Country_Raw__c) || string.isNotBlank(buyerMapObj.Buyer_Global__c) ||  string.isNotBlank(buyerMapObj.Buyer_Raw__c) || string.isNotBlank(buyerMapObj.PDT_Member__c) || string.isNotBlank(buyerMapObj.Platform__c)){
            insert buyerMapObj;
            buyerMapObj = new Buyer_Mapping__c();   
            fetchBuyers();
        }
    }
    
    // for create new revenue share records ...    
    private void createNewRevenues(){
        if(string.isNotBlank(revenueShareMapObj.Data_Supplier__c) || string.isNotBlank(revenueShareMapObj.Segment_Name__c) || string.isNotBlank(revenueShareMapObj.Country__c) || revenueShareMapObj.Revenue_Share__c !=null ){
            insert revenueShareMapObj; 
            revenueShareMapObj = new Revenue_Share_Mapping__c(); 
            fetchRevenueShares();
        }  
    }
    
    // for create new Platform records ...    
    private void createNewPlatforms(){
        if(string.isNotBlank(platformMapObj.Platform_Raw__c) || string.isNotBlank(platformMapObj.Platform_Account__c)){
            insert platformMapObj; 
            platformMapObj = new Platform_Mapping__c(); 
            fetchPlatforms();
        }
    }
    
    // for create new Advertiser records ...    
    private void createNewAdvertiser(){
        if(string.isNotBlank(advertiserMapObj.Advertiser_Raw__c) || string.isNotBlank(advertiserMapObj.Advertiser_Account__c)){
            insert advertiserMapObj; 
            advertiserMapObj = new Advertiser_Mapping__c();
            fetchAdvertisers();
        } 
    }
    
    // for create new Campaign records ...    
    private void createNewCampaign(){
        if(string.isNotBlank(campaignMapObj.Campaign_Raw__c) || string.isNotBlank(campaignMapObj.Advertiser_Account__c)){
            insert campaignMapObj; 
            campaignMapObj = new Campaign_Mapping__c();
            fetchCampaign();
        } 
    }
    
    // for create new Data Supplier records ...    
    private void createNewDataSupplier(){
        if(string.isNotBlank(dataSupplierMapObj.Data_Supplier_Raw__c) || string.isNotBlank(dataSupplierMapObj.Data_Supplier_Account__c)){
            insert dataSupplierMapObj;
            dataSupplierMapObj = new Data_Supplier_Mapping__c();
            fetchDataSuppliers();
        }    
        
    }
    
    // for create new Segment records ...    
    private void createNewSegment(){
        if(string.isNotBlank(segmentMapObj.Segment_Name_Sales_Raw__c) || string.isNotBlank(segmentMapObj.Segment_Name_Supply_Raw__c) 
           || string.isNotBlank(segmentMapObj.Segment_Category_Mapping__c)){
               insert segmentMapObj; 
               segmentMapObj = new Segment_Mapping__c();
               fetchSegments();
           }   
    }
    
    // for creating new records ... 
    public void createNewRecords(){
        isErr = false;
        try{
            if(string.isNotBlank(selOptn)){
                if(selOptn =='AM'){
                    createNewAdvertiser();
                }else if(selOptn =='CM'){
                    createNewCampaign();
                }else if(selOptn =='DM'){
                    createNewDataSupplier();
                }else if(selOptn =='RM'){
                    createNewRevenues();
                }else if(selOptn =='PM'){
                    createNewPlatforms();
                }else if(selOptn == 'SM'){
                    createNewSegment();
                }else{
                    createNewBuyer();
                }
            }
        }catch(Exception exp){
            isErr = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,exp.getMessage()));        
        }
    }
    
    //---------------------------------- deleting New Records ----------------------------------------    
    // for delete mapping records
    public void  deleteMappingRecords(){
        if(string.isNotBlank(selOptn)){
            if(selOptn =='AM'){
                deleteAdvertiserMapping();
            }else if(selOptn =='CM'){
                deleteCampaignMapping();
            }else if(selOptn =='DM'){
                deleteDataSupplierMapping();
            }else if(selOptn =='RM'){
                deleteRevenueMapping();
            }else if(selOptn =='PM'){
                deletePlatformMapping(); 
            }else if(selOptn == 'SM'){
                deleteSegmentMapping();
            }else{
                deleteBuyerMapping();
            }
            fetchRecords();
        }  
    }
    
    // For deleting buyer record ...  
    private void deleteBuyerMapping(){
        try{
            Buyer_Mapping__c delRc = new Buyer_Mapping__c(Id=selId);
            delete delRc;
            
        }catch(Exception exp){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,exp.getMessage()));        
        }
    }
    
    // For deleting revenue record ...  
    private void deleteRevenueMapping(){
        try{
            Revenue_Share_Mapping__c delRc = new Revenue_Share_Mapping__c(Id=selId);
            delete delRc;
            
        }catch(Exception exp){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,exp.getMessage()));        
        }
    }
    
    // For deleting platform record ...  
    private void deletePlatformMapping(){
        try{
            Platform_Mapping__c delRc = new Platform_Mapping__c(Id=selId);
            delete delRc;
            
        }catch(Exception exp){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,exp.getMessage()));        
        }
    }
    
    // For deleting Advertiser record ...  
    private void deleteAdvertiserMapping(){
        try{
            Advertiser_Mapping__c delRc = new Advertiser_Mapping__c(Id=selId);
            delete delRc;
            
        }catch(Exception exp){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,exp.getMessage()));        
        }
    }
    
    // For deleting Campaign record ...  
    private void deleteCampaignMapping(){
        try{
            Campaign_Mapping__c delRc = new Campaign_Mapping__c(Id=selId);
            delete delRc;
            
        }catch(Exception exp){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,exp.getMessage()));        
        }
    }
    
    // For deleting data supplier record ...  
    private void deleteDataSupplierMapping(){
        try{
            Data_Supplier_Mapping__c delRc = new Data_Supplier_Mapping__c(Id=selId);
            delete delRc;
            
        }catch(Exception exp){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,exp.getMessage()));        
        }
    }
    
    // For deleting segment record ...  
    private void deleteSegmentMapping(){
        try{
            Segment_Mapping__c delRc = new Segment_Mapping__c(Id=selId);
            delete delRc;
            
        }catch(Exception exp){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,exp.getMessage()));        
        }
    }
    
    //----------------------------------------- Lookup Value Changed --------------------------
    public void lookupValueChanged(){
        if( selOptn =='SM' ){
            SegmentModel smMdl;
            for(SegmentModel mdl : segmentList){
                if(mdl.sm.Id == selRecId){
                    smMdl = mdl;
                    break;
                }
            }
            if( smMdl != null ){
                List<Segment_Category_Mapping__c> sgmtCategory = [SELECT Id, Segment_Category__c, Segment_Code__c, Rate_Card_CPM__c, Segment_Name__c
                                                                  FROM Segment_Category_Mapping__c WHERE ID = : smMdl.sm.Segment_Category_Mapping__c LIMIT 1];
                if( sgmtCategory != null && sgmtCategory.size() > 0){
                    smMdl.scmSN = sgmtCategory[0].Segment_Name__c;
                    smMdl.scmSCategory = sgmtCategory[0].Segment_Category__c;
                    smMdl.scmSCode = sgmtCategory[0].Segment_Code__c;
                    smMdl.scmRCC = sgmtCategory[0].Rate_Card_CPM__c;
                }
            }
        }
        else if( selOptn =='DM' ){
            DataSupplierModel dmMdl;
            for(DataSupplierModel mdl : dataSupplierList){
                if(mdl.dsm.Id == selRecId){
                    dmMdl = mdl;
                    break;
                }
            }
            if( dmMdl != null ){    
                List<Account> dataSupplierList = [SELECT Id, Publisher_Data_Type__c, Publisher_Site_Type__c, Publisher_Site_Vertical__c,Currency_Code__c 
                                                  FROM Account WHERE Id = : dmMdl.dsm.Data_Supplier_Account__c LIMIT 1];
                if( dataSupplierList != null && dataSupplierList.size() > 0 ){
                    dmMdl.accPDT = dataSupplierList[0].Publisher_Data_Type__c ;
                    dmMdl.accPST = dataSupplierList[0].Publisher_Site_Type__c ;
                    dmMdl.accPSV = dataSupplierList[0].Publisher_Site_Vertical__c ;
                    dmMdl.accCC = dataSupplierList[0].Currency_Code__c;
                }
            }
        }
        else if( selOptn =='AM' ){
            AdvertiserModel amMdl;
            for(AdvertiserModel mdl : advertiserList){
                if( mdl.am.Id == selRecId ){
                    amMdl = mdl;
                    break;
                }
            }
            if( amMdl != null ){
                system.debug('>>>>>>>>>>>>>'+amMdl.am.Advertiser_Account__c);
                List<Account> advertiserAcctList = [SELECT Id,Name,Advertiser_Sector_1__c, Advertiser_Sector_2_New__c  
                                                    FROM Account WHERE Id = :amMdl.am.Advertiser_Account__c LIMIT 1];
                if( advertiserAcctList != null && advertiserAcctList.size()> 0 ){
                    system.debug('>>>>22222>>>>>>>>>'+advertiserAcctList);
                    amMdl.accSector1 = advertiserAcctList[0].Advertiser_Sector_1__c;
                    amMdl.accSector2 = advertiserAcctList[0].Advertiser_Sector_2_New__c ;
                    
                    amMdl.am.Advertiser_Account__r = advertiserAcctList[0];
                  //  amMdl.am.Advertiser_Account__r.Advertiser_Sector_1__c =  amMdl.accSector1;
                  //  amMdl.am.Advertiser_Account__r.Advertiser_Sector_2_New__c = amMdl.accSector2;
                }
            }
        }
        else if( selOptn =='CM' ){
            CampaignModel cmMdl;
            for(CampaignModel mdl : campaignList){
                if( mdl.cm.Id == selRecId ){
                    cmMdl = mdl;
                    break;
                }
            }
            if( cmMdl != null ){
                List<Account> campaignAcctList = [SELECT Id,Name,Advertiser_Sector_1__c, Advertiser_Sector_2_New__c  
                                                  FROM Account WHERE Id = :cmMdl.cm.Advertiser_Account__c LIMIT 1];
                if( campaignAcctList != null && campaignAcctList.size()> 0 ){
                    cmMdl.accSector1 = campaignAcctList[0].Advertiser_Sector_1__c;
                    cmMdl.accSector2 = campaignAcctList[0].Advertiser_Sector_2_New__c ;
                    
                    cmMdl.cm.Advertiser_Account__r = campaignAcctList[0];
                    //cmMdl.cm.Advertiser_Account__r.Advertiser_Sector_1__c =  cmMdl.accSector1;
                   // cmMdl.cm.Advertiser_Account__r.Advertiser_Sector_2_New__c = cmMdl.accSector2;
                }
            }
        }
    }
    
    //----------------------------------------- Saving Methods Section ---------------------------------
    // starting the BatchProcess ...    
    public void SaveAndExecuteMapping(){
        isErr = false;
        try{
            if(string.isNotBlank(selOptn) && (selDate != null || selInvDate != null)){
                if(selOptn =='AM' || selOptn == 'BM'){
                    if( selOptn =='AM' ){
                        DELETE [SELECT Id FROM Advertiser_Mapping__c WHERE Created_From_Exception__c = true];
                    }
                    else{
                        DELETE [SELECT Id FROM Buyer_Mapping__c WHERE Created_From_Exception__c = true];
                    }
                    DataBase.ExecuteBatch(new ProcessSalesDatabaseScriptBatch(selDate, selInvDate, (selOptn =='AM' ? 'Advertiser Mapping' : 'Buyer Mapping')),Integer.valueOf(label.ProcessSalesDatabaseBatchSize));
                }else if(selDate != null && (selOptn =='DM' || selOptn =='RM')){
                    if( selOptn =='DM' ){
                        DELETE [SELECT Id FROM Data_Supplier_Mapping__c WHERE Created_From_Exception__c = true];
                    }
                    else{
                        DELETE [SELECT Id FROM Revenue_Share_Mapping__c WHERE Created_From_Exception__c = true];
                    }
                    DataBase.ExecuteBatch(new ProcessSupplyDatabaseScriptBatch(selDate, (selOptn =='DM' ? 'Data Supplier Mapping' : 'Revenue Share Mapping')));
                }else if(selOptn =='PM'){
                    DELETE [SELECT Id FROM Platform_Mapping__c WHERE Created_From_Exception__c = true];
                    DataBase.ExecuteBatch(new ProcessSalesDatabaseScriptBatch(selDate, selInvDate, 'Platform Mapping'),Integer.valueOf(label.ProcessSalesDatabaseBatchSize));
                }else if(selOptn =='CM'){
                    DELETE [SELECT Id FROM Campaign_Mapping__c WHERE Created_From_Exception__c = true];
                    DataBase.ExecuteBatch(new ProcessSalesDatabaseScriptBatch(selDate,selInvDate, 'Campaign Mapping'),Integer.valueOf(label.ProcessSalesDatabaseBatchSize));
                }else if(selOptn == 'SM'){
                    DELETE [SELECT Id FROM Segment_Mapping__c WHERE Created_From_Exception__c = true];
                    DataBase.ExecuteBatch(new ProcessSalesDatabaseScriptBatch(selDate,selInvDate, 'Segment Mapping'),Integer.valueOf(label.ProcessSalesDatabaseBatchSize));
                    if(selDate != null)
                        DataBase.ExecuteBatch(new ProcessSupplyDatabaseScriptBatch(selDate, 'Segment Mapping'),Integer.valueOf(label.ProcessSupplyDatabaseBatchSize));
                }
            }
        }catch(Exception exp){
            isErr = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,exp.getMessage()));        
        }
    }
    
    // saving the record ...
    public void saveRecord(){
        isErr = false;
        try{
            if(selRecId != null && selRecId.length() > 0){
                if(selOptn =='AM'){
                    saveAdvertiseMapping(selRecId);
                }else if(selOptn =='CM'){
                    saveCampaignMapping(selRecId);
                }else if(selOptn =='DM'){
                    saveDataSupplierMapping(selRecId);
                }else if(selOptn =='RM'){
                    saveRevenueShareMapping(selRecId);
                }else if(selOptn =='PM'){
                    savePlatformShareMapping(selRecId);
                }else if(selOptn == 'SM'){
                    saveSagmentMapping(selRecId);
                }else if(selOptn == 'BM'){
                    saveBuyerMapping(selRecId);
                }
                selRecId = '';
            }
        }catch(Exception exp){
            isErr = true;            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,exp.getMessage()));        
        }
    }
    
    // For saving sagment mapping  record ...
    private void saveSagmentMapping(String recId){
        List<Segment_Mapping__c> updateSM = new List<Segment_Mapping__c>();
        list<Segment_Category_Mapping__c> updateSCM = new list<Segment_Category_Mapping__c>();
        for(SegmentModel mdl : segmentList){
            if(mdl.sm.Id == recId){
                mdl.sm.Created_From_Exception__c = false;
                updateSM.add(mdl.sm);
            }
            if(mdl.sm.Segment_Category_Mapping__c!=null){
                updateSCM.add(new Segment_Category_Mapping__c(id=mdl.sm.Segment_Category_Mapping__c,Segment_Name__c = mdl.scmSN, Rate_Card_CPM__c = mdl.scmRCC ,Segment_Category__c = mdl.scmSCategory, Segment_Code__c = mdl.scmSCode));
            }
        }
        if(!updateSM.isEmpty()){
            update updateSM;
        }
        if(updateSCM.size()>0){
            update updateSCM; 
        }
        fetchRecords(); 
    }
    
    // For saving  advertise mapping  record ...
    private void saveAdvertiseMapping(String recId){
        try{
            set<Id> setid = new Set<Id>();
            for(AdvertiserModel mdl : advertiserList){
                if(mdl.am.Advertiser_Account__c!=null){
                    setid.add(mdl.am.Advertiser_Account__c);
                }
            }
            List<Advertiser_Mapping__c> updateAM = new List<Advertiser_Mapping__c>();
            List<account> updateAcc = new List<account>();
            for(AdvertiserModel mdl : advertiserList){
                if(mdl.am.Id == recId){
                    mdl.am.Created_From_Exception__c = false;
                    updateAM.add(mdl.am);
                    mdl.isOpn = true;
                }
                if(mdl.am.Id == recId){
                    if(mdl.am.Advertiser_Account__c!=null)
                    {
                        Account acc = new Account(Id=mdl.am.Advertiser_Account__c);
                        if(selSector1Val != null && selSector1Val != '' && selSector1Val != 'none'){
                            acc.Advertiser_Sector_1__c= selSector1Val;
                        }else if(selSector1Val != null && selSector1Val == 'none'){
                            acc.Advertiser_Sector_1__c= null;
                        }else{
                            acc.Advertiser_Sector_1__c= mdl.am.Advertiser_Account__r.Advertiser_Sector_1__c;
                        }
                        if(selSector2Val != null && selSector2Val != '' && selSector2Val != 'none'){
                            acc.Advertiser_Sector_2_New__c = selSector2Val;
                        }else if(selSector2Val != null && selSector2Val == 'none'){
                            acc.Advertiser_Sector_2_New__c = null;
                        }else{
                            acc.Advertiser_Sector_2_New__c = mdl.am.Advertiser_Account__r.Advertiser_Sector_2_New__c;
                        }
                        
                        updateAcc.add(acc);
                        
                        mdl.isOpn = true;
                    }
                }
            }
            
            if(!updateAM.isEmpty()){
                update updateAM;
            }
            
            if(updateAcc.size()>0){
                update updateAcc; 
            } 
            fetchRecords(); 
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }   
    }
    
    // For saving  Campaign mapping  record ...
    private void saveCampaignMapping(String recId){
        try{
            set<Id> setIds = new Set<Id>();
            for(CampaignModel mdl : campaignList){
                if(mdl.cm.Advertiser_Account__c!=null){
                    setids.add(mdl.cm.Advertiser_Account__c);
                }
            }
            List<Campaign_Mapping__c> updateCM = new List<Campaign_Mapping__c>();
            List<account> updateAcct = new List<account>();
            for(CampaignModel mdl : campaignList){
                if(mdl.cm.Id == recId){
                    mdl.cm.Created_From_Exception__c = false;
                    updateCM.add(mdl.cm);
                    mdl.isOpn = true;
                }
                if(mdl.cm.Id == recId){
                    if(mdl.cm.Advertiser_Account__c!=null)
                    {
                        Account acc = new Account(Id=mdl.cm.Advertiser_Account__c);
                        if(mdl.accSector1 != null && mdl.accSector1.length() > 0 )
                        {
                            acc.Advertiser_Sector_1__c= mdl.cm.Advertiser_Account__r.Advertiser_Sector_1__c;
                        }if(mdl.accSector2 != null && mdl.accSector2.length() > 0 )
                        {
                            acc.Advertiser_Sector_2_New__c = mdl.cm.Advertiser_Account__r.Advertiser_Sector_2_New__c;
                        }
                        
                        updateAcct.add(acc);
                        mdl.isOpn = true;
                    }
                }
            }
            
            if(!updateCM.isEmpty()){
                update updateCM;
            }
            
            if(updateAcct.size()>0){
                update updateAcct; 
            } 
            fetchRecords(); 
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }   
    }
    
    // For saving  advertise mapping  record ...
    private void saveDataSupplierMapping(String recId){
        List<Data_Supplier_Mapping__c> updateDSM = new List<Data_Supplier_Mapping__c>();
        list<account> updateAcc = new list<account>();
        
        for(DataSupplierModel mdl : dataSupplierList){
            if(mdl.dsm.Id == recId){
                mdl.dsm.Created_From_Exception__c = false;
                updateDSM.add(mdl.dsm);
                mdl.isOpn = true;
            }
            
            if(mdl.dsm.Id == recId && mdl.dsm.Data_Supplier_Account__c!=null){
                Account ac = new Account();
                ac.Id = mdl.dsm.Data_Supplier_Account__c;
                if(publisherDataType != null && publisherDataType != '' && publisherDataType != 'none'){
                    ac.Publisher_Data_Type__c = publisherDataType;
                }else if(publisherDataType != null && publisherDataType == 'none'){
                    ac.Publisher_Data_Type__c = null;
                }else{
                    ac.Publisher_Data_Type__c = mdl.dsm.Data_Supplier_Account__r.Publisher_Data_Type__c;
                }
                
                if(publisherSiteType != null && publisherSiteType != '' && publisherSiteType != 'none'){
                    ac.Publisher_Site_Type__c = publisherSiteType;
                }else if(publisherSiteType != null && publisherSiteType == 'none'){
                    ac.Publisher_Site_Type__c = null;
                }else{
                    ac.Publisher_Site_Type__c = mdl.dsm.Data_Supplier_Account__r.Publisher_Site_Type__c;
                }   
                
                if(publisherVert != null && publisherVert != '' && publisherVert != 'none'){
                    ac.Publisher_Site_Vertical__c = publisherVert;
                }else if(publisherVert != null && publisherVert == 'none'){
                    ac.Publisher_Site_Vertical__c = null;
                }else{
                    ac.Publisher_Site_Vertical__c = mdl.dsm.Data_Supplier_Account__r.Publisher_Site_Vertical__c;
                }
                
                
                if(curC != null && curC != '' && curC != 'none'){
                    ac.Currency_Code__c = curC;
                }else if(curC != null && curC == 'none'){
                    ac.Currency_Code__c = null;
                }else{
                    ac.Currency_Code__c = mdl.dsm.Data_Supplier_Account__r.Currency_Code__c;
                }
                
                updateAcc.add(ac);
                
                mdl.isOpn = true;
            }
        }
        
        if(updateAcc.size()>0){
            update updateAcc;      
        } 
        if(!updateDSM.isEmpty()){
            update updateDSM;
        }
        
        fetchRecords();  
    }
    
    //----------------------------------- Creating and updating the plateform mapping records -------------------------
    // For saving  advertise mapping  record ...
    private void savePlatformShareMapping(String recId){
        List<Platform_Mapping__c> updatePM = new List<Platform_Mapping__c>();
        for(PlatformModel mdl : platformList){
            if(mdl.pm.Id == recId){
                mdl.pm.Created_From_Exception__c = false;
                updatePM.add(mdl.pm);
                mdl.isOpn = true;
            }
        }
        
        if(!updatePM.isEmpty()){            
            update updatePM;
        } 
        fetchRecords();        
    }
    
    //----------------------------------- Creating and updating the revenue sharing mapping records -------------------------    
    // For saving  advertise mapping  record ...
    private void saveRevenueShareMapping(String recId){
        List<Revenue_Share_Mapping__c> updateRSM = new List<Revenue_Share_Mapping__c>();
        for(RevenueShareModel mdl : revenueList){
            if(mdl.rsm.Id == recId){
                mdl.rsm.Created_From_Exception__c = false;
                updateRSM.add(mdl.rsm);
                mdl.isOpn = true;
            }
        }
        
        if(!updateRSM.isEmpty()){            
            update updateRSM;
        }  
        fetchRecords();
    }
    
    //----------------------------------- Creating and updating the buyer mapping records -------------------------    
    // For saving saving buyer record ...  
    private void saveBuyerMapping(String recId){
        List<Buyer_Mapping__c> updateBM = new List<Buyer_Mapping__c>();
        Set<Id> ownerIds = new Set<Id>();
        for(BuyerModel bmdl : buyerList){
            if(bmdl.bm.Id == recId){
                bmdl.bm.Created_From_Exception__c = false;
                updateBM.add(bmdl.bm);
                bmdl.isOpn = true;
            }
        }
        
        
        if(!updateBM.isEmpty()){
            update updateBM; // updating buyer mapping records ...
        } 
        fetchRecords();      
    }
    
    // searching the exception records and creating ...
    public void searchExceptionRecord(){   
        if(selOptn =='BM'){
            buyerList.clear();
            if(isExpChk && (selDate != null || selInvDate != null)){
                createBuyingMapForExceptions();
                fetchRecords();
            }
        }else if(selOptn =='AM'){
            advertiserList.clear();
            if(isExpChk && (selDate != null || selInvDate != null)){
                createAdvertiserMapForExceptions();
                fetchRecords();
            }
        }else if(selOptn =='CM'){
            campaignList.clear();
            if(isExpChk && (selDate != null || selInvDate != null)){
                createCampaignMapForExceptions();
                fetchRecords();
            }
        }else if(selOptn =='PM'){
            advertiserList.clear();
            if(isExpChk && (selDate != null || selInvDate != null)){
                createPlatformMapForExceptions();
                fetchRecords();
            }
        }else if(selOptn =='DM'){
            dataSupplierList.clear();
            
            if(isExpChk && selDate != null){
                createDataSupplierMapForExceptions();
                fetchRecords();
            }
        }else if(selOptn =='RM'){
            revenueList.clear();
            if(isExpChk && selDate != null){
                createRevenueShareMapForExceptions();
                fetchRecords();
            }
        }else if(selOptn =='SM'){
            segmentList.clear();
            if(isExpChk && (selDate != null || selInvDate != null)){
                createSegmentMapForExceptions();
                fetchRecords();
            }
        }
        
        if(!isExpChk){
            fetchRecords();
        }
    }
    
    // creating the new buyer_mapping records based on sales_database ...
    private void createBuyingMapForExceptions(){
        Map<String,Sales_Database__c> sdbMap = new Map<String,Sales_Database__c>();
        Set<String> buyRawSet      = new Set<String>();
        Set<String> buyCntRawSet   = new Set<String>();
        Set<String> buyPltRawSet   = new Set<String>();
        Set<String> buyTcntRawSet  = new Set<String>();
        
        //Added date_invoiced filter, on 28th Feb 2017
        String sqlQuery =  'select Id, Buyer_Raw__c , Buyer_Country_Raw__c, Platform_Raw_Original__c from Sales_Database__c ';
        sqlQuery += ' Where Buyer_Error__c != null AND Buyer_Raw__c != null AND '; 
        sqlQuery += ' Buyer_Country_Raw__c != null AND Platform_Raw_Original__c != null ';
        
        //Update code because of too many soql error. date 31st july 2017
       /* if(selDate != null)
            sqlQuery += ' AND (Date__c =: selDate) ';
        
        if(selInvDate != null)
            sqlQuery += ' AND (Date_Invoiced__c =: selInvDate)';
        */
        If (selDate != null && selInvDate != null )
           sqlQuery += ' AND (Date__c =: selDate OR Date_Invoiced__c =: selInvDate) ';
        Else If (selDate != null & selInvDate == null ) 
           sqlQuery += ' AND (Date__c =: selDate) '; 
        Else If (selDate == null & selInvDate != null)
           sqlQuery += ' AND (Date_Invoiced__c =: selInvDate) ';
        
        List<Sales_Database__c> salesDBList = Database.query(sqlQuery); 
        
        for(Sales_Database__c sb : salesDBList){
            String key = sb.Buyer_Raw__c + '-' + sb.Buyer_Country_Raw__c + '-' + sb.Platform_Raw_Original__c.toUpperCase() ;
            sdbMap.put(key, sb);
            buyRawSet.add(sb.Buyer_Raw__c);
            buyCntRawSet.add(sb.Buyer_Country_Raw__c);
            buyPltRawSet.add(sb.Platform_Raw_Original__c.toUpperCase());
            
        }
        
        if(!sdbMap.isEmpty()){
            List<Buyer_Mapping__c> newBMRecords = new List<Buyer_Mapping__c>();
            Set<String> extbuyers = getUniquBuyerMappings(buyRawSet, buyCntRawSet, buyPltRawSet, buyTcntRawSet);
            for(String key : sdbMap.KeySet()){
                if(!extbuyers.contains(key)){
                    Buyer_Mapping__c bmRec = new Buyer_Mapping__c(Created_From_Exception__c=true);
                    bmRec.Buyer_Raw__c          = sdbMap.get(key).Buyer_Raw__c;
                    bmRec.Buyer_Country_Raw__c  = sdbMap.get(key).Buyer_Country_Raw__c;
                    //Updated on Date 24th July 2017. Convert platform raw in upper case
                    //bmRec.Platform__c         = sdbMap.get(key).Platform_Raw_Original__c;
                    String tempPltRaw           = sdbMap.get(key).Platform_Raw_Original__c;     
                    bmRec.Platform__c           = tempPltRaw != null ? tempPltRaw.toUpperCase() : tempPltRaw;
                    newBMRecords.add(bmRec);
                }
            }
            
            
            if(!newBMRecords.isEmpty()){
                insert newBMRecords;
            }
        }
    }
    
    // getting the unique buyer mapping records ...
    private Set<String> getUniquBuyerMappings(Set<String> buyRawSet, Set<String> buyCntRawSet, Set<String> buyPltRawSet, Set<String> buyTcntRawSet){
        Set<String> tempSet = new Set<String>();
        for(Buyer_Mapping__c bm : [select Id,Buyer_Global__c, Buyer_Raw__c, Buyer_Country_Raw__c, Platform__c from Buyer_Mapping__c Where 
                                   Buyer_Raw__c IN:buyRawSet OR Buyer_Country_Raw__c IN:buyCntRawSet OR Platform__c IN:buyPltRawSet]){
                                       String key = bm.Buyer_Raw__c + '-' + bm.Buyer_Country_Raw__c + '-' + bm.Platform__c.toUpperCase() ;
                                       tempSet.add(key);
                                   }
        return tempSet;
    }
    
    // Creating new Advertiser Mapping records on the basis of Sales database
    private void createAdvertiserMapForExceptions(){
        Map<String,Sales_Database__c> sdbMap = new Map<String,Sales_Database__c>();
        Set<String> advtRawSet      = new Set<String>();
        
        //Added date_invoiced filter, on 28th Feb 2017       
        String sqlQuery =  'select Id, Advertiser_Raw__c from Sales_Database__c ';
        sqlQuery += ' Where Advertiser_Error__c != null AND Advertiser_Raw__c != null '; 
        
        //Updated because of too many soql error. 31st july 2017
       /* if(selDate != null)
            sqlQuery += ' AND (Date__c =: selDate) ';
        
        if(selInvDate != null)
            sqlQuery += ' AND (Date_Invoiced__c =: selInvDate)';
        */
        If (selDate != null && selInvDate != null )
           sqlQuery += ' AND (Date__c =: selDate OR Date_Invoiced__c =: selInvDate) ';
        Else If (selDate != null & selInvDate == null ) 
           sqlQuery += ' AND (Date__c =: selDate) '; 
        Else If (selDate == null & selInvDate != null)
           sqlQuery += ' AND (Date_Invoiced__c =: selInvDate) ';
        
        List<Sales_Database__c> salesDBList = Database.query(sqlQuery); 
        
        for(Sales_Database__c sb : salesDBList){
            sdbMap.put(sb.Advertiser_Raw__c, sb);
            advtRawSet.add( sb.Advertiser_Raw__c );
        }
        
        if(!sdbMap.isEmpty()){
            List<Advertiser_Mapping__c> newAMRecords = new List<Advertiser_Mapping__c>();
            Set<String> extAdvertiser = getUniquAdvertiserMappings(advtRawSet);
            for(String key : sdbMap.KeySet()){
                if(!extAdvertiser.contains(key)){
                    Advertiser_Mapping__c amRec = new Advertiser_Mapping__c(Created_From_Exception__c=true);
                    amRec.Advertiser_Raw__c   = sdbMap.get(key).Advertiser_Raw__c ;
                    newAMRecords.add(amRec);
                }
            }
            
            if(!newAMRecords.isEmpty()){
                insert newAMRecords;
            }
        }
    }
    
    // getting the unique Advertiser mapping records ...
    private Set<String> getUniquAdvertiserMappings(Set<String> advtRawSet){
        Set<String> tempSet = new Set<String>();
        for(Advertiser_Mapping__c am : [select Id, Advertiser_Raw__c from Advertiser_Mapping__c Where 
                                        Advertiser_Raw__c IN: advtRawSet ]){
                                            tempSet.add(am.Advertiser_Raw__c);
                                        }
        return tempSet;
    }
    
  
    
    
    // Creating new Campaign Mapping records on the basis of Sales database
    private void createCampaignMapForExceptions(){
        Map<String,Sales_Database__c> sdbMap = new Map<String,Sales_Database__c>();
        Set<String> advtRawSet = new Set<String>();
        
        //Added date_invoiced filter, on 28th Feb 2017      
        String sqlQuery =  'select Id, Campaign__c,Campaign_Classified_Error__c,Campaign_Raw_Original__c from Sales_Database__c ';
        sqlQuery += ' Where Campaign__c != null AND Campaign_Classified_Error__c != null AND Campaign_Raw_Original__c != null '; 
        
        //Updated because of too many soql error. 31st july 2017
        /*if(selDate != null)
            sqlQuery += ' AND (Date__c =: selDate) ';
        
        if(selInvDate != null)
            sqlQuery += ' AND (Date_Invoiced__c =: selInvDate)';
        */
        If (selDate != null && selInvDate != null )
           sqlQuery += ' AND (Date__c =: selDate OR Date_Invoiced__c =: selInvDate) ';
        Else If (selDate != null & selInvDate == null ) 
           sqlQuery += ' AND (Date__c =: selDate) '; 
        Else If (selDate == null & selInvDate != null)
           sqlQuery += ' AND (Date_Invoiced__c =: selInvDate) ';
        
        List<Sales_Database__c> salesDBList = Database.query(sqlQuery); 
        
        for(Sales_Database__c sb : salesDBList){
            sdbMap.put(sb.Campaign_Raw_Original__c, sb);
            advtRawSet.add( sb.Campaign_Raw_Original__c );
        }
        
        if(!sdbMap.isEmpty()){
            List<Campaign_Mapping__c> newCMRecords = new List<Campaign_Mapping__c>();
            Set<String> extCampaignAdvertiser = getUniquCampaignMappings(advtRawSet);
           
            for(String key : sdbMap.KeySet()){
                if(!extCampaignAdvertiser.contains(key)){
                    Campaign_Mapping__c amRec = new Campaign_Mapping__c(Created_From_Exception__c=true);
                    amRec.Campaign_Raw__c   = sdbMap.get(key).Campaign_Raw_Original__c ;
                    newCMRecords.add(amRec);
                }
            }
            
            if(!newCMRecords.isEmpty()){
                insert newCMRecords;
            }
        }
    }
    
     // getting the unique Advertiser mapping records ...
    private Set<String> getUniquCampaignMappings(Set<String> advtRawSet){
        Set<String> tempSet = new Set<String>();
        for(Campaign_Mapping__c am : [select Id, Campaign_Raw__c from Campaign_Mapping__c Where 
                                        Campaign_Raw__c IN: advtRawSet ]){
                                            tempSet.add(am.Campaign_Raw__c);
                                        }
        return tempSet;
    }
    
    
    // Creating new Platform Mapping records on the basis of Sales database
    private void createPlatformMapForExceptions(){
        Map<String,Sales_Database__c> sdbMap = new Map<String,Sales_Database__c>();
        Set<String> pltfrmRawSet      = new Set<String>();
        
         //Added date_invoiced filter, on 28th Feb 2017 
        String sqlQuery =  'select Id, Platform_Raw__c from Sales_Database__c ';
        sqlQuery += ' Where Platform_Error__c != null AND Platform_Raw__c != null '; 
        
        //Updated because of too many soql error. 31st july 2017
        /*if(selDate != null)
            sqlQuery += ' AND (Date__c =: selDate) ';
        
        if(selInvDate != null)
            sqlQuery += ' AND (Date_Invoiced__c =: selInvDate)';
        */
        If (selDate != null && selInvDate != null )
           sqlQuery += ' AND (Date__c =: selDate OR Date_Invoiced__c =: selInvDate) ';
        Else If (selDate != null & selInvDate == null ) 
           sqlQuery += ' AND (Date__c =: selDate) '; 
        Else If (selDate == null & selInvDate != null)
           sqlQuery += ' AND (Date_Invoiced__c =: selInvDate) ';
        
        List<Sales_Database__c> salesDBList = Database.query(sqlQuery); 
        
        for(Sales_Database__c sb : salesDBList){
            sdbMap.put(sb.Platform_Raw__c, sb);
            pltfrmRawSet.add( sb.Platform_Raw__c );
        }
        
        if(!sdbMap.isEmpty()){
            List<Platform_Mapping__c> newPMRecords = new List<Platform_Mapping__c>();
            Set<String> extPlatform = getUniquePlatformMappings(pltfrmRawSet);
            for(String key : sdbMap.KeySet()){
                if(!extPlatform.contains(key)){
                    Platform_Mapping__c pmRec = new Platform_Mapping__c(Created_From_Exception__c=true);
                    pmRec.Platform_Raw__c = sdbMap.get(key).Platform_Raw__c ;
                    newPMRecords.add(pmRec);
                }
            }
            
            if(!newPMRecords.isEmpty()){
                insert newPMRecords;
            }
        }
    }
    
    // getting the unique Platform mapping records ...
    private Set<String> getUniquePlatformMappings(Set<String> pltfrmRawSet){
        Set<String> tempSet = new Set<String>();
        for(Platform_Mapping__c pm : [select Id, Platform_Raw__c, Platform_Account__c,Platform__c  from Platform_Mapping__c Where 
                                      Platform_Raw__c IN: pltfrmRawSet]){
                                          tempSet.add(pm.Platform_Raw__c );
                                      }
        return tempSet;
    }
    
    // Creating new Revenue Share Mapping records on the basis of Supply database
    private void createRevenueShareMapForExceptions(){
        Map<String,Supply_Database__c> sdbMap = new Map<String,Supply_Database__c>();
        Set<String> revShrRawSet      = new Set<String>();
        Set<String> revShrSegNameSet   = new Set<String>();
        Set<String> revShrTrgtCntrySet   = new Set<String>();
    
        for(Supply_Database__c sb : [select Id, Data_Supplier_Raw__c, Segment_Name__c from Supply_Database__c 
                                     Where Data_Supplier_Error__c != null AND (Date__c =: selDate)
                                     AND Data_Supplier_Raw__c != null 
                                     AND Segment_Name__c != null ]){
                                         String key = sb.Data_Supplier_Raw__c + '-' + sb.Segment_Name__c ;
                                         sdbMap.put(key, sb);
                                         revShrRawSet.add( sb.Data_Supplier_Raw__c );
                                         revShrSegNameSet.add( sb.Segment_Name__c );
                                         
                                     }
        
        
        if(!sdbMap.isEmpty()){
            List<Revenue_Share_Mapping__c> newRSRecords = new List<Revenue_Share_Mapping__c>();
            Set<String> extRevShare = getUniqueRevenueShareMappings(revShrRawSet, revShrSegNameSet, revShrTrgtCntrySet);
            for(String key : sdbMap.KeySet()){
                if(!extRevShare.contains(key)){
                    Revenue_Share_Mapping__c rsRec = new Revenue_Share_Mapping__c(Created_From_Exception__c=true);
                    rsRec.Data_Supplier__c = sdbMap.get(key).Data_Supplier_Raw__c;
                    rsRec.Segment_Name__c = sdbMap.get(key).Segment_Name__c  ;
                    
                    newRSRecords.add( rsRec );
                }
            }
            
            if(!newRSRecords.isEmpty()){
                insert newRSRecords;
            }
        }
    }
    
    // getting the unique Revenue Share Mapping mapping records ...
    private Set<String> getUniqueRevenueShareMappings(Set<String> revShrRawSet, Set<String> revShrSegNameSet, Set<String> revShrTrgtCntrySet ){
        Set<String> tempSet = new Set<String>();
        for(Revenue_Share_Mapping__c rs : [select Id, Data_Supplier__c, Segment_Name__c, Country__c from Revenue_Share_Mapping__c Where 
                                           Data_Supplier__c IN: revShrRawSet OR Segment_Name__c IN: revShrSegNameSet OR Country__c IN : revShrTrgtCntrySet ]){
                                               String key = rs.Data_Supplier__c + '-' + rs.Segment_Name__c + '-' + rs.Country__c;
                                               tempSet.add(key);
                                           }
        return tempSet;
    }
    
    // Creating new Data Supplier Mapping records on the basis of Supply database
    private void createDataSupplierMapForExceptions(){
        Map<String,Supply_Database__c> sdbMap = new Map<String,Supply_Database__c>();
        Set<String> dataSuplRawSet      = new Set<String>();
        
         for(Supply_Database__c sb : [select Id, Data_Supplier_Raw__c from Supply_Database__c 
                                     Where ( Data_Supplier_Error__c != null OR Data_Supplier_Error__c !='' )
                                     AND ( Date__c =: selDate) 
                                     AND ( Data_Supplier_Raw__c != null AND Data_Supplier_Raw__c != '' )] ) {
                                         sdbMap.put(sb.Data_Supplier_Raw__c, sb);
                                         dataSuplRawSet.add( sb.Data_Supplier_Raw__c );
                                     }
        
        if(!sdbMap.isEmpty()){
            List<Data_Supplier_Mapping__c> newDSRecords = new List<Data_Supplier_Mapping__c>();
            Set<String> extRevShare = getUniqueDataSupplierMappings(dataSuplRawSet);
            for(String key : sdbMap.KeySet()){
                if(!extRevShare.contains(key)){
                    Data_Supplier_Mapping__c dsRec = new Data_Supplier_Mapping__c(Created_From_Exception__c=true);
                    dsRec.Data_Supplier_Raw__c = sdbMap.get(key).Data_Supplier_Raw__c;
                    newDSRecords.add( dsRec );
                }
            }
            
            if(!newDSRecords.isEmpty()){
                insert newDSRecords;
            }
        }
    }
    
    // getting the Data Supplier Share Mapping mapping records ...
    private Set<String> getUniqueDataSupplierMappings(Set<String> dataSuplRawSet){
        Set<String> tempSet = new Set<String>();
        for(Data_Supplier_Mapping__c ds : [select Id, Data_Supplier_Raw__c from Data_Supplier_Mapping__c Where 
                                           Data_Supplier_Raw__c IN: dataSuplRawSet ]){
                                               tempSet.add(ds.Data_Supplier_Raw__c);
                                           }
        return tempSet;
    }
    
    // Creating new Segment Mapping records on the basis of Sales + Supply database
    private void createSegmentMapForExceptions(){
        Map<String,Supply_Database__c> splyDbMap = new Map<String,Supply_Database__c>();
        Map<String,Sales_Database__c> salesDbMap = new Map<String,Sales_Database__c>();
        Set<String> segmentRawSet      = new Set<String>();
        
        for(Supply_Database__c sb : [select Id, Segment_Name_Supply_Raw__c from Supply_Database__c 
                                     Where Segment_Name_Error__c != null AND (Date__c =: selDate) AND Segment_Name_Supply_Raw__c != null]){
                                         splyDbMap.put(sb.Segment_Name_Supply_Raw__c , sb);
                                         segmentRawSet.add( sb.Segment_Name_Supply_Raw__c );
                                     }
        
        if(!splyDbMap.isEmpty()){
            List<Segment_Mapping__c> newSGRecords = new List<Segment_Mapping__c>();
            Set<String> extSegment = getUniqueSegmentMappingsSupply(segmentRawSet);
            for(String key : splyDbMap.KeySet()){
                if(!extSegment.contains(key)){
                    Segment_Mapping__c sgRec = new Segment_Mapping__c (Created_From_Exception__c=true);
                    sgRec.Segment_Name_Supply_Raw__c = splyDbMap.get(key).Segment_Name_Supply_Raw__c ;
                    newSGRecords.add( sgRec );
                }
            }
            
            if(!newSGRecords.isEmpty()){
                insert newSGRecords;
            }
        }
        
        segmentRawSet.clear();
        
        //Added date_invoiced filter on 28th Feb 2017        
        String sqlQuery =  'select Id, Segment_Name_Sales_Raw__c from Sales_Database__c ';
        sqlQuery += ' Where Segment_Name_Error__c != null AND Segment_Name_Sales_Raw__c != null ';        
       
        //Update because of too many soql error. 31st july 2017
        /*if(selDate != null)
            sqlQuery += ' AND (Date__c =: selDate) ';
        
        if(selInvDate != null)
            sqlQuery += ' AND (Date_Invoiced__c =: selInvDate)';
        */
        If (selDate != null && selInvDate != null )
           sqlQuery += ' AND (Date__c =: selDate OR Date_Invoiced__c =: selInvDate) ';
        Else If (selDate != null & selInvDate == null ) 
           sqlQuery += ' AND (Date__c =: selDate) '; 
        Else If (selDate == null & selInvDate != null)
           sqlQuery += ' AND (Date_Invoiced__c =: selInvDate) ';
        
        List<Sales_Database__c> salesDBList = Database.query(sqlQuery); 
        
        for(Sales_Database__c sb : salesDBList){
            salesDbMap.put(sb.Segment_Name_Sales_Raw__c , sb);
            segmentRawSet.add(sb.Segment_Name_Sales_Raw__c);
        }
        
        if(!salesDbMap.isEmpty()){
            List<Segment_Mapping__c> newSGRecords = new List<Segment_Mapping__c>();
            Set<String> extSegment = getUniqueSegmentMappingsSales(segmentRawSet);
            for(String key : salesDbMap.KeySet()){
                if(!extSegment.contains(key)){
                    Segment_Mapping__c sgRec = new Segment_Mapping__c (Created_From_Exception__c=true);
                    sgRec.Segment_Name_Sales_Raw__c = salesDbMap.get(key).Segment_Name_Sales_Raw__c ;
                    newSGRecords.add( sgRec );
                }
            }
            
            if(!newSGRecords.isEmpty()){
                insert newSGRecords;
            }
        }
    }
    
    // getting the Segment Mapping Supply Database records ...
    private Set<String> getUniqueSegmentMappingsSupply(Set<String> segmentRawSet){
        Set<String> tempSet = new Set<String>();
        for(Segment_Mapping__c sg : [select Id, Segment_Name_Supply_Raw__c from Segment_Mapping__c Where 
                                     Segment_Name_Supply_Raw__c IN: segmentRawSet]){
                                         tempSet.add(sg.Segment_Name_Supply_Raw__c);
                                     }
        return tempSet;
    }
    
    // getting the Segment Mapping Sales Database records ...
    private Set<String> getUniqueSegmentMappingsSales(Set<String> segmentRawSet){
        Set<String> tempSet = new Set<String>();
        for(Segment_Mapping__c sg : [select Id, Segment_Name_Sales_Raw__c from Segment_Mapping__c Where 
                                     Segment_Name_Sales_Raw__c IN: segmentRawSet]){
                                         tempSet.add(sg.Segment_Name_Sales_Raw__c);
                                     }
        return tempSet;
    }
    
    //---------------------------------- Wrapper Class Section ---------------------------------
    public class BuyerModel{
        public Buyer_Mapping__c  bm {get;set;}
        public string buyerCountry  {get;set;}
        public Boolean isOpn {get;set;}        
        
        public BuyerModel(Buyer_Mapping__c rec){
            bm = rec;
            buyerCountry = bm.Buyer_and_Buyer_Country__c!=null?bm.Buyer_and_Buyer_Country__c : ''; 
        }        
    } 
    
    // ------------------------------- Revenue Share Mapping Wrapper class Section ----------------------------
    public class RevenueShareModel{
        public Revenue_Share_Mapping__c rsm {get;set;}
        public Boolean isOpn {get;set;}   
        
        public RevenueShareModel(Revenue_Share_Mapping__c rsm){
            this.rsm = rsm;
        }
    }
    
    // ------------------------------ Platform Mapping  Wrapper class Section ---------------------------------
    public class PlatformModel{
        public Platform_Mapping__c pm {get;set;}
        public Boolean isOpn {get;set;}
        
        public PlatformModel(Platform_Mapping__c  pm){
            this.pm = pm;
        }
    }    
    
    // ------------------------------ Advertiser Mapping Wrapper class Section ---------------------------------
    public class AdvertiserModel{
        public Advertiser_Mapping__c am {get;set;}
        public String accSector1 {get;set;}
        public String accSector2 {get;set;}
        public Boolean isOpn {get;set;}
        
        public string AdvSec1{get;set;}
        public string AdvSec2{get;set;}
        
        private String tempaccSector1;
        private String tempaccSector2;
        
        public Decimal salesDBRevenue{get;set;}
        public AdvertiserModel(Advertiser_Mapping__C am){
            this.am = am;
            this.salesDBRevenue = 0;
            accSector1 = string.isNotBlank(am.Advertiser_Account__r.Advertiser_Sector_1__c)?am.Advertiser_Account__r.Advertiser_Sector_1__c : '';
            accSector2 = string.isNotBlank(am.Advertiser_Account__r.Advertiser_Sector_2_New__c )?am.Advertiser_Account__r.Advertiser_Sector_2_New__c  : '';
            
            tempaccSector1 = accSector1;
            tempaccSector2 = accSector2;
        }
    }  
    
    // ------------------------------ Campaign Mapping Wrapper class Section ---------------------------------
    public class CampaignModel{
        public Campaign_Mapping__c cm {get;set;}
        public String accSector1 {get;set;}
        public String accSector2 {get;set;}
        public Boolean isOpn {get;set;}
        
        public string AdvSec1{get;set;}
        public string AdvSec2{get;set;}
        
        private String tempaccSector1;
        private String tempaccSector2;
        
        
        public CampaignModel(Campaign_Mapping__c cm){
            this.cm = cm;
            accSector1 = string.isNotBlank(cm.Advertiser_Account__r.Advertiser_Sector_1__c)?cm.Advertiser_Account__r.Advertiser_Sector_1__c : '';
            accSector2 = string.isNotBlank(cm.Advertiser_Account__r.Advertiser_Sector_2_New__c )?cm.Advertiser_Account__r.Advertiser_Sector_2_New__c  : '';
            
            tempaccSector1 = accSector1;
            tempaccSector2 = accSector2;
        }
    }  
    
    // ---------------------------- Data Supplier Mapping  Wrapper class Section ---------------------------------
    public class DataSupplierModel{
        public Data_Supplier_Mapping__c dsm {get;set;}
        public String accPDT  {get;set;}
        public String accPST  {get;set;}
        public String accPSV  {get;set;}
        public String accCC  {get;set;}
        public Boolean isOpn {get;set;}
        
        private String tempaccPDT;
        private String tempaccPST;
        private String tempaccPSV;
        private String tempaccCC;
        
        public DataSupplierModel(Data_Supplier_Mapping__c dsm){
            this.dsm = dsm;
            accPDT  = string.isNotBlank(dsm.Data_Supplier_Account__r.Publisher_Data_Type__c) ? dsm.Data_Supplier_Account__r.Publisher_Data_Type__c : '';
            accPST  = string.isNotBlank(dsm.Data_Supplier_Account__r.Publisher_Site_Type__c) ? dsm.Data_Supplier_Account__r.Publisher_Site_Type__c : '';
            accPSV  = string.isNotBlank(dsm.Data_Supplier_Account__r.Publisher_Site_Vertical__c) ? dsm.Data_Supplier_Account__r.Publisher_Site_Vertical__c : '';
            accCC  = string.isNotBlank(dsm.Data_Supplier_Account__r.Currency_Code__c) ? dsm.Data_Supplier_Account__r.Currency_Code__c : '';             //Currency code field added by saifullah 23/03/2017
            
            tempaccPDT = accPDT;
            tempaccPST = accPST;
            tempaccPSV = accPSV;
            tempaccCC = accCC;
        }       
    }
    
    // --------------------------- Segment Mapping Wrapper class Section ---------------------
    public class SegmentModel{
        public Segment_Mapping__c sm {get;set;}
        public String scmSN {get;set;}
        public Decimal scmRCC {get;set;}
        public String scmSCategory {get;set;}
        public String scmSCode    {get;set;}
        
        private String tempscmSN;
        private Decimal tempscmRCC;
        private String tempscmSCategory;
        private String tempscmSCode;
        
        
        public SegmentModel(Segment_Mapping__c sm){
            this.sm        = sm;
            scmSN         = string.isNotBlank(sm.Segment_Category_Mapping__r.Segment_Name__c) ? sm.Segment_Category_Mapping__r.Segment_Name__c : '';
            scmRCC        = sm.Segment_Category_Mapping__r.Rate_Card_CPM__c != null ? sm.Segment_Category_Mapping__r.Rate_Card_CPM__c : 0;
            scmSCategory  = string.isNotBlank(sm.Segment_Category_Mapping__r.Segment_Category__c) ? sm.Segment_Category_Mapping__r.Segment_Category__c : '';
            scmSCode      = string.isNotBlank(sm.Segment_Category_Mapping__r.Segment_Code__c) ? sm.Segment_Category_Mapping__r.Segment_Code__c : '';
            
            tempscmSN = scmSN;
            tempscmRCC = scmRCC;
            tempscmSCategory = scmSCategory;
            tempscmSCode = scmSCode;            
        }
    }
    
}