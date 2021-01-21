import { LightningElement, api } from 'lwc';

export default class FeedbackButton extends LightningElement {
    @api iconSize = 'xx-small';
    showError = false;

    openModal() {
        this.template.querySelector('.slds-modal').classList.add('slds-fade-in-open');
        this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop_open');
    }
    closeModal() {
        this.template.querySelector('.slds-modal').classList.remove('slds-fade-in-open');
        this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop_open');
    }
    
    sendFeedback() {
        let feedback = '';
        if (this.template.querySelector('lightning-textarea').value) {
            feedback = this.template.querySelector('lightning-textarea').value.trim();
        }
        if (feedback && feedback.length > 0) {
            console.log(feedback);
            this.showError = false;
        } else {
            console.log('EMPTY!!');
            this.showError = true;
        }
    }
}