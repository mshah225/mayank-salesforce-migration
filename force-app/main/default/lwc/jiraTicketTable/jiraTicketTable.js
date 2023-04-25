import {LightningElement, api} from 'lwc';
import submitForm from '@salesforce/apex/JiraAddCommentFormController.submitForm';
import LightningQuestionAnswerModal from 'c/lightningQuestionAnswerModal';
import {cloneObj} from 'c/helperFunctions';

export default class JiraTicketTable extends LightningElement {
    @api tickets;

    @api set testFormQuestions(val) {
        this._testFormQuestions = cloneObj(val);
    }
    get testFormQuestions() {
        return this._testFormQuestions;
    }
    _testFormQuestions = [];

    @api set techReviewFormQuestions(val) {
        this._techReviewFormQuestions = cloneObj(val);
    }
    get techReviewFormQuestions() {
        return this._techReviewFormQuestions;
    }
    _techReviewFormQuestions = [];

    async openTestFormModal(e) {
        const issueKey = e.target.value;

        const result = await LightningQuestionAnswerModal.open({
            size: 'medium',
            description: 'Submit test form',
            title: 'Testing Form for ' + issueKey,
            questions: this.testFormQuestions,
        });

        // If submitted
        if (result.state === 'success') {
            let comment = '';
            for (let i = 0; i < result.body.length; i++) {
                const formDetail = result.body[i];
                comment += this.addToTicketComment(formDetail.question, formDetail.answer);
            }

            submitForm({jiraKey: issueKey, ticketComment: comment, status: 'In Testing'})
                .then(() => {})
                .catch((err) => {
                    // eslint-disable-next-line no-console
                    console.error(err);
                })
                .finally(() => {});
        }
    }
    openTestFormModalKeyboard(e) {
        if (this.isSelectionKey(e.which)) this.openTestFormModal(e);
    }

    async openTechReviewFormModal(e) {
        const issueKey = e.target.value;

        const result = await LightningQuestionAnswerModal.open({
            size: 'medium',
            description: 'Submit tech review form',
            title: 'Tech Form for ' + issueKey,
            questions: this.techReviewFormQuestions,
        });

        // If submitted
        if (result.state === 'success') {
            let comment = '';
            for (let i = 0; i < result.body.length; i++) {
                const formDetail = result.body[i];
                comment += this.addToTicketComment(formDetail.question, formDetail.answer);
            }

            submitForm({jiraKey: issueKey, ticketComment: comment, status: 'Technical Review'})
                .then(() => {})
                .catch((err) => {
                    // eslint-disable-next-line no-console
                    console.error(err);
                })
                .finally(() => {});
        }
    }
    openTechReviewFormModalKeyboard(e) {
        if (this.isSelectionKey(e.which)) this.openTechReviewFormModal(e);
    }

    /**
     * Nicely formats a question-answer pair to be submitted as a comment in JIRA
     *
     * @param {String} question The question asked
     * @param {String} answer The answer provided
     * @returns
     */
    addToTicketComment(question, answer) {
        if (question != null && answer != null) {
            return '*' + question + '*\n' + answer + '\n\n';
        }
        return '';
    }

    /**
     * Is this keycode a selection type key?
     * @param {Integer} code
     * @returns True is the pressed key is a selection type button (enter or space)
     */
    isSelectionKey(code) {
        return code === 13 /*enter*/ || code === 32 /*space*/;
    }
}
