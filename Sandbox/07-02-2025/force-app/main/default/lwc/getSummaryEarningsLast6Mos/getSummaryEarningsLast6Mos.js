import { LightningElement, api } from 'lwc';
import getAccountName from '@salesforce/apex/SupplierEarningReportSummaryController.getAccountName';
import getSummaryDetail from '@salesforce/apex/SupplierEarningReportSummaryController.getSummaryDetail';
import getEarningsBreakdown from '@salesforce/apex/SupplierEarningReportSummaryController.getEarningsBreakdown';
import getSummaryEarningsMonthsFromToday from '@salesforce/apex/SupplierEarningReportSummaryController.getSummaryEarningsMonthsFromToday';
import {
    FlowNavigationNextEvent,
    FlowNavigationFinishEvent
} from 'lightning/flowSupport';

export default class GetSummaryEarningsLast6Mos extends LightningElement {
    @api
    accountId;

    @api
    accountName;
    
    summaryDetailResp = {};
    @api
    get summaryDetail(){
        return JSON.stringify(this.summaryDetailResp);
    }

    earningsBreakdownResp = [];
    @api
    get earningsBreakdown(){
        return JSON.stringify(this.earningsBreakdownResp);
    }

    summaryEarningsLast6Mos = [];
    @api
    get summaryEarnings(){
        return JSON.stringify(this.summaryEarningsLast6Mos);
    }

    @api
    availableActions = [];

    connectedCallback(){
        this.initializeComponent();
    }

    async initializeComponent(){
        this.accountName = await getAccountName({ accountId: this.accountId });
        this.summaryDetailResp = await getSummaryDetail({ accountId: this.accountId });
        this.earningsBreakdownResp = await getEarningsBreakdown({ accountId: this.accountId  });
        console.log('accountName: '+this.accountName);
        console.log('summaryDetail: '+(this.summaryDetail ? JSON.stringify(this.summaryDetail) : ''));
        console.log('earningsBreakdown: '+(this.earningsBreakdown ? JSON.stringify(this.earningsBreakdown) : ''));

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
        console.log('summaryEarningsLast6Mos: '+(JSON.stringify(this.summaryEarningsLast6Mos)));

        if (this.availableActions.find((action) => action === 'NEXT')) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        } else if (this.availableActions.find((action) => action === 'FINISH')) {
            // navigate to the next screen
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
        }
    }
}