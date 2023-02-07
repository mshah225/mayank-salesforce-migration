import {LightningElement, api} from 'lwc';
import createBugReport from '@salesforce/apex/JiraReportIssueController.createBugReport';
import createNewDevelopmentRequest from '@salesforce/apex/JiraReportIssueController.createNewDevelopmentRequest';

export default class JiraReportIssueForm extends LightningElement {
    @api title;
    @api type;
    @api questionListJSON;

    configurableQuestions = [];
    disabledButton = false;

    alert;
    alertHref;

    connectedCallback() {
        if (this.questionListJSON != null && this.questionListJSON != '') {
            this.configurableQuestions = JSON.parse(this.questionListJSON);
        }

        for (let i = 0; i < this.configurableQuestions.length; i++) {
            const question = this.configurableQuestions[i];
            question.key = 'key-' + i;
            question.answer = '';
            // Setup label for request form (this is a temporary holdever from before we supported setting jiraLabel - can be removed in a future update to page config)
            if (question.action === 'requestForm') {
                if (question.jiraLabel == null) question.jiraLabel = 'Request Form';
                question.action = null;
            }
            // Set the label to the question if it is unspecified
            if (question.jiraLabel == null) question.jiraLabel = question.question;
        }
    }

    changeAnswers(e) {
        const newAnswer = e.detail;
        let questionKey = newAnswer.key;
        let answer = newAnswer.answer;

        let found = false;
        for (let i = 0; i < this.configurableQuestions.length && !found; i++) {
            if (this.configurableQuestions[i].key === questionKey) {
                this.configurableQuestions[i].answer = answer;
                found = true;
            }
        }
    }

    isValid() {
        const allQuestionSections = this.template.querySelectorAll('c-lightning-question-answer-section');
        let valid = true;
        for (let i = 0; i < allQuestionSections.length; i++) {
            valid &= allQuestionSections[i].reportValidity();
        }
        return valid;
    }

    submit() {
        if (this.isValid()) {
            let title = null;
            let qaList = [];
            let watchers = null;

            for (let i = 0; i < this.configurableQuestions.length; i++) {
                const q = this.configurableQuestions[i];

                const thisQA = '*' + q.jiraLabel + '*\n' + q.answer;
                if (q.type === 'label') continue; // don't add labels to the body
                if (q.action != null) {
                    // is action is specified - then we need to do something special
                    if (q.action === 'title') if (q.answer.length > 0) title = q.answer;
                    if (q.action === 'watcherList') if (q.answer.length > 0) watchers = q.answer;
                    continue;
                }
                if (q.answer.length === 0) continue; // skip is empty
                // for each question and answer - we add it to the qaList
                qaList.push(thisQA);
            }

            let description = qaList.join('\n\n'); // combine to make mega string

            let type = this.type;

            this.disabledButton = true;

            let createIssue = type === 'New Devlopment Request' ? createNewDevelopmentRequest : createBugReport; // determine which function to call

            createIssue({
                title,
                description,
                watchers,
            })
                .then((val) => {
                    let key = val;
                    this.alert = 'Jira Issue Successfully Created';
                    this.alertHref = 'https://asudev.jira.com/browse/' + key;
                    this.clearInputs();
                })
                .catch((err) => {
                    console.error(err);
                    this.alert =
                        'Cannot create JIRA ticket, please email your request to salesforce.development@asu.edu';
                    this.alertHref = null;
                })
                .finally(() => {
                    this.disabledButton = false;
                });
        } else {
            this.alert = 'Please complete the required forms below!';
            this.alertHref = null;
        }
    }

    clearInputs() {
        const allQuestionSections = this.template.querySelectorAll('c-lightning-question-answer-section');
        for (let i = 0; i < allQuestionSections.length; i++) {
            allQuestionSections[i].clearAll();
        }
    }
}
