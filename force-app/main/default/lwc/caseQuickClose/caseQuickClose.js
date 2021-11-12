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
    casesStatusOptions;
    isLoading = false;
    isFormVisible = false;
    isButtonVisible = true;
    errorDetail = '';
    selectedStatus;
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
        return getFieldValue(this.record, STATUS_FIELD);
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

    // Label of the status field we are re-creating
    get statusInputLabel() {
        return this.statusFieldLabel;
    }
    get statusInputPlaceholder() {
        return 'Select ' + this.statusFieldLabel;
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
                            before.push(element.fieldPath);
                        } else {
                            after.push(element.fieldPath);
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
        event.preventDefault();
        this.loading = true;

        // Vars
        let fields = event.detail.fields;
        fields.Status = this.selectedStatus;

        // Custom Status Logic
        if (fields.Status === 'Closed: SPAM') {
            // Vars
            const currentSubject = getFieldValue(this.record.data, SUBJECT_FIELD);
            const currentDescription = getFieldValue(this.record.data, DESCRIPTION_FIELD);

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
        this.errorMessage = error;
    }
}
