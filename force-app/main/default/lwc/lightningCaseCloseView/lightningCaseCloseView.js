/**
 * Author: Created by Carl Hussey (11/11/2021)
 *         Modified Robert Nordman (04/08/2024)
 * Date: 04/08/2024
 * Description:
 *  To use, create a fieldset on Case with an API name in the following format:
 *  CQC_RT_RECORD_TYPE_API_NAME (Examples: CQC_RT_ASU_Service, CQC_RT_ASU_Advisor_Outreach)
 *
 * This view component is primarily responsible for providing the fields that must be filled out in order to close Quick Close the case.
 * It also raises multiple events indicating progress on the form
 *
 * @api fields/functions:
 * caseIds: Array<String>
 *      List of all case ids that need to be closed by the form.
 * commit(): Function<Promise>
 *      A function that calls the submit function for the lightning-record-edit form
 *      The parent should implement a submit button and when that is pressed, it should call this.
 *
 *
 * The expected interaction with this view is as follows:
 *  PARENT refers to the parent LWC, CHILD refers to this LWC, USER refers to the end user.
 *
 * 1. PARENT pass caseIds.
 * 2. CHILD shows Loading icon shown while all items are loaded for form.
 * 3. Wires complete.
 * 4. Loading icon hidden and form is shown.
 * 5. `ready` event is sent.
 * 6. USER fills in form, entering values into fields.
 * 7. USER presses a submit/cancel button in parent component (we don't provide this since formatting differs depending on if this is in a modal or not).
 * 8. PARENT call .commit() on this component.
 * 9. CHILD prepare fields on all records based on entered values. Checks form is valid.
 * 10. CHILD raises a `status` event ("submitting") indcating form submission is in progress.
 * 11. Parent reacts to this and locks the submit button so additional submissions aren't attempted while the first is loading.
 * 12. CHILD submits form.
 * 13. If successful, CHILD raises a `status` event ("success") indcating success,
 * 14. If toasts are enabled, opens a toast alerting the user of success.
 * 15. If unsuccessful, CHILD raises a `status` event (form_error) indcating form_error and show a warning at the top of the form.
 * *. If any unexpected errors occur at any stage (non validation rule errors), raise an error event,
 *
 *
 * Events::
 * status - status events are information about the state of the form
 * {
 *   detail: {
 *     type: "success"|"form_error"|"submitting"
 *   }
 * }
 *
 * error - any location that causes an unexpected error, such as a failed wire, can cause this
 * {
 *   errors: List<String> // list of human readable error messages.
 * }
 *
 * ready - published once the form has completed the initlal load
 * {
 *   detail: {}
 * }
 */
import {LightningElement, api, wire} from 'lwc';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {notifyRecordUpdateAvailable} from 'lightning/uiRecordApi';
import getFieldsFromFieldSet from '@salesforce/apex/ObjectHelper.getFieldsFromFieldSet';
import updateRecords from '@salesforce/apex/RecordController.updateRecords';
import {extractErrorMessages} from 'c/helperFunctions';

// Fields/Objects
import CASE_OBJ from '@salesforce/schema/Case';
import RECORD_TYPE_ID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import RECORD_TYPE_NAME_FIELD from '@salesforce/schema/Case.RecordType.DeveloperName';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import IS_CLOSED_FIELD from '@salesforce/schema/Case.IsClosed';

// Vars
const FIELDSET_PREFIX = 'CQC_RT_';

export default class LightningCaseCloseView extends LightningElement {
    // List of cases that need to be modified
    @api caseIds = [];

    // Details about the first case record
    caseRecord = undefined;
    // Case Status options
    caseStatusOptions = undefined;
    // Field set of which fields to display
    fieldSet = undefined;

    // Validation errors from updating case - these are user-fixable and we show them and allow the user to modify the form and try again
    validationError = undefined;

    // The validation error message can contain escaped characters (such as quotes being represented using &quot;)
    // so this getter converts those back into the not escaped variants for displaying to user
    get validationErrorStr() {
        // Not set, return null/undefined
        if (this.validationError == null) return this.validationError;
        // Set, therefore get nice error message
        const node = document.createElement('span');
        node.innerHTML = this.validationError;
        return node.textContent;
    }

    // Any other error - these are unexpected and could be from permission issues or otherwise - these indicate an unfixable failure mode
    unexpectedError = undefined;

    /**
     * Uses the first case to determine record type/prepopulate fields
     */
    get firstCaseId() {
        return this.caseIds.length > 0 ? this.caseIds[0] : undefined; // undefined rather than null to prevent wires from running prematurely
    }

    /**
     * Lookup fields for the first case record
     */
    @wire(getRecord, {
        recordId: '$firstCaseId',
        fields: [STATUS_FIELD, IS_CLOSED_FIELD, RECORD_TYPE_ID_FIELD, RECORD_TYPE_NAME_FIELD],
    })
    wiredCase(result) {
        this.caseWire = result;
        const {error, data} = result;

        if (error !== undefined) {
            this.handleGlobalError(error);
        }

        if (data !== undefined) {
            this.caseRecord = data;
        }
    }
    caseWire = undefined;

