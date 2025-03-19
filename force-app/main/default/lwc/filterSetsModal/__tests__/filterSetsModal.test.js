/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {FilterSetsModalTest} from 'c/filterSetsModal';
import {graphql} from 'lightning/uiGraphQLApi';
import {flushPromises} from 'c/helperTestFunctions';
import Id from '@salesforce/user/Id';
import {updateRecord} from 'lightning/uiRecordApi';

const wireResponseMock = require('./data/wireResponse.json');
const noFilterSetsWireResponseMock = require('./data/noFilterSetsWireResponse.json');
const expectedPinnedFilters = require('./data/expectedPinnedFiltersList.json');
const expectedUnpinnedFilters = require('./data/expectedUnpinnedFiltersList.json');

describe('c-filter-sets-modal', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Clear mocks
        jest.clearAllMocks();
    });

    test('Queries for users filter sets', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        // Await wire to enqueue
        await flushPromises();

        // GraphQL has undefined variables thus preventing it from running
        expect(graphql.getLastConfig()).toMatchObject({variables: {userId: Id}});
    });

    test('No saved filters', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        graphql.emit(noFilterSetsWireResponseMock);

        expect(element.nonpinnedFilterSets).toMatchObject([]);
        expect(element.numberNonpinned).toEqual(0);
        expect(element.hasNonpinnedFilterSets).toEqual(false);

        expect(element.pinnedFilterSets).toMatchObject([]);
        expect(element.numberPinned).toEqual(0);
    });

    test('Gets all unpinned filters', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        graphql.emit(wireResponseMock);

        expect(element.numberNonpinned).toEqual(expectedUnpinnedFilters.length);
        expect(element.nonpinnedFilterSets).toMatchObject(expectedUnpinnedFilters);
        expect(element.hasNonpinnedFilterSets).toEqual(true);
    });

    test('Gets all pinned filters', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        graphql.emit(wireResponseMock);

        expect(element.pinnedFilterSets).toMatchObject(expectedPinnedFilters);
        expect(element.numberPinned).toEqual(expectedPinnedFilters.length);
    });

    test('Handles pin events', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        graphql.emit(wireResponseMock);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('pin', {
                detail: {
                    filterSetId: wireResponseMock.uiapi.query.Filter_Set__c.edges[0].node.Id,
                    pinned: true,
                },
            })
        );

        // Check updateRecord was called for related filter set user association
        expect(updateRecord).toHaveBeenCalled();
        expect(updateRecord).toHaveBeenCalledWith({
            fields: {
                Id: wireResponseMock.uiapi.query.Filter_Set__c.edges[0].node.Filter_Set_User_Associations__r.edges[0]
                    .node.Id,
                Pinned__c: true,
            },
        });
    });

    test('Handles unpin events', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        graphql.emit(wireResponseMock);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('pin', {
                detail: {
                    filterSetId: wireResponseMock.uiapi.query.Filter_Set__c.edges[0].node.Id,
                    pinned: false,
                },
            })
        );

        // Check updateRecord was called for related filter set user association
        expect(updateRecord).toHaveBeenCalled();
        expect(updateRecord).toHaveBeenCalledWith({
            fields: {
                Id: wireResponseMock.uiapi.query.Filter_Set__c.edges[0].node.Filter_Set_User_Associations__r.edges[0]
                    .node.Id,
                Pinned__c: false,
            },
        });
    });

    test('Toasts after pin', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        const toastHandler = jest.fn((evnt) => {
            expect(evnt.detail).toMatchObject({
                variant: 'success',
            });
        });
        element.addEventListener('lightning__showtoast', toastHandler);

        await flushPromises(); // Wait for wire to enqueue

        graphql.emit(wireResponseMock);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('pin', {
                detail: {
                    filterSetId: wireResponseMock.uiapi.query.Filter_Set__c.edges[0].node.Id,
                    pinned: true,
                },
            })
        );

        await flushPromises(); // Wait for Apex to return successfully

        // Check updateRecord was called for related filter set user association
        expect(toastHandler).toHaveBeenCalled();
    });
});
