/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {AdvisorPortalTest} from 'c/advisorPortalA';
import {getRecord, createRecord, updateRecord} from 'lightning/uiRecordApi';
import getUsersAndPods from '@salesforce/apex/AdvisorPortalFilterSectionController.getUsersAndPods';
import {graphql} from 'lightning/uiGraphQLApi';
import LightningConfirm from 'lightning/confirm';
import ToastContainer from 'lightning/toastContainer';
import {flushPromises} from 'c/helperTestFunctions';

jest.mock(
    '@salesforce/apex/AdvisorPortalFilterSectionController.getUsersAndPods',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);

const filterSetPrivateMock = require('./data/appliedFilterSetPrivate.json');
const filterSetSharedByMeMock = require('./data/appliedFilterSetSharedByMe.json');
const filterSetSharedWithMeMock = require('./data/appliedFilterSetSharedWithMe.json');

describe('c-advisor-portal Save filter set', () => {
    // Function to emit values that are consistent across all tests
    // you cannot do this in beforeEach since the emit must happen after the element has
    // been created and added to the document
    const emitCommon = () => {
        getUsersAndPods.emit([
            {label: 'Tommy Nordman', value: 'USER-1'},
            {label: '--My PODs--', value: 'HEADER-XX1'},
            {label: 'Cat Owners', value: 'POD-1'},
            {label: 'Employee', value: 'POD-2'},
        ]);
    };

    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    test('Overwrite button disabled', () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        // Button disabled
        expect(
            [...element.shadowRoot.querySelectorAll('lightning-button')].filter((v) => v.label === 'Overwrite')[0]
                .disabled
        ).toEqual(true);
    });

    test('Button enabled after applying filter set and changing fields', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);
        graphql.emit(filterSetPrivateMock);

        // Await render
        await flushPromises();

        // Change ownerIds
        element.shadowRoot.querySelector('c-advisor-portal-user-select').dispatchEvent(
            new CustomEvent('changeusers', {
                detail: {
                    value: 'USER-1;USER-2;POD-3;POD-4',
                },
            })
        );
        await flushPromises(); // Await rerender

        // Button enabled
        expect(
            [...element.shadowRoot.querySelectorAll('lightning-button')].filter((v) => v.label === 'Overwrite')[0]
                .disabled
        ).toEqual(false);
    });

    test('Overwrite button opens confirmation modal', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);
        graphql.emit(filterSetPrivateMock);
        emitCommon();
        await flushPromises(); // Await render
        element.shadowRoot.querySelector('c-advisor-portal-user-select').dispatchEvent(
            new CustomEvent('changeusers', {
                detail: {
                    value: 'USER-1;POD-2',
                },
            })
        ); // Change ownerIds
        await flushPromises(); // Await rerender

        // Press button
        [...element.shadowRoot.querySelectorAll('lightning-button')].filter((v) => v.label === 'Overwrite')[0].click();

        // Confirmation opened
        expect(LightningConfirm.open).toHaveBeenCalled();
    });

    test('Prompt success updates filter set', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);
        graphql.emit(filterSetPrivateMock);
        emitCommon();
        await flushPromises(); // Await render
        element.shadowRoot.querySelector('c-advisor-portal-user-select').dispatchEvent(
            new CustomEvent('changeusers', {
                detail: {
                    value: 'USER-1;POD-2',
                },
            })
        ); // Change ownerIds
        await flushPromises(); // Await rerender

        // Mock responding confirmation
        LightningConfirm.open.mockResolvedValueOnce(true);

        // Press button
        [...element.shadowRoot.querySelectorAll('lightning-button')].filter((v) => v.label === 'Overwrite')[0].click();
        await flushPromises(); // Await confirmation to complete

        // Called to create new filter set
        expect(updateRecord).toHaveBeenCalledWith({
            fields: {
                Id: 'FS-1',
                Value__c: '{"caseTypeState":"ProactiveCasesState","ownerIds":"USER-1;POD-2"}',
            },
        });
    });

    test('Cancelled prompt prevents updating filter set', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);
        graphql.emit(filterSetPrivateMock);
        emitCommon();
        await flushPromises(); // Await render
        element.shadowRoot.querySelector('c-advisor-portal-user-select').dispatchEvent(
            new CustomEvent('changeusers', {
                detail: {
                    value: 'USER-1;POD-2',
                },
            })
        ); // Change ownerIds
        await flushPromises(); // Await rerender

        // Mock responding confirmation
        LightningConfirm.open.mockResolvedValueOnce(false);

        // Press button
        [...element.shadowRoot.querySelectorAll('lightning-button')].filter((v) => v.label === 'Overwrite')[0].click();
        await flushPromises(); // Await confirmation to complete

        // Called to create new filter set
        expect(updateRecord).not.toHaveBeenCalledWith({
            fields: {
                Id: 'FS-1',
                Value__c: '{"caseTypeState":"ProactiveCasesState","ownerIds":"USER-1;POD-2"}',
            },
        });
    });

    test('Shows success toast', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);
        const toastHandler = jest.fn((evnt) => {
            expect(evnt.detail).toMatchObject({
                title: 'Filter set has been updated',
                variant: 'success',
            });
        });
        element.addEventListener('lightning__showtoast', toastHandler);
        graphql.emit(filterSetPrivateMock);
        emitCommon();
        await flushPromises(); // Await render
        element.shadowRoot.querySelector('c-advisor-portal-user-select').dispatchEvent(
            new CustomEvent('changeusers', {
                detail: {
                    value: 'USER-1;POD-2',
                },
            })
        ); // Change ownerIds
        await flushPromises(); // Await rerender

        // Mock responding confirmation
        LightningConfirm.open.mockResolvedValueOnce(true);

        // Press button
        [...element.shadowRoot.querySelectorAll('lightning-button')].filter((v) => v.label === 'Overwrite')[0].click();
        await flushPromises(); // Await confirmation modal
        await flushPromises(); // Await successful update

        // Showed success toast
        expect(toastHandler).toHaveBeenCalled();
    });

    test('Error while saving filter', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);
        const toastHandler = jest.fn((evnt) => {
            expect(evnt.detail).toMatchObject({
                title: 'Unable to overwrite filter set',
                message: 'Duplicate name',
                variant: 'error',
            });
        });
        element.addEventListener('lightning__showtoast', toastHandler);
        graphql.emit(filterSetPrivateMock);
        emitCommon();
        await flushPromises(); // Await render
        element.shadowRoot.querySelector('c-advisor-portal-user-select').dispatchEvent(
            new CustomEvent('changeusers', {
                detail: {
                    value: 'USER-1;POD-2',
                },
            })
        ); // Change ownerIds
        await flushPromises(); // Await rerender

        // Mock responding confirmation
        LightningConfirm.open.mockResolvedValueOnce(true);
        updateRecord.mockRejectedValueOnce('Duplicate name');

        // Press button
        [...element.shadowRoot.querySelectorAll('lightning-button')].filter((v) => v.label === 'Overwrite')[0].click();
        await flushPromises(); // Await confirmation modal
        await flushPromises(); // Await failed update

        // Showed success toast
        expect(toastHandler).toHaveBeenCalled();
    });
});
