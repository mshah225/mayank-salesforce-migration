import {LightningElement, api} from 'lwc';
import createNewIssue from '@salesforce/apex/JiraReportIssueController.callout';

export default class JiraNewDevelopmentRequest extends LightningElement {
    @api jiraUserId;

    questions1 = [
        {
            key: 'summary',
            question: 'Summary of the issue (Title):',
            type: 'textarea',
            subnote: 'FIELD LIMIT: This field must be less than 255 characters.',
            required: true,
        },
        {
            key: 'problem',
            question: 'What is the problem that needs to be solved?',
            type: 'textarea',
            subnote: 'FIELD LIMIT: This field must be less than 3000 characters.',
            required: true,
        },
        {
            key: 'who',
            question: 'Who is going to be using this?',
            type: 'textarea',
            subnote: 'FIELD LIMIT: This field must be less than 3000 characters.',
            required: true,
        },
        {
            key: 'extra',
            question: 'Additional information:',
            type: 'textarea',
            subnote: 'FIELD LIMIT: This field must be less than 3000 characters.',
            required: true,
        },
    ];
    questions2 = [
        {
            key: 'requestForm',
            question:
                'Please include the link to your shared document with your request details. A template for your request details is above.',
            type: 'textarea',
        },
        {
            key: 'watchers',
            question: 'Watchers for the ticket:',
            type: 'textarea',
            subnote:
                ' Enter the ASURITES for each user you want to watch this ticket. Each ASURITE must be separated with a comma.',
        },
    ];

    // Can the submit button be clicked?
    disabledButton = false;

    // eslint-disable-next-line no-undef
    questionAnswersMap = new Map();
    changeAnswers(e) {
        const answers = e.detail;
        for (let i = 0; i < answers.length; i++) {
            const answer = answers[i];
            this.questionAnswersMap.set(answer.key, answer.answer);
        }
        console.log(this.questionAnswersMap);
    }

    isValid() {
        let allSections = this.template.querySelectorAll('c-jira-question-answer-section');
        let valid = true;
        for (let i = 0; i < allSections.length; i++) {
            valid &= allSections[i].reportValidity();
        }
        return valid;
    }

    submit() {
        if (this.isValid()) {
            this.disabledButton = true;
            const answerMap = this.questionAnswersMap;

            const title = answerMap.get('summary');
            let description =
                '*' +
                this.getQuestionForKey('problem').question +
                '*\\n' +
                answerMap.get('problem') +
                '\\n\\n' +
                '*' +
                this.getQuestionForKey('who').question +
                '*' +
                '\\n' +
                answerMap.get('who') +
                '\\n\\n' +
                '*' +
                this.getQuestionForKey('extra').question +
                '*' +
                '\\n' +
                answerMap.get('extra') +
                '\\n\\n';
            if (answerMap.has('requestForm')) {
                description += '*Request Form:*\\n' + answerMap.get('requestForm') + '\\n\\n';
            }

            let watchers = answerMap.get('watchers');
            const type = 'New Development Request';

            createNewIssue({
                title,
                description,
                watchers,
                type,
            })
                .then((data) => {
                    this.showSuccess(data);
                })
                .catch((err) => {
                    this.showError(err);
                })
                .finally(() => {
                    this.disabledButton = false;
                });
        }
    }

    showSuccess(v) {
        console.log(v);
    }

    showError(v) {
        console.log(v);
    }

    getQuestionForKey(questionKey) {
        for (let i = 0; i < this.questions1.length; i++) {
            if (this.questions1[i].key === questionKey) {
                return this.questions1[i];
            }
        }

        for (let i = 0; i < this.questions2.length; i++) {
            if (this.questions2[i].key === questionKey) {
                return this.questions2[i];
            }
        }

        return null;
    }
}
