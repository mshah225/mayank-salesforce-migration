/* eslint-disable no-undef */
import {createElement} from 'lwc';
import LightningComboBox from 'c/lightningComboBox';
import {cloneObj} from 'c/helperFunctions';
import {flushPromises} from 'c/helperTestFunctions';

const WEEKDAY_OPTIONS = [
    {label: 'Monday', value: 'mon'},
    {label: 'Tuesday', value: 'tue'},
    {label: 'Wednesday', value: 'wed'},
    {label: 'Thursday', value: 'thr'},
    {label: 'Friday', value: 'fri'},
    {label: 'Saturday', value: 'sat'},
    {label: 'Sunday', value: 'sun'},
];

describe('c-lightning-combo-box', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Not setting dropdown label', () => {
        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        document.body.appendChild(element);

        // Assert that the label is not rendered (since it is unset)
        expect(element.shadowRoot.querySelector('.slds-form-element__label')).toBeFalsy();
    });

    test('Setting dropdown label', () => {
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'City';
        document.body.appendChild(element);

        // Assert that the label is rendered and equal to the set label
        expect(element.shadowRoot.querySelector('.slds-form-element__label')).toBeTruthy();
        expect(element.shadowRoot.querySelector('.slds-form-element__label').textContent).toContain('City');
    });

    test('Not setting required flag', () => {
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        document.body.appendChild(element);

        // Assert that the required flag is not rendered
        expect(element.shadowRoot.querySelector('.required-flag')).toBeFalsy();
    });

    test('Setting required flag (boolean)', () => {
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.required = true;
        document.body.appendChild(element);

        // Assert that the required flag is rendered
        expect(element.shadowRoot.querySelector('.required-flag')).toBeTruthy();
    });

    test('Setting required flag (string)', () => {
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.required = 'true';
        document.body.appendChild(element);

        // Assert that the required flag is rendered
        expect(element.shadowRoot.querySelector('.required-flag')).toBeTruthy();
    });

    test('Checking validity', async () => {
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.required = true;
        document.body.appendChild(element);

        // Assert that not valid since no options are selected
        expect(element.checkValidity()).toBeFalsy();

        // Await rerender
        await flushPromises();

        // Assert that the error message is not being shown
        expect(element.shadowRoot.querySelector('.slds-form-element__help')).toBeFalsy();
    });

    test('Reporting validity', async () => {
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.required = true;
        document.body.appendChild(element);

        // Assert that not valid since no options are selected
        expect(element.reportValidity()).toBeFalsy();

        // Await rerender
        await flushPromises();

        // Assert that the error message is not being shown
        expect(element.shadowRoot.querySelector('.slds-form-element__help')).toBeTruthy();
    });

    test('Setting options', () => {
        // Create LWC
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.options = WEEKDAY_OPTIONS;
        document.body.appendChild(element);

        // Assert that all the desired options are being rendered
        const allListItems = [...element.shadowRoot.querySelectorAll('li')];
        expect(allListItems.length).toBe(WEEKDAY_OPTIONS.length);

        for (let i = 0; i < WEEKDAY_OPTIONS.length; i++) {
            const opt = WEEKDAY_OPTIONS[i];
            const listItem = allListItems[i];

            expect(listItem.textContent).toEqual(opt.label);
        }
    });

    test('Setting options with labels intermixed', () => {
        // All options in dropdown
        const options = [
            {label: 'Winter', value: 'winter', isLabel: true},
            {label: 'December', value: '12', isLabel: false},
            {label: 'January', value: '1', isLabel: false},
            {label: 'February', value: '2', isLabel: false},
            {label: 'Spring', value: 'spring', isLabel: true},
            {label: 'March', value: '3', isLabel: false},
            {label: 'April', value: '4', isLabel: false},
            {label: 'May', value: '5', isLabel: false},
            {label: 'Summer', value: 'summer', isLabel: true},
            {label: 'June', value: '6', isLabel: false},
            {label: 'July', value: '7', isLabel: false},
            {label: 'August', value: '8', isLabel: false},
            {label: 'Autumn', value: 'fall', isLabel: true},
            {label: 'September', value: '9', isLabel: false},
            {label: 'October', value: '10', isLabel: false},
            {label: 'November', value: '11', isLabel: false},
        ];

        // Create LWC
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Month';
        element.options = cloneObj(options);
        document.body.appendChild(element);

        // Assert that all the desired options are being rendered
        const allListItems = [...element.shadowRoot.querySelectorAll('li')];
        expect(allListItems.length).toBe(options.length);

        for (let i = 0; i < options.length; i++) {
            const opt = options[i];
            const listItem = allListItems[i];

            if (opt.isLabel) {
                // Contains label
                expect(listItem.textContent).toEqual(opt.label);
                // Marked as a header
                expect(listItem.querySelector('.slds-listbox__option-header')).toBeTruthy();
                // Not focusable
                expect(listItem.getAttribute('tabindex')).not.toEqual('0');
            } else {
                // Contains label
                expect(listItem.textContent).toEqual(opt.label);
                // Not a header
                expect(listItem.querySelector('.slds-listbox__option-header')).toBeFalsy();
                // Is a normal element
                expect(listItem.querySelector('.slds-media__body')).toBeTruthy();
                // Has value in data-key
                expect(listItem.dataset.key).toEqual(opt.value);
                // Is focusable
                expect(listItem.getAttribute('tabindex')).toEqual('0');
            }
        }
    });

    test('Preselecting options (singleselect)', () => {
        // Create LWC
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.options = WEEKDAY_OPTIONS;
        element.value = 'wed';
        document.body.appendChild(element);

        const allListItems = [...element.shadowRoot.querySelectorAll('li')];

        for (let i = 0; i < WEEKDAY_OPTIONS.length; i++) {
            const opt = WEEKDAY_OPTIONS[i];
            const listItem = allListItems[i];

            // Checkbox is or is not shown
            if ('wed' === opt.value) expect(listItem.querySelector('lightning-icon')).toBeTruthy();
            else expect(listItem.querySelector('lightning-icon')).toBeFalsy();
        }
    });

    test('Preselecting options (multiselect)', () => {
        // Create LWC
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.multiSelect = true;
        element.options = WEEKDAY_OPTIONS;
        element.value = 'mon;sat';
        document.body.appendChild(element);

        const allListItems = [...element.shadowRoot.querySelectorAll('li')];

        for (let i = 0; i < WEEKDAY_OPTIONS.length; i++) {
            const opt = WEEKDAY_OPTIONS[i];
            const listItem = allListItems[i];

            // Checkbox is or is not shown
            if (['mon', 'sat'].includes(opt.value)) expect(listItem.querySelector('lightning-icon')).toBeTruthy();
            else expect(listItem.querySelector('lightning-icon')).toBeFalsy();
        }
    });

    test('Changing options checkboxes (singleselect)', async () => {
        // Create LWC
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.options = WEEKDAY_OPTIONS;
        element.value = 'wed';
        document.body.appendChild(element);

        const allListItems = [...element.shadowRoot.querySelectorAll('li')];

        // Click on dropdown
        element.shadowRoot.querySelector('.slds-input').dispatchEvent(
            new MouseEvent('mousedown', {
                bubbles: true,
            })
        );
        await flushPromises(); // Wait for rerender

        // Click on Saturday
        element.shadowRoot.querySelector('[data-key="sat"]').click();
        await flushPromises(); // Wait for rerender

        // Only Saturday is selected
        for (let i = 0; i < WEEKDAY_OPTIONS.length; i++)
            if ('sat' === WEEKDAY_OPTIONS[i].value)
                expect(allListItems[i].querySelector('lightning-icon')).toBeTruthy();
            else expect(allListItems[i].querySelector('lightning-icon')).toBeFalsy();

        // Click on Thursday
        element.shadowRoot.querySelector('[data-key="thr"]').click();
        await flushPromises(); // Wait for rerender

        // Only Thursday is selected
        for (let i = 0; i < WEEKDAY_OPTIONS.length; i++)
            if ('thr' === WEEKDAY_OPTIONS[i].value)
                expect(allListItems[i].querySelector('lightning-icon')).toBeTruthy();
            else expect(allListItems[i].querySelector('lightning-icon')).toBeFalsy();

        // Click on Thursday
        element.shadowRoot.querySelector('[data-key="thr"]').click();
        await flushPromises(); // Wait for rerender

        // None are selected
        for (let i = 0; i < WEEKDAY_OPTIONS.length; i++)
            expect(allListItems[i].querySelector('lightning-icon')).toBeFalsy();
    });

    test('Changing options checkboxes (multiselect)', async () => {
        // Create LWC
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.options = WEEKDAY_OPTIONS;
        element.multiSelect = true;
        element.value = 'wed';
        document.body.appendChild(element);

        const allListItems = [...element.shadowRoot.querySelectorAll('li')];

        // Click on dropdown
        element.shadowRoot.querySelector('.slds-input').dispatchEvent(
            new MouseEvent('mousedown', {
                bubbles: true,
            })
        );
        await flushPromises(); // Wait for rerender

        // Click on Saturday
        element.shadowRoot.querySelector('[data-key="sat"]').click();
        await flushPromises(); // Wait for rerender

        // Both Wednesday and Saturday are selected
        for (let i = 0; i < WEEKDAY_OPTIONS.length; i++)
            if (['wed', 'sat'].includes(WEEKDAY_OPTIONS[i].value))
                expect(allListItems[i].querySelector('lightning-icon')).toBeTruthy();
            else expect(allListItems[i].querySelector('lightning-icon')).toBeFalsy();

        // Click on Thursday
        element.shadowRoot.querySelector('[data-key="thr"]').click();
        await flushPromises(); // Wait for rerender

        // Wednesday, Thursday, and Saturday are selected
        for (let i = 0; i < WEEKDAY_OPTIONS.length; i++)
            if (['wed', 'thr', 'sat'].includes(WEEKDAY_OPTIONS[i].value))
                expect(allListItems[i].querySelector('lightning-icon')).toBeTruthy();
            else expect(allListItems[i].querySelector('lightning-icon')).toBeFalsy();

        // Click on Saturday
        element.shadowRoot.querySelector('[data-key="sat"]').click();
        await flushPromises(); // Wait for rerender

        // Both Wednesday and Thursday are selected
        for (let i = 0; i < WEEKDAY_OPTIONS.length; i++)
            if (['wed', 'thr'].includes(WEEKDAY_OPTIONS[i].value))
                expect(allListItems[i].querySelector('lightning-icon')).toBeTruthy();
            else expect(allListItems[i].querySelector('lightning-icon')).toBeFalsy();
    });

    test('Changing options events (singleselect)', async () => {
        // Seutp
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.name = 'weekday';
        element.options = WEEKDAY_OPTIONS;
        document.body.appendChild(element);
        const changeHandler = jest.fn();
        element.addEventListener('change', changeHandler);

        // Click on dropdown
        element.shadowRoot.querySelector('.slds-input').dispatchEvent(
            new MouseEvent('mousedown', {
                bubbles: true,
            })
        );
        await flushPromises(); // Wait for rerender

        // Click on Saturday
        changeHandler.mockImplementationOnce((v) => {
            expect(v.detail).toMatchObject({name: 'weekday', value: 'sat'});
        });
        element.shadowRoot.querySelector('[data-key="sat"]').click();
        expect(changeHandler).toHaveBeenCalledTimes(1);

        // Click on Thursday
        changeHandler.mockImplementationOnce((v) => {
            expect(v.detail).toMatchObject({name: 'weekday', value: 'thr'});
        });
        element.shadowRoot.querySelector('[data-key="thr"]').click();
        expect(changeHandler).toHaveBeenCalledTimes(2);

        // Click on Thursday
        changeHandler.mockImplementationOnce((v) => {
            expect(v.detail).toMatchObject({name: 'weekday', value: ''});
        });
        element.shadowRoot.querySelector('[data-key="thr"]').click();
        expect(changeHandler).toHaveBeenCalledTimes(3);
    });

    test('Changing options events (multiselect)', async () => {
        // Create LWC
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.name = 'weekday';
        element.options = WEEKDAY_OPTIONS;
        element.multiSelect = true;
        element.value = 'wed';
        document.body.appendChild(element);
        const changeHandler = jest.fn();
        element.addEventListener('change', changeHandler);

        // Click on dropdown
        element.shadowRoot.querySelector('.slds-input').dispatchEvent(
            new MouseEvent('mousedown', {
                bubbles: true,
            })
        );
        await flushPromises(); // Wait for rerender

        // Click on Saturday
        changeHandler.mockImplementationOnce((v) => {
            expect(v.detail).toMatchObject({name: 'weekday', value: 'wed;sat'});
        });
        element.shadowRoot.querySelector('[data-key="sat"]').click();
        expect(changeHandler).toHaveBeenCalledTimes(1);

        // Click on Thursday
        changeHandler.mockImplementationOnce((v) => {
            expect(v.detail).toMatchObject({name: 'weekday', value: 'wed;sat;thr'});
        });
        element.shadowRoot.querySelector('[data-key="thr"]').click();
        expect(changeHandler).toHaveBeenCalledTimes(2);

        // Click on Thursday
        changeHandler.mockImplementationOnce((v) => {
            expect(v.detail).toMatchObject({name: 'weekday', value: 'sat;thr'});
        });
        element.shadowRoot.querySelector('[data-key="wed"]').click();
        expect(changeHandler).toHaveBeenCalledTimes(3);
    });

    test('Toggle dropdown', async () => {
        // Create LWC
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.name = 'weekday';
        element.options = WEEKDAY_OPTIONS;
        element.multiSelect = true;
        element.value = 'wed';
        document.body.appendChild(element);

        // Starts as closed
        expect(element.shadowRoot.querySelector('.slds-combobox').classList).not.toContain('slds-is-open');

        // Click on dropdown
        element.shadowRoot.querySelector('.slds-input').dispatchEvent(
            new MouseEvent('mousedown', {
                bubbles: true,
            })
        );
        await flushPromises(); // Wait for rerender

        // Is now open
        expect(element.shadowRoot.querySelector('.slds-combobox').classList).toContain('slds-is-open');

        // Click on dropdown
        element.shadowRoot.querySelector('.slds-input').dispatchEvent(
            new MouseEvent('mousedown', {
                bubbles: true,
            })
        );
        await flushPromises(); // Wait for rerender

        // Is now closed
        expect(element.shadowRoot.querySelector('.slds-combobox').classList).not.toContain('slds-is-open');
    });

    test('Autoclose dropdown for singleselect', async () => {
        // Seutp
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.name = 'weekday';
        element.options = WEEKDAY_OPTIONS;
        document.body.appendChild(element);
        const commitHandler = jest.fn();
        element.addEventListener('commit', commitHandler);

        // Click on dropdown
        element.shadowRoot.querySelector('.slds-input').dispatchEvent(
            new MouseEvent('mousedown', {
                bubbles: true,
            })
        );
        await flushPromises(); // Wait for rerender

        // Is now open
        expect(element.shadowRoot.querySelector('.slds-combobox').classList).toContain('slds-is-open');

        // Click on Saturday
        element.shadowRoot.querySelector('[data-key="sat"]').click();
        await flushPromises(); // Wait for rerender

        // Is now closed
        expect(element.shadowRoot.querySelector('.slds-combobox').classList).not.toContain('slds-is-open');
    });

    test('Do not autoclose dropdown for multiselect', async () => {
        // Seutp
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.name = 'weekday';
        element.multiSelect = true;
        element.options = WEEKDAY_OPTIONS;
        document.body.appendChild(element);
        const commitHandler = jest.fn();
        element.addEventListener('commit', commitHandler);

        // Click on dropdown
        element.shadowRoot.querySelector('.slds-input').dispatchEvent(
            new MouseEvent('mousedown', {
                bubbles: true,
            })
        );
        await flushPromises(); // Wait for rerender

        // Is now open
        expect(element.shadowRoot.querySelector('.slds-combobox').classList).toContain('slds-is-open');

        // Click on Saturday
        element.shadowRoot.querySelector('[data-key="sat"]').click();
        await flushPromises(); // Wait for rerender

        // Is still open
        expect(element.shadowRoot.querySelector('.slds-combobox').classList).toContain('slds-is-open');
    });

    test('Commit events when close dropdown (singleselect)', async () => {
        // Seutp
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.name = 'weekday';
        element.options = WEEKDAY_OPTIONS;
        document.body.appendChild(element);
        const commitHandler = jest.fn();
        element.addEventListener('commit', commitHandler);

        // Click on dropdown
        element.shadowRoot.querySelector('.slds-input').dispatchEvent(
            new MouseEvent('mousedown', {
                bubbles: true,
            })
        );
        await flushPromises(); // Wait for rerender

        // Called with correct event
        commitHandler.mockImplementationOnce((v) => {
            expect(v.detail).toMatchObject({name: 'weekday', value: 'sat'});
        });

        // Click on Saturday
        element.shadowRoot.querySelector('[data-key="sat"]').click();
        await flushPromises(); // Wait for rerender

        // Commit event raised
        expect(commitHandler).toHaveBeenCalledTimes(1);
    });

    test('Commit events when close dropdown (multiselect)', async () => {
        // Seutp
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.name = 'weekday';
        element.options = WEEKDAY_OPTIONS;
        document.body.appendChild(element);
        const commitHandler = jest.fn();
        element.addEventListener('commit', commitHandler);

        // Click on dropdown
        element.shadowRoot.querySelector('.slds-input').dispatchEvent(
            new MouseEvent('mousedown', {
                bubbles: true,
            })
        );
        await flushPromises(); // Wait for rerender

        // Click on Saturday
        element.shadowRoot.querySelector('[data-key="sat"]').click();
        await flushPromises(); // Wait for rerender

        // Click on Thursday
        element.shadowRoot.querySelector('[data-key="thr"]').click();
        await flushPromises(); // Wait for rerender

        // Called with correct event
        commitHandler.mockImplementationOnce((v) => {
            expect(v.detail).toMatchObject({name: 'weekday', value: 'thr'});
        });

        // Close dropdown
        element.shadowRoot.querySelector('.slds-input').dispatchEvent(
            new MouseEvent('mousedown', {
                bubbles: true,
            })
        );
        await flushPromises(); // Wait for rerender

        // Commit event raised
        expect(commitHandler).toHaveBeenCalledTimes(1);
    });

    test('Placeholder none selected', () => {
        // Seutp
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.options = WEEKDAY_OPTIONS;
        document.body.appendChild(element);

        // Correct placeholder label
        expect(element.shadowRoot.querySelector('input').placeholder).toContain('Select an Option');
    });

    test('Placeholder (singleselect)', () => {
        // Seutp
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.options = WEEKDAY_OPTIONS;
        element.value = 'wed';
        document.body.appendChild(element);

        // Correct placeholder label
        expect(element.shadowRoot.querySelector('input').placeholder).toContain('Wednesday');
    });

    test('Placeholder (multiselect, 1)', () => {
        // Seutp
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.options = WEEKDAY_OPTIONS;
        element.multiSelect = true;
        element.value = 'wed';
        document.body.appendChild(element);

        // Correct placeholder label
        expect(element.shadowRoot.querySelector('input').placeholder).toContain('1 Option Selected');
    });

    test('Placeholder (multiselect, >1)', () => {
        // Seutp
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.options = WEEKDAY_OPTIONS;
        element.multiSelect = true;
        element.value = 'wed;sat;mon';
        document.body.appendChild(element);

        // Correct placeholder label
        expect(element.shadowRoot.querySelector('input').placeholder).toContain('3 Options Selected');
    });

    test('Show spinner', async () => {
        // Seutp
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.options = WEEKDAY_OPTIONS;
        element.value = 'mon';
        element.spinnerActive = true;
        document.body.appendChild(element);

        // Shows spinner
        expect(element.shadowRoot.querySelector('.slds-input__icon lightning-spinner')).toBeTruthy();

        // Turn off spinner
        element.spinnerActive = false;
        await flushPromises(); // await rerender

        // Hides spinner
        expect(element.shadowRoot.querySelector('.slds-input__icon lightning-spinner')).toBeFalsy();
    });

    test('Search filter', async () => {
        // Seutp
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.options = WEEKDAY_OPTIONS;
        element.searchable = true;
        document.body.appendChild(element);

        // Enter search text
        element.shadowRoot.querySelector('input').value = 'S';
        element.shadowRoot.querySelector('input').dispatchEvent(new CustomEvent('input'));
        await flushPromises(); // await rerender

        // Check list is filtered
        let allListItems = [...element.shadowRoot.querySelectorAll('li')];

        expect(allListItems.length).toEqual(5);

        expect(allListItems[0].textContent).toEqual('Tuesday');
        expect(allListItems[1].textContent).toEqual('Wednesday');
        expect(allListItems[2].textContent).toEqual('Thursday');
        expect(allListItems[3].textContent).toEqual('Saturday');
        expect(allListItems[4].textContent).toEqual('Sunday');

        // Enter search text
        element.shadowRoot.querySelector('input').value = 'Sa';
        element.shadowRoot.querySelector('input').dispatchEvent(new CustomEvent('input'));
        await flushPromises(); // await rerender

        // Check list is filtered
        allListItems = [...element.shadowRoot.querySelectorAll('li')];

        expect(allListItems.length).toEqual(1);

        expect(allListItems[0].textContent).toEqual('Saturday');
    });

    test('Invalid preselection events', async () => {
        // Create LWC
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.name = 'lucky_numbers';
        element.options = [
            {label: '1', value: '1'},
            {label: '2', value: '2'},
            {label: '3', value: '3'},
        ];
        element.multiSelect = true;
        element.value = '2;4';

        const changeHandler = jest.fn();
        const commitHandler = jest.fn();

        changeHandler.mockImplementationOnce((v) => {
            expect(v.detail).toMatchObject({
                name: 'lucky_numbers',
                value: '2',
            });
        });
        commitHandler.mockImplementationOnce((v) => {
            expect(v.detail).toMatchObject({
                name: 'lucky_numbers',
                value: '2',
            });
        });

        element.addEventListener('change', changeHandler);
        element.addEventListener('commit', commitHandler);

        // Add to page
        document.body.appendChild(element);

        // Let it render
        await flushPromises();

        expect(changeHandler).toHaveBeenCalledTimes(1);
        expect(commitHandler).toHaveBeenCalledTimes(1);
    });

    test('Changing valid options dynamically', async () => {
        // Create LWC
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.name = 'lucky_numbers';
        element.options = [
            {label: '1', value: '1'},
            {label: '2', value: '2'},
            {label: '3', value: '3'},
        ];
        element.multiSelect = true;
        element.value = '2;4';

        const changeHandler = jest.fn();
        const commitHandler = jest.fn();

        element.addEventListener('change', changeHandler);
        element.addEventListener('commit', commitHandler);

        // Add to page
        document.body.appendChild(element);
        await flushPromises(); // Let it render

        changeHandler.mockImplementationOnce((v) => {
            expect(v.detail).toMatchObject({
                name: 'lucky_numbers',
                value: '2;4',
            });
        });
        commitHandler.mockImplementationOnce((v) => {
            expect(v.detail).toMatchObject({
                name: 'lucky_numbers',
                value: '2;4',
            });
        });

        // Change the options list to include selected value (i.e. the conditional options finished loading)

        element.options = [
            {label: '1', value: '1'},
            {label: '2', value: '2'},
            {label: '3', value: '3'},
            {label: '4', value: '4'},
            {label: '5', value: '5'},
        ];
        expect(changeHandler).toHaveBeenCalledTimes(2);
        expect(commitHandler).toHaveBeenCalledTimes(2);
    });
});
