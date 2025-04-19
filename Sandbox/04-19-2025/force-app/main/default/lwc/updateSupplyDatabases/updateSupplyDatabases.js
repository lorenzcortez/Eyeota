import { LightningElement, api, wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import executeBatch from '@salesforce/apex/UpdateSupplyDatabasesController.executeBatch';

export default class CalculateMonthlyRevenue extends LightningElement {
    recordId;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    connectedCallback(){
        console.log('recordId recordId recordId = ' + this.recordId);
        executeBatch({recordId : this.recordId})
        .then(result => {  
            console.log('result result result', result);
            const evt = new ShowToastEvent({
                title: 'Info',
                message: 'Batch is now currently running.',
                variant: 'info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch(error => {
            console.log('### Error ' + JSON.stringify(error));
        });  
    }
}