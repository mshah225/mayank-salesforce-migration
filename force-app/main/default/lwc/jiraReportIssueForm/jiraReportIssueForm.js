import {LightningElement, api} from 'lwc';
import createIssue from '@salesforce/apex/JiraReportIssueController.callout';

export default class JiraReportIssueForm extends LightningElement {
    @api title;

    alert;
    get showAlert() {
        return this.alert != null && this.alert !== '';
    }
    alertHref;
    get showAlertLink() {
        return this.alertHref != null && this.alertHref !== '';
    }

    @api question1;
    @api question2;
    @api question3;
    @api type;

    configurableQuestions = [];
    alwaysQuestions = [
        {
            key: 'requestFormLink',
            question:
                'Please include the link to your shared document with your request details. A template for your request details is above.',
            answer: '',
            type: 'textarea',
        },
        {
            key: 'watchers',
            question: 'Watchers for the ticket:',
            answer: '',
            type: 'textarea',
            subnote:
                'Enter the ASURITES for each user you want to watch this ticket. Each ASURITE must be separated with a comma.',
        },
    ];
    disabledButton = false;

    connectedCallback() {
        this.configurableQuestions = [
            {
                key: 'title',
                question: 'Summary of the issue (Title):',
                answer: '',
                type: 'textarea',
                subnote: 'FIELD LIMIT: This field must be less than 255 characters.',
                required: true,
            },
            {
                key: 'question1',
                question: this.question1,
                answer: '',
                type: 'textarea',
                subnote: 'FIELD LIMIT: This field must be less than 3000 characters.',
                required: true,
            },
            {
                key: 'question2',
                question: this.question2,
                answer: '',
                type: 'textarea',
                subnote: 'FIELD LIMIT: This field must be less than 3000 characters.',
                required: true,
            },
            {
                key: 'question3',
                question: this.question3,
                answer: '',
                type: 'textarea',
                subnote: 'FIELD LIMIT: This field must be less than 3000 characters.',
                required: true,
            },
        ];
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
        for (let i = 0; i < this.alwaysQuestions.length && !found; i++) {
            if (this.alwaysQuestions[i].key === questionKey) {
                this.alwaysQuestions[i].answer = answer;
                found = true;
            }
        }
    }

    isValid() {
        const allQuestionSections = this.template.querySelectorAll('c-jira-question-answer-section');
        let valid = true;
        for (let i = 0; i < allQuestionSections.length; i++) {
            valid &= allQuestionSections[i].reportValidity();
        }
        return valid;
    }

    submit() {
        if (this.isValid()) {
            let title = this.configurableQuestions[0].answer;

            let description =
                '*' +
                this.question1 +
                '*' +
                '\\n' +
                this.configurableQuestions[1].answer +
                '\\n\\n' +
                '*' +
                this.question2 +
                '*' +
                '\\n' +
                this.configurableQuestions[2].answer +
                '\\n\\n' +
                '*' +
                this.question3 +
                '*' +
                '\\n' +
                this.configurableQuestions[3].answer +
                '\\n\\n';

            if (this.alwaysQuestions[0].answer.length > 0) {
                description += '*Request Form:*\\n' + this.alwaysQuestions[0].answer + '\\n\\n';
            }

            let watchers = '';
            if (this.alwaysQuestions[1].answer.length > 0) watchers = this.alwaysQuestions[1].answer;

            let type = this.type;

            this.disabledButton = true;
            createIssue({
                title,
                description,
                watchers,
                type,
            })
                .then((val) => {
                    let key = val;
                    this.alert = 'Jira Issue Successfully Created';
                    this.alertHref = 'https://asudev.jira.com/browse/' + key;
                    this.clearInputs();
                })
                .catch((err) => {
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
        const allQuestionSections = this.template.querySelectorAll('c-jira-question-answer-section');
        for (let i = 0; i < allQuestionSections.length; i++) {
            allQuestionSections[i].clearAll();
        }
    }
}
