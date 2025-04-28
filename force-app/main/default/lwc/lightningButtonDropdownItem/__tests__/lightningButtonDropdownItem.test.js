/* eslint-disable no-undef */
import {createElement} from 'lwc';
import LightningButtonDropdownItem from 'c/lightningButtonDropdownItem';

describe('c-lightning-button-dropdown-item', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Raises select events when pressed', () => {
        // Arrange
        const element = createElement('c-lightning-button-dropdown-item', {
            is: LightningButtonDropdownItem,
        });
        document.body.appendChild(element);

        const selectHandler = jest.fn();
        element.addEventListener('select', selectHandler);

        // Press button
        element.shadowRoot.querySelector('button').click();

        // Raised event
        expect(selectHandler).toHaveBeenCalledTimes(1);
    });
});
