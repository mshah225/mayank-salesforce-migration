import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getFieldsFromFieldSet from '@salesforce/apex/ObjectHelper.getFieldsFromFieldSet';

// Fields
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import RECORD_TYPE_DEVELOPER_NAME_FIELD from '@salesforce/schema/Case.RecordType.DeveloperName';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import CASE_NUMBER_FIELD from '@salesforce/schema/Case.CaseNumber';
import IS_CLOSED_FIELD from '@salesforce/schema/Case.IsClosed';
import ID_FIELD from '@salesforce/schema/Case.Id';

// Constants
const OBJECT_NAME = 'Case';
const FIELDSET_PREFIX = 'CQC_RT_';

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
    caseStatusOptions = [];
    isLoading = false;
    isFormVisible = false;
    isButtonVisible = true;
    isSpamButtonVisible = true;
    errorDetail = '';
    errorContact = 'salesforce.support@asu.edu';
    selectedStatus = null;
    defaultStatus = null;
    inputFieldsBefore = [];
    inputFieldsAfter = [];
    statusFieldLabel;
    validationError;
    allowedCloseCaseSpamRTs = ['ASU_Service', 'ASU_Admission_Services', 'ASU_Secure_Case'];

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            SUBJECT_FIELD,
            DESCRIPTION_FIELD,
            RECORD_TYPE_DEVELOPER_NAME_FIELD,
            STATUS_FIELD,
            CASE_NUMBER_FIELD,
            IS_CLOSED_FIELD,
        ],
    })
    wiredCase({error, data}) {
        if (error) {
            this.record = undefined;
            this.handleGlobalError(error);
        } else if (data) {
            this.record = data;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$record.recordTypeId',
        fieldApiName: STATUS_FIELD,
    })
    wiredStatusOptions({error, data}) {
        if (error) {
            this.caseStatusOptions = undefined;
            this.handleGlobalError(error);
        } else if (data) {
            this.caseStatusOptions = this.buildStatusOptions(data);

            try {
                if (this.caseStatusOptions.length === 0) {
                    throw new Error('Unable to access Status Options for Picklist.');
                }
                this.loadFieldset();
            } catch (e) {
                this.handleGlobalError(e);
            }
        }
    }

    get isRTAllowedClosedSpam() {
        const currentRT = getFieldValue(this.record, RECORD_TYPE_DEVELOPER_NAME_FIELD);
        return this.allowedCloseCaseSpamRTs.includes(currentRT);
    }

    get hasValidationError() {
        return !!this.validationError;
    }
    set hasValidationError(error) {
        this.validationError = error;
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

    get statusOptions() {
        return this.caseStatusOptions;
    }

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

    get buttonVisible() {
        return this.isButtonVisible;
    }
    set buttonVisible(visible) {
        this.isButtonVisible = visible;
    }

    get spamButtonVisible() {
        return this.isSpamButtonVisible;
    }
    set spamButtonVisible(visible) {
        this.isSpamButtonVisible = visible;
    }

    get hasError() {
        return !!this.errorDetail;
    }

    get errorMessage() {
        return this.errorDetail;
    }
    set errorMessage(detail) {
        this.errorDetail = detail;
    }

    get errorContactEmail() {
        return this.errorContact;
    }

    get statusInputLabel() {
        return this.statusFieldLabel;
    }
    get statusInputPlaceholder() {
        return 'Select ' + this.statusFieldLabel;
    }
    get statusRequired() {
        return this.statusFieldRequired;
    }

    get currentStatus() {
        const isClosed = getFieldValue(this.record, IS_CLOSED_FIELD);
        return isClosed ? getFieldValue(this.record, STATUS_FIELD) : this.defaultStatus;
    }

    buildStatusOptions(options) {
        return options.values
            .filter((s) => s.attributes.closed)
            .map((element) => ({
                label: element.label,
                value: element.value,
            }));
    }

    loadFieldset() {
        const recordTypeDeveloperName = getFieldValue(this.record, RECORD_TYPE_DEVELOPER_NAME_FIELD);
        const fieldSetName = FIELDSET_PREFIX + recordTypeDeveloperName.replace(/ /g, '_');
        let hasStatusField = false;
        const before = [];
        const after = [];

        getFieldsFromFieldSet({objectName: OBJECT_NAME, fieldSetName})
            .then((data) => {
                const objStr = JSON.parse(data);
                const listOfFields = JSON.parse(Object.values(objStr)[1]);

                if (!listOfFields) {
                    throw new Error(`Unable to find Field Set with API name "${fieldSetName}"`);
                }

                listOfFields.forEach((element) => {
                    if (element.fieldPath !== 'Status') {
                        if (!hasStatusField) {
                            before.push({path: element.fieldPath, required: element.required});
                        } else {
                            after.push({path: element.fieldPath, required: element.required});
                        }
                    } else {
                        hasStatusField = true;
                        this.statusFieldLabel = element.label;
                    }
                });

                if (before.length === 0 && after.length === 0 && !hasStatusField) {
                    throw new Error('No fields found in fieldset.');
                }
                if (!hasStatusField) {
                    throw new Error(
                        'No Status field defined in fieldset. Please add the Case Status Field to the Field Set.'
                    );
                }
                this.inputFieldsBefore = before;
                this.inputFieldsAfter = after;
            })
            .catch((error) => {
                this.handleGlobalError(error);
            });
    }

    handleOnCaseCloseButton() {
        this.loading = true;
        this.buttonVisible = false;
        this.spamButtonVisible = false;
        setTimeout(() => {
            this.formVisible = true;
        }, 1200);
    }

    handleOnCaseCloseSpamButton() {
        setTimeout(() => {
            this.handleCloseSpam();
        }, 1200);
    }

    handleCloseSpam() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[STATUS_FIELD.fieldApiName] = 'Closed: SPAM';

        const currentSubject = getFieldValue(this.record, SUBJECT_FIELD);
        const currentDescription = getFieldValue(this.record, DESCRIPTION_FIELD);

        if (!currentSubject.startsWith('SPAM:')) {
            fields[SUBJECT_FIELD.fieldApiName] = 'SPAM: ' + currentSubject;
        }
        if (!currentDescription.startsWith('SPAM:')) {
            fields[DESCRIPTION_FIELD.fieldApiName] = 'SPAM: ' + currentDescription;
        }

        const recordInput = {fields};

        updateRecord(recordInput)
            .then(() => {
                this.handleOnCaseCloseSuccess();
            })
            .catch((error) => {
                this.handleGlobalError(error);
            });
    }

    handleOnSubmit(event) {
        let fields = event.detail.fields;
        fields.Status = this.selectedStatus;
        event.preventDefault();

        if (!this.validateFields()) {
            return;
        }

        this.loading = true;

        if (fields.Status === 'Closed: SPAM') {
            const currentSubject = getFieldValue(this.record, SUBJECT_FIELD);
            const currentDescription = getFieldValue(this.record, DESCRIPTION_FIELD);

            if (!currentSubject.startsWith('SPAM:')) {
                fields.Subject = 'SPAM: ' + currentSubject;
            }
            if (!currentDescription.startsWith('SPAM:')) {
                fields.Description = 'SPAM: ' + currentDescription;
            }
        }

        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleOnCaseCloseSuccess() {
        const caseNumber = getFieldValue(this.record, CASE_NUMBER_FIELD);
        const evt = new ShowToastEvent({
            title: 'Case Closed',
            message: 'Case Number: ' + caseNumber,
            variant: 'success',
        });
        this.dispatchEvent(evt);
        this.handleResetForm();
    }

    handleResetForm() {
        this.loading = false;
        this.formVisible = false;
        this.buttonVisible = true;
        this.spamButtonVisible = true;
        this.errorMessage = '';
        this.hasValidationError = null;
    }

    handleOnFormLoad() {
        this.loading = false;
    }

    handleOnFormError(event) {
        this.loading = false;
        this.hasValidationError = event.detail;
    }

    handleOnCancel() {
        this.handleResetForm();
    }

    handleOnStatusChange(event) {
        this.selectedStatus = event.detail.value;
        const hiddenStatusField = this.template.querySelector('[data-id="statusField"]');
        hiddenStatusField.value = this.selectedStatus;
    }

    handleGlobalError(error) {
        this.errorMessage = this.reduceErrors(error);
    }

    reduceErrors(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }

        return errors
            .filter((error) => !!error)
            .map((error) => {
                if (Array.isArray(error.body)) {
                    return error.body.map((e) => e.message);
                } else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                } else if (typeof error.message === 'string') {
                    return error.message;
                }
                return error.statusText;
            })
            .reduce((prev, curr) => prev.concat(curr), [])
            .filter((message) => !!message);
    }

    validateFields() {
        return [
            ...this.template.querySelectorAll('lightning-input-field'),
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, field) => validSoFar && field.reportValidity(), true);
    }
}
