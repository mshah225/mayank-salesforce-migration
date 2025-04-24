/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {FilterSetsModalTest} from 'c/filterSetsModal';
import {graphql} from 'lightning/uiGraphQLApi';
import {flushPromises} from 'c/helperTestFunctions';
import Id from '@salesforce/user/Id';
import {createRecord, deleteRecord} from 'lightning/uiRecordApi';
import FilterSetShareModal from 'c/filterSetShareModal';

// Private vs Shared filters
const wirePrivate = require('./data/wire/private.json');
const wireSharedByMe = require('./data/wire/sharedByMe.json');

FilterSetShareModal.open = jest.fn(() => {
    return Promise.resolve();
});

describe('c-filter-sets-modal', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Clear mocks
        jest.clearAllMocks();
    });

    test('Open sharing modal', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        graphql.emit(wirePrivate);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('share', {
                detail: {
                    filterSetId: wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id,
                },
            })
        );

        // Opens confirmation modal
        expect(FilterSetShareModal.open).toHaveBeenCalled();

        await flushPromises(); // Wait for confirmation modal to close successfully
    });

    test('Removes unshared users', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        graphql.emit(wireSharedByMe);

        await flushPromises(); // Wait for page to render

        FilterSetShareModal.open.mockImplementationOnce(() => {
            return Promise.resolve({userIds: []});
        });

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('share', {
                detail: {
                    filterSetId: wireSharedByMe.uiapi.query.Filter_Set__c.edges[0].node.Id,
                },
            })
        );
        await flushPromises(); // Wait for confirmation modal to close successfully and deleteRecord to queue

        expect(deleteRecord).toHaveBeenCalledWith(
            wireSharedByMe.uiapi.query.Filter_Set__c.edges[0].node.Filter_Set_User_Associations__r.edges[1].node.Id
        );
    });

    test('Adds newly shared users', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        graphql.emit(wireSharedByMe);

        await flushPromises(); // Wait for page to render

        FilterSetShareModal.open.mockImplementationOnce(() => {
            return Promise.resolve({userIds: ['USER-1', 'USER-2', 'USER-3']});
        });

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('share', {
                detail: {
                    filterSetId: wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id,
                },
            })
        );
        await flushPromises(); // Wait for confirmation modal to close and createRecord to queue

        expect(createRecord).toHaveBeenCalledWith({
            apiName: 'Filter_Set_User_Association__c',
            fields: {
                User__c: 'USER-1',
                Filter_Set__c: wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id,
            },
        });
        expect(createRecord).toHaveBeenCalledWith({
            apiName: 'Filter_Set_User_Association__c',
            fields: {
                User__c: 'USER-2',
                Filter_Set__c: wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id,
            },
        });
        expect(createRecord).toHaveBeenCalledWith({
            apiName: 'Filter_Set_User_Association__c',
            fields: {
                User__c: 'USER-3',
                Filter_Set__c: wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id,
            },
        });
    });
});
