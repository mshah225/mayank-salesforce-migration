/* eslint-disable no-console */
import {LightningElement, api} from 'lwc';

export default class LightningComboBoxMultiSelect extends LightningElement {
    @api label = '';
    @api placeholder = 'Select an Option';
    @api required = false;
    @api variant = 'standard'; // Use only null, standard, or label-hidden

    set singleSelect(val) {
        let newVal = val;
        if (typeof newVal === 'string') {
            newVal = newVal === 'true';
        }
        this._singleSelect = newVal;
    }
    @api get singleSelect() {
        return this._singleSelect;
    }
    _singleSelect = false;

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
    }
    @api get value() {
        const selectedValues = [];
        for (let i = 0; i < this._options.length; i++) {
            const opt = this._options[i];
            if (opt.isSelected) {
                selectedValues.push(opt.value.toLowerCase());
                if (this.singleSelect) break; //only the first one for singleSelect mode
            }
        }
        return selectedValues.join(';');
    }
    _value = '';

    @api get options() {
        return this._options;
    }
    set options(val) {
        // Create proper objects
        const newOptions = [];
        const oldOptions = this._options;
        let foundOne = false;
        for (let i = 0; i < val.length; i++) {
            const opt = val[i];
            let isLabel = false;
            let isSelected = false;
            if (opt.isLabel != null) {
                isLabel = opt.isLabel;
            }
            if (opt.isSelected != null) {
                isSelected = opt.isSelected;
            }

            // mark that we've found oe
            if (isSelected && !foundOne) {
                foundOne = true;
            }

            // and from then on, mark all as unselected
            if (this.singleSelect) {
                if (foundOne) {
                    isSelected = false;
                }
            }

            newOptions.push({label: opt.label, value: opt.value, isSelected: isSelected, isLabel: isLabel});
        }
        this._options = newOptions;

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
    }
    _options = [];

    shown = false;
    firstOpen = true; // used to detect the first opening - during which the shown variable is sometimes randomly detected as true, cause unknown

    get hasOptions() {
        return this.options.length > 0;
    }

    @api quietSelect(val) {
        this.value = val;
    }

    @api loudSelect(val) {
        this.value = val;
        this.updateValue();
    }

    @api focus() {
        this.template.querySelector('.slds-combobox').focus();
        this.focusEvent();
    }

    @api reportValidity() {
        let valid = true;

        if (this.required && this.value.length === 0) {
            valid = false;
        }

        return valid;
    }

    toggleDropdown() {
        if (this.shown && !this.firstOpen) {
            this.closeDropdown();
        } else {
            this.firstOpen = false;
            this.openDropdown();
        }
    }
    openDropdown() {
        this.shown = true;
        this.setDropdownState(true);
        this.focus();
        this.updateActiveBorder();
    }
    closeDropdown() {
        this.shown = false;
        this.setDropdownState(false);
        this.updateErrorState();
        this.updateActiveBorder();
    }
    setDropdownState(shouldOpen) {
        const openClass = 'slds-is-open';

        const dropdown = this.template.querySelector('.slds-dropdown-trigger');
        const isOpen = dropdown.classList.contains(openClass);
        if (shouldOpen == null) {
            if (isOpen) {
                dropdown.classList.remove(openClass);
            } else {
                dropdown.classList.add(openClass);
            }
        } else {
            if (shouldOpen) {
                if (!isOpen) {
                    dropdown.classList.add(openClass);
                }
            } else {
                if (isOpen) {
                    dropdown.classList.remove(openClass);
                }
            }
        }
    }
    toggleDropdownKeyboard(e) {
        if (this.isSelectionKey(e.which)) this.toggleDropdown();
        if (e.which === 27) this.closeDropdown(); // escape button
    }

    // Close modal when clicking out - must make sure click wasn't another item in modal
    closeModalTimeout = null;
    focusOutOfDropdown() {
        this.closeModalTimeout = setTimeout(() => {
            this.closeDropdown();
        }, 40);
    }
    focusInDropdown() {
        if (this.closeModalTimeout != null) {
            clearTimeout(this.closeModalTimeout);
            this.closeModalTimeout = null;
        } else {
            if (!this.shown) this.openDropdown();
        }
    }

    toggleOption(event) {
        const clickedVal = event.currentTarget.dataset.value;
        for (let i = 0; i < this._options.length; i++) {
            const opt = this._options[i];
            if (opt.value === clickedVal) {
                // toggle this option
                if (opt.isSelected) {
                    opt.isSelected = false;
                } else {
                    opt.isSelected = true;
                }
            } else {
                // mark all others as unselected in singleSelect mode
                if (this.singleSelect) {
                    opt.isSelected = false;
                }
            }
        }
        this._options = [...this._options];

        this.updateValue();
    }
    toggleOptionKeyboard(e) {
        if (this.isSelectionKey(e.which)) this.toggleOption(e);
        if (e.which === 27) this.closeDropdown(); // escape button
        e.stopPropagation();
    }

    isSelectionKey(code) {
        return code === 13 /*enter*/ || code === 32 /*space*/;
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
    focusEvent() {
        this.dispatchEvent(new CustomEvent('focus', {}));
    }

    get shownStr() {
        return '' + this.shown;
    }

    get placard() {
        let placard = '';

        let countSelected = 0;
        let selectedOpt;
        for (let i = 0; i < this.options.length; i++) {
            const opt = this.options[i];
            if (opt.isSelected) {
                countSelected++;
                selectedOpt = opt;
            }
        }

        if (this.singleSelect) {
            if (countSelected === 0) {
                placard = this.placeholder;
            } else {
                placard = selectedOpt.label;
            }
        } else {
            if (countSelected === 0) {
                placard = this.placeholder;
            } else if (countSelected === 1) {
                placard = '1 option selected';
            } else if (countSelected > 1) {
                placard = countSelected + ' options selected';
            }
        }

        return placard;
    }

    hasError = false;
    updateErrorState() {
        if (this.required) {
            if (this.value.length === 0) {
                this.hasError = true;
            } else {
                this.hasError = false;
            }
        } else {
            this.hasError = false;
        }

        const combobox = this.template.querySelector('.slds-form-element');
        const errorClass = 'slds-has-error';

        if (this.hasError) {
            combobox.classList.add(errorClass);
        } else {
            combobox.classList.remove(errorClass);
        }
    }

    updateActiveBorder() {
        const combobox = this.template.querySelector('.slds-combobox');
        const activeClass = 'active';

        if (this.shown) {
            combobox.classList.add(activeClass);
        } else {
            combobox.classList.remove(activeClass);
        }
    }
}
