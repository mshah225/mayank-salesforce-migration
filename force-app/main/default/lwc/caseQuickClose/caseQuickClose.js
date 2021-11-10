import {LightningElement, api, wire} from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getFieldsFromFieldSet from '@salesforce/apex/FieldSetHelper.getFieldsFromFieldSet';
const FIELDSET_PREFIX = 'CQC_RT_';
const FIELDS = [
    'Case.RecordTypeId',
    'Case.Subject',
    'Case.Description',
    'Case.RecordType.DeveloperName',
    'Case.Status',
];

export default class CaseQuickClose extends LightningElement {
    @api recordId;
    record;
    recordType;
    statusOptions;

    // UI
    showSpinner = false;
    isFormShown = false;
    isCloseButtonShown = true;
    hasLoaded = false;

    statusOptions;
    selectedStatus;
    inputFieldAPIs = [];
    currentStatusPositionIndex;

    /**
     * Get the current record to access the record type data
     */
    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    getCurrentRecord({error, data}) {
        if (data) {
            let result = JSON.parse(JSON.stringify(data));
            this.record = result;
            this.recordType = result.fields.RecordType;
            this.loadFieldset();
        } else if (error) {
            let result = JSON.parse(JSON.stringify(error));
            console.log('error: ', result);
        }
    }

    /**
     * Get the current record to access the record type data
     */
    @wire(getPicklistValues, {recordTypeId: '$record.recordTypeId', fieldApiName: STATUS_FIELD})
    statusValues({error, data}) {
        if (data) {
            let result = JSON.parse(JSON.stringify(data));
            this.createStatusOptions(result);
        } else if (error) {
            let result = JSON.parse(JSON.stringify(error));
            console.log('error: ', result);
        }
    }

    /**
     * Return a list of status options
     */
    get caseStatusOptions() {
        return this.statusOptions;
    }

    /**
     * Get the current status of this case
     */
    get currentCaseStatus() {
        return this.record.fields.Status.value;
    }

    /**
     * Get the fieldset name to lookup
     */
    fieldSetNameHelper() {
        let currentRecordType = this.recordType.value.fields.DeveloperName.value;
        currentRecordType = currentRecordType.replace(/ /g, '_');
        return FIELDSET_PREFIX + currentRecordType;
    }

    /**
     * Create our options for the status dropdown
     * @param {*} statusData
     */
    createStatusOptions(statusData) {
        let closed = statusData.values.filter((s) => s.attributes.closed === true);
        // Create our options
        this.statusOptions = closed.map((element) => {
            return {
                label: element.label,
                value: element.value,
            };
        });
    }

    /**
     * Load the record edit form using the fields in the fieldset
     */
    loadFieldset() {
        // Vars
        let fieldSetName = this.fieldSetNameHelper();

        // Fetch the fields using fieldset
        getFieldsFromFieldSet({fieldSetName: fieldSetName})
            .then((data) => {
                // Hold all of our fields
                let items = [];
                // Get the entire map
                let objStr = JSON.parse(data);
                // Get the list of fields, its a reverse order to extract from map
                let listOfFields = JSON.parse(Object.values(objStr)[1]);
                // Prepare items array using field api names

                // Store the index position of our status field defined in the fieldset
                // We will be replacing this field, so we need to know where to re-insert it
                listOfFields.map((element, index) => {
                    let result;
                    if (element.label === 'Status') {
                        this.currentStatusPositionIndex = index;
                    } else {
                        result = items.push(element.fieldPath);
                    }
                    return result;
                });

                this.inputFieldAPIs = items;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                console.log('error', error);
            });
    }

    /**
     * Show form on button click
     */
    showForm() {
        this.isCloseButtonShown = false;
        this.showSpinner = true;
        setTimeout(() => {
            this.isFormShown = true;
        }, 1200);
    }

    /**
     * Reset our form
     */
    resetForm() {
        this.showSpinner = false;
        this.isFormShown = false;
        this.isCloseButtonShown = true;
    }

    /**
     * Override the submit method to modify data prior to submission
     */
    handleSubmit(event) {
        // Prevent submitting the form so we can override
        event.preventDefault();
        this.showSpinner = true;

        // Vars
        let fields = event.detail.fields;
        fields.Status = this.selectedStatus;

        // If the selected status is Closed: Spam, modify some case data
        if (fields.Status === 'Closed: SPAM') {
            let currentSubject = this.record.fields.Subject.value;
            let currentDescription = this.record.fields.Description.value;

            // Modify case details
            if (!currentSubject.startsWith('SPAM:')) {
                fields.Subject = 'SPAM: ' + currentSubject;
            }
            if (!currentDescription.startsWith('SPAM:')) {
                fields.Description = 'SPAM: ' + currentDescription;
            }
        }

        // Submit the form
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    /**
     * On success, show a toast event and notify parent component
     * @param {*} event
     */
    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: 'Case Closed',
            message: 'Record ID: ' + event.detail.id,
            variant: 'success',
        });
        this.dispatchEvent(evt);
        this.resetForm();
    }

    /**
     * On record edit form load
     */
    handleOnFormLoad() {
        this.showSpinner = false;
        this.hasLoaded = true;
    }

    /**
     * On record edit form error
     */
    handleOnFormError() {
        this.showSpinner = false;
    }

    /**
     * On cancel edit
     */
    handleCancel() {
        this.resetForm();
    }

    /**
     * Handle case status change
     * @param {*} event
     */
    handleStatusOnChange(event) {
        this.selectedStatus = event.detail.value;
    }
}
