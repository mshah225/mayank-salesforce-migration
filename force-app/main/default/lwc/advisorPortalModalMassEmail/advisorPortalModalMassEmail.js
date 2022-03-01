import {LightningElement, api, wire} from 'lwc';
import fetchUser from '@salesforce/apex/AdvisorPortalMassEmailModalController.fetchUser';
import createPortalEmailsStr from '@salesforce/apex/AdvisorPortalMassEmailModalController.createPortalEmailsStr';

export default class AdvisorPortalModalMassEmail extends LightningElement {
    @api selectedContactWrappers = [];

    myname = 'Your Name';

    questions = [];
    buttons = [];

    subject = '';
    body = '';

    connectedCallback() {
        this.goToStageOne(); // just in case fetch user takes too long to resolve

        fetchUser()
            .then((data) => {
                this.myname = data.Name;
                this.goToStageOne(); // causes updates to fields in stage one modal
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error(err);
            });
    }

    @api openModal() {
        this.template.querySelector('c-lightning-question-answer-modal').openModal();
    }
    @api closeModal() {
        this.template.querySelector('c-lightning-question-answer-modal').closeModal();
    }

    previewEmails() {
        const modal = this.template.querySelector('c-lightning-question-answer-modal');
        if (modal.reportValidity()) {
            this.subject = modal.questions[0].answer;
            this.body = modal.questions[1].answer;
            this.goToStageTwo();
        }
    }
    sendEmails() {
        const jsonWrappers = [];
        for (let i = 0; i < this.selectedContactWrappers.length; i++) {
            const entry = this.selectedContactWrappers[i];
            const cases = [];
            for (let j = 0; j < entry.cases.length; j++) {
                cases.push({portalCase: {Id: entry.cases[j].caseId}});
            }
            // Add to wrappers
            jsonWrappers.push(
                JSON.stringify({
                    portalContact: {Id: entry.contactId},
                    cases: cases,
                })
            );
        }

        this.sendLoadingEvent(true);
        createPortalEmailsStr({
            contactWrappersJSONList: jsonWrappers,
            subject: this.subject,
            body: this.body,
        })
            .then(() => {
                this.subject = '';
                this.body = '';
                this.makeToast('success', 'Success', 'Sent emails.');
            })
            .catch((err) => {
                console.error(err);
                this.makeToast('error', 'Failures', 'Emails were unable to be sent.');
            })
            .finally(() => {
                this.closeModal();
                this.sendLoadingEvent(false);
            });
    }

    goToStageOne() {
        this.questions = this.getStageOneModalQuestions();
        this.buttons = this.getStageOneModalButtons();
    }
    goToStageTwo() {
        this.questions = this.getStageTwoModalQuestions();
        this.buttons = this.getStageTwoModalButtons();
    }

    getStageOneModalQuestions() {
        return [
            {key: 'subject', question: 'Subject', answer: this.subject, required: true, type: 'text'},
            {key: 'body', question: 'Dear StudentFirstName,', answer: this.body, required: true, type: 'textarea'},
            {key: 'note', question: 'Sincerely, ' + this.myname, type: 'label'},
        ];
    }
    getStageOneModalButtons() {
        return [
            {
                key: 'close',
                ariaLabel: 'Cancel',
                label: 'Cancel',
                onClick: () => {
                    this.closeModal();
                },
                classes: 'slds-button slds-button_neutral',
            },
            {
                key: 'next',
                ariaLabel: 'Preview',
                label: 'Preview',
                onClick: () => {
                    this.previewEmails();
                },
                classes: 'slds-button slds-button_brand',
            },
        ];
    }

    getStageTwoModalQuestions() {
        return [
            {key: 'subject', question: this.subject, type: 'label-bold'},
            {key: 'body-prefix', question: 'Dear StudentFirstName,', type: 'label'},
            {key: 'body', question: this.body, type: 'label'},
            {key: 'body-suffix', question: 'Sincerely, ' + this.myname, type: 'label'},
        ];
    }
    getStageTwoModalButtons() {
        let sendLabel = 'Send (';
        const numberOfEmails = this.getEstimateOnNumberOfEmails();
        if (numberOfEmails > 1) {
            sendLabel += numberOfEmails + ' Emails';
        } else {
            sendLabel += '1 Email';
        }
        sendLabel += ')';

        return [
            {
                key: 'back',
                ariaLabel: 'Go Back',
                label: 'Go Back',
                onClick: () => {
                    this.goToStageOne();
                },
                classes: 'slds-button slds-button_neutral',
            },
            {
                key: 'submit',
                ariaLabel: sendLabel,
                label: sendLabel,
                onClick: () => {
                    this.sendEmails();
                },
                classes: 'slds-button slds-button_brand',
            },
        ];
    }

    getEstimateOnNumberOfEmails() {
        let count = 0;
        for (let i = 0; i < this.selectedContactWrappers.length; i++) {
            const contactWrapper = this.selectedContactWrappers[i];

            let countOfCasesForThisContact = contactWrapper.cases.length;

            count += countOfCasesForThisContact > 0 ? countOfCasesForThisContact : 1;
        }
        return count;
    }

    sendLoadingEvent(loadMore) {
        this.dispatchEvent(new CustomEvent('loading', {detail: loadMore}));
    }

    makeToast(type, title, body) {
        this.dispatchEvent(
            new CustomEvent('showtoast', {
                detail: {
                    title: title,
                    message: body,
                    type: type,
                    duration: 5000,
                },
            })
        );
    }
}
