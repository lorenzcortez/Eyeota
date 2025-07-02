import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPartnerBrandedData from '@salesforce/apex/SupplierEarningReportSummaryController.getPartnerBrandedData';
import getCustomData from '@salesforce/apex/SupplierEarningReportSummaryController.getCustomData';
import getEyeotaBrandedData from '@salesforce/apex/SupplierEarningReportSummaryController.getEyeotaBrandedData';
import getBuyerAndAdvertiserDetailData from '@salesforce/apex/SupplierEarningReportSummaryController.getBuyerAndAdvertiserDetailData';
import getAccountName from '@salesforce/apex/SupplierEarningReportSummaryController.getAccountName';
import getSummaryDetail from '@salesforce/apex/SupplierEarningReportSummaryController.getSummaryDetail';
import getEarningsBreakdown from '@salesforce/apex/SupplierEarningReportSummaryController.getEarningsBreakdown';

const columns = [
    { label: 'Country', fieldName: 'country', wrapText: true, hideDefaultActions: true  },
    { label: 'Organization Name', fieldName: 'organizationName', wrapText: true, hideDefaultActions: true  },
    { label: 'Category', fieldName: 'category', wrapText: true, hideDefaultActions: true  },
    { label: 'Segment Name', fieldName: 'segmentName', wrapText: true, hideDefaultActions: true  },
    { label: 'Segment Key', fieldName: 'segmentKey', wrapText: true, hideDefaultActions: true  },
    { label: 'Gross Earnings (USD)', fieldName: 'grossEarning', type: 'currency', wrapText: true, hideDefaultActions: true  },
    { label: 'Net Earnings (USD)', fieldName: 'netEarningUSD', type: 'currency', wrapText: true, hideDefaultActions: true  },
    { label: 'Net Earnings', fieldName: 'netEarning', type: 'currency', wrapText: true, hideDefaultActions: true  }
];

const buyerAndAdvertiserDetailColumns = [
    { label: 'Buyer Country', fieldName: 'buyerCountry', wrapText: true, hideDefaultActions: true  },
    { label: 'Target Country', fieldName: 'targetCountry', wrapText: true, hideDefaultActions: true  },
    { label: 'Buyer', fieldName: 'buyer', wrapText: true, hideDefaultActions: true  },
    { label: 'Advertiser', fieldName: 'advertiser', wrapText: true, hideDefaultActions: true  },
    { label: 'Segment Name', fieldName: 'segmentName', wrapText: true, hideDefaultActions: true  },
    { label: 'Gross Earnings (USD)', fieldName: 'grossEarning', type: 'currency', wrapText: true, hideDefaultActions: true  },
];

export default class SupplierEarningReports extends LightningElement {
    @api
    accountId;
    accountName;
    columns     = columns;
    buyerAndAdvertiserDetailColumns = buyerAndAdvertiserDetailColumns;
    rowLimit    = 20;
    isShowSpinner = true;

    //Summary
    summaryDetail = {};
    earningsBreakdown = [];

    // PartnerBranded
    partnerBrandedData          = [];
    partnerBrandedRowOffset     = 0;
    isLoadingPartnerBranded     = false;
    allPartnerBrandedDataLoaded = false;

    // Eyeota Branded
    eyeotaBrandedData          = [];
    eyeotaBrandedRowOffset     = 0;
    isLoadingEyeotaBranded     = false;
    allEyeotaBrandedDataLoaded = false;
    
    // Custom
    customData          = [];
    customRowOffset     = 0;
    isLoadingCustom     = false;
    allCustomDataLoaded = false;

