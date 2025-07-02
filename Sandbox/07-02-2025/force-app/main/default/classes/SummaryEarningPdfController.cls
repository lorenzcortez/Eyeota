public class SummaryEarningPdfController {
    public String accountName;
    public String summaryDetail;
    public String earningsBreakdown;
    public String summaryEarningsLast6Mos;

    public SummaryEarningPdfController() {
        this.accountName = ApexPages.currentPage().getParameters().get('accountName');
        this.summaryDetail = ApexPages.currentPage().getParameters().get('summaryDetail');
        this.earningsBreakdown = ApexPages.currentPage().getParameters().get('earningsBreakdown');
        this.summaryEarningsLast6Mos = ApexPages.currentPage().getParameters().get('summaryEarningsLast6Mos');
    }

    
    public String getAccountName(){
        return this.accountName;
    }
    public SupplierEarningReportSummaryController.SummaryDetail getSummaryDetail(){
        if(this.summaryDetail != null){
            return (SupplierEarningReportSummaryController.SummaryDetail)JSON.deserialize(this.summaryDetail, SupplierEarningReportSummaryController.SummaryDetail.class);
        }
        return new SupplierEarningReportSummaryController.SummaryDetail();
    }
    public List<SupplierEarningReportSummaryController.EarningBreakdown> getEarningsBreakdown(){
        if(this.earningsBreakdown != null){
            return (List<SupplierEarningReportSummaryController.EarningBreakdown>)JSON.deserialize(this.earningsBreakdown, List<SupplierEarningReportSummaryController.EarningBreakdown>.class);
        }
        return new List<SupplierEarningReportSummaryController.EarningBreakdown>();
    }
    public List<SupplierEarningReportSummaryController.SummaryEarning> getSummaryEarningsLast6Mo(){
        if(this.summaryEarningsLast6Mos != null){
            return (List<SupplierEarningReportSummaryController.SummaryEarning>)JSON.deserialize(this.summaryEarningsLast6Mos, List<SupplierEarningReportSummaryController.SummaryEarning>.class);
        }
        return new List<SupplierEarningReportSummaryController.SummaryEarning>();
    }
}