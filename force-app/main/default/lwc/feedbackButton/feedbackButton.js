import {LightningElement, api, track} from 'lwc';
import submitFeedback from '@salesforce/apex/FeedbackButtonService.submitFeedback';

export default class FeedbackButton extends LightningElement {
    @api iconSize = 'xx-small';
    @api carName;
    @api title =
        'We value your feedback. Do you have a question, issue, or idea to improve this service? Submit it below';
    @api sendToastEvent = false;
    @track hideModal = true;
    @track notHideModal = false;
    @track loading = false;

    openModal() {
        this.hideModal = false;
        this.notHideModal = true;
        this.template.querySelector('.slds-modal').classList.add('slds-fade-in-open');
        this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop_open');
        this.template.querySelector('.slds-modal').focus();
    }
    closeModal() {
        this.template.querySelector('.slds-modal').classList.remove('slds-fade-in-open');
        this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop_open');
        this.hideModal = true;
        this.notHideModal = false;
    }

    sendFeedback() {
        let feedback = '';
        if (this.template.querySelector('lightning-textarea').value) {
            feedback = this.template.querySelector('lightning-textarea').value.trim();
        }
        if (feedback.length > 0) {
            this.loading = true;
            submitFeedback({carName: this.carName, feedbackText: feedback})
                .then(() => {
                    this.closeModal();
                    this.template.querySelector('lightning-textarea').value = '';
                    this.makeToast('success', 'Success', 'Feedback successfully submitted');
                })
                .catch((error) => {
                    let errorMsg = error.body.message;
                    if (
                        !errorMsg.includes(
                            'Our support team has been notified of this error. If you require immediate assistance please call 1-855-ASU-5080'
                        )
                    ) {
                        errorMsg +=
                            '. Our support team has been notified of this error. If you require immediate assistance please call 1-855-ASU-5080';
                    }

                    this.makeToast('error', 'Error', errorMsg);
                })
                .finally(() => {
                    this.loading = false;
                });
        } else {
            this.makeToast('error', 'Error', 'Feedback must contain some content.');
        }
    }

    makeToast(type, title, body) {
        if (this.sendToastEvent) {
            this.dispatchEvent(
                new CustomEvent('showtoast', {
                    detail: {
                        title: title,
                        message: body,
                        type: type,
                        duration: 15000,
                    },
                })
            );
        } else {
            this.template.querySelector('c-lightning-design-toast').fireParams(title, body, type, 15000);
        }
    }
}
