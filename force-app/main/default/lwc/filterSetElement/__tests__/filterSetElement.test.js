/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {FilterSetElementTest} from 'c/filterSetElement';
import {flushPromises} from 'c/helperTestFunctions';
import {cloneObj} from 'c/helperFunctions';

const privateFilterSet = require('./data/privateFilterSet.json');
const sharedByMeFilterSet = require('./data/sharedByMeFilterSet.json');
const sharedWithMeFilterSet = require('./data/sharedWithMeFilterSet.json');

describe('c-filter-set-element', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Extracts details about filter set', () => {
        const element = createElement('c-filter-set-element', {
            is: FilterSetElementTest,
        });
        element.filterSet = privateFilterSet;
        document.body.appendChild(element);

        // Assert
        expect(element.filterName).toEqual(privateFilterSet.Name);
        expect(element.shareType).toEqual('Private');
        expect(element.ownerName).toContain(privateFilterSet.Owner__r.Name);
        expect(element.createdDate).toContain(privateFilterSet.CreatedDate);
    });

    test('Raises proper event when pressing apply', () => {
        const element = createElement('c-filter-set-element', {
            is: FilterSetElementTest,
        });
        element.filterSet = privateFilterSet;
        document.body.appendChild(element);

        const applyHandler = jest.fn((evnt) => {
            expect(evnt).toMatchObject({
                detail: {
                    filterSetId: privateFilterSet.Id,
                },
            });
        });
        element.addEventListener('apply', applyHandler);

        // Press button
        element.shadowRoot.querySelector('c-lightning-button-dropdown').dispatchEvent(new CustomEvent('click'));

        // Assert
        expect(applyHandler).toHaveBeenCalledTimes(1);
    });

    test('Pin label', () => {
        const element = createElement('c-filter-set-element', {
            is: FilterSetElementTest,
        });
        const unpinnedFilterSet = cloneObj(privateFilterSet);
        unpinnedFilterSet.Pinned__c = false;
        element.filterSet = unpinnedFilterSet;
        document.body.appendChild(element);

        // Proper label
        expect(element.pinLabel).toEqual('Pin');
    });

    test('Raises proper event when pressing pin', () => {
        const element = createElement('c-filter-set-element', {
            is: FilterSetElementTest,
        });
        const unpinnedFilterSet = cloneObj(privateFilterSet);
        unpinnedFilterSet.Pinned__c = false;
        element.filterSet = unpinnedFilterSet;
        document.body.appendChild(element);

        const pinHandler = jest.fn((evnt) => {
            expect(evnt.detail).toMatchObject({
                filterSetId: privateFilterSet.Id,
                pinned: true,
            });
        });
        element.addEventListener('pin', pinHandler);

        // Press button
        element.shadowRoot
            .querySelector('c-lightning-button-dropdown')
            .dispatchEvent(new CustomEvent('select', {detail: {name: 'pin'}}));

        // Assert
        expect(pinHandler).toHaveBeenCalledTimes(1);
    });

    test('Unpin label', () => {
        const element = createElement('c-filter-set-element', {
            is: FilterSetElementTest,
        });
        const unpinnedFilterSet = cloneObj(privateFilterSet);
        unpinnedFilterSet.Pinned__c = true;
        element.filterSet = unpinnedFilterSet;
        document.body.appendChild(element);

        // Proper label
        expect(element.pinLabel).toEqual('Unpin');
    });

    test('Raises proper event when pressing unpin', () => {
        const element = createElement('c-filter-set-element', {
            is: FilterSetElementTest,
        });
        const pinnedFilterSet = cloneObj(privateFilterSet);
        pinnedFilterSet.Pinned__c = true;
        element.filterSet = pinnedFilterSet;
        document.body.appendChild(element);

        const pinHandler = jest.fn((evnt) => {
            expect(evnt.detail).toMatchObject({
                filterSetId: pinnedFilterSet.Id,
                pinned: false,
            });
        });
        element.addEventListener('pin', pinHandler);

        // Press button
        element.shadowRoot
            .querySelector('c-lightning-button-dropdown')
            .dispatchEvent(new CustomEvent('select', {detail: {name: 'pin'}}));

        // Assert
        expect(pinHandler).toHaveBeenCalledTimes(1);
    });

    test('Raises proper event when pressing share', () => {
        const element = createElement('c-filter-set-element', {
            is: FilterSetElementTest,
        });
        element.filterSet = privateFilterSet;
        document.body.appendChild(element);

        const shareHandler = jest.fn((evnt) => {
            expect(evnt).toMatchObject({
                detail: {
                    filterSetId: privateFilterSet.Id,
                },
            });
        });
        element.addEventListener('share', shareHandler);

        // Press button
        element.shadowRoot
            .querySelector('c-lightning-button-dropdown')
            .dispatchEvent(new CustomEvent('select', {detail: {name: 'share'}}));

        // Assert
        expect(shareHandler).toHaveBeenCalledTimes(1);
    });

    test('Raises proper event when pressing view', () => {
        const element = createElement('c-filter-set-element', {
            is: FilterSetElementTest,
        });
        element.filterSet = privateFilterSet;
        document.body.appendChild(element);

        const viewHandler = jest.fn((evnt) => {
            expect(evnt).toMatchObject({
                detail: {
                    filterSetId: privateFilterSet.Id,
                },
            });
        });
        element.addEventListener('view', viewHandler);

        // Press button
        element.shadowRoot
            .querySelector('c-lightning-button-dropdown')
            .dispatchEvent(new CustomEvent('select', {detail: {name: 'view'}}));

        // Assert
        expect(viewHandler).toHaveBeenCalledTimes(1);
    });

    test('Raises proper event when pressing remove', () => {
        const element = createElement('c-filter-set-element', {
            is: FilterSetElementTest,
        });
        element.filterSet = privateFilterSet;
        document.body.appendChild(element);

        const removeHandler = jest.fn((evnt) => {
            expect(evnt).toMatchObject({
                detail: {
                    filterSetId: privateFilterSet.Id,
                },
            });
        });
        element.addEventListener('remove', removeHandler);

        // Press button
        element.shadowRoot
            .querySelector('c-lightning-button-dropdown')
            .dispatchEvent(new CustomEvent('select', {detail: {name: 'remove'}}));

        // Assert
        expect(removeHandler).toHaveBeenCalledTimes(1);
    });

    test('Show rename button if is owner', async () => {
        const element = createElement('c-filter-set-element', {
            is: FilterSetElementTest,
        });
        element.filterSet = sharedByMeFilterSet;
        document.body.appendChild(element);

        await flushPromises(); // Await render

        // Yes rename button
        expect(element.shadowRoot.querySelector('c-lightning-text-editable').hideEdit).toEqual(false);
    });

    test('Hide rename button if not owner', async () => {
        const element = createElement('c-filter-set-element', {
            is: FilterSetElementTest,
        });
        element.filterSet = sharedWithMeFilterSet;
        document.body.appendChild(element);

        await flushPromises(); // Await render

        // No rename button
        expect(element.shadowRoot.querySelector('c-lightning-text-editable').hideEdit).toEqual(true);
    });

    test('Rename events are raised', async () => {
        const element = createElement('c-filter-set-element', {
            is: FilterSetElementTest,
        });
        element.filterSet = privateFilterSet;
        document.body.appendChild(element);

        const renameHandler = jest.fn((evnt) => {
            expect(evnt).toMatchObject({
                detail: {
                    filterSetId: privateFilterSet.Id,
                    value: 'New Name',
                },
            });
        });
        element.addEventListener('rename', renameHandler);

        // Change name
        element.shadowRoot
            .querySelector('c-lightning-text-editable')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'New Name'}}));

        await flushPromises();

        // Check for event
        expect(renameHandler).toHaveBeenCalledTimes(1);
    });
});
