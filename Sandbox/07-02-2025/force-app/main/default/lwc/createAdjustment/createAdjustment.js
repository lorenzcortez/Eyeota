import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createAdjustmentAndTypes from '@salesforce/apex/AdjustmentController.createAdjustmentAndTypes';

export default class CreateAdjustment extends LightningElement {
    
    isShowModal = false;
    isShowSpinner = false;
    year;
    selectedMonth;

    monthOptions = [
        {label : 'January', value : 'January'},
        {label : 'February', value : 'February'},
        {label : 'March', value : 'March'},
        {label : 'April', value : 'April'},
        {label : 'May', value : 'May'},
        {label : 'June', value : 'June'},
        {label : 'July', value : 'July'},
        {label : 'August', value : 'August'},
        {label : 'September', value : 'September'},
        {label : 'October', value : 'October'},
        {label : 'November', value : 'November'},
        {label : 'December', value : 'December'}
    ];

    connectedCallback(){
        let currentDate = new Date();
        let currentMonth = currentDate.getMonth() + 1;
        this.selectedMonth = this.monthOptions[currentMonth].value;
    }

    handleCreateAdjustment(){
        this.isShowModal = true;
    }

    hideCancel(){
        this.isShowModal = false;
    }

    changeMonth(event){
        this.selectedMonth = event.detail.value;
    }

    changeYear(event){
        this.year = event.target.value;
    }

    handleClick(event){
        const allValid = [...this.template.querySelectorAll('.validate')].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            this.isShowSpinner = true;
            createAdjustmentAndTypes({ month : this.selectedMonth, year: this.year.toString()})
            .then(result => {
                console.log('result result result', result);
                this.isShowSpinner = false;
                this.hideCancel();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record successfully created.',
                        variant: 'success',
                    }),
                );

                let url = window.location.origin + '/'+ result;
                window.open(url, '_self');

            }).catch(error => {
                console.log('error error error' + JSON.stringify(error));
            });
        }
    }
}