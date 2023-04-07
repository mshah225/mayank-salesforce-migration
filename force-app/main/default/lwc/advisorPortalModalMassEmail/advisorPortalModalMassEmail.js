import {api, wire} from 'lwc';
import fetchUser from '@salesforce/apex/AdvisorPortalMassEmailModalController.fetchUser';
import createPortalEmailsStr from '@salesforce/apex/AdvisorPortalMassEmailModalController.createPortalEmailsStr';
import {falseWireRun} from 'c/helperFunctions';
import LightningModal from 'lightning/modal';

export default class AdvisorPortalModalMassEmail extends LightningModal {
    @api selectedContactWrappers = [];
    @api loadingCb;
    @api toastCb;
    @api navCb;

    // What is the user's name?
    myname = '%Your Name%';

    // State variables to track current subject and body
    subject = '';
    body = '';

    isSubmitting = false;

    // Retrieve the current user and update the questions with the user's name
    @wire(fetchUser, {})
    fetchedUser(result) {
        if (falseWireRun(result)) return;

        let {data, error} = result;
        if (data != null) {
            this.myname = data.Name;
        } else if (error != null) {
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

    // Call the loadingCb
    sendLoadingEvent(loadMore) {
        if (this.loadingCb != null) this.loadingCb(new CustomEvent('loading', {detail: loadMore}));
    }

    // Call the toastCb
    makeToast(type, title, body) {
        if (this.toastCb != null)
            this.toastCb(
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

    // Call the navCb
    navigate(location, params) {
        if (this.navCb != null) {
            this.navCb(
                new CustomEvent('navigate', {
                    detail: {
                        location: location,
                        params: params,
                    },
                })
            );
        }
    }
}
