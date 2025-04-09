/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {AdvisorPortalTest} from 'c/advisorPortalA';
import {createRecord, updateRecord, deleteRecord} from 'lightning/uiRecordApi';
import {graphql} from 'lightning/uiGraphQLApi';
import checkIfCanShareFilterSets from '@salesforce/apex/FilterSetController.checkIfCanShare';
import FilterSetShareModal from 'c/filterSetShareModal';
import FilterSetRemoveModal from 'c/filterSetRemoveModal';
import {flushPromises} from 'c/helperTestFunctions';

jest.mock(
    '@salesforce/apex/FilterSetController.checkIfCanShare',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);
FilterSetShareModal.open = jest.fn(() => {
    return Promise.resolve();
});
FilterSetRemoveModal.open = jest.fn(() => {
    return Promise.resolve();
});

const filterSetPrivateMock = require('./data/appliedFilterSetPrivate.json');
const filterSetSharedByMeMock = require('./data/appliedFilterSetSharedByMe.json');
const filterSetSharedWithMeMock = require('./data/appliedFilterSetSharedWithMe.json');
const filterSetPinnedMock = require('./data/appliedFilterSetPinned.json');
const filterSetNotPinnedMock = require('./data/appliedFilterSetNotPinned.json');

describe('c-advisor-portal View filter set', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    test('Queries details about filter set', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);

        await flushPromises(); // wait for wire to enqueue

        expect(graphql.getLastConfig()).toMatchObject({variables: {filterSetId: 'FS-1'}});
    });

    test('Shows details about filter set - PRIVATE', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);

        graphql.emit(filterSetPrivateMock);
        checkIfCanShareFilterSets.emit(true);

        // Await render
        await flushPromises();

        expect(element.filterSetSharedType).toEqual('Private');
        expect(element.filterSetName).toEqual('Freshmen');

        // Shows as pinned
        expect(
            [...element.shadowRoot.querySelectorAll('lightning-button-icon-stateful')].filter(
                (elem) => elem.iconName === 'utility:pin'
            )[0].selected
        ).toEqual(true);

        // Can share
        expect(
            [...element.shadowRoot.querySelectorAll('lightning-button-icon')].filter(
                (elem) => elem.iconName === 'utility:share'
            )[0]
        ).toBeTruthy();

        // Can change name
        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-text-editable')].filter(
                (elem) => elem.name === 'filterSetName'
            )[0].hideEdit
        ).toEqual(false);
    });

    test('Shows details about filter set - SHARED BY ME', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);

        graphql.emit(filterSetSharedByMeMock);
        checkIfCanShareFilterSets.emit(true);

        // Await render
        await flushPromises();

        expect(element.filterSetSharedType).toEqual('Shared by me');
        expect(element.filterSetName).toEqual('Freshmen');

        // Shows as pinned
        expect(
            [...element.shadowRoot.querySelectorAll('lightning-button-icon-stateful')].filter(
                (elem) => elem.iconName === 'utility:pin'
            )[0].selected
        ).toEqual(true);

        // Can share
        expect(
            [...element.shadowRoot.querySelectorAll('lightning-button-icon')].filter(
                (elem) => elem.iconName === 'utility:share'
            )[0]
        ).toBeTruthy();

        // Can change name
        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-text-editable')].filter(
                (elem) => elem.name === 'filterSetName'
            )[0].hideEdit
        ).toEqual(false);
    });

    test('Shows details about filter set - SHARED WITH ME', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);

        graphql.emit(filterSetSharedWithMeMock);
        checkIfCanShareFilterSets.emit(true);

        // Await render
        await flushPromises();

        expect(element.filterSetSharedType).toEqual('Shared with me');
        expect(element.filterSetName).toEqual('Freshmen');

        // Shows as pinned
        expect(
            [...element.shadowRoot.querySelectorAll('lightning-button-icon-stateful')].filter(
                (elem) => elem.iconName === 'utility:pin'
            )[0].selected
        ).toEqual(true);

        // Cannot share
        expect(
            [...element.shadowRoot.querySelectorAll('lightning-button-icon')].filter(
                (elem) => elem.iconName === 'utility:share'
            )[0]
        ).toBeFalsy();

        // Cannot change name
        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-text-editable')].filter(
                (elem) => elem.name === 'filterSetName'
            )[0].hideEdit
        ).toEqual(true);
    });

    test('Unpinning a filter set', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);

        graphql.emit(filterSetPinnedMock);
        checkIfCanShareFilterSets.emit(true);

        // Await render
        await flushPromises();

        // Shows as pinned
        expect(
            [...element.shadowRoot.querySelectorAll('lightning-button-icon-stateful')].filter(
                (elem) => elem.iconName === 'utility:pin'
            )[0].selected
        ).toEqual(true);

        // Press unpin button
        [...element.shadowRoot.querySelectorAll('lightning-button-icon-stateful')]
            .filter((elem) => elem.iconName === 'utility:pin')[0]
            .click();

        // Calls updateRecord
        expect(updateRecord).toHaveBeenCalledWith({
            fields: {
                Id: 'FSUA-1',
                Pinned__c: false,
            },
        });
    });

    test('Pinning a filter set', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);

        graphql.emit(filterSetNotPinnedMock);
        checkIfCanShareFilterSets.emit(true);

        // Await render
        await flushPromises();

        // Shows as unpinned
        expect(
            [...element.shadowRoot.querySelectorAll('lightning-button-icon-stateful')].filter(
                (elem) => elem.iconName === 'utility:pin'
            )[0].selected
        ).toEqual(false);

        // Press pin button
        [...element.shadowRoot.querySelectorAll('lightning-button-icon-stateful')]
            .filter((elem) => elem.iconName === 'utility:pin')[0]
            .click();

        // Calls updateRecord
        expect(updateRecord).toHaveBeenCalledWith({
            fields: {
                Id: 'FSUA-1',
                Pinned__c: true,
            },
        });
    });

    test('Removing a filter set', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);

        graphql.emit(filterSetPrivateMock);
        checkIfCanShareFilterSets.emit(true);

        // Await render
        await flushPromises();

        // Modal responds with full delete
        FilterSetRemoveModal.open.mockImplementationOnce(() => {
            return Promise.resolve({delete: true});
        });

        // Press delete button
        [...element.shadowRoot.querySelectorAll('lightning-button-icon')]
            .filter((elem) => elem.iconName === 'utility:delete')[0]
            .click();
        // Opens delete modal
        expect(FilterSetRemoveModal.open).toHaveBeenCalled();

        // Await modal response
        await flushPromises();

        // Actually does delete
        expect(deleteRecord).toHaveBeenCalledWith('FS-1');
    });

    test('Sharing a filter set', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);

        graphql.emit(filterSetPrivateMock);
        checkIfCanShareFilterSets.emit(true);

        // Await render
        await flushPromises();

        // Modal responds with new users to share with
        FilterSetShareModal.open.mockImplementationOnce(() => {
            return Promise.resolve({userIds: ['NEW-USER-1', 'NEW-USER-2', 'NEW-USER-3']});
        });

        // Press share button
        [...element.shadowRoot.querySelectorAll('lightning-button-icon')]
            .filter((elem) => elem.iconName === 'utility:share')[0]
            .click();
        // Opens share modal
        expect(FilterSetShareModal.open).toHaveBeenCalled();

        // Await modal response
        await flushPromises();

        // Actually does creation
        expect(createRecord).toHaveBeenCalledWith({
            apiName: 'Filter_Set_User_Association__c',
            fields: {
                User__c: 'NEW-USER-1',
                Filter_Set__c: 'FS-1',
            },
        });
        expect(createRecord).toHaveBeenCalledWith({
            apiName: 'Filter_Set_User_Association__c',
            fields: {
                User__c: 'NEW-USER-2',
                Filter_Set__c: 'FS-1',
            },
        });
        expect(createRecord).toHaveBeenCalledWith({
            apiName: 'Filter_Set_User_Association__c',
            fields: {
                User__c: 'NEW-USER-3',
                Filter_Set__c: 'FS-1',
            },
        });
    });

    test('Renaming a filter set', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);

        graphql.emit(filterSetPrivateMock);
        checkIfCanShareFilterSets.emit(true);

        // Await render
        await flushPromises();

        // Press delete button
        [...element.shadowRoot.querySelectorAll('c-lightning-text-editable')]
            .filter((elem) => elem.name === 'filterSetName')[0]
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'New Name'}}));

        // Calls updateRecord
        expect(updateRecord).toHaveBeenCalledWith({
            fields: {
                Id: 'FS-1',
                Name: 'New Name',
            },
        });
    });
});
