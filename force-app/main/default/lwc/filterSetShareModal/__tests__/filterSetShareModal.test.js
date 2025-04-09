/* eslint-disable no-undef */
import {createElement} from 'lwc';
import FilterSetShareModal from 'c/filterSetShareModal';
import {flushPromises} from 'c/helperTestFunctions';
import getShareOptions from '@salesforce/apex/FilterSetController.getShareOptions';

jest.mock(
    '@salesforce/apex/FilterSetController.getShareOptions',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);
const wireUserOptionsMock = require('./data/userOptions.json');
const filterSetPrivate = require('./data/filterSetPrivate.json');
const filterSetShared = require('./data/filterSetShared.json');
const filterSetGrad = require('./data/filterSetGRAD.json');
const filterSetUgrad = require('./data/filterSetUGRAD.json');

describe('c-filter-set-share-modal', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Clear mocks
        jest.clearAllMocks();
    });

    test('Queries for users based on career=GRD', async () => {
        const element = createElement('c-filter-set-share-modal', {
            is: FilterSetShareModal,
        });
        element.filterSet = filterSetGrad;
        document.body.appendChild(element);
        await flushPromises(); // Wait for wire to enqueue

        expect(getShareOptions.getLastConfig()).toEqual({mode: 'GRAD'});
    });

    test('Queries for users based on career=UGRD', async () => {
        const element = createElement('c-filter-set-share-modal', {
            is: FilterSetShareModal,
        });
        element.filterSet = filterSetUgrad;
        document.body.appendChild(element);
        await flushPromises(); // Wait for wire to enqueue

        expect(getShareOptions.getLastConfig()).toEqual({mode: 'UGRAD'});
    });

    test('All options from user list', async () => {
        const element = createElement('c-filter-set-share-modal', {
            is: FilterSetShareModal,
        });
        element.filterSet = filterSetPrivate;
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        // After wire completes - with some options
        getShareOptions.emit(wireUserOptionsMock);

        await flushPromises(); // Wait for page to render

        expect(element.shadowRoot.querySelector('c-lightning-combo-box').options).toEqual(
            wireUserOptionsMock.sort((a, b) => {
                return a.label.localeCompare(b.label);
            })
        );
    });

    test('All options from already shared list', async () => {
        const element = createElement('c-filter-set-share-modal', {
            is: FilterSetShareModal,
        });
        element.filterSet = filterSetShared;
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        // After wire completes - with some options
        getShareOptions.emit([]);

        await flushPromises(); // Wait for page to render

        expect(element.shadowRoot.querySelector('c-lightning-combo-box').options).toEqual(
            filterSetShared.Filter_Set_User_Associations__r.map((v) => {
                return {
                    label: v.User__r.Name + ' - ' + v.User__r.Alias,
                    value: v.User__c,
                };
            }).sort((a, b) => {
                return a.label.localeCompare(b.label);
            })
        );
    });

    test('Mixed options from user list', async () => {
        const element = createElement('c-filter-set-share-modal', {
            is: FilterSetShareModal,
        });
        element.filterSet = filterSetShared;
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        // After wire completes - with some options
        getShareOptions.emit(wireUserOptionsMock);

        await flushPromises(); // Wait for page to render

        let allOptions = [];

        wireUserOptionsMock.forEach((v) => {
            allOptions.push(v);
        });
        filterSetShared.Filter_Set_User_Associations__r.forEach((v) => {
            allOptions.push({
                label: v.User__r.Name + ' - ' + v.User__r.Alias,
                value: v.User__c,
            });
        });
        allOptions = allOptions.sort((a, b) => {
            if (
                filterSetShared.Filter_Set_User_Associations__r.map((v) => v.User__c).includes(a.value) &&
                filterSetShared.Filter_Set_User_Associations__r.map((v) => v.User__c).includes(b.value)
            )
                return a.label.localeCompare(b.label);
            else if (filterSetShared.Filter_Set_User_Associations__r.map((v) => v.User__c).includes(a.value)) return -1;
            else if (filterSetShared.Filter_Set_User_Associations__r.map((v) => v.User__c).includes(b.value)) return 1;

            return a.label.localeCompare(b.label);
        });

        let seen = [];
        allOptions = allOptions.filter((v) => {
            if (seen.includes(v.value)) return false;
            seen.push(v.value);
            return true;
        });

        expect(element.shadowRoot.querySelector('c-lightning-combo-box').options).toEqual(allOptions);
    });

    test('Picklist changing', async () => {
        const element = createElement('c-filter-set-share-modal', {
            is: FilterSetShareModal,
        });
        element.filterSet = filterSetShared;
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        // After wire completes - with some options
        getShareOptions.emit(wireUserOptionsMock);

        await flushPromises(); // Wait for page to render

        let userIds = [wireUserOptionsMock[0].value, wireUserOptionsMock[1].value];

        element.shadowRoot.querySelector('c-lightning-combo-box').dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: userIds.join(';'),
                },
            })
        );

        await flushPromises(); // Wait for page to rerender

        expect(element.shadowRoot.querySelectorAll('lightning-pill')).toHaveLength(userIds.length);
    });

    test('Starting pills', async () => {
        const element = createElement('c-filter-set-share-modal', {
            is: FilterSetShareModal,
        });
        element.filterSet = filterSetShared;
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        // After wire completes - with some options
        getShareOptions.emit([]);

        await flushPromises(); // Wait for page to render

        expect(element.shadowRoot.querySelectorAll('lightning-pill')).toHaveLength(
            filterSetShared.Filter_Set_User_Associations__r.length
        );
    });

    test('Removing pills', async () => {
        const element = createElement('c-filter-set-share-modal', {
            is: FilterSetShareModal,
        });
        element.filterSet = filterSetShared;
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        // After wire completes - with some options
        getShareOptions.emit([]);

        await flushPromises(); // Wait for page to render

        element.shadowRoot.querySelector('lightning-pill').dispatchEvent(new CustomEvent('remove', {}));

        await flushPromises(); // Wait for page to rerender

        expect(element.shadowRoot.querySelectorAll('lightning-pill')).toHaveLength(
            filterSetShared.Filter_Set_User_Associations__r.length - 1
        );
    });

    test('Select all', async () => {
        const element = createElement('c-filter-set-share-modal', {
            is: FilterSetShareModal,
        });
        element.filterSet = filterSetShared;
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        // After wire completes - with some options
        getShareOptions.emit(wireUserOptionsMock);

        await flushPromises(); // Wait for page to render

        let allUserIds = [];
        filterSetShared.Filter_Set_User_Associations__r.forEach((v) => allUserIds.push(v.User__c));
        wireUserOptionsMock.forEach((v) => allUserIds.push(v.value));
        allUserIds = [...new Set(allUserIds)];

        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((elem) => elem.label === 'Select all users')[0]
            .click();

        await flushPromises(); // Wait for page to rerender

        expect(element.shadowRoot.querySelectorAll('lightning-pill')).toHaveLength(allUserIds.length);
    });

    test('Clear all', async () => {
        const element = createElement('c-filter-set-share-modal', {
            is: FilterSetShareModal,
        });
        element.filterSet = filterSetShared;
        document.body.appendChild(element);

        await flushPromises(); // Wait for wire to enqueue

        // After wire completes - with some options
        getShareOptions.emit(wireUserOptionsMock);

        await flushPromises(); // Wait for page to render

        let allUserIds = [];
        filterSetShared.Filter_Set_User_Associations__r.forEach((v) => allUserIds.push(v.User__c));
        wireUserOptionsMock.forEach((v) => allUserIds.push(v.value));
        allUserIds = [...new Set(allUserIds)];

        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((elem) => elem.label === 'Clear selection')[0]
            .click();

        await flushPromises(); // Wait for page to rerender

        expect(element.shadowRoot.querySelectorAll('lightning-pill')).toHaveLength(0);
    });
});
