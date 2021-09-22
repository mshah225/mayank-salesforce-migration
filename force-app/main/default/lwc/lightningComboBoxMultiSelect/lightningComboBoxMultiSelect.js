/* eslint-disable no-console */
import {LightningElement, api} from 'lwc';

export default class LightningComboBoxMultiSelect extends LightningElement {
    @api get label() {
        return this._label;
    }
    set label(val) {
        this._label = val;
        this._labelForDiv = val + ' Options';
        this._labelForUl = val + ' Options List';
    }
    @api placeholder = '--Select--';
    @api required = false;
    @api variant = 'standard'; // Use only null, standard, or label-hidden

    @api get value() {
        const selectedValues = [];
        for (let i = 0; i < this._options.length; i++) {
            const opt = this._options[i];
            if (opt.isSelected) {
                selectedValues.push(opt.value.toLowerCase());
            }
        }
        return selectedValues.join(';');
    }
    set value(val) {
        const selectedValues = val.toLowerCase().split(';');
        for (let i = 0; i < this._options.length; i++) {
            const opt = this._options[i];
            if (selectedValues.includes(opt.value.toLowerCase())) {
                opt.isSelected = true;
            } else {
                opt.isSelected = false;
            }
        }
        this._value = val;
        this.updatePlacard();
    }

    @api get options() {
        return this._options;
    }
    set options(val) {
        // Create proper objects
        const newOptions = [];
        const oldOptions = this._options;
        for (let i = 0; i < val.length; i++) {
            newOptions.push({label: val[i].label, value: val[i].value, isSelected: false});
        }
        this._options = newOptions;

        // Mark is length > 0
        if (this._options.length > 0) {
            this.hasOptions = true;
        } else {
            this.hasOptions = false;
        }

        // Mark any values that are selected in set value
        const selectedValues = this._value.toLowerCase().split(';');
        for (let i = 0; i < this._options.length; i++) {
            const opt = this._options[i];
            if (selectedValues.includes(opt.value.toLowerCase())) {
                opt.isSelected = true;
            }
        }
        // Mark any options that match old option list
        const oldOptionSelectedList = [];
        for (let i = 0; i < oldOptions.length; i++) {
            const opt = oldOptions[i];
            if (opt.isSelected) {
                oldOptionSelectedList.push(opt.value.toLowerCase());
            }
        }
        for (let i = 0; i < this._options.length; i++) {
            const opt = this._options[i];
            if (oldOptionSelectedList.includes(opt.value.toLowerCase())) {
                opt.isSelected = true;
            }
        }

        this.updatePlacard();
    }

    _label = '';
    _labelForDiv = '';
    _labelForUl = '';
    _value = '';
    _options = [];
    hasOptions = false;
    shownPlacard = '';
    comboboxClasses = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    shown = 'false';

    connectedCallback() {
        this.shownPlacard = this.placeholder;
    }

    @api resetMultiSelect() {
        for (let i = 0; i < this._options.length; i++) {
            this._options[i].isSelected = false;
        }
        this._value = '';
        this.shownPlacard = this.placeholder;
        this.updateValue();
    }

    toggleDropdown() {
        const openClass = 'slds-is-open';
        const classList = this.comboboxClasses.split(' ');
        if (classList.includes(openClass)) {
            classList.splice(classList.indexOf(openClass), 1);
            this.shown = 'false';
        } else {
            classList.push(openClass);
            this.template.querySelector('.focusWrapper').focus();
            this.shown = 'true';
        }
        this.comboboxClasses = classList.join(' ');
    }
    closeDropdown() {
        const openClass = 'slds-is-open';
        const classList = this.comboboxClasses.split(' ');
        if (classList.includes(openClass)) {
            classList.splice(classList.indexOf(openClass), 1);
        }
        this.comboboxClasses = classList.join(' ');
        this.shown = 'false';
    }

    toggleOption(event) {
        const clickedVal = event.currentTarget.dataset.value;
        for (let i = 0; i < this._options.length; i++) {
            const opt = this._options[i];
            if (opt.value === clickedVal) {
                if (opt.isSelected) {
                    opt.isSelected = false;
                } else {
                    opt.isSelected = true;
                }
            }
        }

        this.updatePlacard();

        this.updateValue();
    }

    updateValue() {
        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: this.value,
                },
            })
        );
    }

    updatePlacard() {
        let countSelected = 0;
        for (let i = 0; i < this._options.length; i++) {
            if (this._options[i].isSelected) countSelected++;
        }
        if (countSelected === 0) {
            this.shownPlacard = this.placeholder;
        } else if (countSelected === 1) {
            this.shownPlacard = '1 option selected';
        } else if (countSelected > 1) {
            this.shownPlacard = countSelected + ' options selected';
        }
    }
}
