import {api} from 'lwc';
import {cloneObj} from 'c/helperFunctions';
import LightningModal from 'lightning/modal';

export default class LightningQuestionAnswerModal extends LightningModal {
    @api title = '';

    @api set questions(val) {
        this._questions = cloneObj(val);
    }
    get questions() {
        return this._questions;
    }
    _questions = [];

    @api buttonDescription = {
        okButtonLabel: 'Okay',
        cancelButtonLabel: 'Cancel',
        awaitBeforeClosing: () => {
            return Promise.resolve();
        },
    };

    isSubmitting = false;

    reportValidity() {
        const qaSection = this.template.querySelector('c-lightning-question-answer-section');
        return qaSection.reportValidity();
    }

    handleOkay() {
        if (!this.reportValidity()) {
            return; // Cannot complete if required fields aren't filled in
        }

        let response = new QAModalResponse('success', this.questions);

        if (this.buttonDescription.awaitBeforeClosing != null) {
            this.disableClose = true;
            this.isSubmitting = true;
            this.buttonDescription
                .awaitBeforeClosing(response)
                .finally(() => {
                    this.disableClose = false;
                    this.isSubmitting = false;
                })
                .then(() => {
                    this.close(response);
                });
        } else {
            this.close(response);
        }
    }

    handleCancel() {
        let response = new QAModalResponse('cancel', null);

        if (this.buttonDescription.awaitBeforeClosing != null) {
            this.disableClose = true;
            this.isSubmitting = true;
            this.buttonDescription
                .awaitBeforeClosing(response)
                .finally(() => {
                    this.disableClose = false;
                    this.isSubmitting = false;
                })
                .then(() => {
                    this.close(response);
                });
        } else {
            this.close(response);
        }
    }

    changeAnswer(e) {
        const key = e.detail.key;
        const ans = e.detail.answer;
        for (let i = 0; i < this.questions.length; i++) {
            const q = this.questions[i];
            if (q.key === key) {
                q.answer = ans;
            }
        }
    }
}

export class QAModalResponse {
    state = null;
    body = null;

    /**
     * @param state Describes if this is completing as a part of a 'success' or a 'cancel'
     * @param body Passed message (such as the body of the question and answers for the QA section)
     */
    constructor(state, body) {
        this.state = state;
        this.body = body;
    }
}