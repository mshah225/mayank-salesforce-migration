import {LightningElement, api} from 'lwc';
import submitForm from '@salesforce/apex/JiraAddCommentFormController.submitForm';
import LightningQuestionAnswerModal from 'c/lightningQuestionAnswerModal';

export default class JiraTicketTable extends LightningElement {
    @api tickets;

    testFormQuestions = [
        {key: 'environment', question: 'What environment will be used for testing?', type: 'textarea'},
        {key: 'testplan', question: 'Test plan (including test cases):', type: 'textarea'},
        {key: 'testers', question: 'Tester(s):', type: 'textarea'},
        {key: 'config', question: 'What configuration changes need to be made?', type: 'textarea'},
    ];
    techReviewFormQuestions = [
        {key: 'summary', question: 'Brief summary of the changes:', type: 'textarea'},
        {key: 'changes', question: 'What were the test cases?', type: 'textarea'},
        {key: 'admin', question: 'Name of admin who tested and signed off:', type: 'textarea'},
        {key: 'stakeholder', question: 'Name of stakeholder representative who signed off:', type: 'textarea'},
        {key: 'metadata', question: 'What metadata needs to be migrated?', type: 'textarea'},
        {
            key: 'config',
            question: 'What configuration and security changes need to be made before or after deploy?',
            type: 'textarea',
        },
        {key: 'documentation', question: 'Future state documentaion (with explanation of changes):', type: 'textarea'},
    ];

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
