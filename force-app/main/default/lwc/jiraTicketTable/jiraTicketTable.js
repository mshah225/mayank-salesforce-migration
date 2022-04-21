import {LightningElement, api} from 'lwc';
import submitForm from '@salesforce/apex/JiraAddCommentFormController.submitForm';

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

    currentlyHasFocus;
    setFocusHere(e) {
        this.currentlyHasFocus = e.target;
    }

    openTestFormModal(e) {
        const modal = this.template.querySelector('.testing-form-modal');
        modal.title = 'Testing Form for ' + e.target.value;
        modal.dataset.issueKey = e.target.value;
        modal.returnFocusTo = this.currentlyHasFocus;
        modal.openModal();
    }
    openTestFormModalKeyboard(e) {
        if (this.isSelectionKey(e.which)) this.openTestFormModal(e);
    }
    submitTestForm(e) {
        const issueKey = e.originalTarget.dataset.issueKey;
        const formDetails = JSON.parse(e.detail);
        let comment = '';
        for (let i = 0; i < formDetails.length; i++) {
            const formDetail = formDetails[i];
            comment += `*${formDetail.question}*\\n${formDetail.answer
                .replace(/\r\n]/g, '\\r')
                .replace(new RegExp('"', 'g'), '\\"')}\\n\n`;
        }

        console.log(issueKey);
        console.log(formDetails);
        console.log(comment);

        console.log({jiraKey: issueKey, ticketComment: comment, status: 'In Testing'});

        submitForm({jiraKey: issueKey, ticketComment: comment, status: 'In Testing'})
            .then(() => {})
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error(err);
            })
            .finally(() => {});
    }

    openTechReviewFormModal(e) {
        const modal = this.template.querySelector('.tech-review-form-modal');
        modal.title = 'Tech Form for ' + e.target.value;
        modal.dataset.issueKey = e.target.value;
        modal.returnFocusTo = this.currentlyHasFocus;
        modal.openModal();
    }
    openTechReviewFormModalKeyboard(e) {
        if (this.isSelectionKey(e.which)) this.openTechReviewFormModal(e);
    }
    submitTechReviewForm(e) {
        const issueKey = e.originalTarget.dataset.issueKey;
        const formDetails = JSON.parse(e.detail);
        let comment = '';
        for (let i = 0; i < formDetails.length; i++) {
            const formDetail = formDetails[i];
            comment += `*${formDetail.question}*\\n${formDetail.answer
                .replace(/\r\n]/g, '\\r')
                .replace(new RegExp('"', 'g'), '\\"')}\\n\n`;
        }

        console.log(issueKey);
        console.log(formDetails);
        console.log(comment);

        submitForm({jiraKey: issueKey, ticketComment: comment, status: 'Technical Review'})
            .then(() => {})
            .catch(() => {})
            .finally(() => {});
    }

    isSelectionKey(code) {
        return code === 13 /*enter*/ || code === 32 /*space*/;
    }
}
