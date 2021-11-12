import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getFieldsFromFieldSet from '@salesforce/apex/FieldSetHelper.getFieldsFromFieldSet';

// Fields
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import RECORD_TYPE_DEVELOPER_NAME_FIELD from '@salesforce/schema/Case.RecordType.DeveloperName';
import STATUS_FIELD from '@salesforce/schema/Case.Status';

// Vars
const FIELDSET_PREFIX = 'CQC_RT_';

export default class CaseQuickClose extends LightningElement {
    @api recordId;
    // Configuration exposed for lightning builder
    @api componentName = 'Case Quick Close';
    @api closeButtonLabel = 'Close Case';
    @api closeButtonVariant = 'brand';
    @api recordSubmitButtonLabel = 'Submit';
    @api recordSubmitButtonVariant = 'brand';
    // Configuration exposed for lightning builder
    record;
    casesStatusOptions;
    isLoading = false;
    isFormVisible = false;
    isButtonVisible = true;
    errorDetail = '';
    selectedStatus;
    inputFields = [];
    currentStatusPositionIndex;

    // Case Record
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [SUBJECT_FIELD, DESCRIPTION_FIELD, RECORD_TYPE_DEVELOPER_NAME_FIELD, STATUS_FIELD],
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

    // Case Status Options
    @wire(getPicklistValues, {
        recordTypeId: '$record.recordTypeId',
        fieldApiName: STATUS_FIELD,
    })
    wiredStatusOptions({error, data}) {
        if (error) {
            this.caseStatusOptions = undefined;
            this.handleGlobalError(error);
        }
        if (data) {
            this.caseStatusOptions = this.buildStatusOptions(data);
            this.loadFieldset();
        }
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

    // Submit Button Variant
    get lwcRecordSubmitButtonVariant() {
        return this.recordSubmitButtonVariant;
    }

    // Case Status (Current)
    get currentCaseStatus() {
        return getFieldValue(this.record.data, STATUS_FIELD);
    }

    // Case Status Options (Type = Closed)
    get statusOptions() {
        return this.caseStatusOptions;
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

    // Button Visibility
    get buttonVisible() {
        return this.isButtonVisible;
    }
    set buttonVisible(visible) {
        this.isButtonVisible = visible;
    }

    // Error
    get hasError() {
        return this.errorDetail ? true : false;
    }

    // Error Message
    get errorMessage() {
        return this.errorDetail;
    }
    set errorMessage(detail) {
        this.errorDetail = detail;
    }

    // Build Status Options Array
    buildStatusOptions(options) {
        return options.values
            .filter((s) => s.attributes.closed === true)
            .map((element) => {
                return {
                    label: element.label,
                    value: element.value,
                };
            });
    }

    // Load Fieldset
    loadFieldset() {
        // Vars
        const recordTypeDeveloperName = getFieldValue(this.record, RECORD_TYPE_DEVELOPER_NAME_FIELD);
        const fieldSetName = FIELDSET_PREFIX + recordTypeDeveloperName.replace(/ /g, '_');
        let items = [];
        let result;

        // Get Fields
        getFieldsFromFieldSet({fieldSetName: fieldSetName})
            .then((data) => {
                // Vars
                let objStr = JSON.parse(data),
                    listOfFields = JSON.parse(Object.values(objStr)[1]);

                // Store the index position of our status field defined in the fieldset
                listOfFields.map((element, index) => {
                    if (element.fieldPath === 'Status') {
                        this.currentStatusPositionIndex = index;
                    } else {
                        result = items.push(element.fieldPath);
                    }
                    return result;
                });

                // Error Check
                if (!items.includes('Status')) {
                    this.loading = false;
                    throw new Error('No status field defined in fieldset.');
                }
                this.inputFields = items;
            })
            .catch((error) => {
                this.handleGlobalError(error);
            });
    }

    // Show Record Edit Form
    handleOnCaseCloseButton() {
        this.buttonVisible = false;
        this.loading = true;
        setTimeout(() => {
            this.formVisible = true;
        }, 1200);
    }

    // Override Submit
    handleOnSubmit(event) {
        event.preventDefault();
        this.loading = true;

        // Vars
        let fields = event.detail.fields;
        fields.Status = this.selectedStatus;

        // Custom Status Logic
        if (fields.Status === 'Closed: SPAM') {
            // Vars
            let currentSubject = getFieldValue(this.record.data, SUBJECT_FIELD);
            let currentDescription = getFieldValue(this.record.data, DESCRIPTION_FIELD);

            // Modify case details
            if (!currentSubject.startsWith('SPAM:')) {
                fields.Subject = 'SPAM: ' + currentSubject;
            }
            if (!currentDescription.startsWith('SPAM:')) {
                fields.Description = 'SPAM: ' + currentDescription;
            }
        }
        // Submit
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    // Success
    handleOnCaseCloseSuccess(event) {
        const evt = new ShowToastEvent({
            title: 'Case Closed',
            message: 'Record ID: ' + event.detail.id,
            variant: 'success',
        });
        this.dispatchEvent(evt);
        this.resetForm();
    }

    // Reset
    handleResetForm() {
        this.loading = false;
        this.formVisible = false;
        this.buttonVisible = true;
    }

    // Form Loaded
    handleOnFormLoad() {
        this.loading = false;
    }

    // Form Error
    handleOnFormError() {
        this.loading = false;
    }

    // Cancel Form
    handleOnCancel() {
        this.handleResetForm();
    }

    // Status Change
    handleOnStatusChange(event) {
        this.selectedStatus = event.detail.value;
    }

    // Global Error
    handleGlobalError(error) {
        this.errorMessage = error;
    }
}
