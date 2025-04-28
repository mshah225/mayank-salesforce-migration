/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {FilterSetsModalTest} from 'c/filterSetsModal';
import {graphql} from 'lightning/uiGraphQLApi';
import {flushPromises} from 'c/helperTestFunctions';
import {updateRecord} from 'lightning/uiRecordApi';

// Filter set pinned or not pinned
const wirePinned = require('./data/wire/pinned.json');
const wireNotPinned = require('./data/wire/notPinned.json');

describe('c-filter-sets-modal', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Clear mocks
        jest.clearAllMocks();
    });

    test('Handles pin events', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        graphql.emit(wireNotPinned);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('pin', {
                detail: {
                    filterSetId: wireNotPinned.uiapi.query.Filter_Set__c.edges[0].node.Id,
                    pinned: true,
                },
            })
        );

        // Check updateRecord was called for related filter set user association
        expect(updateRecord).toHaveBeenCalledWith({
            fields: {
                Id: wireNotPinned.uiapi.query.Filter_Set__c.edges[0].node.Filter_Set_User_Associations__r.edges[0].node
                    .Id,
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

        graphql.emit(wirePinned);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('pin', {
                detail: {
                    filterSetId: wirePinned.uiapi.query.Filter_Set__c.edges[0].node.Id,
                    pinned: false,
                },
            })
        );

        // Check updateRecord was called for related filter set user association
        expect(updateRecord).toHaveBeenCalledWith({
            fields: {
                Id: wirePinned.uiapi.query.Filter_Set__c.edges[0].node.Filter_Set_User_Associations__r.edges[0].node.Id,
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

        graphql.emit(wireNotPinned);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('pin', {
                detail: {
                    filterSetId: wireNotPinned.uiapi.query.Filter_Set__c.edges[0].node.Id,
                    pinned: true,
                },
            })
        );

        await flushPromises(); // Wait for Apex to return successfully

        // Check toast was raised for success
        expect(toastHandler).toHaveBeenCalled();
    });
});
