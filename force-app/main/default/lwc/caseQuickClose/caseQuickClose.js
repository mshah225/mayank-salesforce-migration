/**
 * Author: Created by Carl Hussey
 * Date: 11/11/2021
 * Description:
 *  To use, create a fieldset on Case with an API name in the following format:
 *  CQC_RT_RECORD_TYPE_API_NAME (Examples: CQC_RT_ASU_Service, CQC_RT_ASU_Advisor_Outreach)
 */
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
    @api componentName = 'Case Quick Close';
    @api closeButtonLabel = 'Close Case';
    @api closeButtonVariant = 'brand';
    @api recordSubmitButtonLabel = 'Submit';
    @api recordSubmitButtonVariant = 'brand';
    record;
    casesStatusOptions = [];
    isLoading = false;
    isFormVisible = false;
    isButtonVisible = true;
    errorDetail = '';
    errorContact = 'salesforce.support@asu.edu';
    selectedStatus = '';
    inputFieldsBefore = [];
    inputFieldsAfter = [];
    statusFieldLabel;

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

            // If we weren't able to get the status options, set error
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

    // Error Contact Info
    get errorContactEmail() {
        return this.errorContact;
    }

    // Label of the status field we are re-creating
    get statusInputLabel() {
        return this.statusFieldLabel;
    }
    get statusInputPlaceholder() {
        return 'Select ' + this.statusFieldLabel;
    }
    get statusRequired() {
        return this.statusFieldRequired;
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
        let hasStatusField = false;
        let before = [];
        let after = [];

        // Get Fields
        getFieldsFromFieldSet({fieldSetName: fieldSetName})
            .then((data) => {
                // Vars
                let objStr = JSON.parse(data),
                    listOfFields = JSON.parse(Object.values(objStr)[1]);

                // Error Check
                if (listOfFields == null) {
                    throw new Error(`Unable to find Field Set with API name "${fieldSetName}"`);
                }

                // Map list of fields from APEX response
                listOfFields.map((element) => {
                    /*
                        If the current field is not Status and we have not yet encountered the Status field,
                        add the field to the Before Array. If we have encountered Status field, we add this field
                        to the After array.
                    */
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
                    return null;
                });

                // Error Check
                if (before.length === 0 && after.length === 0) {
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

    // Show Record Edit Form
    handleOnCaseCloseButton() {
        this.loading = true;
        this.buttonVisible = false;
        setTimeout(() => {
            this.formVisible = true;
        }, 1200);
    }

    // Override Submit
    handleOnSubmit(event) {
        // Vars
        let fields = event.detail.fields;
        fields.Status = this.selectedStatus;
        event.preventDefault();

        // Make sure our fields are validated
        if (!this.validateFields()) {
            return;
        }

        this.loading = true;

        // Custom Status Logic
        if (fields.Status === 'Closed: SPAM') {
            // Vars
            const currentSubject = getFieldValue(this.record, SUBJECT_FIELD);
            const currentDescription = getFieldValue(this.record, DESCRIPTION_FIELD);

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
        this.handleResetForm();
    }

    // Reset
    handleResetForm() {
        this.loading = false;
        this.formVisible = false;
        this.buttonVisible = true;
        this.errorMessage = '';
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
        this.errorMessage = this.reduceErrors(error);
    }

    // Reduces one or more LDS errors into a string[] of error messages.
    reduceErrors(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }

        return (
            errors
                // Remove null/undefined items
                .filter((error) => !!error)
                // Extract an error message
                .map((error) => {
                    // UI API read errors
                    if (Array.isArray(error.body)) {
                        return error.body.map((e) => e.message);
                    }
                    // UI API DML, Apex and network errors
                    else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    }
                    // JS errors
                    else if (typeof error.message === 'string') {
                        return error.message;
                    }
                    // Unknown error shape so try HTTP status text
                    return error.statusText;
                })
                // Flatten
                .reduce((prev, curr) => prev.concat(curr), [])
                // Remove empty strings
                .filter((message) => !!message)
        );
    }

    // Validate Fields
    validateFields() {
        return [
            ...this.template.querySelectorAll('lightning-input-field'),
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, field) => {
            // Return whether all fields up to this point are valid and whether current field is valid
            // reportValidity returns validity and also displays/clear message on element based on validity
            return validSoFar && field.reportValidity();
        }, true);
    }
}