    // Buyer and Advertiser Detail
    buyerAndAdvertiserDetailData          = [];
    buyerAndAdvertiserDetailRowOffset     = 0;
    isLoadingBuyerAndAdvertiserDetail    = false;
    allBuyerAndAdvertiserDetailDataLoaded = false;


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.state?.c__accountId) {
            this.accountId = currentPageReference.state?.c__accountId;
        }
    }

    async connectedCallback() {
        console.log('connectedCallback'); 
        console.log('accountId', this.accountId);

        try {
            await this.getAccountName();
            await this.getSummaryDetail();
            await this.getEarningsBreakdown();
        } catch (error) {
            console.error('Error in one of the methods:', error);
        } finally {
           this.isShowSpinner = false;
        }
    }

    async getAccountName(){
        const response = await getAccountName({accountId: this.accountId})
        console.log('account name', response);
        if(response){
            this.accountName = response;
        }
    }

    async getSummaryDetail(){
        const response = await getSummaryDetail({accountId: this.accountId})
        console.log(' summary response', JSON.stringify(response)); 
        if(response){
            this.summaryDetail = response;
        }
    }
    
    async getEarningsBreakdown(){
        const response = await getEarningsBreakdown({ accountId: this.accountId });
        console.log(' earnings breakdown', JSON.stringify(response));
        if(response){
            this.earningsBreakdown = response;
        }
    }

    async partnerBrandedloadMoreData(){
        if (this.allPartnerBrandedDataLoaded || this.isLoadingPartnerBranded) return;
        this.isLoadingPartnerBranded = true;

        try {
            const response = await getPartnerBrandedData({accountId: this.accountId, rows: this.rowLimit, offset: this.partnerBrandedRowOffset})
            console.log('response response response', response); 
            if (response.length < this.rowLimit) {
                this.allPartnerBrandedDataLoaded = true;
            }
            this.partnerBrandedData = [...this.partnerBrandedData, ...response];
            this.partnerBrandedRowOffset += this.rowLimit;

        } catch (error) {
            console.error('Error fetching data:', error);
        } finally {
            this.isLoadingPartnerBranded = false;
        }
    }

    async customloadMoreData(){
        if (this.allCustomDataLoaded || this.isLoadingCustom) return;
        this.isLoadingCustom = true;
        
        try {
            const response = await getCustomData({accountId: this.accountId, rows: this.rowLimit, offset: this.customRowOffset})
            console.log('response response response', response); 
            if (response.length < this.rowLimit) {
                this.allCustomDataLoaded = true;
            }
            this.customData = [...this.customData, ...response];
            this.customRowOffset += this.rowLimit;
        } catch (error) {
            console.error('Error fetching data:', error);
        } finally {
            this.isLoadingCustom = false;
        }
    }

    async eyeotaBrandedloadMoreData(){
        if (this.allEyeotaBrandedDataLoaded || this.isLoadingEyeotaBranded) return;
        this.isLoadingEyeotaBranded = true;

        try {
            const response = await getEyeotaBrandedData({accountId: this.accountId, rows: this.rowLimit, offset: this.eyeotaBrandedRowOffset})
            console.log('response response response', response);
            if (response.length < this.rowLimit) {
                this.allEyeotaBrandedDataLoaded = true;
            }
            this.eyeotaBrandedData = [...this.eyeotaBrandedData, ...response];
            this.eyeotaBrandedRowOffset += this.rowLimit; 
        } catch (error) {
            console.error('Error fetching data:', error);
        } finally {
            this.isLoadingEyeotaBranded = false;
        }
    }

    async buyerAndAdvertiserDetailloadMoreData(){
        if (this.allBuyerAndAdvertiserDetailDataLoaded || this.isLoadingBuyerAndAdvertiserDetail) return;
        this.isLoadingBuyerAndAdvertiserDetail = true;

        try {
            const response = await getBuyerAndAdvertiserDetailData({accountId: this.accountId, rows: this.rowLimit, offset: this.buyerAndAdvertiserDetailRowOffset})
            console.log('response response response', response);
            if (response.length < this.rowLimit) {
                this.allBuyerAndAdvertiserDetailDataLoaded = true;
            }
            this.buyerAndAdvertiserDetailData = [...this.buyerAndAdvertiserDetailData, ...response];
            this.buyerAndAdvertiserDetailRowOffset += this.rowLimit; 
        } catch (error) {
            console.error('Error fetching data:', error);
        } finally {
            this.isLoadingBuyerAndAdvertiserDetail = false;
        }
    }

    async generateFile(event){
        let tabName         = event.target.name,
            queryLimit      = 2000,
            data            = [],
            isLoopThrough   = true,
            queryOffset     = 0;

        console.log('tabName tabName tabName', tabName);

        this.isShowSpinner   = true;

        do {
            let response = [];
            if(tabName == 'Partner-branded'){
                response = await getPartnerBrandedData({accountId: this.accountId, rows: queryLimit, offset: queryOffset})
            } else if(tabName == 'Eyeota-branded'){
                response = await getEyeotaBrandedData({accountId: this.accountId, rows: queryLimit, offset: queryOffset})
            } else if(tabName == 'Custom'){
                response = await getCustomData({accountId: this.accountId, rows: queryLimit, offset: queryOffset})
            }  else if(tabName == 'Buyer and Advertiser Detail'){
                response = await getBuyerAndAdvertiserDetailData({accountId: this.accountId, rows: queryLimit, offset: queryOffset})
            }
            
            console.log('response response response', response);
            data.push(...response);
            queryOffset += queryLimit;
            if (response.length < queryLimit) {
                isLoopThrough = false;
            }

        } while (isLoopThrough);

        let headers = tabName == 'Buyer and Advertiser Detail' ? this.buyerAndAdvertiserDetailColumns : this.columns;
        let csvBody = data.map(item => {
            let arrayOfData = [];
            headers.forEach( header => {
                if(header.fieldName in item ){
                    if(isNaN(item[header.fieldName])){
                        arrayOfData.push('"' + item[header.fieldName].replaceAll('#','') + '"');
                    } else {
                        arrayOfData.push('"' + item[header.fieldName] + '"');
                    }
                } else {
                     arrayOfData.push('""');
                }
            });
            return arrayOfData;
        }),
        csvHeader = headers.map( header => {
            return header.label
        });

        let csvFile   = csvHeader.toString() +'\n'+csvBody.join('\n');
        const downLink = document.createElement('a');
        downLink.href = 'data:text/csv;charset=utf-8,'+encodeURI(csvFile);
        downLink.target = '_blank';
        downLink.download = tabName + '.csv';
        downLink.click();

        const toastEvent = new ShowToastEvent({
            title   : 'Success',
            message : 'Successfully Imported.',
            variant : 'success'
        });
        this.dispatchEvent(toastEvent);
        this.isShowSpinner = false;
    }

    async handlePartnerBrandedTab(){
        this.isShowSpinner = true;

        await this.partnerBrandedloadMoreData();

        this.isShowSpinner = false;
    }

    async handleEyeotaBrandedTab(){
        this.isShowSpinner = true;

        await this.eyeotaBrandedloadMoreData();

        this.isShowSpinner = false;
    }

    async handleCustomTab(){
        this.isShowSpinner = true;

        await this.customloadMoreData();

        this.isShowSpinner = false;
    }

    async handleBuyerAdvertiserTab(){
        this.isShowSpinner = true;

        await this.buyerAndAdvertiserDetailloadMoreData();

        this.isShowSpinner = false;
    }

    makeId(){
        const dateString = Date.now().toString(36);
        const randomness = Math.random().toString(36).substr(2);
        return dateString + randomness;
    };
}