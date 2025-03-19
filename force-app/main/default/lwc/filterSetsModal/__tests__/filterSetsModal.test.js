/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {FilterSetsModalTest} from 'c/filterSetsModal';
import {graphql} from 'lightning/uiGraphQLApi';
import {flushPromises} from 'c/helperTestFunctions';
import Id from '@salesforce/user/Id';
import LightningConfirm from 'lightning/confirm';
import {createRecord, updateRecord, deleteRecord} from 'lightning/uiRecordApi';

// Has both pinned and unpinned filters
const wireBasic = require('./data/wire/basic.json');
const expectedBasic = require('./data/expected/basic.json');
// Has no filters
const wireNone = require('./data/wire/none.json');
// Filter set pinned or not pinned
const wirePinned = require('./data/wire/pinned.json');
const wireNotPinned = require('./data/wire/notPinned.json');
// Private vs Shared filters
const wirePrivate = require('./data/wire/private.json');
const wireSharedWithMe = require('./data/wire/sharedWithMe.json');
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

        graphql.emit(wireNone);

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

        graphql.emit(wireBasic);

        const unpinnedFilters = expectedBasic.filter((v) => !v.Pinned__c);

        expect(element.numberNonpinned).toEqual(unpinnedFilters.length);
        expect(element.nonpinnedFilterSets).toMatchObject(unpinnedFilters);
        expect(element.hasNonpinnedFilterSets).toEqual(true);
    });

    test('Gets all pinned filters', async () => {
        const element = createElement('c-filter-sets-modal', {
            is: FilterSetsModalTest,
        });
        document.body.appendChild(element);

        graphql.emit(wireBasic);

        const pinnedFilters = expectedBasic.filter((v) => v.Pinned__c);

        expect(element.numberPinned).toEqual(pinnedFilters.length);
        expect(element.pinnedFilterSets).toMatchObject(pinnedFilters);
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
