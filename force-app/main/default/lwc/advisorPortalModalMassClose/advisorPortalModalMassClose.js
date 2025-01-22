/**
 * Author: Created by Robert Nordman
 * Description:
 * User to close multiple casse at the same time in the Advisor Portal
 *
 * @api fields/functions:
 * selectedContactWrappers: [{cases: [{caseId: String}, ...]}, ...]
 *      The contact wrappers, contains contacts and cases, for which we need to close each selected case.
 * loadingCb: Function(CustomEvent('loading', {detail: Boolean}))
 *      Callback that is run everytime this component wants to indicate it is busy loading something.
 *      The detail contains a boolean indicate if the loading counter should be incremented or decremented.
 *      This is needed because as a LightningModal, this componenet cannot raise events to its parent component
 * toastCb: Function(
 *              CustomEvent('showtoast', {detail: {
 *                  title: String,
 *                  message: String,
 *                  type: String,
 *                  duration: Number}}) |
 *              ShowToastEvent({
 *                  title: String,
 *                  messsage: String,
 *                  variant: String
 *              })
 *          )
 *      Callback that is run everytime this component wants to show a toast
 *      This is needed because as a LightningModal, this componenet cannot raise events to its parent component
 * navCb: Function(
 *              CustomEvent('navigate', {detail:{
 *                  location: String,
 *                  params: Object
 *              }})
 *          )
 *      Callback that is run everytime this component wants to navigate to another place
 *      This is needed because as a LightningModal, this componenet cannot raise events to its parent component
 */

import {api} from 'lwc';
import LightningModal from 'lightning/modal';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {extractErrorMessages} from 'c/helperFunctions';

export default class AdvisorPortalModalMassClose extends LightningModal {
    @api selectedContactWrappers = [];

    @api loadingCb;
    @api toastCb;
    @api navCb;

    // Extract case ids from contact wrappers
    get caseIds() {
        let caseIds = [];
        for (const contactWrapper of this.selectedContactWrappers)
            for (const caseWrapper of contactWrapper.cases) caseIds.push(caseWrapper.caseId);
        return caseIds;
    }

    isSubmitting = false;

    _errorMessage = null;
    get errorMessage() {
        return `${this._errorMessage}\nContact Salesforce Support: salesforce.support@asu.edu`;
    }
    set errorMessage(v) {
        this._errorMessage = v;
    }
    get hasError() {
        return this._errorMessage != null;
    }

    /**
     * Close the mass close modal
     */
    closeModal() {
        this.close(true);
    }

    /**
     * Attempt to commit the changes, closing all the cases
     */
    closeCases() {
        this.refs.caseCloseView.commit();
    }

    /**
     * When updates occur we need to react.
     * When the form is submitting we need to prevent repeat submissions.
     * When the form has succesfully submitted, we can close modal.
     * When the form has errored (usually due to missing a required field), we need to allow a new submission attempt
     */
    statusHandler(evnt) {
        if (evnt.detail.type === 'success') {
            this.isSubmitting = false;
            this.makeToast('success', 'Cases Closed', 'All cases closed successfully');
            this.closeModal();
        } else if (evnt.detail.type === 'form_error') {
            this.isSubmitting = false;
        } else if (evnt.detail.type === 'submitting') {
            this.isSubmitting = true;
        }
    }

    /**
     * Handle errors the child component
     */
    errorHandler(evnt) {
        this.isSubmitting = false;
        this.errorMessage = evnt.detail.errors[0];
    }

    // Global Error from any error raising events in this component
    handleGlobalError(error) {
        this.errorMessage = extractErrorMessages(error)[0];
    }

    // Call the loadingCb
    sendLoadingEvent(loadMore) {
        if (this.loadingCb != null) this.loadingCb(new CustomEvent('loading', {detail: loadMore}));
    }

    // Call the toastCb
    makeToast(type, title, body) {
        if (this.toastCb != null)
            this.toastCb(
                new ShowToastEvent({
                    title: title,
                    message: body,
                    variant: type,
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

export class AdvisorPortalModalMassCloseTest extends AdvisorPortalModalMassClose {
    @api get caseIds() {
        return super.caseIds;
    }

    @api get errorMessage() {
        return super.errorMessage;
    }
    set errorMessage(v) {
        super.errorMessage = v;
    }

    @api get hasError() {
        return super.hasError;
    }
}
