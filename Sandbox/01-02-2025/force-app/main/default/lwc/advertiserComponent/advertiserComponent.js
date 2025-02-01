import { LightningElement, wire, api} from 'lwc';
import getItems from '@salesforce/apex/AdvertiserController.getRecords';
import execute from '@salesforce/apex/AdvertiserController.execute';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AdvertiserComponent extends LightningElement {
    data            = [];
    selectedRecord  = [];
    showModal       = false;

    dateFrom;
    dateTo;
    country;
    platform;

    onChangeDateFrom(event){
        this.dateFrom = event.target.value;
    }

    onChangeDateTo(event){
        this.dateTo = event.target.value;
    }

    onChangeCountry(event){
        this.country = event.target.value;
    }

    onPlatform(event){
        this.platform = event.target.value;
    }

    handleSearch(){
        this.showModal  = true;
        this.data       = [];

        console.log('dateFrom dateFrom dateFrom', this.dateFrom);
        console.log('dateTo dateTo dateTo', this.dateTo);
        console.log('country country country', this.country);
        console.log('platform platform platform', this.platform);

        let isProceed = true;

        if( this.dateFrom != 'undefined' && this.dateTo != 'undefined' && new Date(this.dateFrom).getTime() > new Date(this.dateTo).getTime() ){
            console.log('Date Checker');
            this.showToastMessage('Error', 'Date From must be less than Date To.', 'error');
            this.showModal  = false
            isProceed = false;
        } 

        if( isProceed ){
            getItems({dateFrom : this.dateFrom, dateTo : this.dateTo, countryCode : this.country, platform : this.platform})
            .then(result => {
                console.log('result result result', result);
                this.data = result;
                this.showModal = false;
            })
            .catch(error => {
                console.log('Error', error.body.message);
                this.showToastMessage('Error', error.body.message, 'error');
            });
        }
    }

    selectMapping(event){
        console.log('event.detail', event.detail.Id);
        console.log('event.detail', event.detail.Name);

        let mappingId   = event.detail.Id,
            name        = event.detail.Name;

        let index   = this.selectedRecord.findIndex(item => item.name === name);
        let data    = this.data.find(item => item.name === name);
        if( index != -1 ){
            this.selectedRecord = this.selectedRecord.map(item => {
                if(item.name === name){
                    item.mappingId  = mappingId;
                    item.hasAccount = data.itemAccount.hasAccount
                }
                return item;
            });
        } else {
            this.selectedRecord.push({
                name,
                mappingId,
                hasAccount : data.itemAccount.hasAccount
            });
        }

        console.log('this.selectedRecord', JSON.stringify(this.selectedRecord));
    }

    selectAccount(event){
        let accountId   = event.detail.Id,
            name        = event.detail.Name;

        let index   = this.selectedRecord.findIndex(item => item.name === name);
        let data    = this.data.filter(item => item.name === name);
        console.log('data', data);
        if( index != -1 ){
            this.selectedRecord = this.selectedRecord.map(item => {
                if(item.name === name){
                    item.accountId  = accountId;
                    item.hasMapping = data[0].itemadvertiserMapping.hasAdvertisingMapping
                }
                return item;
            });
        } else {
            this.selectedRecord.push({
                name,
                accountId,
                hasMapping : data[0].itemadvertiserMapping.hasAdvertisingMapping
            });
        }

        console.log('this.selectedRecord', JSON.stringify(this.selectedRecord));
    }

    onclearAccount(event){
        let name    = event.detail;
        console.log('event.detail', name);
        
        let index   = this.selectedRecord.findIndex(item => item.name === name);
        if( index != -1 ){
            this.selectedRecord = this.selectedRecord.map(item => {
                if(item.name === name && "accountId" in item){
                    if("mappingId" in item){
                        delete item.accountId;
                    }
                }
                return item;
            });
        } 
        console.log('this.selectedRecord', JSON.stringify(this.selectedRecord));
    }

    onclearMapping(event){
        let name    = event.detail;
        console.log('onclearMapping', name);
        let index   = this.selectedRecord.findIndex(item => item.name === name);
        if( index != -1 ){
            this.selectedRecord = this.selectedRecord.map(item => {
                if(item.name === name && "mappingId" in item){
                    delete item.mappingId;
                }
                return item;
            });
        } 

        console.log('this.selectedRecord', JSON.stringify(this.selectedRecord));
    }

    handleSingleExecute(event){
        let name        = event.target?.dataset?.name;
        let toBulkData  =  [];
        let proceed     = true;
        
        console.log('this.selectedRecord', JSON.stringify(this.selectedRecord));
        console.log('name name name', name);

        let filterDataResult =  this.data.filter( item => !item.itemAccount.hasAccount && !item.itemadvertiserMapping.hasAdvertisingMapping && item.name == name );
        if( filterDataResult.length > 0 ){
            toBulkData.push({
                name : filterDataResult[0].name,
                accountId : '',
                mappingId : ''
            });
        }
        
        if(this.selectedRecord.length > 0){
            let filterSelectedRecord =  this.selectedRecord.filter(item => item.name == name);
            console.log('filterSelectedRecord', filterSelectedRecord);
            if( filterSelectedRecord.length > 0 ){
                if(filterSelectedRecord[0].hasMapping && "accountId" in filterSelectedRecord[0] && !("mappingId" in filterSelectedRecord[0]) ){
                    this.showToastMessage('Error', 'Please select Advertiser Mapping before you can click execute.', 'error');
                    proceed = false;
                } else if(filterSelectedRecord[0].hasAccount && "mappingId" in filterSelectedRecord[0] && !("accountId" in filterSelectedRecord[0])){
                    this.showToastMessage('Error', 'Please select Account before you can click execute.', 'error');
                    proceed = false;
                } else {
                    filterSelectedRecord.forEach(item => {
                        if( "accountId" in item && "mappingId" in item ){
                            toBulkData.push({
                                name : item.name,
                                accountId : item.accountId,
                                mappingId : item.mappingId
                            });
                        } else if( !item.hasAccount && "accountId" in item ){
                            toBulkData.push({
                                name : item.name,
                                accountId : item.accountId,
                                mappingId : null
                            });
                        } else if( !item.hasMapping && "accountId" in item ){
                            toBulkData.push({
                                name : item.name,
                                accountId : null,
                                mappingId : item.mappingId,
                            });
                        }
                    });
                }
            }
        }

        
        console.log('toBulkData toBulkData toBulkData', JSON.stringify(toBulkData));
        if( toBulkData.length > 0){
            this.handleExecute(toBulkData);
        } else {
            if( proceed ){
                this.showToastMessage('Error', 'Can\'t find any records to execute.', 'error'); 
            }
        }
    }

    handleBulk(event){
        let toBulkData =  [];
    
        let filterDataResult =  this.data.filter( item => !item.itemAccount.hasAccount && !item.itemadvertiserMapping.hasAdvertisingMapping );
        if( filterDataResult.length > 0 ){
            filterDataResult.forEach(item => {
                toBulkData.push({
                    name : item.name,
                    accountId : '',
                    mappingId : ''
                });
            })
        }
    
        this.selectedRecord.forEach(item => {
            if( "accountId" in item && "mappingId" in item ){
                toBulkData.push({
                    name : item.name,
                    accountId : item.accountId,
                    mappingId : item.mappingId
                });
            } else if( !item.hasAccount && "accountId" in item ){
                toBulkData.push({
                    name : item.name,
                    accountId : item.accountId,
                    mappingId : null
                });
            } else if( !item.hasMapping && "accountId" in item ){
                toBulkData.push({
                    name : item.name,
                    accountId : null,
                    mappingId : item.mappingId,
                });
            }
        });

        console.log('toBulkData toBulkData toBulkData', JSON.stringify(toBulkData));
        if( toBulkData.length > 0 ){
            this.handleExecute(toBulkData);
        } else {
            if( this.selectedRecord.length == 0){
                this.showToastMessage('Error', 'Can\'t find any records to execute.', 'error'); 
            }
        }
    }

    async handleExecute( data ){
        
        console.log('data data data', data);
        this.showModal = true;
        try {
            let result = await execute({jsonData : JSON.stringify(data)});
            console.log('result result result', result);
            if( result ){
                this.selectedRecord = [];
                this.showToastMessage('Success', 'Record/s Successfully executed.', 'success');
                this.handleSearch();
            }
        } catch (error) {
            console.log('Error', error.body.message);
            this.showToastMessage('Error', error.body.message, 'error');
            this.showModal = false;
        }
    }

    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({ title, message, variant, mode: 'dismissable'});
        this.dispatchEvent(evt);
    }
}