import {LightningElement, api} from 'lwc';

export default class LightningDesignModal extends LightningElement {
    @api title = 'Basic modal';
    @api description = 'Modal body';
    @api buttons = [];

    hideModal = true;
    notHideModal = false;

    @api
    openModal() {
        this.hideSaveModal = false;
        this.notHideSaveModal = true;
        this.template.querySelector('.slds-modal').classList.add('slds-fade-in-open');
        this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop_open');
        this.template.querySelector('.slds-modal').focus();
    }
    @api
    closeModal() {
        this.template.querySelector('.slds-modal').classList.remove('slds-fade-in-open');
        this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop_open');
        this.hideSaveModal = true;
        this.notHideSaveModal = false;
    }
}
