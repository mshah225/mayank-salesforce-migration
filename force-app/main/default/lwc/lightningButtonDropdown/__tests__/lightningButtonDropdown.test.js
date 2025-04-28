/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {LightningButtonDropdownTest} from 'c/lightningButtonDropdown';

describe('c-lightning-button-dropdown', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Raise event when clicking on primary button', () => {
        const element = createElement('c-lightning-button-dropdown', {
            is: LightningButtonDropdownTest,
        });
        document.body.appendChild(element);

        const clickHandler = jest.fn();
        element.addEventListener('click', clickHandler);

        // Press button
        element.shadowRoot.querySelector('.primary-action').click();

        // Detect onclick event
        expect(clickHandler).toHaveBeenCalledTimes(1);
    });

    test('Dropdown starts as closed', () => {
        const element = createElement('c-lightning-button-dropdown', {
            is: LightningButtonDropdownTest,
        });
        document.body.appendChild(element);

        // All state variables indicate dropdown is closed
        expect(element.dropdownOpen).toEqual(false);
        expect(element.dropdownIcon).toEqual('utility:right');
        expect(element.dropdownIconText).toEqual('See more actions');
    });

    test('No event when clicking dropdown button', () => {
        const element = createElement('c-lightning-button-dropdown', {
            is: LightningButtonDropdownTest,
        });
        document.body.appendChild(element);

        const clickHandler = jest.fn();
        element.addEventListener('click', clickHandler);

        // Press button
        element.shadowRoot.querySelector('.dropdown-button').click();

        // No onclick event
        expect(clickHandler).toHaveBeenCalledTimes(0);
    });

    test('Pressing dropdown button opens dropdwon', () => {
        const element = createElement('c-lightning-button-dropdown', {
            is: LightningButtonDropdownTest,
        });
        document.body.appendChild(element);

        const clickHandler = jest.fn();
        element.addEventListener('click', clickHandler);

        // Press button
        element.shadowRoot.querySelector('.dropdown-button').click();

        // All state variables indicate dropdown is open
        expect(element.dropdownOpen).toEqual(true);
        expect(element.dropdownIcon).toEqual('utility:down');
        expect(element.dropdownIconText).toEqual('Close action dropdown');
    });

    test('Pressing button in dropdown closes dropdown', () => {
        const element = createElement('c-lightning-button-dropdown', {
            is: LightningButtonDropdownTest,
        });
        document.body.appendChild(element);

        // Press button within dropdown
        element.shadowRoot
            .querySelector('.dropdown-menu')
            .dispatchEvent(new CustomEvent('select', {deafilt: {}, bubbles: true, compose: true}));

        // Select closes when option in dropdown is pressed
        expect(element.dropdownOpen).toEqual(false);
    });

    test('Pressing button in dropdown propagates', () => {
        const element = createElement('c-lightning-button-dropdown', {
            is: LightningButtonDropdownTest,
        });
        document.body.appendChild(element);

        const selectHandler = jest.fn();
        element.addEventListener('select', selectHandler);

        // Press button within dropdown
        element.shadowRoot.querySelector('.dropdown-menu').dispatchEvent(
            new CustomEvent('select', {
                detail: {},
                bubbles: true,
                composed: true,
            })
        );

        // Detect onselect event
        expect(selectHandler).toHaveBeenCalledTimes(1);
    });
});
