/* eslint-disable no-undef */
import {createElement} from 'lwc';
import LightningTextEditable from 'c/lightningTextEditable';
import {flushPromises} from 'c/helperTestFunctions';

describe('c-lightning-text-editable', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Test default shows value and edit button', () => {
        const element = createElement('c-lightning-text-editable', {
            is: LightningTextEditable,
        });
        element.value = 'Avon Lake';
        document.body.appendChild(element);

        // Has value
        expect(element.shadowRoot.textContent).toContain('Avon Lake');
        // Has edit button
        expect(
            [...element.shadowRoot.querySelectorAll('lightning-button-icon')].filter((v) => v.title === 'Edit')[0]
        ).toBeTruthy();
    });

    test('Show value with no edit button', () => {
        const element = createElement('c-lightning-text-editable', {
            is: LightningTextEditable,
        });
        element.value = 'Avon Lake';
        element.hideEdit = true;
        document.body.appendChild(element);

        // Has value
        expect(element.shadowRoot.textContent).toContain('Avon Lake');
        // Has no edit button
        expect(
            [...element.shadowRoot.querySelectorAll('lightning-button-icon')].filter((v) => v.title === 'Edit')[0]
        ).toBeFalsy();
    });

    test('Test entering edit mode', async () => {
        const element = createElement('c-lightning-text-editable', {
            is: LightningTextEditable,
        });
        element.value = 'Avon Lake';
        document.body.appendChild(element);

        // Press edit button
        [...element.shadowRoot.querySelectorAll('lightning-button-icon')].filter((v) => v.title === 'Edit')[0].click();

        await flushPromises(); //await rerender

        // Has input field
        expect(element.shadowRoot.querySelector('lightning-input')).toBeTruthy();
        // Correct starting value
        expect(element.shadowRoot.querySelector('lightning-input').value).toEqual('Avon Lake');
    });

    test('Show save and cancel buttons in edit mode', async () => {
        const element = createElement('c-lightning-text-editable', {
            is: LightningTextEditable,
        });
        element.value = 'Avon Lake';
        document.body.appendChild(element);

        // Press edit button
        [...element.shadowRoot.querySelectorAll('lightning-button-icon')].filter((v) => v.title === 'Edit')[0].click();

        await flushPromises(); //await rerender

        // Save button
        expect(
            [...element.shadowRoot.querySelectorAll('lightning-button-icon')].filter(
                (v) => v.title === 'Save changes'
            )[0]
        ).toBeTruthy();
        // Cancel button
        expect(
            [...element.shadowRoot.querySelectorAll('lightning-button-icon')].filter(
                (v) => v.title === 'Revert changes'
            )[0]
        ).toBeTruthy();
    });

    test('Test changing value edit mode', async () => {
        const element = createElement('c-lightning-text-editable', {
            is: LightningTextEditable,
        });
        element.value = 'Avon Lake';
        document.body.appendChild(element);

        // Press edit button
        [...element.shadowRoot.querySelectorAll('lightning-button-icon')].filter((v) => v.title === 'Edit')[0].click();

        await flushPromises(); //await rerender

        element.shadowRoot
            .querySelector('lightning-input')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'Arizona State'}}));

        await flushPromises(); //await rerender

        // Value has been updated
        expect(element.shadowRoot.querySelector('lightning-input').value).toEqual('Arizona State');
    });

    test('Test saving changes', async () => {
        const element = createElement('c-lightning-text-editable', {
            is: LightningTextEditable,
        });
        element.value = 'Avon Lake';
        document.body.appendChild(element);

        const changeHandler = jest.fn((v) => {
            expect(v.detail).toMatchObject({value: 'Arizona State'});
        });
        element.addEventListener('change', changeHandler);

        // Press edit button
        [...element.shadowRoot.querySelectorAll('lightning-button-icon')].filter((v) => v.title === 'Edit')[0].click();

        await flushPromises(); //await rerender

        // Change value
        element.shadowRoot
            .querySelector('lightning-input')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'Arizona State'}}));
        // Press save
        [...element.shadowRoot.querySelectorAll('lightning-button-icon')]
            .filter((v) => v.title === 'Save changes')[0]
            .click();

        await flushPromises(); //await rerender

        // Check for no event
        expect(changeHandler).toHaveBeenCalledTimes(1);
    });

    test('Test cancelling changes', async () => {
        const element = createElement('c-lightning-text-editable', {
            is: LightningTextEditable,
        });
        element.value = 'Avon Lake';
        document.body.appendChild(element);

        const changeHandler = jest.fn();
        element.addEventListener('change', changeHandler);

        // Press edit button
        [...element.shadowRoot.querySelectorAll('lightning-button-icon')].filter((v) => v.title === 'Edit')[0].click();

        await flushPromises(); //await rerender

        // Change value
        element.shadowRoot
            .querySelector('lightning-input')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'Arizona State'}}));
        // Press cancel
        [...element.shadowRoot.querySelectorAll('lightning-button-icon')]
            .filter((v) => v.title === 'Revert changes')[0]
            .click();

        await flushPromises(); //await rerender

        // Check for no event
        expect(changeHandler).toHaveBeenCalledTimes(0);
        // Reset value
        expect(element.shadowRoot.textContent).toContain('Avon Lake');
    });

    test('Save with enter', async () => {
        const element = createElement('c-lightning-text-editable', {
            is: LightningTextEditable,
        });
        element.value = 'Avon Lake';
        document.body.appendChild(element);
        const changeHandler = jest.fn((v) => {
            expect(v.detail).toMatchObject({value: 'Arizona State'});
        });
        element.addEventListener('change', changeHandler);

        // Press edit button
        [...element.shadowRoot.querySelectorAll('lightning-button-icon')].filter((v) => v.title === 'Edit')[0].click();

        await flushPromises(); //await rerender

        // Change value
        element.shadowRoot
            .querySelector('lightning-input')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'Arizona State'}}));

        // Press enter to confirm changes
        element.shadowRoot.querySelector('lightning-input').dispatchEvent(new KeyboardEvent('keydown', {key: 'Enter'}));

        await flushPromises(); //await rerender

        // Check for event
        expect(changeHandler).toHaveBeenCalledTimes(1);
    });

    test('Cancel with escape', async () => {
        const element = createElement('c-lightning-text-editable', {
            is: LightningTextEditable,
        });
        element.value = 'Avon Lake';
        document.body.appendChild(element);
        const changeHandler = jest.fn((v) => {
            expect(v.detail).toMatchObject({value: 'Arizona State'});
        });
        element.addEventListener('change', changeHandler);

        // Press edit button
        [...element.shadowRoot.querySelectorAll('lightning-button-icon')].filter((v) => v.title === 'Edit')[0].click();

        await flushPromises(); //await rerender

        // Change value
        element.shadowRoot
            .querySelector('lightning-input')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'Arizona State'}}));

        // Press escape to cancel changes
        element.shadowRoot
            .querySelector('lightning-input')
            .dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape'}));

        await flushPromises(); //await rerender

        // Check for no event
        expect(changeHandler).toHaveBeenCalledTimes(0);
        // Reset value
        expect(element.shadowRoot.textContent).toContain('Avon Lake');
    });
});
