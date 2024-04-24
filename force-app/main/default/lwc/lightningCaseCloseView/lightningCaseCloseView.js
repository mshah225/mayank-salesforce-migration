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
 * The expected interaction with this view is as follows:
 *  PARENT refers to the parent LWC, CHILD refers to this LWC, USER refers to the end user.
 *
 * 1. PARENT pass caseIds.
 * 2. USER fills in form, entering values into fields.
 * 3. USER presses a submit/cancel button in parent component (we don't provide this since formatting differs depending on if this is in a modal or not)
 * 4. PARENT call .commit() on this component
 * 5. CHILD prepare fields on all records based on entered values. Checks form is valid.
 * 6. CHILD raises a status event ("submitting") indcating form submission is in progress.
 * 7. Parent reacts to this and locks the submit button so additional submissions aren't attempted while the first is loading
 * 8. CHILD submits form.
 * 9. If successful, CHILD raises a status event ("success") indcating success, or if statusEvents are disabled, opens a toast alerting the user of success.
 * 10. If unsuccessful, CHILD raises a status event (form_error) indcating form_error and show a warning at the top of the form.
 * 11. If any unexpected errors occur (non validation rule errors), raise an error event, or if statusEvents are disabled expose the errors to USER via error toasts.
 *
 * Events::
 * status
 * {
 *   detail: {
 *     type: "success"|"form_error"|"submitting",
 *     event: onsuccess or onerror event from lightning-record-edit-form, or null
 *   }
 * }
 *
 * error
 * {
 *   errors: List<String> // list of human readable error messages.
 * }
 */
import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import {gql, graphql} from 'lightning/uiGraphQLApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getFieldsFromFieldSet from '@salesforce/apex/FieldSetHelper.getFieldsFromFieldSet';
import closeCasesList from '@salesforce/apex/LightningCaseCloseController.closeCasesList';
import {parseBoolean, extractErrorMessages} from 'c/helperFunctions';

// Fields/Objects
import RECORD_TYPE_ID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import CASE_NUMBER_FIELD from '@salesforce/schema/Case.CaseNumber';
import IS_CLOSED_FIELD from '@salesforce/schema/Case.IsClosed';

// Vars
const FIELDSET_PREFIX = 'CQC_RT_';

export default class LightningCaseCloseView extends LightningElement {
    // Support both mass case mode, and (when false) single case mode
    @api set massOperation(val) {
        this._massOperation = parseBoolean(val);
    }
    get massOperation() {
        return this._massOperation;
    }
    _massOperation = false;

    // List of cases that need to be modified
    @api caseIds = [];

    // When in mass case mode, override which record type is used (since cases may have differing record types)?
    @api recordTypeIdOverride = null;

    // Toggle to enable error/status events - this is useful if you need to react to changes in the form
    @api set statusEvents(val) {
        this._statusEvents = parseBoolean(val);
    }
    get statusEvents() {
        return this._statusEvents;
    }
    _statusEvents = false;

    // Show modals
    @api set showToasts(val) {
        this._showToasts = parseBoolean(val);
    }
    get showToasts() {
        return this._showToasts;
    }
    _showToasts = true;

    record;
    isLoading = true;
    defaultStatus = null;
    fieldSet = null;
    statusFieldLabel;
    validationError;
    submittedFields = null; // fields on most recent submit attempt
    recordTypeGQLInfo = null;

    // First Case in list
    get firstCaseId() {
        return this.caseIds.length > 0 ? this.caseIds[0] : null;
    }

    // Case Record
    @wire(getRecord, {
        recordId: '$firstCaseId',
        fields: [STATUS_FIELD, IS_CLOSED_FIELD, RECORD_TYPE_ID_FIELD, CASE_NUMBER_FIELD],
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

    /**
     * Get the record type names for Case (so we can convert between name and id)
     */
    @wire(graphql, {
        query: gql`
            query recordTypes {
                uiapi {
                    query {
                        RecordType(where: {SobjectType: {eq: "Case"}}) {
                            edges {
                                node {
                                    Id
                                    DeveloperName {
                                        value
                                    }
                                }
                            }
                        }
                    }
                }
            }
        `,
    })
    gotRecordTypeInfoGQL({error, data}) {
        if (error) {
            this.handleGlobalError(error);
        }

        if (data) {
            this.recordTypeGQLInfo = data;
        }
    }

    get recordTypeId() {
        return this.recordTypeIdOverride ?? this.record?.recordTypeId ?? null;
    }
    get recordTypeName() {
        // Filter list of record type info to contain only those of the relevant record type
        let recordTypeGQLInfo = (this.recordTypeGQLInfo?.uiapi?.query?.RecordType?.edges ?? [])
            .filter((v) => this.recordTypeId !== null && v?.node?.Id === this.recordTypeId)
            .map((v) => v?.node?.DeveloperName?.value);

        // If there if data, then return it
        return recordTypeGQLInfo.length > 0 ? recordTypeGQLInfo[0] : null;
    }

    // Case Status Options
    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId',
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
            } catch (e) {
                this.handleGlobalError(e);
            }
        }
    }

    // Validation Error Override
    get hasValidationError() {
        return this.validationError ? true : false;
    }
    set hasValidationError(error) {
        this.validationError = error;
    }

    // Loading Indicator
    get loading() {
        return this.isLoading;
    }
    set loading(status) {
        this.isLoading = status;
    }

    // Once field set is ready we can start loading the edit form
    get fieldSetReady() {
        return this.fieldSet != null;
    }

    // Case Status Options (Type = Closed)
    @api get statusOptions() {
        return this.caseStatusOptions;
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

    // All the fields that go before "Status" on the form
    get inputFieldsBefore() {
        if (this.fieldSet === null) return [];

        let allFields = this.fieldSet.map((element) => {
            return {path: element.fieldPath, required: element.required};
        });
        let isBeforeStatus = true;
        let beforeFields = allFields.reduce((prev, cur) => {
            if (cur.path === 'Status') isBeforeStatus = false; // Added all fields before status
            if (isBeforeStatus) prev.push(cur);
            return prev;
        }, []);

        return beforeFields;
    }

    // All the fields that go after "Status" on the form
    get inputFieldsAfter() {
        if (this.fieldSet === null) return [];

        let allFields = this.fieldSet.map((element) => {
            return {path: element.fieldPath, required: element.required};
        });
        let isAfterStatus = false;
        let afterFields = allFields.reduce((prev, cur) => {
            if (isAfterStatus) prev.push(cur);
            if (cur.path === 'Status') isAfterStatus = true; // Add all fields after Status
            return prev;
        }, []);

        return afterFields;
    }

    /**
     * Get the current status
     *
     * This value set on the status input field.
     * We don't want to pass its status on a non-closed case,
     * since the option will not be available in the dropdown for setting.
     */
    get currentStatus() {
        let isClosed = getFieldValue(this.record, IS_CLOSED_FIELD);
        return isClosed ? getFieldValue(this.record, STATUS_FIELD) : this.defaultStatus;
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

    get fieldSetName() {
        return this.recordTypeName ? FIELDSET_PREFIX + this.recordTypeName.replace(/ /g, '_') : null;
    }

    /**
     * Load the field set for the record type
     */
    @wire(getFieldsFromFieldSet, {objectName: 'Case', fieldSetName: '$fieldSetName'})
    gotFieldsFromFieldSet({data, error}) {
        if (error) {
            this.handleGlobalError(error);
        }

        if (data) {
            try {
                // Vars
                this.fieldSet = data.FIELD_LIST;

                // Error Check
                if (this.fieldSet == null) {
                    throw new Error(`Unable to find Field Set with API name "${this.fieldSetName}"`);
                }

                let hasStatusField = this.fieldSet.reduce((prev, cur) => {
                    return prev || cur.fieldPath === 'Status';
                }, false);

                // Error Check
                if (!hasStatusField) {
                    throw new Error(
                        'No Status field defined in fieldset. Please add the Case Status Field to the Field Set.'
                    );
                }
            } catch (err) {
                this.handleGlobalError(err);
            }
        }
    }

    /**
     * Submit the edit form. This presses the submit button, this indirectly calling the `handleSubmit` function.
     */
    @api async commit() {
        try {
            this.refs.submitButton.click();
        } catch (err) {
            this.handleGlobalError(err);
        }
    }

    /**
     * When the submit button is pressed, we need to validate the form and attempt to submit it.
     *
     * If this does attempt to submit the case, then this will trigger either the handleOnCaseCloseSuccess
     * or handleOnFormError functions upon completion
     */
    handleOnSubmit(event) {
        try {
            // Cannot submit while loading - because either not ready yet, or submission is already in progress
            if (this.loading) {
                return;
            }

            // Get fields from form
            this.submittedFields = event.detail.fields;

            // Don't do default submission because we neeed to validate stuff first
            event.preventDefault();

            // Make sure our fields are validated
            if (!this.validateFields()) {
                this.reportFormError(null);
                return;
            }

            this.loading = true;

            // Dispatch submitting status event (so parent can disable submit button)
            if (this.statusEvents) {
                this.dispatchEvent(
                    new CustomEvent('status', {
                        detail: {
                            type: 'submitting',
                            event: event,
                        },
                    })
                );
            }
            // Now call the default submit function (this will update record and update LDS)
            this.refs.recordEditForm.submit();
        } catch (err) {
            this.handleGlobalError(err);
        }
    }

    /**
     * The case has been successfully updated, operate on other cases if mass operation - and then report success
     */
    async handleOnCaseCloseSuccess(event) {
        // If this is a mass operation then we need to close all the other cases since the record-edit-form only allows us to close the first one.
        if (this.massOperation) {
            const caseList = [];

            // Skip the first, since that was closed via the record-edit-form subimission
            for (let i = 1; i < this.caseIds.length; i++) {
                // Get case id
                const caseId = this.caseIds[i];
                // Copy all the other fields onto record and add to list
                caseList.push(Object.assign({Id: caseId}, this.submittedFields));
            }

            if (caseList.length > 0) {
                // Close the remaining cases if they are still open

                try {
                    await closeCasesList({cases: caseList});
                    this.reportSuccesfulCaseClose(event);
                } catch (err) {
                    this.loading = false;
                    this.handleGlobalError(err);
                }
            } else {
                // There was only one case (even though in mass operation mode)
                this.reportSuccesfulCaseClose(event);
            }
        }
        // If this is not in massOperation mode, then no need to close any other cases
        else {
            this.reportSuccesfulCaseClose(event);
        }
    }

    /**
     * After successfully updating all cases, this is called to remove the loading icon and alert the user/PARENT component.
     * Send a status event indicating success
     */
    reportSuccesfulCaseClose(event) {
        this.loading = false;

        if (this.statusEvents) {
            // Send a success event
            this.dispatchEvent(
                new CustomEvent('status', {
                    detail: {
                        type: 'success',
                        event: event,
                    },
                })
            );
        }

        if (this.showToasts) {
            const evt = new ShowToastEvent({
                title: `${this.massOperation ? 'Cases' : 'Case'} Closed`,
                message: this.massOperation
                    ? ''
                    : `Case Number: ${getFieldValue(this.record, IS_CLOSED_FIELD) ?? 'UNKNOWN'}`,
                variant: 'success',
            });
            this.dispatchEvent(evt);
        }

        this.handleResetForm();
    }

    /**
     * The case has failed to update, we should display the error since this indicates that a validation rule has failed
     * This usually is because the user forgot to enter a required field.
     *
     * Send a status event indicating form error
     */
    handleOnFormError(event) {
        this.loading = false;
        this.hasValidationError = event.detail;
        this.reportFormError(event);
    }

    reportFormError(event) {
        if (this.statusEvents) {
            // Send form error status
            this.dispatchEvent(
                new CustomEvent('status', {
                    detail: {
                        type: 'form_error',
                        event: event,
                    },
                })
            );
        }
    }

    /**
     * Reset the form values, clearing entered values and displayed errors
     */
    @api handleResetForm() {
        this.loading = false;
        this.hasValidationError = null;
    }

    /**
     * The form takes time to load using Lightning Data Service, to populate options in dropdowns.
     */
    handleOnFormLoad() {
        this.loading = false;
    }

    /**
     * Set the hidden status field elements value based on the visible status dropdown.
     * We need this hidden value in order to make updateDependentField work properly.
     */
    handleOnStatusChange(event) {
        let hiddenStatusField = this.refs.hiddenStatusField;
        hiddenStatusField.value = event.detail.value;
    }

    /**
     * Handle unexpected errors, either by show a toast to the user and sending an error event
     */
    handleGlobalError(error) {
        console.error('Error During Case Closure', error); // log it
        console.error(extractErrorMessages(error));

        this.dispatchEvent(
            new CustomEvent('error', {
                detail: {
                    errors: extractErrorMessages(error),
                },
            })
        );

        if (this.showToasts) {
            const messages = extractErrorMessages(error);
            const evt = new ShowToastEvent({
                title: 'Error During Case Closure',
                message:
                    messages.length > 0
                        ? messages[0]
                        : 'Unable to extract error message - full error object printed to Javascript console.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
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
