/* eslint-disable no-undef */
import {createElement} from 'lwc';
import FilterSetRemoveModal from 'c/filterSetRemoveModal';
import {flushPromises} from 'c/helperTestFunctions';

const filterSetPrivate = require('./data/filterSetPrivate.json');

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
        element.filterSet = filterSetPrivate;
        document.body.appendChild(element);

        // Await render
        await flushPromises();

        // Await rerender
        await flushPromises();

        expect(element.shadowRoot.querySelector('lightning-modal-body').textContent).toContain(
            `You are removing ${filterSetPrivate.Name} from the System`
        );
    });

    test('Delete mode, commit', async () => {
        const element = createElement('c-filter-set-remove-modal', {
            is: FilterSetRemoveModal,
        });
        element.filterSet = filterSetPrivate;
        document.body.appendChild(element);

        // Await render
        await flushPromises();

        // Press save button
        [...element.shadowRoot.querySelectorAll('lightning-button')].filter((elem) => elem.label === 'Save')[0].click();
        await flushPromises();

        // Correct close payload
        expect(element.closeValue).toMatchObject({
            delete: true,
        });
    });
});