    /**
     * Get the current status if it is already closed
     *
     * This value is set on the status input field.
     * We don't want to pass the status of a non-closed case,
     * since the option will not be available in the dropdown for setting.
     */
    get currentStatus() {
        return this.caseRecord
            ? getFieldValue(this.caseRecord, IS_CLOSED_FIELD)
                ? getFieldValue(this.caseRecord, STATUS_FIELD)
                : undefined
            : undefined;
    }

    /**
     * The record type id of the first case, or undefined if this isn't set yet
     */
    get recordTypeId() {
        return this.caseRecord ? getFieldValue(this.caseRecord, RECORD_TYPE_ID_FIELD) : undefined; // undefined rather than null to prevent wires from running prematurely
    }

    /**
     * The record type name of the first case, or undefined if this isn't set yet
     */
    get recordTypeName() {
        return this.caseRecord ? getFieldValue(this.caseRecord, RECORD_TYPE_NAME_FIELD) : undefined; // undefined rather than null to prevent wires from running prematurely
    }

    /**
     * Get the case status options for this case record type
     */
    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId',
        fieldApiName: STATUS_FIELD,
    })
    wiredStatusOptions({error, data}) {
        if (error !== undefined) {
            this.handleGlobalError(error);
        }

        if (data !== undefined) {
            this.caseStatusOptions = this.buildStatusOptions(data);

            // If we weren't able to get the status options, set error
            if (this.caseStatusOptions.length === 0) {
                this.handleGlobalError(new Error('Unable to access Status Options for Picklist.'));
            }
        }
    }

    // Name of the field set (this is based on record type)
    get fieldSetName() {
        return this.recordTypeName ? FIELDSET_PREFIX + this.recordTypeName.replace(/ /g, '_') : undefined; // undefined rather than null to prevent wires from running prematurely
    }

    /**
     * Load the field set for the record type
     */
    @wire(getFieldsFromFieldSet, {objectName: CASE_OBJ.objectApiName, fieldSetName: '$fieldSetName'})
    gotFieldsFromFieldSet({data, error}) {
        if (error !== undefined) {
            this.handleGlobalError(error);
        }

        if (data !== undefined) {
            this.fieldSet = data?.FIELD_LIST;

            // Cannot find field set
            if (this.fieldSet == null) {
                this.handleGlobalError(new Error(`Unable to find Field Set with API name "${this.fieldSetName}"`));
            } else {
                // Check that has required status field
                let hasStatusField = this.fieldSet.reduce((prev, cur) => {
                    return prev || cur.fieldPath === STATUS_FIELD.fieldApiName;
                }, false);

                // Field set is missing status field
                if (!hasStatusField) {
                    this.handleGlobalError(
                        new Error(
                            'No Status field defined in fieldset. Please add the Case Status Field to the Field Set.'
                        )
                    );
                }
            }
        }
    }

    // Loading Indicator
    get loading() {
        return !this.wiresDone || this.formLoading || this.submitting;
    }

    // Once field set and status options are loaded, we can load form
    get wiresDone() {
        return this.caseRecord !== undefined && this.caseStatusOptions !== undefined && this.fieldSet !== undefined;
    }

    // Label of the status field we are re-creating
    get statusInputLabel() {
        for (const fieldSetField of this.fieldSet ?? [])
            if (fieldSetField.fieldPath === 'Status') return fieldSetField.label;
        return 'Status';
    }
    get statusInputPlaceholder() {
        return 'Select ' + this.statusInputLabel;
    }

    // All the fields that go before "Status" on the form
    get inputFieldsBefore() {
        if (this.fieldSet == null) return [];

        let allFields = this.fieldSet.map((element) => {
            return {path: element.fieldPath, required: element.required};
        });
        let isBeforeStatus = true;
        let beforeFields = allFields.reduce((prev, cur) => {
            if (cur.path === STATUS_FIELD.fieldApiName) isBeforeStatus = false; // Added all fields before status
            if (isBeforeStatus) prev.push(cur);
            return prev;
        }, []);

        return beforeFields;
    }

    // All the fields that go after "Status" on the form
    get inputFieldsAfter() {
        if (this.fieldSet == null) return [];

        let allFields = this.fieldSet.map((element) => {
            return {path: element.fieldPath, required: element.required};
        });
        let isAfterStatus = false;
        let afterFields = allFields.reduce((prev, cur) => {
            if (isAfterStatus) prev.push(cur);
            if (cur.path === STATUS_FIELD.fieldApiName) isAfterStatus = true; // Add all fields after Status
            return prev;
        }, []);

        return afterFields;
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

    /**
     * The form takes time to load using Lightning Data Service, to populate options in dropdowns.
     * Once loading is done, raise an event so parent knows it is ready to allow interaction with this component.
     */
    handleOnFormLoad() {
        this.formLoading = false;

        this.dispatchEvent(
            new CustomEvent('ready', {
                detail: {},
            })
        );
    }
    formLoading = true;

    /**
     * When the submit button is /pressed/, we need to validate the form and attempt to submit it.
     *
     * But, we don't want to use the record-edit-form's standard submission, since we might have multiple
     * records to update, so instead this uses the custom logic to submit
     */
    handleOnSubmit(event) {
        // Cannot submit while loading - because either not ready yet, or submission is already in progress
        if (this.loading) {
            return;
        }

        // Don't do default submission because we neeed to validate stuff first
        event.preventDefault();

        // Make sure our fields are validated
        if (!this.validateFields()) {
            this.sendStatusEvent('form_error');
            return;
        }

        // get status value from status dropdwon
        const statusValue = this.refs.statusField.value;

        // Construct the updated cases
        const caseList = [];
        for (let i = 0; i < this.caseIds.length; i++) {
            // Get case id
            const caseId = this.caseIds[i];
            // Copy all the other fields onto record and add to list
            // eslint-disable-next-line compat/compat
            caseList.push(Object.assign({Id: caseId, Status: statusValue}, event.detail.fields));
        }

        if (caseList.length > 0) {
            // We are submitting, this will enable loading icon
            this.submitting = true;
            this.validationError = undefined;
            // Dispatch submitting status event (so parent can disable submit button)
            this.sendStatusEvent('submitting');

            // Update cases
            updateRecords({records: caseList})
                .then((v) => {
                    if (v.success) {
                        this.validationError = v.errorMessage;
                        this.sendStatusEvent('form_error');
                        return Promise.resolve();
                    }
                    this.validationError = undefined;
                    this.sendStatusEvent('success');

                    // Update LDS cache
                    return notifyRecordUpdateAvailable(
                        (v.recordIds ?? []).map((recordId) => {
                            return {recordId};
                        })
                    );
                })
                .catch((e) => {
                    this.handleGlobalError(e);
                })
                .finally(() => {
                    this.submitting = false;
                });
        } else {
            // There are no cases to update
            this.handleGlobalError(new Error('No cases to close'));
        }
    }
    submitting = false;

    /**
     * Submit the edit form. This presses the submit button, this indirectly calling the `handleSubmit` function.
     * But we call it this way to make sure event.detail.fields is set on the event and so the form can do its extra checks
     */
    @api commit() {
        this.refs.submitButton.click();
    }

    /**
     * Raise a status event to communicate to the parent LWC the current state of an attempted submission
     */
    sendStatusEvent(status) {
        this.dispatchEvent(
            new CustomEvent('status', {
                detail: {
                    type: status,
                },
            })
        );
    }

    /**
     * Handle unexpected errors, either by show a toast to the user and sending an error event
     */
    handleGlobalError(error) {
        this.unexpectedError = extractErrorMessages(error)[0];
        this.dispatchEvent(
            new CustomEvent('error', {
                detail: {
                    errors: extractErrorMessages(error),
                },
            })
        );
    }

    // An error has occurred either during a wire or from the case update (and it wasn't an acceptable DmlError),
    // or due to the payload being faulty
    get hasError() {
        return this.unexpectedError != null;
    }
    get errorMessage() {
        return this.unexpectedError;
    }

    /**
     * Runs reportValidity for all fields in form. Report validality both returns false if invalid
     * and also shows/clears alert messages indicating any problems.
     *
     * @returns {Boolean} True if all fields are clientside valid, False otherwise
     */
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

export class LightningCaseCloseViewTest extends LightningCaseCloseView {
    @api
    set caseIds(v) {
        super.caseIds = v;
    }
    get caseIds() {
        return super.caseIds;
    }

    @api get loading() {
        return super.loading;
    }

    @api get currentStatus() {
        return super.currentStatus;
    }

    @api get statusInputLabel() {
        return super.statusInputLabel;
    }

    @api get statusInputPlaceholder() {
        return super.statusInputPlaceholder;
    }

    @api
    set caseStatusOptions(v) {
        super.caseStatusOptions = v;
    }
    get caseStatusOptions() {
        return super.caseStatusOptions;
    }

    @api get hasError() {
        return super.hasError;
    }

    @api
    set errorMessage(v) {
        super.errorMessage = v;
    }
    get errorMessage() {
        return super.errorMessage;
    }

    @api commit() {
        const submitFields = {};
        const inputFields = this.template.querySelectorAll('lightning-input-field');

        for (const inputField of inputFields) {
            submitFields[inputField.dataset.name] = submitFields.value;
        }

        this.template.querySelector('lightning-record-edit-form').dispatchEvent(
            new CustomEvent('submit', {
                detail: {
                    fields: submitFields,
                },
            })
        );
    }
}
