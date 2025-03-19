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

    test('Rename mode', async () => {
        const element = createElement('c-filter-set-element', {
            is: FilterSetElementTest,
        });
        element.filterSet = privateFilterSet;
        document.body.appendChild(element);

        // Currently not in rename mode
        expect(element.renameMode).toEqual(false);

        // Press rename button
        element.shadowRoot.querySelector('lightning-button-icon').click();

        // Now in rename mode
        expect(element.renameMode).toEqual(true);

        // Await re-render
        await flushPromises();

        // Text box is now rendered to change name
        expect(element.shadowRoot.querySelector('lightning-input')).toBeTruthy();
    });

    test('Rename events are raised on enter', async () => {
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

        // Press rename button
        element.shadowRoot.querySelector('lightning-button-icon').click();

        // Await re-render
        await flushPromises();
        // Change name
        element.shadowRoot
            .querySelector('lightning-input')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'New Name'}}));

        // Press enter to apply new name
        element.shadowRoot.querySelector('lightning-input').dispatchEvent(new KeyboardEvent('keydown', {key: 'Enter'}));

        await flushPromises();

        // Check for event
        expect(renameHandler).toHaveBeenCalledTimes(1);
        // Check renamed name
        expect(element.filterName).toEqual('New Name');
    });

    test('Rename cancelled with escape', async () => {
        const element = createElement('c-filter-set-element', {
            is: FilterSetElementTest,
        });
        element.filterSet = privateFilterSet;
        document.body.appendChild(element);

        const renameHandler = jest.fn();
        element.addEventListener('rename', renameHandler);

        // Press rename button
        element.shadowRoot.querySelector('lightning-button-icon').click();

        // Await re-render
        await flushPromises();
        // Change name
        element.shadowRoot
            .querySelector('lightning-input')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'New Name'}}));

        // Press enter to apply new name
        element.shadowRoot
            .querySelector('lightning-input')
            .dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape'}));

        await flushPromises();

        // Check for no event
        expect(renameHandler).toHaveBeenCalledTimes(0);
        // Reset filter name
        expect(element.filterName).toEqual(privateFilterSet.Name);
    });
});
