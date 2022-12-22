import {createElement} from 'lwc';
import LightningComboBox from 'c/lightningComboBox';
import {cloneObj} from 'c/helperFunctions';

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

        // Act
        document.body.appendChild(element);

        // Assert that the label is not rendered (since it is unset)
        expect(element.shadowRoot.querySelector('[data-testid="combobox-label"]')).toBeFalsy();
    });

    test('Setting dropdown label', () => {
        const expectedLabel = 'City';

        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = expectedLabel;

        // Act
        document.body.appendChild(element);

        // Assert that the label is rendered and equal to the set label
        expect(element.shadowRoot.querySelector('[data-testid="combobox-label"]').innerHTML).toBe(expectedLabel);
    });

    test('Not setting required flag', () => {
        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';

        // Act
        document.body.appendChild(element);

        // Assert that the required flag is not rendered
        expect(element.shadowRoot.querySelector('[data-testid="required-flag"]')).toBeFalsy();
    });

    test('Setting required flag (boolean)', () => {
        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.required = true;

        // Act
        document.body.appendChild(element);

        // Assert that the required flag is rendered
        expect(element.shadowRoot.querySelector('[data-testid="required-flag"]')).toBeTruthy();
    });

    test('Setting required flag (string)', () => {
        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.required = 'true';

        // Act
        document.body.appendChild(element);

        // Assert that the required flag is rendered
        expect(element.shadowRoot.querySelector('[data-testid="required-flag"]')).toBeTruthy();
    });

    test('Checking validity', () => {
        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.required = 'true';

        // Act
        document.body.appendChild(element);

        // Assert that not valid since no options are selected
        expect(element.checkValidity()).toBeFalsy();

        // Rerender would be async - so need promise chain (but we expect no rerender to happen in this case - we just are verifying that it isn't)
        return Promise.resolve().then(() => {
            // Assert that the error message is not being shown
            expect(element.shadowRoot.querySelector('[data-testid="error-warning"]')).toBeFalsy();
        });
    });

    test('Reporting validity', () => {
        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.required = 'true';

        // Act
        document.body.appendChild(element);

        // Assert that not valid since no options are selected
        expect(element.reportValidity()).toBeFalsy();

        // Rerender is async - so need promise chain
        return Promise.resolve().then(() => {
            // Assert that the error message is being shown
            expect(element.shadowRoot.querySelector('[data-testid="error-warning"]')).toBeTruthy();
        });
    });

    test('Setting options', () => {
        const options = [
            {label: 'Monday', value: 'mon', isLabel: false},
            {label: 'Tuesday', value: 'tue', isLabel: false},
            {label: 'Wednesday', value: 'wed', isLabel: false},
            {label: 'Thursday', value: 'thr', isLabel: false},
            {label: 'Friday', value: 'fri', isLabel: false},
            {label: 'Saturday', value: 'sat', isLabel: false},
            {label: 'Sunday', value: 'sun', isLabel: false},
        ];

        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.required = 'false';
        element.options = cloneObj(options);

        // Act
        document.body.appendChild(element);

        // Assert that all the desired options are being rendered
        const allRenderedOptions = element.shadowRoot.querySelectorAll('[data-testid="dropdown-option"]');
        expect(allRenderedOptions.length).toBe(options.length);

        // Each of the options is rendered
        for (let i = 0; i < options.length; i++) {
            const opt = options[i];
            let wasFound = false;
            for (let j = 0; j < allRenderedOptions.length; j++) {
                const renderedOpt = allRenderedOptions[j];

                if (renderedOpt.querySelector('.slds-media').innerHTML == opt.label) wasFound = true;
            }

            expect(wasFound).toBeTruthy();
        }

        // Each of the rendered options matches one specified option
        for (let i = 0; i < allRenderedOptions.length; i++) {
            const renderedOpt = allRenderedOptions[i];
            let matchedASpecifiedOpt = false;
            for (let j = 0; j < options.length; j++) {
                const opt = options[j];

                if (renderedOpt.querySelector('.slds-media').innerHTML == opt.label) matchedASpecifiedOpt = true;
            }

            expect(matchedASpecifiedOpt).toBeTruthy();
        }
    });

    test('Setting options with labels intermixed', () => {
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

        const selectableOptions = []; // should end up with months
        for (let i = 0; i < options.length; i++) if (!options[i].isLabel) selectableOptions.push(options[i]);

        const nonselectableLabels = []; // should end up with seasons
        for (let i = 0; i < options.length; i++) if (options[i].isLabel) nonselectableLabels.push(options[i]);

        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Month';
        element.required = 'false';
        element.options = cloneObj(options);

        // Act
        document.body.appendChild(element);

        // Assert that all the desired options are being rendered
        const allRenderedOptions = element.shadowRoot.querySelectorAll('[data-testid="dropdown-option"]');
        expect(allRenderedOptions.length).toBe(selectableOptions.length);

        // Each of the options is rendered
        for (let i = 0; i < selectableOptions.length; i++) {
            const opt = selectableOptions[i];
            let wasFound = false;
            for (let j = 0; j < allRenderedOptions.length; j++) {
                const renderedOpt = allRenderedOptions[j];

                if (renderedOpt.querySelector('.slds-media').innerHTML == opt.label) wasFound = true;
            }

            expect(wasFound).toBeTruthy();
        }

        // Each of the rendered options matches one specified option
        for (let i = 0; i < allRenderedOptions.length; i++) {
            const renderedOpt = allRenderedOptions[i];
            let matchedASpecifiedOpt = false;
            for (let j = 0; j < selectableOptions.length; j++) {
                const opt = selectableOptions[j];

                if (renderedOpt.querySelector('.slds-media').innerHTML == opt.label) matchedASpecifiedOpt = true;
            }

            expect(matchedASpecifiedOpt).toBeTruthy();
        }

        // Assert that all the desired labels are being rendered
        const allRenderedLabels = element.shadowRoot.querySelectorAll('[data-testid="dropdown-label"]');
        expect(allRenderedLabels.length).toBe(nonselectableLabels.length);

        // Each of the labels is rendered
        for (let i = 0; i < nonselectableLabels.length; i++) {
            const opt = nonselectableLabels[i];
            let wasFound = false;
            for (let j = 0; j < allRenderedLabels.length; j++) {
                const renderedOpt = allRenderedLabels[j];

                if (renderedOpt.querySelector('.slds-media__body').querySelector('h3').innerHTML == opt.label)
                    wasFound = true;
            }

            expect(wasFound).toBeTruthy();
        }

        // Each of the rendered labels matches one specified labels
        for (let i = 0; i < allRenderedLabels.length; i++) {
            const renderedOpt = allRenderedLabels[i];
            let matchedASpecifiedOpt = false;
            for (let j = 0; j < nonselectableLabels.length; j++) {
                const opt = nonselectableLabels[j];

                if (renderedOpt.querySelector('.slds-media__body').querySelector('h3').innerHTML == opt.label)
                    matchedASpecifiedOpt = true;
            }

            expect(matchedASpecifiedOpt).toBeTruthy();
        }
    });

    test('Preselecting options (multiselect)', () => {
        const options = [
            {label: 'Monday', value: 'mon', isLabel: false},
            {label: 'Tuesday', value: 'tue', isLabel: false},
            {label: 'Wednesday', value: 'wed', isLabel: false},
            {label: 'Thursday', value: 'thr', isLabel: false},
            {label: 'Friday', value: 'fri', isLabel: false},
            {label: 'Saturday', value: 'sat', isLabel: false},
            {label: 'Sunday', value: 'sun', isLabel: false},
        ];
        const specifiedSelectedValues = 'sat;mon';
        const expectedSelectedValues = ['mon', 'sat'];

        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.required = 'true';
        element.multiSelect = 'true';
        element.options = options;
        element.value = specifiedSelectedValues;

        // Act
        document.body.appendChild(element);

        // Assert that all options are rendered
        const allRenderedOptions = element.shadowRoot.querySelectorAll('[data-testid="dropdown-option"]');
        expect(allRenderedOptions.length).toBe(options.length); // options are rendered

        assertCorrectCheckmarks(expectedSelectedValues, element.shadowRoot.querySelector('.slds-listbox'));
    });

    test('Preselecting options (singleselect)', () => {
        const options = [
            {label: 'Monday', value: 'mon', isLabel: false},
            {label: 'Tuesday', value: 'tue', isLabel: false},
            {label: 'Wednesday', value: 'wed', isLabel: false},
            {label: 'Thursday', value: 'thr', isLabel: false},
            {label: 'Friday', value: 'fri', isLabel: false},
            {label: 'Saturday', value: 'sat', isLabel: false},
            {label: 'Sunday', value: 'sun', isLabel: false},
        ];
        const specifiedSelectedValues = 'sat;mon'; // will be cut down to whichever if first in the options list since this is not multiselect
        const expectedSelectedValues = ['mon'];

        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.required = 'true';
        element.multiSelect = 'false';
        element.options = options;
        element.value = specifiedSelectedValues;

        // Act
        document.body.appendChild(element);

        // Assert that all options are rendered
        const allRenderedOptions = element.shadowRoot.querySelectorAll('[data-testid="dropdown-option"]');
        expect(allRenderedOptions.length).toBe(options.length); // options are rendered

        assertCorrectCheckmarks(expectedSelectedValues, element.shadowRoot.querySelector('.slds-listbox'));
    });

    test('Changing options (singleselect)', () => {
        const options = [
            {label: 'Monday', value: 'mon', isLabel: false},
            {label: 'Tuesday', value: 'tue', isLabel: false},
            {label: 'Wednesday', value: 'wed', isLabel: false},
            {label: 'Thursday', value: 'thr', isLabel: false},
            {label: 'Friday', value: 'fri', isLabel: false},
            {label: 'Saturday', value: 'sat', isLabel: false},
            {label: 'Sunday', value: 'sun', isLabel: false},
        ];
        let expectedSelectedValues = [];

        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.required = 'true';
        element.multiSelect = 'false';
        element.options = options;
        element.value = '';

        // Act
        document.body.appendChild(element);

        // Assert that all options are rendered
        let listBox = element.shadowRoot.querySelector('.slds-listbox');
        let allRenderedOptions = element.shadowRoot.querySelectorAll('[data-testid="dropdown-option"]');
        expect(allRenderedOptions.length).toBe(options.length); // options are rendered

        // ACT - Change selection to MONDAY
        listBox.querySelector('[data-id="mon"]').dispatchEvent(new Event('mousedown', {bubbles: true})); // select monday option
        expectedSelectedValues = ['mon'];

        // Async changes mean we need to use a promise chain
        return Promise.resolve()
            .then(() => {
                // Assert only MONDAY is checked
                assertCorrectCheckmarks(expectedSelectedValues, listBox);

                // ACT - Change selection to WEDNESDAY
                listBox.querySelector('[data-id="wed"]').dispatchEvent(new Event('mousedown', {bubbles: true})); // select wednesday option
                expectedSelectedValues = ['wed'];

                return Promise.resolve();
            })
            .then(() => {
                // Assert only WEDNESDAY is checked
                assertCorrectCheckmarks(expectedSelectedValues, listBox);

                // ACT - Deselect WEDNESDAY
                listBox.querySelector('[data-id="wed"]').dispatchEvent(new Event('mousedown', {bubbles: true})); // unselect wednesday option
                expectedSelectedValues = [];

                return Promise.resolve();
            })
            .then(() => {
                // Assert nothing is checked
                assertCorrectCheckmarks(expectedSelectedValues, listBox);
            });
    });

    test('Changing options (multiselect)', () => {
        const options = [
            {label: 'Monday', value: 'mon', isLabel: false},
            {label: 'Tuesday', value: 'tue', isLabel: false},
            {label: 'Wednesday', value: 'wed', isLabel: false},
            {label: 'Thursday', value: 'thr', isLabel: false},
            {label: 'Friday', value: 'fri', isLabel: false},
            {label: 'Saturday', value: 'sat', isLabel: false},
            {label: 'Sunday', value: 'sun', isLabel: false},
        ];
        let expectedSelectedValues = [];

        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningComboBox,
        });
        element.label = 'Weekday';
        element.required = 'true';
        element.multiSelect = 'true';
        element.options = options;
        element.value = '';

        // Act
        document.body.appendChild(element);

        // Assert that all options are rendered
        let listBox = element.shadowRoot.querySelector('.slds-listbox');
        let allRenderedOptions = element.shadowRoot.querySelectorAll('[data-testid="dropdown-option"]');
        expect(allRenderedOptions.length).toBe(options.length); // options are rendered

        // ACT - Change selection to MONDAY
        listBox.querySelector('[data-id="mon"]').dispatchEvent(new Event('mousedown', {bubbles: true})); // select monday option
        expectedSelectedValues = ['mon'];

        // Async changes mean we need to use a promise chain
        return Promise.resolve()
            .then(() => {
                // Assert only MONDAY is checked
                assertCorrectCheckmarks(expectedSelectedValues, listBox);

                // ACT - Also select WEDNESDAY
                listBox.querySelector('[data-id="wed"]').dispatchEvent(new Event('mousedown', {bubbles: true})); // select wednesday option
                expectedSelectedValues = ['mon', 'wed'];

                return Promise.resolve();
            })
            .then(() => {
                // Assert MONDAY and WEDNESDAY are checked
                assertCorrectCheckmarks(expectedSelectedValues, listBox);

                // ACT - Deselect MONDAY
                listBox.querySelector('[data-id="mon"]').dispatchEvent(new Event('mousedown', {bubbles: true})); // unselect monday option
                expectedSelectedValues = ['wed'];

                return Promise.resolve();
            })
            .then(() => {
                // Assert only WEDNESDAY is checked
                assertCorrectCheckmarks(expectedSelectedValues, listBox);
            });
    });
});

function assertCorrectCheckmarks(expectedValues, listBoxElem) {
    expect(listBoxElem.querySelectorAll('lightning-icon').length).toBe(expectedValues.length); // Assert correct number of checkmarks
    const allRenderedOptions = listBoxElem.querySelectorAll('[data-testid="dropdown-option"]');

    // Make sure checkmarks line up with desired options
    for (let i = 0; i < allRenderedOptions.length; i++) {
        const renderedOpt = allRenderedOptions[i];

        // if this value is one that is meant to be selected
        if (expectedValues.includes(renderedOpt.dataset.id)) {
            expect(renderedOpt.querySelector('lightning-icon')).toBeTruthy(); // then it should have a checkmark
        } else {
            expect(renderedOpt.querySelector('lightning-icon')).toBeFalsy(); // otherwise, no checkmark
        }
    }
}
