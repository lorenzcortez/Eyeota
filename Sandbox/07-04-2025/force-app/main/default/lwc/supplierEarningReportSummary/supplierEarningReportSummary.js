import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import eyeotaLogo from '@salesforce/resourceUrl/EyeotaLogo';
// import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
// import ACCTNAME from '@salesforce/schema/Account.Name';
const columns = [
    { label: 'Earnings Breakdown (Current Billing Month)', fieldName: 'amount', type: 'currency', wrapText: true, hideDefaultActions: true  },
    { label: 'Gross Earnings (USD)', fieldName: 'amount', type: 'currency', wrapText: true, hideDefaultActions: true  },
    { label: 'Net Earnings (USD)', fieldName: 'amount', type: 'currency', wrapText: true, hideDefaultActions: true  },
];

export default class SupplierEarningReportSummary extends LightningElement {

    columns = columns;
    logo = eyeotaLogo;

    @api
    summaryDetail = {};
    @api
    earningsBreakdown = [];

    get totalGrossEarnings(){
        let total = 0;
        this.earningsBreakdown.forEach(earningBreakdown => {
            total += earningBreakdown.grossEarnings;
        });
        return total;
    }

    get totalNetEarnings(){
        let total = 0;
        this.earningsBreakdown.forEach(earningBreakdown => {
            total += earningBreakdown.netEarnings;
        });
        return total;
    }

    @api
    accountId;

    // @wire(getRecord, { recordId: '$accountId', fields: [ACCTNAME] })
    // wiredAccount;

    @api
    dSupplier;
    // get dataSupplier(){
    //     let name = '';
    //     if(this.wiredAccount.data){
    //         name = getFieldValue(this.wiredAccount.data, ACCTNAME);
    //     }
    //     return name;
    // }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.accountId = currentPageReference.state.c__accountId;
        }
    }

    connectedCallback() {
        const data = this.generateData({ amountOfRecords: 5 });
        this.data = data;
    }

    generateData({ amountOfRecords }) {
        return [...Array(amountOfRecords)].map((_, index) => {
            return {
                name: `Name (${index})`,
                website: 'www.salesforce.com',
                amount: Math.floor(Math.random() * 100),
                phone: `${Math.floor(Math.random() * 9000000000) + 1000000000}`,
                closeAt: new Date(
                    Date.now() + 86400000 * Math.ceil(Math.random() * 20)
                ),
            };
        });
    }
}