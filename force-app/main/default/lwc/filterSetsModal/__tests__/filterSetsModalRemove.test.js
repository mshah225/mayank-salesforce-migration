/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {FilterSetsModalTest} from 'c/filterSetsModal';
import {graphql} from 'lightning/uiGraphQLApi';
import {flushPromises} from 'c/helperTestFunctions';
import {deleteRecord} from 'lightning/uiRecordApi';
import FilterSetRemoveModal from 'c/filterSetRemoveModal';

// Private vs Shared filters
const wirePrivate = require('./data/wire/private.json');

FilterSetRemoveModal.open = jest.fn(() => {
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

    test('Opens modal for remove events', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        graphql.emit(wirePrivate);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('remove', {
                detail: {
                    filterSetId: wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id,
                },
            })
        );

        // Check deleteRecord was called for the filter set
        expect(FilterSetRemoveModal.open).toHaveBeenCalled();
    });

    test('Cancel remove', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        // Reject confirmation modal
        FilterSetRemoveModal.open.mockImplementationOnce(() => {
            return Promise.resolve();
        });

        await flushPromises(); // Wait for wire to enqueue

        graphql.emit(wirePrivate);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('remove', {
                detail: {
                    filterSetId: wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id,
                },
            })
        );

        await flushPromises(); // Wait for confirmation modal to be cancelled

        // Check deleteRecord was NOT called
        expect(deleteRecord).not.toHaveBeenCalled();
    });

    test('Remove filter set', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        // Mock full delete response from modal
        FilterSetRemoveModal.open.mockImplementationOnce(() => {
            return Promise.resolve({delete: true});
        });

        await flushPromises(); // Wait for wire to enqueue

        graphql.emit(wirePrivate);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('remove', {
                detail: {
                    filterSetId: wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id,
                },
            })
        );

        await flushPromises(); // Wait for confirmation modal to complete

        // Check deleteRecord was called to delete filter set
        expect(deleteRecord).toHaveBeenCalledWith(wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id);
    });

    test('Unshare filter set', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        // Mock full unshare response from modal
        FilterSetRemoveModal.open.mockImplementationOnce(() => {
            return Promise.resolve({delete: false, unshare: ['FSUA-1', 'FSUA-2', 'FSUA-3']});
        });

        await flushPromises(); // Wait for wire to enqueue

        graphql.emit(wirePrivate);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('remove', {
                detail: {
                    filterSetId: wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id,
                },
            })
        );

        await flushPromises(); // Wait for confirmation modal to complete

        // Check deleteRecord was called to delete FSUAs not the entire filter set
        expect(deleteRecord).not.toHaveBeenCalledWith(wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id);
        expect(deleteRecord).toHaveBeenCalledWith('FSUA-1');
        expect(deleteRecord).toHaveBeenCalledWith('FSUA-2');
        expect(deleteRecord).toHaveBeenCalledWith('FSUA-3');
    });

    test('Toast after delete', async () => {
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

        // Mock full delete response from modal
        FilterSetRemoveModal.open.mockImplementationOnce(() => {
            return Promise.resolve({delete: true});
        });

        await flushPromises(); // Wait for wire to enqueue

        graphql.emit(wirePrivate);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('remove', {
                detail: {
                    filterSetId: wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id,
                },
            })
        );

        await flushPromises(); // Wait for confirmation modal to complete
        await flushPromises(); // wait for deleteRecord call to complete

        // Check deleteRecord was called to delete filter set
        expect(toastHandler).toHaveBeenCalled();
    });
});
