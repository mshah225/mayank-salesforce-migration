import { LightningElement, api } from 'lwc';
import submitFeedback from '@salesforce/apex/FeedbackButtonService.submitFeedback';

export default class FeedbackButton extends LightningElement {
    @api iconSize = 'xx-small';
    @api carName;

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
        if (feedback.length > 0) {
            submitFeedback({ carName: this.carName, feedbackText: feedback })
                .then(result => {
                    this.makeToast('success', 'Success', 'Feedback successfully submitted');
                })
                .catch(error => {
                    if (error.body.message.includes('Our support team has been notified of this error. If you require immediate assistance please call 1-855-ASU-5080')) {
                        this.makeToast('error', 'Error', error.body.message);
                    } else {
                        this.makeToast('error', 'Error', error.body.message+'. Our support team has been notified of this error. If you require immediate assistance please call 1-855-ASU-5080');
                    }
                });
        } else {
            this.makeToast('error','Error','Feedback must contain some content.')
        }
    }

    makeToast(type, title, body) {
        console.log(type);
        console.log(title);
        console.log(body);
    }
}