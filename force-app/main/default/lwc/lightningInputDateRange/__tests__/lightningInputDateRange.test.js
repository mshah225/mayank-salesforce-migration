/* eslint-disable no-undef */
import {createElement} from 'lwc';
import LightningInputDateRange from 'c/lightningInputDateRange';

describe('c-lightning-input-date-range', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Set label', () => {
        const element = createElement('c-lightning-input-date-range', {
            is: LightningInputDateRange,
        });
        element.label = 'Created Date';
        document.body.appendChild(element);

        expect(element.shadowRoot.querySelector('.slds-form-element__label').textContent).toContain('Created Date');
    });

    test('Preset values', () => {
        const element = createElement('c-lightning-input-date-range', {
            is: LightningInputDateRange,
        });
        element.label = 'Created Date';
        element.fromValue = '2020-04-01';
        element.toValue = '2020-06-01';
        document.body.appendChild(element);

        const allInputs = [...element.shadowRoot.querySelectorAll('lightning-input')];

        expect(allInputs[0].value).toEqual('2020-04-01');
        expect(allInputs[1].value).toEqual('2020-06-01');
    });

    test('Change from date', () => {
        const element = createElement('c-lightning-input-date-range', {
            is: LightningInputDateRange,
        });
        element.label = 'Created Date';
        document.body.appendChild(element);
        const changeHandler = jest.fn((evnt) => {
            expect(evnt.detail).toMatchObject({
                value: {
                    from: '2020-04-01',
                },
            });
        });
        element.addEventListener('change', changeHandler);

        const allInputs = [...element.shadowRoot.querySelectorAll('lightning-input')];

        // Change from date
        allInputs[0].dispatchEvent(new CustomEvent('change', {detail: {value: '2020-04-01'}}));

        expect(changeHandler).toHaveBeenCalled();
    });

    test('Change to date', () => {
        const element = createElement('c-lightning-input-date-range', {
            is: LightningInputDateRange,
        });
        element.label = 'Created Date';
        document.body.appendChild(element);
        const changeHandler = jest.fn((evnt) => {
            expect(evnt.detail).toMatchObject({
                value: {
                    to: '2020-06-01',
                },
            });
        });
        element.addEventListener('change', changeHandler);

        const allInputs = [...element.shadowRoot.querySelectorAll('lightning-input')];

        // Change to date
        allInputs[1].dispatchEvent(new CustomEvent('change', {detail: {value: '2020-06-01'}}));

        expect(changeHandler).toHaveBeenCalled();
    });

    test('Change to and from date', () => {
        const element = createElement('c-lightning-input-date-range', {
            is: LightningInputDateRange,
        });
        element.label = 'Created Date';
        document.body.appendChild(element);

        const allInputs = [...element.shadowRoot.querySelectorAll('lightning-input')];

        // Change from date
        allInputs[0].dispatchEvent(new CustomEvent('change', {detail: {value: '2020-04-01'}}));

        // Add listener now that first change event has fired
        const changeHandler = jest.fn((evnt) => {
            expect(evnt.detail).toMatchObject({
                value: {
                    from: '2020-04-01',
                    to: '2020-06-01',
                },
            });
        });
        element.addEventListener('change', changeHandler);

        // Change to date
        allInputs[1].dispatchEvent(new CustomEvent('change', {detail: {value: '2020-06-01'}}));

        expect(changeHandler).toHaveBeenCalled();
    });
});
