/* eslint-disable no-undef */
import {createElement} from 'lwc';
import FilterSetRemoveModal from 'c/filterSetRemoveModal';
import Id from '@salesforce/user/Id';
import {flushPromises} from 'c/helperTestFunctions';

const filterSetSharedWithMeWithMe = require('./data/filterSetSharedWithMe.json');

describe('c-filter-set-remove-modal', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Proper text', async () => {
        const element = createElement('c-filter-set-remove-modal', {
            is: FilterSetRemoveModal,
        });
        element.filterSet = filterSetSharedWithMeWithMe;
        document.body.appendChild(element);

        // Await render
        await flushPromises();

        // Await rerender
        await flushPromises();

        expect(element.shadowRoot.querySelector('lightning-modal-body').textContent).toContain(
            `You are removing ${filterSetSharedWithMeWithMe.Name} from your list`
        );
    });

    test('Delete mode, commit', async () => {
        const element = createElement('c-filter-set-remove-modal', {
            is: FilterSetRemoveModal,
        });
        element.filterSet = filterSetSharedWithMeWithMe;
        document.body.appendChild(element);

        // Await render
        await flushPromises();

        // Press save button
        [...element.shadowRoot.querySelectorAll('lightning-button')].filter((elem) => elem.label === 'Save')[0].click();
        await flushPromises();

        // Correct close payload
        expect(element.closeValue).toMatchObject({
            delete: false,
            unshare: [
                filterSetSharedWithMeWithMe.Filter_Set_User_Associations__r.filter((v) => v.User__c === Id)[0].Id,
            ],
        });
    });
});
