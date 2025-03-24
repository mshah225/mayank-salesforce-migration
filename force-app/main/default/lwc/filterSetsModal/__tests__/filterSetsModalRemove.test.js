/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {FilterSetsModalTest} from 'c/filterSetsModal';
import {graphql} from 'lightning/uiGraphQLApi';
import {flushPromises} from 'c/helperTestFunctions';
import LightningConfirm from 'lightning/confirm';
import {deleteRecord} from 'lightning/uiRecordApi';

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

    test('Handles remove events - private', async () => {
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

        // Opens confirmation modal
        expect(LightningConfirm.open).toHaveBeenCalledWith({
            label: 'Remove filter set',
            message: `You are removing ${wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Name.value} from the System`,
        });

        await flushPromises(); // Wait for confirmation modal to close successfully

        // Check deleteRecord was called for the filter set
        expect(deleteRecord).toHaveBeenCalledWith(wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id);
    });

    test('Handles cancel remove events - private', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        // Reject confirmation modal
        LightningConfirm.open.mockImplementationOnce(() => {
            return Promise.resolve(false);
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

    test('Toast after delete - private', async () => {
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
            new CustomEvent('remove', {
                detail: {
                    filterSetId: wirePrivate.uiapi.query.Filter_Set__c.edges[0].node.Id,
                },
            })
        );

        await flushPromises(); // Wait for confirmation modal to close successfully
        await flushPromises(); // wait for deleteRecord call to complete

        // Check toast was raised for success
        expect(toastHandler).toHaveBeenCalled();
    });

    test('Handles remove events - shared, not owner', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        graphql.emit(wireSharedWithMe);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('remove', {
                detail: {
                    filterSetId: wireSharedWithMe.uiapi.query.Filter_Set__c.edges[0].node.Id,
                },
            })
        );

        // Opens confirmation modal
        expect(LightningConfirm.open).toHaveBeenCalledWith({
            label: 'Remove filter set',
            message: `You are removing ${wireSharedWithMe.uiapi.query.Filter_Set__c.edges[0].node.Name.value} from your list`,
        });

        await flushPromises(); // Wait for confirmation modal to close successfully

        // Check deleteRecord was called for the filter set
        expect(deleteRecord).toHaveBeenCalledWith(
            wireSharedWithMe.uiapi.query.Filter_Set__c.edges[0].node.Filter_Set_User_Associations__r.edges[0].node.Id
        );
    });

    test('Handles cancel remove events - shared, not owner', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        // Reject confirmation modal
        LightningConfirm.open.mockImplementationOnce(() => {
            return Promise.resolve(false);
        });

        await flushPromises(); // Wait for wire to enqueue

        graphql.emit(wireSharedWithMe);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('remove', {
                detail: {
                    filterSetId: wireSharedWithMe.uiapi.query.Filter_Set__c.edges[0].node.Id,
                },
            })
        );

        await flushPromises(); // Wait for confirmation modal to be cancelled

        // Check deleteRecord was NOT called
        expect(deleteRecord).not.toHaveBeenCalled();
    });

    test('Toast after delete - shared, not owner', async () => {
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

        graphql.emit(wireSharedWithMe);

        await flushPromises(); // Wait for page to render

        // Raise event
        element.shadowRoot.querySelector('c-filter-set-element').dispatchEvent(
            new CustomEvent('remove', {
                detail: {
                    filterSetId: wireSharedWithMe.uiapi.query.Filter_Set__c.edges[0].node.Id,
                },
            })
        );

        await flushPromises(); // Wait for confirmation modal to close successfully
        await flushPromises(); // wait for deleteRecord call to complete

        // Check toast was raised for success
        expect(toastHandler).toHaveBeenCalled();
    });
});
