import { LightningElement, api, track, wire } from 'lwc';

export default class SearchComponent extends LightningElement {
    isLoading = true; 

    @api options    = [];
    @api label      = '';
    @api isRequired = false;
    @api isDisabled = false;

    optionsStorage = [];
    selected;

    connectedCallback(){
        this.optionsStorage = this.options;
    }

    @api validate() {
        this.template.querySelector('lightning-input').reportValidity();
    }

    onClick(){
        this.template.querySelector('.slds-combobox.slds-dropdown-trigger.slds-dropdown-trigger_click')?.classList.add('slds-is-open');
        this.template.querySelector('.slds-combobox.slds-dropdown-trigger.slds-dropdown-trigger_click')?.focus();
    }

    handleInputChange(event) {
        const inputVal  = event.target.value;
        console.log('inputVal inputVal inputVal', inputVal);
        this.options = inputVal == '' ?  this.optionsStorage : this.optionsStorage.filter(item => item.name.toLowerCase().includes(inputVal.toLowerCase()));
        
        if( inputVal == '' ){
            console.log('dispatchEvent');
            if( this.selected != null || this.selected != 'undefined' ){
                const selectedEvent = new CustomEvent('clear', { 
                    detail: this.selected
                });
                this.dispatchEvent(selectedEvent);
                console.log('dispatchEvent D');
            }
        }
      
        this.selected = '';
    }

    handleOnBlur(event) {
        setTimeout(() => {
            if (!this.selected) {
                this.template.querySelector('.slds-combobox.slds-dropdown-trigger.slds-dropdown-trigger_click')?.classList.remove('slds-is-open');
            }
        }, 300);
    }

    handleOptionClick(event) {
        this.selected = event.currentTarget?.dataset?.name;
        console.log('selected selected selected', this.selected);
        this.template.querySelector('.slds-combobox.slds-dropdown-trigger.slds-dropdown-trigger_click')?.classList.remove('slds-is-open');
        const selectedEvent = new CustomEvent('objectselected', { 
            detail: {
                Id : event.currentTarget?.dataset?.id,
                Name : this.selected
            }
        });
        this.dispatchEvent(selectedEvent);

    }
}