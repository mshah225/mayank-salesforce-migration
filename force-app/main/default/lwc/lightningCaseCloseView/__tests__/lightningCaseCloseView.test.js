/* eslint-disable no-undef */
import {createElement} from 'lwc';
import LightningCaseCloseView from 'c/lightningCaseCloseView';
import {getRecord} from 'lightning/uiRecordApi';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import {graphql} from 'lightning/uiGraphQLApi';
import getFieldsFromFieldSet from '@salesforce/apex/FieldSetHelper.getFieldsFromFieldSet';
import closeCasesList from '@salesforce/apex/LightningCaseCloseController.closeCasesList';
import {flushPromises} from 'c/helperFunctions';

import CASE_NUMBER_FIELD from '@salesforce/schema/Case.CaseNumber';
import RECORD_TYPE_ID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import IS_CLOSED_FIELD from '@salesforce/schema/Case.IsClosed';

// Mock realistic data
const caseRecordMock = require('./data/caseRecord.json');
const fieldSetResponseMock = require('./data/fieldSetResponse.json');
const recordTypeInfoMock = require('./data/recordTypeInfo.json');
const statusOptionsMock = require('./data/statusOptions.json');

jest.mock(
    '@salesforce/apex/FieldSetHelper.getFieldsFromFieldSet',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/LightningCaseCloseController.closeCasesList',
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

    test('Loading until ready', async () => {
        // Arrange
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseView,
        });

        // Act
        document.body.appendChild(element);

        // Loading icon is shown initially
        expect(element.shadowRoot.querySelector('lightning-spinner')).toBeTruthy();

        // Finished loading fieldset
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        await flushPromises();

        // Loading icon is still shown
        expect(element.shadowRoot.querySelector('lightning-spinner')).toBeTruthy();

        // Edit form finished loading
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {}));
        await flushPromises();

        // Loading icon is hidden after loading
        expect(element.shadowRoot.querySelector('lightning-spinner')).toBeFalsy();
    });

    test('Queries for (first) case details', async () => {
        // Arrange
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseView,
        });
        element.caseIds = ['5005900000BNavNAAT', '5005900000BO6k1AAD'];

        // Act
        document.body.appendChild(element);
        await flushPromises();

        // Queries for the first case record
        expect(getRecord.getLastConfig()).toEqual({
            recordId: '5005900000BNavNAAT',
            fields: [STATUS_FIELD, IS_CLOSED_FIELD, RECORD_TYPE_ID_FIELD, CASE_NUMBER_FIELD],
        });
    });

    test('Uses record type of first case', async () => {
        // Arrange
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseView,
        });
        element.caseIds = ['5005900000BNavNAAT'];

        // Act
        document.body.appendChild(element);

        // Wire requests return for case record and record type info
        getRecord.emit(caseRecordMock);
        graphql.emit(recordTypeInfoMock);
        await flushPromises();

        // Uses case record type
        expect(getFieldsFromFieldSet.getLastConfig()).toEqual({
            fieldSetName: 'CQC_RT_ASU_Advisor_Outreach',
        });
    });

    test('Uses override record type', async () => {
        // Arrange
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseView,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        element.recordTypeIdOverride = '0126T000001QHKsQAO'; // GRAD Advisor

        // Act
        document.body.appendChild(element);

        // Wire requests return for record type info
        graphql.emit(recordTypeInfoMock);
        await flushPromises();

        // Uses override record type
        expect(getFieldsFromFieldSet.getLastConfig()).toEqual({
            fieldSetName: 'CQC_RT_ASU_Graduate_Advisor_Portal',
            objectName: 'Case',
        });
    });

    test('Displays fields from fieldset', async () => {
        // Arrange
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseView,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        element.recordTypeIdOverride = '0126T000001QHKsQAO';

        // Act
        document.body.appendChild(element);

        // Wire requests return for record type info and fieldset info
        graphql.emit(recordTypeInfoMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        await flushPromises();

        const allInputFields = element.shadowRoot.querySelectorAll('lightning-input-field');

        // Correct number
        expect(allInputFields).toHaveLength(7);
        // And verifies they are in the proper order
        allInputFields.forEach((elem, indx) => {
            expect(elem.dataset).toHaveProperty('name', fieldSetResponseMock?.FIELD_LIST[indx]?.fieldPath);
        });
    });

    test('Gets (closed) status picklist options', async () => {
        // Arrange
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseView,
        });
        element.caseIds = ['5005900000BNavNAAT'];

        // Act
        document.body.appendChild(element);

        // Wire requests return for case record and record type info
        getRecord.emit(caseRecordMock);
        graphql.emit(recordTypeInfoMock);
        await flushPromises();

        // Queries for case status picklist options
        expect(getPicklistValues.getLastConfig()).toEqual({
            recordTypeId: '012d00000021xGKAAY',
            fieldApiName: STATUS_FIELD,
        });

        // Promise returns
        getPicklistValues.emit(statusOptionsMock);
        await flushPromises();

        // Populates combobox with options
        expect(element.statusOptions).toHaveLength(4);
        expect(element.statusOptions).toContainEqual({
            label: 'Closed: Customer Self-Resolved',
            value: 'Closed: Customer Self-Resolved',
        });
        expect(element.statusOptions).toContainEqual({
            label: 'Conferred with Student by Email',
            value: 'Conferred with Student by Email',
        });
        expect(element.statusOptions).toContainEqual({
            label: 'Conferred with Student by Phone',
            value: 'Conferred with Student by Phone',
        });
        expect(element.statusOptions).toContainEqual({
            label: 'In Person Meeting',
            value: 'In Person Meeting',
        });
    });

    test('Form errors are shown', async () => {
        // Arrange
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseView,
        });
        element.caseIds = ['5005900000BNavNAAT'];

        // Act
        document.body.appendChild(element);

        // Wire requests return
        getRecord.emit(caseRecordMock);
        graphql.emit(recordTypeInfoMock);
        getPicklistValues.emit(statusOptionsMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        await flushPromises();

        // And edit form is done loading
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {}));
        await flushPromises();

        // Error after attemping to submit form
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(
            new CustomEvent('error', {
                detail: {
                    message: 'An error occurred while trying to update the record. Please try again.',
                    detail: '',
                },
            })
        );
        await flushPromises();

        // Error is shown at top of form
        expect(element.shadowRoot.querySelector('div[role="alert"]')).toBeTruthy();
        expect(element.shadowRoot.querySelector('div[role="alert"] h2').textContent).toEqual(
            'An error occurred while trying to update the record. Please try again.'
        );
    });

    test('Form errors hidden after success', async () => {
        // Arrange
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseView,
        });
        element.caseIds = ['5005900000BNavNAAT'];

        // Act
        document.body.appendChild(element);

        // Wire requests return
        getRecord.emit(caseRecordMock);
        graphql.emit(recordTypeInfoMock);
        getPicklistValues.emit(statusOptionsMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        await flushPromises();

        // And edit form done loading
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {}));
        await flushPromises();

        // Error after attemping to submit form
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(
            new CustomEvent('error', {
                detail: {
                    message: 'An error occurred while trying to update the record. Please try again.',
                    detail: '',
                },
            })
        );
        await flushPromises();

        // Error is shown at top of form
        expect(element.shadowRoot.querySelector('div[role="alert"]')).toBeTruthy();

        // Successfully submits form
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(
            new CustomEvent('success', {
                detail: {},
            })
        );
        await flushPromises();

        // Error is shown at top of form
        expect(element.shadowRoot.querySelector('div[role="alert"]')).toBeFalsy();
    });

    test('Multi-case close', async () => {
        // Arrange
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseView,
        });
        element.caseIds = ['5005900000BNavNAAT', '5005900000BNavO', '5005900000BNavP', '5005900000BNavQ'];
        element.massOperation = true;

        // Act
        document.body.appendChild(element);

        // Wire requests return
        getRecord.emit(caseRecordMock);
        graphql.emit(recordTypeInfoMock);
        getPicklistValues.emit(statusOptionsMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        await flushPromises();

        // And edit form done loading
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {}));
        await flushPromises();

        // Attempt to submit form
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(
            new CustomEvent('submit', {
                detail: {
                    fields: {
                        Recommended_Actions_Other__c: 'Visting family',
                        Recommended_Actions__c: 'other',
                        Status: 'Conferred with Student by Phone',
                    },
                },
            })
        );
        await flushPromises();

        // And the close call will return a success
        closeCasesList.mockResolvedValue(null);
        await flushPromises();

        // Successfully submits form
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(
            new CustomEvent('success', {
                detail: {},
            })
        );
        await flushPromises();

        // Calls mass close for all the other cases
        expect(closeCasesList).toHaveBeenCalledWith({
            cases: [
                {
                    Id: '5005900000BNavO',
                    Recommended_Actions_Other__c: 'Visting family',
                    Recommended_Actions__c: 'other',
                    Status: 'Conferred with Student by Phone',
                },
                {
                    Id: '5005900000BNavP',
                    Recommended_Actions_Other__c: 'Visting family',
                    Recommended_Actions__c: 'other',
                    Status: 'Conferred with Student by Phone',
                },
                {
                    Id: '5005900000BNavQ',
                    Recommended_Actions_Other__c: 'Visting family',
                    Recommended_Actions__c: 'other',
                    Status: 'Conferred with Student by Phone',
                },
            ],
        });
    });

    test('Status events on success, single mode', async () => {
        // Arrange
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseView,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        element.statusEvents = true;

        const statusHandler = jest.fn();
        element.addEventListener('status', statusHandler);

        // Act
        document.body.appendChild(element);

        // Wire requests return
        getRecord.emit(caseRecordMock);
        graphql.emit(recordTypeInfoMock);
        getPicklistValues.emit(statusOptionsMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        await flushPromises();

        // And edit form done loading
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {}));
        await flushPromises();

        // Successfully submits form
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(
            new CustomEvent('success', {
                detail: {},
            })
        );
        await flushPromises();

        // Raised the success stauts event
        expect(statusHandler).toHaveBeenCalledTimes(1);
        expect(statusHandler.mock.lastCall[0].detail.type).toEqual('success');
    });

    test('Status events on success, multi-mode but single record', async () => {
        // Arrange
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseView,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        element.statusEvents = true;
        element.massOperation = true;

        const statusHandler = jest.fn();
        element.addEventListener('status', statusHandler);

        // Act
        document.body.appendChild(element);

        // Wire requests return
        getRecord.emit(caseRecordMock);
        graphql.emit(recordTypeInfoMock);
        getPicklistValues.emit(statusOptionsMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        await flushPromises();

        // And edit form done loading
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {}));
        await flushPromises();

        // Successfully submits form
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(
            new CustomEvent('success', {
                detail: {},
            })
        );
        await flushPromises();

        // Raised the success stauts event
        expect(statusHandler).toHaveBeenCalledTimes(1);
        expect(statusHandler.mock.lastCall[0].detail.type).toEqual('success');
    });

    test('Status events on success, multi-mode with multiple records', async () => {
        // Arrange
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseView,
        });
        element.caseIds = ['5005900000BNavNAAT', '5005900000BNavO'];
        element.statusEvents = true;
        element.massOperation = true;

        const statusHandler = jest.fn();
        element.addEventListener('status', statusHandler);

        // Act
        document.body.appendChild(element);

        // Wire requests return
        getRecord.emit(caseRecordMock);
        graphql.emit(recordTypeInfoMock);
        getPicklistValues.emit(statusOptionsMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        await flushPromises();

        // And edit form done loading
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {}));
        await flushPromises();

        // And the close call will return a success
        closeCasesList.mockResolvedValue(null);
        await flushPromises();

        // Successfully submits form
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(
            new CustomEvent('success', {
                detail: {},
            })
        );
        await flushPromises();

        // Raised the success stauts event
        expect(statusHandler).toHaveBeenCalledTimes(1);
        expect(statusHandler.mock.lastCall[0].detail.type).toEqual('success');
    });

    test('Status events on submit (to indicate loading)', async () => {
        // Arrange
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseView,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        element.statusEvents = true;

        const statusHandler = jest.fn();
        element.addEventListener('status', statusHandler);

        // Act
        document.body.appendChild(element);

        // Wire requests return
        getRecord.emit(caseRecordMock);
        graphql.emit(recordTypeInfoMock);
        getPicklistValues.emit(statusOptionsMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        await flushPromises();

        // And edit form done loading
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {}));
        await flushPromises();

        // Submit button is pressed
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(
            new CustomEvent('submit', {
                detail: {
                    fields: {
                        Recommended_Actions_Other__c: 'Visting family',
                        Recommended_Actions__c: 'other',
                        Status: 'Conferred with Student by Phone',
                    },
                },
            })
        );
        await flushPromises();

        // Raised the success stauts event
        expect(statusHandler).toHaveBeenCalledTimes(1);
        expect(statusHandler.mock.lastCall[0].detail.type).toEqual('submitting');
    });

    test('Status events on error', async () => {
        // Arrange
        const element = createElement('c-lightning-case-close-view', {
            is: LightningCaseCloseView,
        });
        element.caseIds = ['5005900000BNavNAAT'];
        element.statusEvents = true;

        const statusHandler = jest.fn();
        element.addEventListener('status', statusHandler);

        // Act
        document.body.appendChild(element);

        // Wire requests return
        getRecord.emit(caseRecordMock);
        graphql.emit(recordTypeInfoMock);
        getPicklistValues.emit(statusOptionsMock);
        getFieldsFromFieldSet.emit(fieldSetResponseMock);
        await flushPromises();

        // And edit form done loading
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(new CustomEvent('load', {}));
        await flushPromises();

        // Error after attemping to submit form
        element.shadowRoot.querySelector('lightning-record-edit-form').dispatchEvent(
            new CustomEvent('error', {
                detail: {
                    message: 'An error occurred while trying to update the record. Please try again.',
                    detail: '',
                },
            })
        );
        await flushPromises();

        // Raised the success stauts event
        expect(statusHandler).toHaveBeenCalledTimes(1);
        expect(statusHandler.mock.lastCall[0].detail.type).toEqual('form_error');
    });
});
