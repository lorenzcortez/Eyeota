import { LightningElement, api } from 'lwc';
import executeRequest from '@salesforce/apex/ExecuteSegmentRevenueTransaction.execute';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ExecuteSegmentRevenutAssignment extends LightningElement {
    @api batchSize;
    handleClick(event){
        this.batchSize = this.batchSize == "" || this.batchSize == null ? 50 : this.batchSize;
        console.log('batchSize', this.batchSize);

        executeRequest({batchSize : this.batchSize})
        .then( result => {  
            this.showToastMessage('Success', 'Batch Successfully executed.', 'success');
        }).catch(error => {
            console.log('Error '+JSON.stringify(error));
        }); 
    }

    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({ title, message, variant, mode: 'dismissable'});
        this.dispatchEvent(evt);
    }
}