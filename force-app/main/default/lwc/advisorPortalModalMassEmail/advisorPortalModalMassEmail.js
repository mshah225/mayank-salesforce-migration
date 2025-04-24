import {api, wire} from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import LightningModal from 'lightning/modal';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import createPortalEmailsStr from '@salesforce/apex/AdvisorPortalMassEmailModalController.createPortalEmailsStr';
import USER_ID from '@salesforce/user/Id';
import USER_NAME_FIELD from '@salesforce/schema/User.Name';

export default class AdvisorPortalModalMassEmail extends LightningModal {
    @api selectedContactWrappers = [];

    // What is the user's name?
    myname = '%Your Name%';

    // State variables to track current subject and body
    subject = '';
    body = '';

    isSubmitting = false;

    // Retrieve the current user and update the questions with the user's name
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [USER_NAME_FIELD],
    })
    gotUserDetail({error, data}) {
        if (data !== undefined) {
            this.myname = data.fields.Name.value;
        }
    }

    // Track which "page" of the modal we are on
    stage = 'writing';
    get writingStage() {
        return this.stage === 'writing';
    }
    get previewStage() {
        return this.stage === 'preview';
    }

    // Send label should say approx how many emails will be sent
    get sendLabel() {
        return 'Send (' + this.getEstimateOnNumberOfEmails() + ')';
    }

    // Close the modal
    closeModal() {
        this.close();
    }

    // Preview the email (go to the preview stage)
    previewEmails() {
        const formElements = this.template.querySelectorAll(
            'lightning-modal-body lightning-input, lightning-modal-body lightning-textarea'
        );

        let isValid = true;

        for (let i = 0; i < formElements.length; i++) {
            isValid &= formElements[i].reportValidity();
        }

        if (isValid) {
            this.stage = 'preview';
        }
    }

    // Go back to the writing stage
    goBack() {
        this.stage = 'writing';
    }

    // Send the emails!
    sendEmails() {
        const contactWrappers = [];
        for (let i = 0; i < this.selectedContactWrappers.length; i++) {
            const entry = this.selectedContactWrappers[i];
            const cases = [];
            for (let j = 0; j < entry.cases.length; j++) {
                cases.push({portalCase: {Id: entry.cases[j].caseId}});
            }
            // Add to wrappers
            contactWrappers.push({
                portalContact: {Id: entry.contactId},
                cases: cases,
            });
        }

        this.sendLoadingEvent(true);
        this.disableClose = true;
        this.isSubmitting = true;

        createPortalEmailsStr({
            contactWrappersListJSON: JSON.stringify(contactWrappers),
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
                this.disableClose = false;
                this.isSubmitting = false;
                this.closeModal();
                this.sendLoadingEvent(false);
            });
    }

    // Record changes to the body and subject
    changeSubject(e) {
        this.subject = e.detail.value;
    }

    changeBody(e) {
        this.body = e.detail.value;
    }

    // Estimate the number of emails by counting number of cases per contact
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
            new ShowToastEvent({
                title: title,
                message: body,
                variant: type,
            })
        );
    }
}
