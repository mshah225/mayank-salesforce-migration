/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {FilterSetsModalTest} from 'c/filterSetsModal';
import {graphql} from 'lightning/uiGraphQLApi';
import {flushPromises} from 'c/helperTestFunctions';
import {createRecord, updateRecord} from 'lightning/uiRecordApi';

// Has both pinned and unpinned filters
const wireBasic = require('./data/wire/basic.json');
const expectedBasic = require('./data/expected/basic.json');
// Has no filters
const wireNone = require('./data/wire/none.json');
// Wire with a sort order preference
const wireWithPreferences = require('./data/wire/withPreferences.json');

describe('c-filter-sets-modal', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Clear mocks
        jest.clearAllMocks();
    });

    test('Apply sort - Shared First', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);
        graphql.emit(wireBasic);

        await flushPromises(); // await render

        // Change sort
        element.shadowRoot
            .querySelector('lightning-combobox')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'Shared First'}}));

        // Check order
        let sortedFilterSets = expectedBasic
            .filter((v) => !v.Pinned__c)
            .sort((a, b) => {
                return a.Is_Shared__c === b.Is_Shared__c ? 0 : a.Is_Shared__c ? -1 : 1;
            });
        expect(element.nonpinnedFilterSets).toMatchObject(sortedFilterSets);
    });

    test('Apply sort - Private First', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);
        graphql.emit(wireBasic);

        await flushPromises(); // await render

        // Change sort
        element.shadowRoot
            .querySelector('lightning-combobox')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'Private First'}}));

        // Check order
        let sortedFilterSets = expectedBasic
            .filter((v) => !v.Pinned__c)
            .sort((a, b) => {
                return a.Is_Shared__c === b.Is_Shared__c ? 0 : !a.Is_Shared__c ? -1 : 1;
            });
        expect(element.nonpinnedFilterSets).toMatchObject(sortedFilterSets);
    });

    test('Apply saved sort', () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);
        graphql.emit(wireWithPreferences);

        // Check order was applied
        expect(element.sortOrder).toEqual(
            wireWithPreferences.uiapi.query.User_Filter_Set_Preference__c.edges[0].node.Sort_Order__c.value
        );
    });

    test('Save sort with no existing preferences record', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        graphql.emit(wireNone);

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
        graphql.emit(wireWithPreferences);

        await flushPromises(); // await render

        // Change sort
        element.shadowRoot
            .querySelector('lightning-combobox')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'Private First'}}));

        await flushPromises(); // await calling createRecord

        // Check createRecord was called
        expect(updateRecord).toHaveBeenCalledWith({
            fields: {
                Id: wireWithPreferences.uiapi.query.User_Filter_Set_Preference__c.edges[0].node.Id,
                Sort_Order__c: 'Private First',
            },
        });
    });
});
