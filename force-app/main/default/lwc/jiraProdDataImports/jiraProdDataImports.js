import {LightningElement, api} from 'lwc';
import createDataImport from '@salesforce/apex/JiraReportIssueController.createDataImport';

export default class JiraProdDataImports extends LightningElement {
    @api title;
    @api questionListJSON;

    alert;
    alertHref;

    configurableQuestions = [];
    disabledButton = false;

    /**
     * Parse the JSON string and convert it to an object (with empty string answers)
     */
    connectedCallback() {
        if (this.questionListJSON != null && this.questionListJSON !== '') {
            this.configurableQuestions = JSON.parse(this.questionListJSON);
        }

        for (let i = 0; i < this.configurableQuestions.length; i++) {
            const question = this.configurableQuestions[i];
            question.key = 'key-' + i;
            question.answer = '';
        }
    }

    /**
     * Whenever a change event is detected
     * record the answer for the question in the configurableQuestion map
     *
     * @param {ChangeEvent} e
     */
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

    /**
     * Reports validity - marking invalid answers (missing required or invalid length)
     * @returns true if the question-answers-section is valid
     */
    isValid() {
        const allQuestionSections = this.template.querySelectorAll('c-lightning-question-answer-section');
        let valid = true;
        for (let i = 0; i < allQuestionSections.length; i++) {
            valid &= allQuestionSections[i].reportValidity();
        }
        return valid;
    }

    /**
     * Attempts to submit the form.  If it is valid, this should result in the creation of a JIRA ticket
     * if it isn't valid, just report what is invalid
     */
    submit() {
        if (this.isValid()) {
            let title = null;
            let qaList = [];
            let watchers = null;
            let reqForm = null;

            for (let i = 0; i < this.configurableQuestions.length; i++) {
                const q = this.configurableQuestions[i];
                const thisQA = '*' + q.question + '*\n' + q.answer;
                if (q.type === 'label') continue; // don't add labels to the body
                if (q.action != null) {
                    // is action is specified - then we need to do something special
                    if (q.action === 'title') if (q.answer.length > 0) title = q.answer;
                    if (q.action === 'watcherList') if (q.answer.length > 0) watchers = q.answer;
                    if (q.action === 'requestForm') if (q.answer.length > 0) reqForm = q.answer;
                    continue;
                }
                // for each question and answer - we add it to the qaList
                qaList.push(thisQA);
            }

            if (reqForm != null) qaList.push('*Import URL:*\n' + reqForm);

            let description = qaList.join('\n\n'); // combine to make mega string

            this.disabledButton = true;

            createDataImport({
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

    /**
     * Clear all inputs to empty
     */
    clearInputs() {
        const allQuestionSections = this.template.querySelectorAll('c-lightning-question-answer-section');
        for (let i = 0; i < allQuestionSections.length; i++) {
            allQuestionSections[i].clearAll();
        }
    }
}
