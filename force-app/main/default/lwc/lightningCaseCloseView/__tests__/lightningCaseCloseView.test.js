/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {LightningCaseCloseViewTest} from 'c/lightningCaseCloseView';
import {getRecord} from 'lightning/uiRecordApi';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import getFieldsFromFieldSet from '@salesforce/apex/ObjectHelper.getFieldsFromFieldSet';
import updateRecords from '@salesforce/apex/RecordController.updateRecords';
import {flushPromises} from 'c/helperTestFunctions';

import CASE_OBJ from '@salesforce/schema/Case';
import RECORD_TYPE_ID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import RECORD_TYPE_NAME_FIELD from '@salesforce/schema/Case.RecordType.DeveloperName';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import IS_CLOSED_FIELD from '@salesforce/schema/Case.IsClosed';

// Mock realistic data
const caseRecordMock = require('./data/caseRecord.json');
const caseRecordNotClosedMock = require('./data/caseRecordNotClosed.json');
const fieldSetResponseMock = require('./data/fieldSetResponse.json');
const statusOptionsMock = require('./data/statusOptions.json');
// Mock responses for updating records
const updateRecordsSuccessMock = require('./data/updateRecordsSuccess.json');
const updateRecordsFailureMock = require('./data/updateRecordsFailure.json');
const updateRecordsErrorMock = require('./data/updateRecordsError.json');

jest.mock(
    '@salesforce/apex/ObjectHelper.getFieldsFromFieldSet',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/RecordController.updateRecords',
    () => {
        return {
            default: jest.fn(),
        };
    },
    {virtual: true}
);

