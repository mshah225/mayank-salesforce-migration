import {LightningElement} from 'lwc';
import submitFeedback from '@salesforce/apex/FeedbackButtonService.submitFeedback';
import LightningQuestionAnswerModal from 'c/lightningQuestionAnswerModal';

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
    feedbackModalButtons = [];

    async openModal() {
        await LightningQuestionAnswerModal.open({
            size: 'small',
            description: 'Provide feedback',
            title: 'Feedback',
            questions: this.questions,
            buttonDescription: {
                okButtonLabel: 'Save',
                cancelButtonLabel: 'Cancel',
                awaitBeforeClosing: (resp) => {
                    if (resp.state === 'success') {
                        // If the submit button has been pressed
                        let feedback = resp.body[0].answer; // answer to the first question

                        if (feedback == null) feedback = '';
                        feedback = feedback.trim();

                        // Submit it - then return to close the modal
                        return submitFeedback({carName: this.carName, feedbackText: feedback})
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

                                throw error;
                            });
                    } else {
                        // If the cancel button was pressed
                        return Promise.resolve();
                    }
                },
            },
        });
    }

    openModalKeyboard(e) {
        if (this.isSelectionKey(e.which)) this.openModal();
    }

    makeToast(type, title, body) {
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
