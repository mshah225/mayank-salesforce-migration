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
    allowedCloseCaseSpamRTs = ['ASU_Service', 'ASU_Admission_Services', 'ASU_Secure_Case'];

    get recordIdList() {
        return [this.recordId];
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [SUBJECT_FIELD, CASE_NUMBER_FIELD, DESCRIPTION_FIELD, RECORD_TYPE_DEVELOPER_NAME_FIELD],
    })
    wiredCase({error, data}) {
        if (error) {
            this.record = undefined;
            this.handleGlobalError(error);
        } else if (data) {
            this.record = data;
        }
    }

    // Can this case be closed as spam via button
    get isRTAllowedClosedSpam() {
        const currentRT = getFieldValue(this.record, RECORD_TYPE_DEVELOPER_NAME_FIELD) ?? null;
        return this.allowedCloseCaseSpamRTs.includes(currentRT);
    }

    get lwcComponentName() {
        return this.componentName;
    }

    get lwcCloseButtonLabel() {
        return this.closeButtonLabel;
    }

    get lwcCloseButtonVariant() {
        return this.closeButtonVariant;
    }

    get lwcRecordSubmitButtonLabel() {
        return this.recordSubmitButtonLabel;
    }

    get lwcCloseSpamButtonLabel() {
        return this.closeSpamButtonLabel;
    }

    get lwcCloseSpamButtonVariant() {
        return this.closeSpamButtonVariant;
    }

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

    get spamButtonVisible() {
        return this.isRTAllowedClosedSpam && this.isSpamButtonVisible;
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

    get errorMessage() {
        return this.errorDetail + `\nContact Salesforce Support: salesforce.support@asu.edu`;
    }
    set errorMessage(detail) {
        this.errorDetail = detail;
    }
    get hasError() {
        return this.errorDetail != null;
    }

    /**
     * The cases were successfully updated, show a toast indicating this, and close the modal.
     * We need to enable.disable the submit button during submission
     */
    statusHandler(evnt) {
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

    // Close spam directly
    handleCloseSpam() {
        this.loading = true;

        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[STATUS_FIELD.fieldApiName] = 'Closed: SPAM';

        const currentSubject = getFieldValue(this.record, SUBJECT_FIELD) ?? '';
        const currentDescription = getFieldValue(this.record, DESCRIPTION_FIELD) ?? 'null';

        if (currentSubject && !currentSubject.startsWith('SPAM:')) {
            fields[SUBJECT_FIELD.fieldApiName] = 'SPAM: ' + currentSubject;
        }
        if (currentDescription && !currentDescription.startsWith('SPAM:')) {
            fields[DESCRIPTION_FIELD.fieldApiName] = 'SPAM: ' + currentDescription;
        }

        const recordInput = {fields};

        updateRecord(recordInput)
            .then(() => {
                this.handleOnCaseCloseSuccess();
            })
            .catch((error) => {
                this.handleGlobalError(error);
            })
            .finally(() => {
                this.loading = false;
            });
    }

    // Submit form
    handleOnSubmit() {
        this.refs.caseCloseView.commit();
    }

    // Success
    handleOnCaseCloseSuccess() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Case Closed',
                message: `Case Number: ${getFieldValue(this.record, CASE_NUMBER_FIELD) ?? 'UNKNOWN'}`,
                variant: 'success',
            })
        );
        this.handleResetForm();
    }

    handleResetForm() {
        this.formVisible = false;
        this.buttonVisible = true;
        this.spamButtonVisible = true;
        this.errorMessage = null;
    }

    handleOnCancel() {
        this.handleResetForm();
    }

    handleFormReady() {
        this.formReady = true;
    }

    // Global Error from any error raising events in this component
    handleGlobalError(error) {
        this.errorMessage = extractErrorMessages(error)[0];
    }
}

export class CaseQuickCloseTest extends CaseQuickClose {
    @api get recordId() {
        return super.recordId;
    }
    set recordId(v) {
        super.recordId = v;
    }

    @api get formVisible() {
        return super.formVisible;
    }
    set formVisible(v) {
        super.formVisible = v;
    }

    @api get buttonVisible() {
        return super.buttonVisible;
    }
    set buttonVisible(v) {
        super.buttonVisible = v;
    }

    @api get spamButtonVisible() {
        return super.spamButtonVisible;
    }
    set spamButtonVisible(v) {
        super.spamButtonVisible = v;
    }

    @api get loading() {
        return super.loading;
    }
    set loading(v) {
        super.loading = v;
    }

    @api get formReady() {
        return super.formReady;
    }
    set formReady(v) {
        super.formReady = v;
    }

    @api get hasError() {
        return super.hasError;
    }
    set hasError(v) {
        super.hasError = v;
    }

    @api get errorMessage() {
        return super.errorMessage;
    }
    set errorMessage(v) {
        super.errorMessage = v;
    }
}