describe('c-lightning-case-close-view', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    test('Loading until all wires are complete', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        document.body.appendChild(element);
        await flushPromises(); // all wires are queued

        expect(element.loading).toEqual(true); // Still loading
        expect(element.shadowRoot).not.toHaveChildElement('lightning-record-edit-form');

        getRecord.emit(caseRecordMock); // return case record
        await flushPromises();

        expect(element.loading).toEqual(true); // Still loading
        expect(element.shadowRoot).not.toHaveChildElement('lightning-record-edit-form');

        getPicklistValues.emit(statusOptionsMock); // return status options
        await flushPromises();

        expect(element.loading).toEqual(true); // Still loading
        expect(element.shadowRoot).not.toHaveChildElement('lightning-record-edit-form');

        getFieldsFromFieldSet.emit(fieldSetResponseMock); // return field set fields
        await flushPromises();

        expect(element.loading).toEqual(true); // Still loading
        expect(element.shadowRoot).toHaveChildElement('lightning-record-edit-form');

        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {})); // Form fisnished loading
        await flushPromises();

        expect(element.loading).toEqual(false); // Still loading
        expect(element.shadowRoot).toHaveChildElement('lightning-record-edit-form');
    });

    test('Loads status and field set based on case record type AND form only shown once they are ready', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        document.body.appendChild(element);
        await flushPromises();

        // Record done loading
        expect(getRecord.getLastConfig()).toMatchObject({
            recordId: '5005900000BNavNAAT',
            fields: [STATUS_FIELD, IS_CLOSED_FIELD, RECORD_TYPE_ID_FIELD, RECORD_TYPE_NAME_FIELD],
        });
        getRecord.emit(caseRecordMock);
        await flushPromises();

        // But form is not ready yet
        expect(element.shadowRoot).not.toHaveChildElement('lightning-record-edit-form');

        // Requested field set and status options
        expect(getFieldsFromFieldSet.getLastConfig()).toMatchObject({
            objectName: CASE_OBJ.objectApiName,
            fieldSetName: `CQC_RT_${caseRecordMock.fields.RecordType.value.fields.DeveloperName.value}`,
        });
        expect(getPicklistValues.getLastConfig()).toMatchObject({
            recordTypeId: caseRecordMock.fields.RecordTypeId.value,
            fieldApiName: STATUS_FIELD,
        });

        getPicklistValues.emit(statusOptionsMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);

        await flushPromises();

        // record edit form can now be shown
        expect(element.shadowRoot).toHaveChildElement('lightning-record-edit-form');
    });

    test('Queries for (first) case details', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT', '5005900000BO6k1AAD'];
        document.body.appendChild(element);
        await flushPromises();

        // Queries for the first case record
        expect(getRecord.getLastConfig()).toMatchObject({
            recordId: '5005900000BNavNAAT',
            fields: [STATUS_FIELD, IS_CLOSED_FIELD, RECORD_TYPE_ID_FIELD, RECORD_TYPE_NAME_FIELD],
        });
    });

    test('Uses record type of first case', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT', '5005900000BO6k1AAD'];
        document.body.appendChild(element);
        await flushPromises();

        // Wire requests return for case record and record type info
        getRecord.emit(caseRecordMock);
        await flushPromises();

        // Uses case record type
        expect(getFieldsFromFieldSet.getLastConfig()).toMatchObject({
            objectName: CASE_OBJ.objectApiName,
            fieldSetName: `CQC_RT_${caseRecordMock.fields.RecordType.value.fields.DeveloperName.value}`,
        });
        expect(getPicklistValues.getLastConfig()).toMatchObject({
            recordTypeId: caseRecordMock.fields.RecordTypeId.value,
            fieldApiName: STATUS_FIELD,
        });
    });

    test('Displays fields from fieldset', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        document.body.appendChild(element);
        await flushPromises();

        // Wire requests all complete
        getRecord.emit(caseRecordMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        getPicklistValues.emit(statusOptionsMock);
        await flushPromises();

        const allInputFields = element.shadowRoot.querySelectorAll('lightning-input-field, lightning-combobox');

        // Correct number
        expect(allInputFields).toHaveLength(fieldSetResponseMock.FIELD_LIST.length);
        // And verifies they are in the proper order
        allInputFields.forEach((elem, indx) => {
            expect(elem.dataset).toHaveProperty('name', fieldSetResponseMock?.FIELD_LIST[indx]?.fieldPath);
        });
    });

    test('Gets (closed) status picklist options', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        document.body.appendChild(element);
        await flushPromises();

        // Wires complete
        getRecord.emit(caseRecordMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        getPicklistValues.emit(statusOptionsMock);
        await flushPromises();

        const closedStatuses = statusOptionsMock.values.filter((v) => v?.attributes?.closed);

        // Populates combobox with options
        expect(element.caseStatusOptions).toHaveLength(closedStatuses.length);
        for (let closedOpt of closedStatuses) {
            expect(element.caseStatusOptions).toContainEqual({
                label: closedOpt.label,
                value: closedOpt.value,
            });
        }
    });

    test('ready event raised once form is loaded', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        const readyHandler = jest.fn();
        element.addEventListener('ready', readyHandler);
        document.body.appendChild(element);
        await flushPromises();

        // Wires are all ready
        getRecord.emit(caseRecordMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        getPicklistValues.emit(statusOptionsMock);
        await flushPromises();

        // Finally read now that field set is loaded
        expect(element.shadowRoot.querySelector('lightning-record-edit-form')).toBeTruthy();

        // The ready handler has not been called yet
        expect(readyHandler).toHaveBeenCalledTimes(0);

        // And edit form is done loading
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {}));

        // The ready handler has now called
        expect(readyHandler).toHaveBeenCalledTimes(1);
    });

    test('Prepopulates with status IF status is closed', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        await flushPromises();

        // Wires are all ready
        getRecord.emit(caseRecordMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        getPicklistValues.emit(statusOptionsMock);
        await flushPromises();

        // Selects the current CLOSED status
        expect(element.currentStatus).toEqual(caseRecordMock.fields.Status.value);
    });

    test('Does NOT prepopulates with status if status is NOT closed', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        await flushPromises();

        // Wires are all ready
        getRecord.emit(caseRecordNotClosedMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        getPicklistValues.emit(statusOptionsMock);
        await flushPromises();

        // Selects the current CLOSED status
        expect(element.currentStatus).toEqual(undefined);
    });

    test('Form errors are shown', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        document.body.appendChild(element);
        await flushPromises();

        // Wire requests return
        getRecord.emit(caseRecordMock);
        getPicklistValues.emit(statusOptionsMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        await flushPromises();
        // And edit form is done loading
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {}));
        await flushPromises();

        // Attempt to submit
        updateRecords.mockResolvedValue(updateRecordsFailureMock);
        element.commit();
        await flushPromises(); // finished committing

        // Get correct error message
        let errorMsg = document.createElement('p');
        errorMsg.innerHTML = updateRecordsFailureMock.errorMessage;
        errorMsg = errorMsg.textContent;

        // Error is shown at top of form
        expect(element.shadowRoot.querySelector('div[role="alert"]')).toBeTruthy();
        expect(element.shadowRoot.querySelector('div[role="alert"]').textContent).toEqual(errorMsg);
    });

    test('Form errors hidden after success', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        document.body.appendChild(element);
        await flushPromises();

        // Wire requests return
        getRecord.emit(caseRecordMock);
        getPicklistValues.emit(statusOptionsMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        await flushPromises();
        // And edit form is done loading
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {}));
        await flushPromises();

        // Attempt to submit
        updateRecords.mockResolvedValue(updateRecordsFailureMock);
        element.commit();
        await flushPromises(); // finished committing

        // Error is shown at top of form
        expect(element.shadowRoot.querySelector('div[role="alert"]')).toBeTruthy();

        // Attempt to submit
        updateRecords.mockResolvedValue(updateRecordsSuccessMock); // Changes form to respond with success
        element.commit();
        await flushPromises(); // finished committing

        // Error removed from top of form
        expect(element.shadowRoot.querySelector('div[role="alert"]')).toBeFalsy();
    });

    test('Status events, happy path', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        const statusHandler = jest.fn();
        element.addEventListener('status', statusHandler);
        document.body.appendChild(element);

        // Wire requests return
        getRecord.emit(caseRecordMock);
        getPicklistValues.emit(statusOptionsMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        await flushPromises();
        // And edit form is done loading
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {}));
        await flushPromises();

        // Attempt to submit
        updateRecords.mockResolvedValue(updateRecordsSuccessMock);
        element.commit();

        // Raised a "submitting" status event
        expect(statusHandler).toHaveBeenCalledTimes(1);
        expect(statusHandler.mock.lastCall[0]).toMatchObject({detail: {type: 'submitting'}});

        await flushPromises(); // finished submitting

        // Raised the success stauts event
        expect(statusHandler).toHaveBeenCalledTimes(2);
        expect(statusHandler.mock.lastCall[0]).toMatchObject({detail: {type: 'success'}});
    });

    test('Status events, form error path', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        const statusHandler = jest.fn();
        element.addEventListener('status', statusHandler);
        document.body.appendChild(element);

        // Wire requests return
        getRecord.emit(caseRecordMock);
        getPicklistValues.emit(statusOptionsMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        await flushPromises();
        // And edit form is done loading
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {}));
        await flushPromises();

        // Attempt to submit
        updateRecords.mockResolvedValue(updateRecordsFailureMock);
        element.commit();

        // Raised a "submitting" status event
        expect(statusHandler).toHaveBeenCalledTimes(1);
        expect(statusHandler.mock.lastCall[0]).toMatchObject({detail: {type: 'submitting'}});

        await flushPromises(); // finished submitting

        // Raised the success stauts event
        expect(statusHandler).toHaveBeenCalledTimes(2);
        expect(statusHandler.mock.lastCall[0]).toMatchObject({detail: {type: 'form_error'}});
    });

    test('Error from getRecord wire', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        const errorHandler = jest.fn();
        element.addEventListener('error', errorHandler);
        document.body.appendChild(element);

        // Wire requests return
        const errorStr = 'Apex methods that are to be cached must be marked as @AuraEnabled(cacheable=true)';
        getRecord.error({message: errorStr});
        await flushPromises();

        // Error event was raised
        expect(element.hasError).toEqual(true);
        expect(element.errorMessage).toEqual(errorStr);
        expect(errorHandler).toHaveBeenCalledTimes(1);
        expect(errorHandler.mock.lastCall[0]).toMatchObject({detail: {errors: [errorStr]}});
    });

    test('Error from getPicklistValues wire', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        const errorHandler = jest.fn();
        element.addEventListener('error', errorHandler);
        document.body.appendChild(element);

        // Wire requests return
        const errorStr = 'Apex methods that are to be cached must be marked as @AuraEnabled(cacheable=true)';
        getPicklistValues.error({message: errorStr});
        await flushPromises();

        // Error event was raised
        expect(element.hasError).toEqual(true);
        expect(element.errorMessage).toEqual(errorStr);
        expect(errorHandler).toHaveBeenCalledTimes(1);
        expect(errorHandler.mock.lastCall[0]).toMatchObject({detail: {errors: [errorStr]}});
    });

    test('Error from getFieldsFromFieldSet wire', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        const errorHandler = jest.fn();
        element.addEventListener('error', errorHandler);
        document.body.appendChild(element);

        // Wire requests return
        const errorStr = 'Apex methods that are to be cached must be marked as @AuraEnabled(cacheable=true)';
        getFieldsFromFieldSet.error({message: errorStr});
        await flushPromises();

        // Error event was raised
        expect(element.hasError).toEqual(true);
        expect(element.errorMessage).toEqual(errorStr);
        expect(errorHandler).toHaveBeenCalledTimes(1);
        expect(errorHandler.mock.lastCall[0]).toMatchObject({detail: {errors: [errorStr]}});
    });

    test('Error from submitting form (non DML error)', async () => {
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseViewTest,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        const errorHandler = jest.fn();
        element.addEventListener('error', errorHandler);
        document.body.appendChild(element);

        // Wire requests return
        getRecord.emit(caseRecordMock);
        getPicklistValues.emit(statusOptionsMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        await flushPromises();
        // And edit form is done loading
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {}));
        await flushPromises();

        // Attempt to submit
        updateRecords.mockRejectedValue(updateRecordsErrorMock);
        element.commit();
        await flushPromises();
        await flushPromises();

        // Error event was raised
        expect(element.hasError).toEqual(true);
        expect(element.errorMessage).toEqual(updateRecordsErrorMock.body.message);
        expect(errorHandler).toHaveBeenCalledTimes(1);
        expect(errorHandler.mock.lastCall[0]).toMatchObject({detail: {errors: [updateRecordsErrorMock.body.message]}});
    });
});
