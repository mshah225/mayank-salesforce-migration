/* eslint-disable no-undef */
import {createElement} from 'lwc';
import Id from '@salesforce/user/Id';
import FilterSetRemoveModal from 'c/filterSetRemoveModal';
import {flushPromises} from 'c/helperTestFunctions';

const filterSetSharedByMe = require('./data/filterSetSharedByMe.json');

describe('c-filter-set-remove-modal', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Delete mode, render', async () => {
        const element = createElement('c-filter-set-remove-modal', {
            is: FilterSetRemoveModal,
        });
        element.filterSet = filterSetSharedByMe;
        document.body.appendChild(element);

        // Await render
        await flushPromises();

        // Press radio button to delete
        element.shadowRoot.querySelector('lightning-radio-group').dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: 'delete',
                },
            })
        );

        // Await rerender
        await flushPromises();

        expect(element.shadowRoot.querySelector('c-lightning-combo-box')).toBeFalsy();
        expect(element.shadowRoot.querySelector('lightning-pill')).toBeFalsy();
    });

    test('Delete mode, commit', async () => {
        const element = createElement('c-filter-set-remove-modal', {
            is: FilterSetRemoveModal,
        });
        element.filterSet = filterSetSharedByMe;
        document.body.appendChild(element);

        // Await render
        await flushPromises();

        // Press radio button to delete
        element.shadowRoot.querySelector('lightning-radio-group').dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: 'delete',
                },
            })
        );

        // Await rerender
        await flushPromises();

        // Press remove button
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((elem) => elem.label === 'Remove')[0]
            .click();
        await flushPromises();

        // Correct close payload
        expect(element.closeValue).toMatchObject({
            delete: true,
        });
    });

    test('Unshare mode, render', async () => {
        const element = createElement('c-filter-set-remove-modal', {
            is: FilterSetRemoveModal,
        });
        element.filterSet = filterSetSharedByMe;
        document.body.appendChild(element);

        // Await render
        await flushPromises();

        // Press radio button to unshare
        element.shadowRoot.querySelector('lightning-radio-group').dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: 'unshare',
                },
            })
        );

        // Await rerender
        await flushPromises();

        expect(element.shadowRoot.querySelector('c-lightning-combo-box')).toBeTruthy();
        expect(element.shadowRoot.querySelector('lightning-pill')).toBeTruthy();
    });

    test('Unshare mode, 1 pill per user', async () => {
        const element = createElement('c-filter-set-remove-modal', {
            is: FilterSetRemoveModal,
        });
        element.filterSet = filterSetSharedByMe;
        document.body.appendChild(element);

        // Await render
        await flushPromises();

        // Press radio button to unshare
        element.shadowRoot.querySelector('lightning-radio-group').dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: 'unshare',
                },
            })
        );

        // Await rerender
        await flushPromises();

        const allPills = [...element.shadowRoot.querySelectorAll('lightning-pill')];
        const otherUsersFSUA = filterSetSharedByMe.Filter_Set_User_Associations__r.filter((v) => v.User__c !== Id);

        // One pill per shared user
        expect(allPills).toHaveLength(otherUsersFSUA.length);

        // Correct first
        expect(allPills[0].label).toEqual(otherUsersFSUA[0].User__r.Name + ' - ' + otherUsersFSUA[0].User__r.Alias);
        expect(allPills[0].dataset.userid).toEqual(filterSetSharedByMe.Filter_Set_User_Associations__r[0].User__c);

        // Correct second
        expect(allPills[1].label).toEqual(otherUsersFSUA[1].User__r.Name + ' - ' + otherUsersFSUA[1].User__r.Alias);
        expect(allPills[1].dataset.userid).toEqual(filterSetSharedByMe.Filter_Set_User_Associations__r[1].User__c);
    });

    test('Unshare mode, removing pills', async () => {
        const element = createElement('c-filter-set-remove-modal', {
            is: FilterSetRemoveModal,
        });
        element.filterSet = filterSetSharedByMe;
        document.body.appendChild(element);

        // Await render
        await flushPromises();

        // Press radio button to unshare
        element.shadowRoot.querySelector('lightning-radio-group').dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: 'unshare',
                },
            })
        );

        // Await rerender
        await flushPromises();

        // Press second pill
        let allPills = [...element.shadowRoot.querySelectorAll('lightning-pill')];
        allPills[1].dispatchEvent(new CustomEvent('remove'));

        // Await rerender
        await flushPromises();

        allPills = [...element.shadowRoot.querySelectorAll('lightning-pill')];
        const otherUsersFSUA = filterSetSharedByMe.Filter_Set_User_Associations__r.filter((v) => v.User__c !== Id);

        // One pill per shared user
        expect(allPills).toHaveLength(otherUsersFSUA.length - 1);

        // Correct first
        expect(allPills[0].label).toEqual(otherUsersFSUA[0].User__r.Name + ' - ' + otherUsersFSUA[0].User__r.Alias);
        expect(allPills[0].dataset.userid).toEqual(filterSetSharedByMe.Filter_Set_User_Associations__r[0].User__c);
    });

    test('Unshare mode, commit', async () => {
        const element = createElement('c-filter-set-remove-modal', {
            is: FilterSetRemoveModal,
        });
        element.filterSet = filterSetSharedByMe;
        document.body.appendChild(element);

        // Await render
        await flushPromises();

        // Press radio button to unshare
        element.shadowRoot.querySelector('lightning-radio-group').dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: 'unshare',
                },
            })
        );

        // Await rerender
        await flushPromises();

        // Press second pill
        let allPills = [...element.shadowRoot.querySelectorAll('lightning-pill')];
        allPills[1].dispatchEvent(new CustomEvent('remove'));

        // Await rerender
        await flushPromises();

        // Press remove button
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((elem) => elem.label === 'Remove')[0]
            .click();
        await flushPromises();

        // Correct close payload
        const otherUsersFSUA = filterSetSharedByMe.Filter_Set_User_Associations__r.filter((v) => v.User__c !== Id);
        expect(element.closeValue).toMatchObject({
            delete: false,
            unshare: [otherUsersFSUA[1].Id],
        });
    });
});
