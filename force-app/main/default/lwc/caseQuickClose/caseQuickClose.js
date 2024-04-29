/**
 * The case quick close form visible on the case record page.
 * Supports either filling in the lightning case close form or closing as spam
 */
import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import {extractErrorMessages} from 'c/helperFunctions';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// Fields
import RECORD_TYPE_DEVELOPER_NAME_FIELD from '@salesforce/schema/Case.RecordType.DeveloperName';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import CASE_NUMBER_FIELD from '@salesforce/schema/Case.CaseNumber';
import ID_FIELD from '@salesforce/schema/Case.Id';

export default class CaseQuickClose extends LightningElement {
    @api recordId;
    @api componentName = 'Case Quick Close';
    @api closeButtonLabel = 'Close Case';
    @api closeButtonVariant = 'brand';
    @api recordSubmitButtonLabel = 'Submit';
    @api recordSubmitButtonVariant = 'brand';
    @api closeSpamButtonLabel = 'Close Spam';
    @api closeSpamButtonVariant = 'destructive';
    record;
    isLoading = false;
    isFormVisible = false;
    isButtonVisible = true;
    isSpamButtonVisible = true;
    isSubmitting = false;
    isFormReady = false;
    errorDetail = null;
    errorContact = 'salesforce.support@asu.edu';
    validationError;
    allowedCloseCaseSpamRTs = ['ASU_Service', 'ASU_Admission_Services', 'ASU_Secure_Case', 'ASU_Advisor_Outreach'];

    get recordIdList() {
        return [this.recordId];
    }

    // Case Record
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [SUBJECT_FIELD, CASE_NUMBER_FIELD, DESCRIPTION_FIELD, RECORD_TYPE_DEVELOPER_NAME_FIELD],
    })
    wiredCase({error, data}) {
        if (error) {
            this.record = undefined;
            this.handleGlobalError(error);
        }
        if (data) {
            this.record = data;
        }
    }

    // Can this case be closed as spam via button
    get isRTAllowedClosedSpam() {
        const currentRT = getFieldValue(this.record, RECORD_TYPE_DEVELOPER_NAME_FIELD);
        return this.allowedCloseCaseSpamRTs.includes(currentRT);
    }

    // Validation Error Override
    get hasValidationError() {
        return this.validationError ? true : false;
    }
    set hasValidationError(error) {
        this.validationError = error;
    }

    // Component Name (Card Title)
    get lwcComponentName() {
        return this.componentName;
    }

    // Button Label
    get lwcCloseButtonLabel() {
        return this.closeButtonLabel;
    }

    // Button Variant
    get lwcCloseButtonVariant() {
        return this.closeButtonVariant;
    }

    // Submit Button Label
    get lwcRecordSubmitButtonLabel() {
        return this.recordSubmitButtonLabel;
    }

    // Button Label
    get lwcCloseSpamButtonLabel() {
        return this.closeSpamButtonLabel;
    }

    // Button Variant
    get lwcCloseSpamButtonVariant() {
        return this.closeSpamButtonVariant;
    }

    // Submit Button Variant
    get lwcRecordSubmitButtonVariant() {
        return this.recordSubmitButtonVariant;
    }

    // Loading Indicator
    get loading() {
        return this.isLoading;
    }
    set loading(status) {
        this.isLoading = status;
    }

    // Form Visibility
    get formVisible() {
        return this.isFormVisible;
    }
    set formVisible(isVisible) {
        this.isFormVisible = isVisible;
    }

    // Close Case Button Visibility
    get buttonVisible() {
        return this.isButtonVisible;
    }
    set buttonVisible(visible) {
        this.isButtonVisible = visible;
    }

    // Spam Button Visibility
    get spamButtonVisible() {
        return this.isSpamButtonVisible;
    }
    set spamButtonVisible(visible) {
        this.isSpamButtonVisible = visible;
    }

    get formReady() {
        return this.isFormReady;
    }
    set formReady(ready) {
        this.isFormReady = ready;
    }

    // Error Message
    get errorMessage() {
        return this.errorDetail;
    }
    set errorMessage(detail) {
        this.errorDetail = detail;
    }

    // Error Contact Info
    get errorContactEmail() {
        return this.errorContact;
    }

    /**
     * The cases were successfully updated, show a toast indicating this, and close the modal.
     * We need to enable.disable the submit button during submission
     */
    statusHandler(evnt) {
        console.debug(evnt);

        if (evnt.detail.type === 'success') {
            this.handleOnCaseCloseSuccess();
            this.isSubmitting = false;
        } else if (evnt.detail.type === 'form_error') {
            this.isSubmitting = false;
        } else if (evnt.detail.type === 'submitting') {
            this.isSubmitting = true;
        }
    }

    /**
     * The cases failed to update for an unexpected reason
     */
    errorHandler(evnt) {
        this.errorMessage = evnt.detail.errors[0];
        this.isSubmitting = false;
    }

    // Show form
    handleOnCaseCloseButton() {
        this.buttonVisible = false;
        this.spamButtonVisible = false;
        this.formVisible = true;
    }

    // Handle Close Spam Cases
    handleOnCaseCloseSpamButton() {
        this.loading = true;
        this.handleCloseSpam();
    }

    // Close Spam Logic
    handleCloseSpam() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[STATUS_FIELD.fieldApiName] = 'Closed: SPAM';

        // Vars
        const currentSubject = getFieldValue(this.record, SUBJECT_FIELD) ?? '';
        const currentDescription = getFieldValue(this.record, DESCRIPTION_FIELD) ?? '';

        // Modify case details
        if (!currentSubject.startsWith('SPAM:')) {
            fields[SUBJECT_FIELD.fieldApiName] = 'SPAM: ' + currentSubject;
        }
        if (!currentDescription.startsWith('SPAM:')) {
            fields[DESCRIPTION_FIELD.fieldApiName] = 'SPAM: ' + currentDescription;
        }

        const recordInput = {fields};

        // Update the record
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Case Closed',
                        message: `Case Number: ${getFieldValue(this.record, CASE_NUMBER_FIELD) ?? 'UNKNOWN'}`,
                        variant: 'success',
                    })
                );

                this.handleOnCaseCloseSuccess();
            })
            .catch((error) => {
                this.handleGlobalError(error);
            })
            .finally(() => {
                this.loading = false;
            });
    }

    // Override Submit
    handleOnSubmit() {
        // Submit form
        this.refs.caseCloseView.commit();
    }

    // Success
    handleOnCaseCloseSuccess() {
        this.handleResetForm();
    }

    // Reset
    handleResetForm() {
        this.formVisible = false;
        this.buttonVisible = true;
        this.spamButtonVisible = true;
        this.errorMessage = null;
    }

    // Cancel Form
    handleOnCancel() {
        this.handleResetForm();
    }

    handleFormReady() {
        this.formReady = true;
    }

    // Global Error from any error raising events in this component
    handleGlobalError(error) {
        this.errorMessage = extractErrorMessages(error);
    }
}
