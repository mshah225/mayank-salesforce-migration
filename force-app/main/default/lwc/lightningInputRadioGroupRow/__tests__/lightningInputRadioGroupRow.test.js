/* eslint-disable no-undef */
import {createElement} from 'lwc';
import LightningInputRadioGroupRow from 'c/lightningInputRadioGroupRow';

describe('c-lightning-input-radio-group-row', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Set label', () => {
        const element = createElement('c-lightning-input-radio-group-row', {
            is: LightningInputRadioGroupRow,
        });
        element.label = 'View cases for';
        document.body.appendChild(element);

        expect(element.shadowRoot.querySelector('.slds-form-element__label').textContent).toContain('View cases for');
    });

    test('Set options', () => {
        const element = createElement('c-lightning-input-radio-group-row', {
            is: LightningInputRadioGroupRow,
        });
        element.label = 'View cases for';
        element.options = [
            {label: 'Undergraduate', value: 'UGRD'},
            {label: 'Graduate', value: 'GRD'},
        ];
        document.body.appendChild(element);

        const options = [...element.shadowRoot.querySelectorAll('.option')];

        expect(options).toHaveLength(2);
        expect(options[0].textContent).toContain('Undergraduate');
        expect(options[1].textContent).toContain('Graduate');
    });

    test('Preselect value', () => {
        const element = createElement('c-lightning-input-radio-group-row', {
            is: LightningInputRadioGroupRow,
        });
        element.options = [
            {label: 'Undergraduate', value: 'UGRD'},
            {label: 'Graduate', value: 'GRD'},
        ];
        element.value = 'GRD';
        document.body.appendChild(element);

        const options = [...element.shadowRoot.querySelectorAll('.option')];

        expect(options[0].querySelector('input').checked).toBeFalsy();
        expect(options[1].querySelector('input').checked).toBeTruthy();
    });

    test('Clicking on a value, visual display', () => {
        const element = createElement('c-lightning-input-radio-group-row', {
            is: LightningInputRadioGroupRow,
        });
        element.options = [
            {label: 'Undergraduate', value: 'UGRD'},
            {label: 'Graduate', value: 'GRD'},
        ];
        document.body.appendChild(element);

        const options = [...element.shadowRoot.querySelectorAll('.option')];

        options[1].click();

        expect(options[0].querySelector('input').checked).toBeFalsy();
        expect(options[1].querySelector('input').checked).toBeTruthy();
    });

    test('Clicking on a value, raises change events', () => {
        const element = createElement('c-lightning-input-radio-group-row', {
            is: LightningInputRadioGroupRow,
        });
        element.options = [
            {label: 'Undergraduate', value: 'UGRD'},
            {label: 'Graduate', value: 'GRD'},
        ];
        document.body.appendChild(element);
        const changeHandler = jest.fn((evnt) => {
            expect(evnt.detail).toMatchObject({value: 'GRD'});
        });
        element.addEventListener('change', changeHandler);

        const options = [...element.shadowRoot.querySelectorAll('.option')];

        options[1].click();

        expect(changeHandler).toHaveBeenCalled();
    });

    test('Does not raise extra events', () => {
        const element = createElement('c-lightning-input-radio-group-row', {
            is: LightningInputRadioGroupRow,
        });
        element.options = [
            {label: 'Undergraduate', value: 'UGRD'},
            {label: 'Graduate', value: 'GRD'},
        ];
        document.body.appendChild(element);
        const changeHandler = jest.fn();
        element.addEventListener('change', changeHandler);

        const options = [...element.shadowRoot.querySelectorAll('.option')];

        options[1].click();
        options[1].click();
        options[1].click();

        expect(changeHandler).toHaveBeenCalledTimes(1);
    });

    test('Alternating value, raises events', () => {
        const element = createElement('c-lightning-input-radio-group-row', {
            is: LightningInputRadioGroupRow,
        });
        element.options = [
            {label: 'Undergraduate', value: 'UGRD'},
            {label: 'Graduate', value: 'GRD'},
        ];
        document.body.appendChild(element);
        const changeHandler = jest.fn();
        element.addEventListener('change', changeHandler);

        const options = [...element.shadowRoot.querySelectorAll('.option')];

        changeHandler.mockImplementationOnce((v) => {
            expect(v.detail).toMatchObject({value: 'GRD'});
        });
        options[1].click();

        changeHandler.mockImplementationOnce((v) => {
            expect(v.detail).toMatchObject({value: 'UGRD'});
        });
        options[0].click();

        changeHandler.mockImplementationOnce((v) => {
            expect(v.detail).toMatchObject({value: 'GRD'});
        });
        options[1].click();

        expect(changeHandler).toHaveBeenCalledTimes(3);
    });
});
