/**
 * Author: Created by Robert Nordman
 * Description:
 * User to close multiple casse at the same time in the Advisor Portal
 *
 * @api fields/functions:
 * selectedContactWrappers: [{cases: [{caseId: String}, ...]}, ...]
 *      The contact wrappers, contains contacts and cases, for which we need to close each selected case.
 */

import {api} from 'lwc';
import LightningModal from 'lightning/modal';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {extractErrorMessages} from 'c/helperFunctions';

export default class AdvisorPortalModalMassClose extends LightningModal {
    @api selectedContactWrappers = [];

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
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Cases Closed',
                    message: 'All cases closed successfully',
                    variant: 'success',
                })
            );
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
