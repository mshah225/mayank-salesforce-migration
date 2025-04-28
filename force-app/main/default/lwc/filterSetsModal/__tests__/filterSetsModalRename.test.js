/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {FilterSetsModalTest} from 'c/filterSetsModal';
import {graphql} from 'lightning/uiGraphQLApi';
import {flushPromises} from 'c/helperTestFunctions';
import {updateRecord} from 'lightning/uiRecordApi';

// Private vs Shared filters
const wirePrivate = require('./data/wire/private.json');
const wireSharedWithMe = require('./data/wire/sharedWithMe.json');

describe('c-filter-sets-modal', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Clear mocks
        jest.clearAllMocks();
    });

    test('Handles rename events', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        graphql.emit(wirePrivate);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('rename', {
                detail: {
                    filterSetId: wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id,
                    value: 'New name',
                },
            })
        );

        // Check updateRecord was called for related filter set user association
        expect(updateRecord).toHaveBeenCalledWith({
            fields: {
                Id: wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id,
                Name: 'New name',
            },
        });
    });

    test('Toasts after rename', async () => {
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

        graphql.emit(wirePrivate);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('rename', {
                detail: {
                    filterSetId: wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id,
                    value: 'New name',
                },
            })
        );

        await flushPromises(); // Wait for Apex to return successfully

        // Check toast was raised for success
        expect(toastHandler).toHaveBeenCalled();
    });
});
