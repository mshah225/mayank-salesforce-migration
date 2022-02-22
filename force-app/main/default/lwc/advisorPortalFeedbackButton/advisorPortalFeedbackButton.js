import {LightningElement} from 'lwc';
import submitFeedback from '@salesforce/apex/FeedbackButtonService.submitFeedback';

export default class AdvisorPortalFeedbackButton extends LightningElement {
    carName = 'Advisor Portal';
    questions = [
        {
            key: 'feedback',
            question:
                'We value your feedback. Do you have a question, issue, or idea to impove the Advisor Portal? Submit it below.',
            type: 'textarea',
        },
    ];

    openModal() {
        this.template.querySelector('c-lightning-question-answer-modal').openModal();
    }

    openModalKeyboard(e) {
        if (this.isSelectionKey(e.which)) this.openModal();
    }

    submitFeedback(e) {
        let feedback = JSON.parse(e.detail)[0].answer;
        if (feedback == null) feedback = '';
        feedback = feedback.trim();
        if (feedback.length > 0) {
            this.loading = true;
            submitFeedback({carName: this.carName, feedbackText: feedback})
                .then(() => {
                    this.makeToast('success', 'Success', 'Feedback successfully submitted');
                })
                .catch((error) => {
                    let errorMsg = error.body.message;
                    if (
                        !errorMsg.includes(
                            'Our support team has been notified of this error. If you require immediate assistance please call 1-855-ASU-5080 (1-855-278-5080)'
                        )
                    ) {
                        errorMsg +=
                            '. Our support team has been notified of this error. If you require immediate assistance please call 1-855-ASU-5080 (1-855-278-5080)';
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
        console.log('[' + type + '] ' + title + ' -- ' + body);
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
    }

    isSelectionKey(code) {
        return code === 13 /*enter*/ || code === 32 /*space*/;
    }
}
