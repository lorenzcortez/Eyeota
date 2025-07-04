import { LightningElement, api } from 'lwc';
import getSummaryEarningsMonthsFromToday from '@salesforce/apex/SupplierEarningReportSummaryController.getSummaryEarningsMonthsFromToday';

export default class SummaryEarningsLast6Mos extends LightningElement {
    @api
    accountId;
    summaryEarningsLast6Mos = [];

    isLoading;

    connectedCallback(){
        this.initializeComponent();
    }

    async initializeComponent(){
        this.isLoading = true;

        let summaryEarnings = [];
        for(let i = 1 ; i <= 7 ; i++){
            let resp = await getSummaryEarningsMonthsFromToday({ accountId: this.accountId, monthsBefore: i });
            if(Array.isArray(resp)){
                resp.forEach(respEarning => {
                    let summaryEarningIndx = summaryEarnings.findIndex(earning => earning.lastSixMonthsCoL1 == respEarning.lastSixMonthsCoL1 &&
                                                                        earning.lastSixMonthsCoL2 == respEarning.lastSixMonthsCoL2 &&
                                                                        earning.billingCurrency == respEarning.billingCurrency);

                    if(summaryEarningIndx >= 0){
                        if(summaryEarnings[summaryEarningIndx].grossEarningsUSD && respEarning.grossEarningsUSD){
                            summaryEarnings[summaryEarningIndx].grossEarningsUSD += respEarning.grossEarningsUSD;
                        }
                        if(summaryEarnings[summaryEarningIndx].netEarningsUSD && respEarning.netEarningsUSD){
                            summaryEarnings[summaryEarningIndx].netEarningsUSD += respEarning.netEarningsUSD;
                        }
                        if(summaryEarnings[summaryEarningIndx].netEarningsBillingCurrency && respEarning.netEarningsBillingCurrency){
                            summaryEarnings[summaryEarningIndx].netEarningsBillingCurrency += respEarning.netEarningsBillingCurrency;
                        }
                    } else {
                        summaryEarnings.push(respEarning);
                    }
                });
            }
        }
        this.summaryEarningsLast6Mos = summaryEarnings;
        
        this.isLoading = false;
    }
}