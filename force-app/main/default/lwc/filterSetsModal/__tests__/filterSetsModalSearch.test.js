/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {FilterSetsModalTest} from 'c/filterSetsModal';
import {graphql} from 'lightning/uiGraphQLApi';
import {flushPromises} from 'c/helperTestFunctions';

// Has both pinned and unpinned filters
const wireBasic = require('./data/wire/basic.json');
const expectedBasic = require('./data/expected/basic.json');

describe('c-filter-sets-modal', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Clear mocks
        jest.clearAllMocks();
    });

    test('Searching filter using name', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);
        graphql.emit(wireBasic);

        await flushPromises(); // await render

        element.shadowRoot
            .querySelector('lightning-input')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'senior'}}));

        let filteredFilterSets = expectedBasic
            .filter((v) => !v.Pinned__c)
            .filter((v) => v.Name.toLowerCase().includes('senior') || v.Owner__r.Name.toLowerCase().includes('senior'));

        expect(element.numberNonpinned).toEqual(filteredFilterSets.length);
        expect(element.nonpinnedFilterSets).toMatchObject(filteredFilterSets);
        expect(element.hasNonpinnedFilterSets).toEqual(true);
    });

    test('Searching filter using owner name', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);
        graphql.emit(wireBasic);

        await flushPromises(); // await render

        element.shadowRoot
            .querySelector('lightning-input')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'nordman'}}));

        let filteredFilterSets = expectedBasic
            .filter((v) => !v.Pinned__c)
            .filter(
                (v) => v.Name.toLowerCase().includes('nordman') || v.Owner__r.Name.toLowerCase().includes('nordman')
            );

        expect(element.numberNonpinned).toEqual(filteredFilterSets.length);
        expect(element.nonpinnedFilterSets).toMatchObject(filteredFilterSets);
        expect(element.hasNonpinnedFilterSets).toEqual(true);
    });
});
