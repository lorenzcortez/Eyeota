import { LightningElement, api, track, wire } from 'lwc';

export default class SearchAccount extends LightningElement {
    isLoading = true; 

    @api options                = [];
    @api label                  = '';
    @api isRequired             = false;
    @api isDisabled             = false;

    optionsStorage = [];
    selectedId;

    @api validate() {
        this.template.querySelector('lightning-input').reportValidity();
    }

    // connectedCallback(){
    //     this.options = [
    //         {
    //             name : 'Test',
    //             reference : 'Test',
    //             label  : 'Test'
    //         }
    //     ];
    // }

    handleInputChange(event) {
        this.selectedId = '';
        const inputVal  = event.target.value;
        this.options    = this.optionsStorage.filter(item => item.name.toLowerCase().includes(inputVal.toLowerCase()));
        if (this.options.length && inputVal) {
            this.template.querySelector('.slds-combobox.slds-dropdown-trigger.slds-dropdown-trigger_click')?.classList.add('slds-is-open');
            this.template.querySelector('.slds-combobox.slds-dropdown-trigger.slds-dropdown-trigger_click')?.focus();
        }
    }

    handleOnBlur(event) {
        setTimeout(() => {
            if (!this.selectedId) {
                this.template.querySelector('.slds-combobox.slds-dropdown-trigger.slds-dropdown-trigger_click')?.classList.remove('slds-is-open');
            }
        }, 300);
    }

    handleOptionClick(event) {

        this.selectedId = event.currentTarget?.dataset?.id;
        this.refName      = event.currentTarget?.dataset?.refName;
        
        this.template.querySelector('.slds-combobox.slds-dropdown-trigger.slds-dropdown-trigger_click')?.classList.remove('slds-is-open');
        const selectedEvent = new CustomEvent('objectselected', { 
            detail: {
                Id : this.selectedId,
                Name : this.refName
            }
        });
        this.dispatchEvent(selectedEvent);

    }
}