/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {FilterSetsModalTest} from 'c/filterSetsModal';
import {graphql} from 'lightning/uiGraphQLApi';
import {flushPromises} from 'c/helperTestFunctions';
import Id from '@salesforce/user/Id';
import {createRecord, updateRecord} from 'lightning/uiRecordApi';
import {cloneObj} from 'c/helperFunctions';

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

    test('Searching filter using name', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);
        graphql.emit(wireResponseMock);

        await flushPromises(); // await render

        element.shadowRoot
            .querySelector('lightning-input')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'senior'}}));

        let filteredFilterSets = expectedUnpinnedFilters.filter(
            (v) => v.Name.toLowerCase().includes('senior') || v.Owner__r.Name.toLowerCase().includes('senior')
        );

        expect(element.numberNonpinned).toEqual(filteredFilterSets.length);
        expect(element.nonpinnedFilterSets).toMatchObject(filteredFilterSets);
        expect(element.hasNonpinnedFilterSets).toEqual(true);
    });

    test('Searching filter using owner name', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);
        graphql.emit(wireResponseMock);

        await flushPromises(); // await render

        element.shadowRoot
            .querySelector('lightning-input')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'justin'}}));

        let filteredFilterSets = expectedUnpinnedFilters.filter(
            (v) => v.Name.toLowerCase().includes('justin') || v.Owner__r.Name.toLowerCase().includes('justin')
        );

        expect(element.numberNonpinned).toEqual(filteredFilterSets.length);
        expect(element.nonpinnedFilterSets).toMatchObject(filteredFilterSets);
        expect(element.hasNonpinnedFilterSets).toEqual(true);
    });

    test('Apply sort - Shared First', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);
        graphql.emit(wireResponseMock);

        await flushPromises(); // await render

        // Change sort
        element.shadowRoot
            .querySelector('lightning-combobox')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'Shared First'}}));

        // Check order
        let sortedFilterSets = expectedUnpinnedFilters.sort((a, b) => {
            return a.Is_Shared__c === b.Is_Shared__c ? 0 : a.Is_Shared__c ? -1 : 1;
        });
        expect(element.nonpinnedFilterSets).toMatchObject(sortedFilterSets);
    });

    test('Apply sort - Private First', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);
        graphql.emit(wireResponseMock);

        await flushPromises(); // await render

        // Change sort
        element.shadowRoot
            .querySelector('lightning-combobox')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'Private First'}}));

        // Check order
        let sortedFilterSets = expectedUnpinnedFilters.sort((a, b) => {
            return a.Is_Shared__c === b.Is_Shared__c ? 0 : !a.Is_Shared__c ? -1 : 1;
        });
        expect(element.nonpinnedFilterSets).toMatchObject(sortedFilterSets);
    });

    test('Apply saved sort', () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);
        graphql.emit(wireResponseMock);

        // Check order was applied
        expect(element.sortOrder).toEqual(
            wireResponseMock.uiapi.query.User_Filter_Set_Preference__c.edges[0].node.Sort_Order__c.value
        );
    });

    test('Save sort with no existing preferences record', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        const wireResponseMockWithNoPrefObj = cloneObj(wireResponseMock);
        wireResponseMockWithNoPrefObj.uiapi.query.User_Filter_Set_Preference__c.edges = [];
        graphql.emit(wireResponseMockWithNoPrefObj);

        await flushPromises(); // await render

        // Change sort
        element.shadowRoot
            .querySelector('lightning-combobox')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'Private First'}}));

        await flushPromises(); // await calling createRecord

        // Check createRecord was called
        expect(createRecord).toHaveBeenCalledWith({
            apiName: 'User_Filter_Set_Preference__c',
            fields: {
                Sort_Order__c: 'Private First',
            },
        });
    });

    test('Save sort with existing preferences record', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);
        graphql.emit(wireResponseMock);

        await flushPromises(); // await render

        // Change sort
        element.shadowRoot
            .querySelector('lightning-combobox')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'Private First'}}));

        await flushPromises(); // await calling createRecord

        // Check createRecord was called
        expect(updateRecord).toHaveBeenCalledWith({
            fields: {
                Id: wireResponseMock.uiapi.query.User_Filter_Set_Preference__c.edges[0].node.Id,
                Sort_Order__c: 'Private First',
            },
        });
    });
});
