public without sharing class SupplierEarningReportSummaryController {
    @AuraEnabled
    public static List<EarningsReportRow> getPartnerBrandedData(String accountId, Integer rows, Integer offset){
        List<EarningsReportRow> records = new List<EarningsReportRow>();
        List<AggregateResult> results = [SELECT
                                                Segment_Category_Mapping__r.Segment_Key_Numeric_String_Only__c,
                                                Data_Supplier_Raw__c,
                                                Segment_Category_Mapping__r.Segment_Supplier_Category__c,
                                                Target_Country_Raw__c,
                                                Segment_Category_Mapping__r.Segment_Name__c,
                                                SUM(Gross_Earnings_Final_USD_For_Export__c) grossEarning,
                                                SUM(Net_Earnings_Final_USD_For_Export__c) netEarningUSD,
                                                SUM(Net_Earnings_Final_ExRate_For_Export__c) netEarning
                                            FROM
                                                Supply_Database__c
                                            WHERE
                                                Data_Supplier__r.Id = :accountId
                                                AND Date_within_Range__c = true
                                                AND Segment_Category_Mapping__r.Segment_Supplier_Category__c = 'Branded'
                                                AND Target_Country_Raw__c != ''
                                                AND Target_Country_Raw__c IN (
                                                'AU', 'BR', 'CA', 'DE',
                                                'DK', 'ES', 'FI', 'FR', 'HK',
                                                'ID', 'IN', 'IT', 'JP', 'KH',
                                                'MX', 'MY', 'NL', 'NO', 'NORDICS', 'NZ', 'PH', 'PL', 'RU', 'SEA',
                                                'SE', 'SG', 'TH', 'TR',
                                                'TW', 'UK',
                                                'US', 'VN'
                                                )
                                                AND (Gross_Earnings_Final_USD_For_Export__c != null OR Gross_Earnings_Final_USD_For_Export__c != 0)
                                            GROUP BY
                                                Data_Supplier_Raw__c,
                                                Segment_Category_Mapping__r.Segment_Supplier_Category__c,
                                                Target_Country_Raw__c,
                                                Segment_Category_Mapping__r.Segment_Name__c,
                                                Segment_Category_Mapping__r.Segment_Key_Numeric_String_Only__c
                                            ORDER BY
                                                Data_Supplier_Raw__c ASC,
                                                Segment_Category_Mapping__r.Segment_Supplier_Category__c ASC,
                                                Target_Country_Raw__c ASC,
                                                Segment_Category_Mapping__r.Segment_Name__c ASC LIMIT :rows OFFSET :offset];

        if(results.size() > 0){
            for(AggregateResult result : results){
                EarningsReportRow record = new EarningsReportRow();
                record.country          = (String) result.get('Target_Country_Raw__c');
                record.organizationName = (String) result.get('Data_Supplier_Raw__c');
                record.category         = (String) result.get('Segment_Supplier_Category__c');
                record.segmentName      = (String) result.get('Segment_Name__c');
                record.grossEarning     = (Double) result.get('grossEarning');
                record.netEarningUSD    = (Double) result.get('netEarningUSD');
                record.netEarning       = (Double) result.get('netEarning');
                record.segmentKey       = (String) result.get('Segment_Key_Numeric_String_Only__c');
                records.add(record);
            }
        }

        return records;
    }

    @AuraEnabled
    public static List<EarningsReportRow> getCustomData(String accountId, Integer rows, Integer offset){
        List<EarningsReportRow> records = new List<EarningsReportRow>();

        List<Supply_Database__c> results = [SELECT
                                                Segment_Category_Mapping__r.Segment_Key_Numeric_String_Only__c,
                                                Data_Supplier_Raw__c,
                                                Segment_Category_Mapping__r.Segment_Supplier_Category__c,
                                                Target_Country_Raw__c,
                                                Segment_Category_Mapping__r.Segment_Name__c,
                                                Gross_Earnings_Final_USD_For_Export__c,
                                                Net_Earnings_Final_USD_For_Export__c,
                                                Net_Earnings_Final_ExRate_For_Export__c
                                            FROM
                                                Supply_Database__c
                                            WHERE
                                                Data_Supplier__r.Id = :accountId
                                                AND Date_within_Range__c = true
                                                AND Segment_Category_Mapping__r.Segment_Supplier_Category__c = 'Custom'
                                                AND (Gross_Earnings_Final_USD_For_Export__c != null OR Gross_Earnings_Final_USD_For_Export__c != 0)
                                            ORDER BY
                                                Data_Supplier_Raw__c ASC,
                                                Segment_Category_Mapping__r.Segment_Supplier_Category__c ASC,
                                                Target_Country_Raw__c ASC,
                                                Segment_Category_Mapping__r.Segment_Name__c ASC LIMIT :rows OFFSET :offset];

        if(results.size() > 0){
            for(Supply_Database__c result : results){
                EarningsReportRow record = new EarningsReportRow();
                record.country          = result.Target_Country_Raw__c;
                record.organizationName = result.Data_Supplier_Raw__c;
                record.category         = result.Segment_Category_Mapping__r.Segment_Supplier_Category__c;
                record.segmentName      = result.Segment_Category_Mapping__r.Segment_Name__c;
                record.grossEarning     = result.Gross_Earnings_Final_USD_For_Export__c;
                record.netEarningUSD    = result.Net_Earnings_Final_USD_For_Export__c;
                record.netEarning       = result.Net_Earnings_Final_ExRate_For_Export__c;
                record.segmentKey       = result.Segment_Category_Mapping__r.Segment_Key_Numeric_String_Only__c;
                records.add(record);
            }
        }

        return records;
    }

    @AuraEnabled
    public static List<EarningsReportRow> getEyeotaBrandedData(String accountId, Integer rows, Integer offset){
        List<EarningsReportRow> records = new List<EarningsReportRow>();
        List<Supply_Database__c> results = [SELECT
                                                Segment_Category_Mapping__r.Segment_Key_Numeric_String_Only__c,
                                                Data_Supplier_Raw__c,
                                                Segment_Category_Mapping__r.Segment_Supplier_Category__c,
                                                Target_Country_Raw__c,
                                                Segment_Category_Mapping__r.Segment_Name__c,
                                                Gross_Earnings_Final_USD_For_Export__c,
                                                Net_Earnings_Final_USD_For_Export__c,
                                                Net_Earnings_Final_ExRate_For_Export__c
                                            FROM
                                                Supply_Database__c
                                            WHERE
                                                Data_Supplier__r.Id = :accountId
                                                AND Date_within_Range__c = true
                                                AND Segment_Category_Mapping__r.Segment_Supplier_Category__c = 'Eyeota'
                                                AND Target_Country_Raw__c NOT IN ('AU', 'BR', 'CA', 'DE', 'ES', 'FR', 'HK', 'IN', 'IT', 'JP', 'MX', 'NL', 'NORDICS', 'DK', 'FI', 'NO', 'SE', 'NZ', 'PL', 'RU', 'SEA', 'ID', 'KH', 'MY', 'PH', 'SG', 'TH', 'VN', 'TR', 'TW', 'UK', 'US')
                                                AND (Segment_Revenue_Transaction__r.Sales_Revenue_RollUp__c != null OR Segment_Revenue_Transaction__r.Sales_Revenue_RollUp__c != 0)
                                            ORDER BY
                                                Data_Supplier_Raw__c ASC,
                                                Segment_Category_Mapping__r.Segment_Supplier_Category__c ASC,
                                                Target_Country_Raw__c ASC,
                                                Segment_Category_Mapping__r.Segment_Name__c ASC LIMIT :rows OFFSET :offset
                                            ];

        if(results.size() > 0){
            for(Supply_Database__c result : results){
                EarningsReportRow record = new EarningsReportRow();
                record.country          = result.Target_Country_Raw__c;
                record.organizationName = result.Data_Supplier_Raw__c;
                record.category         = result.Segment_Category_Mapping__r.Segment_Supplier_Category__c;
                record.segmentName      = result.Segment_Category_Mapping__r.Segment_Name__c;
                record.grossEarning     = result.Gross_Earnings_Final_USD_For_Export__c;
                record.netEarningUSD    = result.Net_Earnings_Final_USD_For_Export__c;
                record.netEarning       = result.Net_Earnings_Final_ExRate_For_Export__c;
                record.segmentKey       = result.Segment_Category_Mapping__r.Segment_Key_Numeric_String_Only__c;
                records.add(record);
            }
        }

        return records;
    }

    @AuraEnabled
    public static List<EarningsReportBuyerAndAdvertiserDetail> getBuyerAndAdvertiserDetailData(String accountId, Integer rows, Integer offset){
        List<EarningsReportBuyerAndAdvertiserDetail> records = new List<EarningsReportBuyerAndAdvertiserDetail>();
        List<AggregateResult> results   = [SELECT
                                                Segment_Category_Mapping__r.Segment_Key_Numeric_String_Only__c,
                                                Buyer_Country_Raw__c,
                                                Target_Country_Raw__c,
                                                Buyer_Raw__c,
                                                Advertiser__r.Name,
                                                Segment_Category_Mapping__r.Segment_Name__c,
                                                SUM(Earnings_Revenue_Final_USD__c) grossEarning
                                            FROM
                                                Sales_Database__c
                                            WHERE
                                                (
                                                    (
                                                        Segment_Category_Mapping__r.Data_Asset_Account__r.Parent.Id = :accountId
                                                        OR Segment_Category_Mapping__r.Data_Asset_Account__r.Parent.Parent.Id = :accountId
                                                    )
                                                    AND (
                                                        Segment_Category_Mapping__r.Data_Asset_Account__r.Parent.Custom_Supplier_Earnings_Report__c = true
                                                        OR Segment_Category_Mapping__r.Data_Asset_Account__r.Parent.Parent.Custom_Supplier_Earnings_Report__c = true
                                                    )
                                                    AND Revenue_For_Export__c != 0
                                                    AND Weekly_Report_Flag__c = FALSE
                                                    AND Date_within_Range__c = true
                                                    AND Buyer_Country_Raw__c = 'US'
                                                    AND Target_Country_Raw__c = 'US'
                                                )
                                            GROUP BY
                                                Buyer_Country_Raw__c,
                                                Target_Country_Raw__c,
                                                Buyer_Raw__c,
                                                Advertiser__r.Name,
                                                Segment_Category_Mapping__r.Segment_Name__c,
                                                Segment_Category_Mapping__r.Segment_Key_Numeric_String_Only__c
                                            ORDER BY
                                                Buyer_Country_Raw__c ASC,
                                                Target_Country_Raw__c ASC,
                                                Buyer_Raw__c ASC,
                                                Advertiser__r.Name ASC,
                                                Segment_Category_Mapping__r.Segment_Name__c ASC LIMIT :rows OFFSET :offset];

         if(results.size() > 0){
            for(AggregateResult result : results){
                EarningsReportBuyerAndAdvertiserDetail record = new EarningsReportBuyerAndAdvertiserDetail();
                record.buyerCountry     = (String) result.get('Buyer_Country_Raw__c');
                record.targetCountry    = (String) result.get('Target_Country_Raw__c');
                record.buyer            = (String) result.get('Buyer_Raw__c');
                record.advertiser       = (String) result.get('Name');
                record.segmentName      = (String) result.get('Segment_Name__c');
                record.grossEarning     = (Double) result.get('grossEarning');
                records.add(record);
            }
        }

        System.debug('records records records' + records);
        return records;
    }

    @AuraEnabled
    public static String getAccountName(Id accountId){
        return [SELECT Id, Name FROM Account WHERE Id = :accountId].Name;
    }

    @AuraEnabled
    public static SummaryDetail getSummaryDetail(String accountId){
        AggregateResult sdbMonth;

        List<AggregateResult> results = [SELECT
                                                CALENDAR_MONTH(Date__c) month,
                                                CALENDAR_YEAR(Date__c) year,
                                                Currency_Code__c
                                            FROM
                                                Supply_Database__c
                                            WHERE
                                                Date_within_Range__c = true AND Data_Supplier__r.Id = :accountId 
                                            GROUP BY
                                                CALENDAR_MONTH(Date__c),
                                                CALENDAR_YEAR(Date__c),
                                                Currency_Code__c
                                            LIMIT 1
                                        ];
        if(results.size() > 0){
            sdbMonth = results[0];
        }
        
        System.debug('sdbMonth' + sdbMonth);
        SummaryDetail summaryDetail = new SummaryDetail(sdbMonth, null, null);
        System.debug('summaryDetail: '+JSON.serialize(summaryDetail));
        return summaryDetail;
    }

    @AuraEnabled
    public static List<EarningBreakdown> getEarningsBreakdown(Id accountId){
        List<EarningBreakdown> earningsBreakdown = new List<EarningBreakdown>();

        List<AggregateResult> earningsBreakdownRecords = [SELECT
                                                                    Segment_Category_Mapping__r.Segment_Supplier_Category__c segmentSuppCat,
                                                                    SUM(Gross_Earnings_Final_USD_For_Export__c) grossEarnings,
                                                                    SUM(Net_Earnings_Final_USD_For_Export__c) exportEarnings,
                                                                    SUM(Net_Earnings_Final_ExRate_For_Export__c) earningExRate
                                                                FROM Supply_Database__c
                                                                WHERE
                                                                    Date_within_Range__c = true
                                                                    AND Data_Supplier__r.Id = :accountId
                                                                    AND Supplier_Gross_Earnings_Final__c != NULL
                                                                    AND Segment_Category_Mapping__r.Segment_Supplier_Category__c != 'D&B O+O'
                                                                GROUP BY Segment_Category_Mapping__r.Segment_Supplier_Category__c
                                                                ORDER BY Segment_Category_Mapping__r.Segment_Supplier_Category__c ASC
                                                            ];
            if(earningsBreakdownRecords.size() > 0){
                for(AggregateResult earningsBreakdownRecord : earningsBreakdownRecords){
                    earningsBreakdown.add(new EarningBreakdown(earningsBreakdownRecord));
                }
            }

        System.debug('earningsBreakdown: '+JSON.serialize(earningsBreakdown));
        return earningsBreakdown;
    }

    @AuraEnabled
    public static List<SummaryEarning> getSummaryEarningsMonthsFromToday(Id accountId, Integer monthsBefore){
        Date dateBeforeMonths = Date.today().addMonths(-monthsBefore);
        Date startDate = Date.newInstance(dateBeforeMonths.year(), dateBeforeMonths.month(), 1);
        Integer numOfDays = Date.daysInMonth(dateBeforeMonths.year(), dateBeforeMonths.month());
        Date endDate = Date.newInstance(dateBeforeMonths.year(), dateBeforeMonths.month(), numOfDays);
        
        List<SummaryEarning> summaryEarnings = new List<SummaryEarning>();
        List<AggregateResult> summaryEarningRecords = [SELECT
                                                                CALENDAR_MONTH(Date__c) month,
                                                                CALENDAR_YEAR(Date__c) year,
                                                                Currency_Code__c,
                                                                SUM(Gross_Earnings_Final_USD_For_Export__c) grossEarnings,
                                                                SUM(Net_Earnings_Final_USD_For_Export__c) exportEarnings,
                                                                SUM(Net_Earnings_Final_ExRate_For_Export__c) earningExRate
                                                            FROM 
                                                                Supply_Database__c
                                                            WHERE
                                                                (Data_Supplier__r.Id = :accountId AND Supplier_Gross_Earnings_Final__c != NULL AND
                                                                Date__c >= :startDate AND Date__c <= :endDate)
                                                            GROUP BY
                                                                CALENDAR_MONTH(Date__c), CALENDAR_YEAR(Date__c),
                                                                Currency_Code__c
                                                            ORDER BY
                                                                CALENDAR_YEAR(Date__c) ASC, 
                                                                CALENDAR_MONTH(Date__c) ASC ];
        if(summaryEarningRecords.size() > 0){
            for(AggregateResult summaryEarningRecord : summaryEarningRecords){
                summaryEarnings.add(new SummaryEarning(summaryEarningRecord));
            }
        }

        return summaryEarnings;
    }

    public class SummaryDetail {
        @AuraEnabled
        public String dataSupplier {get; set;}
        @AuraEnabled
        public String billingCurrency {get; set;}
        @AuraEnabled
        public Double billingMonth {get; set;}
        @AuraEnabled
        public Date reportIssueDate {get; set;}
        @AuraEnabled
        public List<EarningBreakdown> earningsBreakdown {get; set;}
        @AuraEnabled
        public List<SummaryEarning> summaryEarnings {get; set;}
        public SummaryDetail(AggregateResult sdbMonth, List<EarningBreakdown> earningsBreakdown, List<SummaryEarning> summaryEarnings){
            System.debug('sdbMonth' + sdbMonth);
            System.debug('earningsBreakdown earningsBreakdown earningsBreakdown' + earningsBreakdown);
            System.debug('summaryEarnings summaryEarnings summaryEarnings' + summaryEarnings);
           // dataSupplier    = (String) sdbMonth.get('Name');
            billingCurrency = (String) sdbMonth.get('Currency_Code__c');
            billingMonth    = (Double) sdbMonth.get('month');
            reportIssueDate = (Date) Date.today();  
            earningsBreakdown = earningsBreakdown;
            summaryEarnings = summaryEarnings;
        }
        public SummaryDetail(){
            
        }
    }

    public class EarningBreakdown {
        @AuraEnabled
        public String currentBillingMonth {get; set;}  
        @AuraEnabled
        public Double grossEarnings  {get; set;}  
        @AuraEnabled
        public Double netEarnings  {get; set;}  
        public EarningBreakdown(AggregateResult earningsBreakdownRecord){
            currentBillingMonth = (String) earningsBreakdownRecord.get('segmentSuppCat');
            grossEarnings = (Double) earningsBreakdownRecord.get('grossEarnings');
            netEarnings = (Double) earningsBreakdownRecord.get('exportEarnings');
        }
    }

    public class SummaryEarning {
        @AuraEnabled
        public String lastSixMonthsCoL1 {get; set;}  
        @AuraEnabled
        public String lastSixMonthsCol2 {get; set;}  
        @AuraEnabled
        public Double grossEarningsUSD  {get; set;}  
        @AuraEnabled
        public String billingCurrency  {get; set;}
        @AuraEnabled
        public Double netEarningsUSD  {get; set;}
        @AuraEnabled
        public Double netEarningsBillingCurrency  {get; set;}  
        public SummaryEarning(AggregateResult summaryEarningRecord){
            lastSixMonthsCoL1 = String.valueOf(summaryEarningRecord.get('month'));
            lastSixMonthsCoL2 = String.valueOf(summaryEarningRecord.get('year'));
            grossEarningsUSD = (Double) summaryEarningRecord.get('grossEarnings');
            billingCurrency = (String) summaryEarningRecord.get('Currency_Code__c');
            netEarningsUSD  = (Double) summaryEarningRecord.get('exportEarnings');
            netEarningsBillingCurrency = (Double) summaryEarningRecord.get('earningExRate');
        }
    }

    public class EarningsReportRow {
        @AuraEnabled
        public String country {get; set;}
        @AuraEnabled
        public String organizationName {get; set;}
        @AuraEnabled
        public String category {get; set;}
        @AuraEnabled
        public String segmentName {get; set;}
        @AuraEnabled
        public Double grossEarning {get; set;}
        @AuraEnabled
        public Double netEarningUSD {get; set;}
        @AuraEnabled
        public Double netEarning {get; set;}
        @AuraEnabled
        public String segmentKey {get; set;}
    }

    public class EarningsReportBuyerAndAdvertiserDetail {
        @AuraEnabled
        public String buyerCountry {get; set;}
        @AuraEnabled
        public String targetCountry {get; set;}
        @AuraEnabled
        public String buyer {get; set;}
        @AuraEnabled
        public String advertiser {get; set;}
        @AuraEnabled
        public String segmentName {get; set;}
        @AuraEnabled
        public Double grossEarning {get; set;}
    }
}