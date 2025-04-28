/**
 * Author: Created by Tommy Nordman
 * Date: 10/17/2022
 * Description:
 *   A Lightning Design styled combobox.  Has multiple flags to enable/disable functionality.
 *
 *  @param name A name for this field
 *  @param label What label to use for the dropdown
 *  @param placeholder What to show in the dropdown when no options are selected
 *  @param required Is this dropdown a required field for whatever form it is on?
 *  @param multiSelect Can more than one option be selected in the dropdown
 *  @param value Semicolon separated list of values for each option that should be selected
 *  @param options An array of options to show  [ { label: "John", value: "c-01", isLabel: false }, ... ]
 *  @param dynamicDropdown A boolean that indicates whether the dropdown should use fixed positioning (and as a result pop out of modals or other containers)
 *  @function quietSelect(val) Set the value without triggering change events
 *  @function loudSelect(val) Set the value and trigger change events
 *  @function focus() Give focus to the dropdown
 *  @function reportValidity() Reports if the field is valid (error shown if not valid)
 *  @function checkValidity() Check if the field is valid (i.e. if it is required, then it must have a value selected)
 */
import {LightningElement, api, track} from 'lwc';
import {parseBoolean, getFixedYOffset} from 'c/helperFunctions';
import {KeyboardController} from 'c/keyboardController';

export default class LightningComboBox extends LightningElement {
    @api name;

    @api label;
    @api placeholder = 'Select an Option';

    @api set disabled(val) {
        this._disabled = parseBoolean(val);
    }
    get disabled() {
        return this._disabled;
    }
    _disabled = false;

    @api set required(val) {
        this._required = parseBoolean(val);
    }
    get required() {
        return this._required;
    }
    _required = false;

    @api set multiSelect(val) {
        this._multiSelect = parseBoolean(val);
    }
    get multiSelect() {
        return this._multiSelect;
    }
    _multiSelect = false;

    @api set dynamicDropdown(val) {
        this._dynamicDropdown = parseBoolean(val);
    }
    get dynamicDropdown() {
        return this._dynamicDropdown;
    }
    _dynamicDropdown = false;

    @api set value(val) {
        this._value = val;
        this.initialValueOptionsSelect();
    }
    get value() {
        return this.selectedValues.join(';');
    }
    _value = null;
    @track
    selectedValues = [];

    /**
     * option: { label: "John", value: "c-01", isLabel: false }
     * @param {List<option>} val
     *
     * @warning the value should not be a Proxy object of a Proxy object.  More than one layer of Proxies makes JSON.stringify unusably slow
     * @warning this.options should be used rarely, try using this._options instead where possible since this getter is pretty expensive
     *          when there are lots of options in the list
     */
    @api set options(val) {
        this._options = val;
        this.initialValueOptionsSelect();
    }
    get options() {
        const hoveredIndex = this.hoveredIndex;
        // eslint-disable-next-line no-undef
        const selectedSet = new Set(this.selectedValues);

        return (this._options ?? []).map((opt, indx) => {
            return {
                label: opt.label,
                value: opt.value,
                isLabel: opt.isLabel ?? false,
                isSelected: selectedSet.has(opt.value),
                isHovered: indx === hoveredIndex,
                index: indx,
            };
        });
    }
    _options = null;

    /**
     * Determine what to display on closed combo box
     * If nothing is selected, show the placeholder
     * If multiselect combobox, show number of options selected
     * If singleselect combobox, show the label that is selected
     */
    get placard() {
        let _placard = this.placeholder;

        const numberSelected = this.selectedValues.length;

        if (numberSelected === 0) {
            _placard = this.placeholder;
        } else if (numberSelected === 1) {
            if (this.multiSelect) {
                _placard = '1 Option Selected';
            } else {
                _placard = this._options?.filter((opt) => opt.value === this.value)?.at(0)?.label ?? '????????';
            }
        } else {
            _placard = numberSelected + ' Options Selected';
        }

        return _placard;
    }

    /**
     * Show the dropdown right now?
     */
    showDropdown = false;

    /**
     * Index of which index is currently being hovered over
     */
    hoveredIndex = -1;

    /**
     * Combobox class list
     */
    get comboboxClasses() {
        let classes = ['slds-combobox', 'slds-dropdown-trigger', 'slds-dropdown-trigger_click '];
        if (this.showDropdown) classes.push('slds-is-open');
        return classes.join(' ');
    }

    /**
     * Dropdown class list
     */
    get dropdownClasses() {
        let classes = ['slds-dropdown', 'slds-dropdown_length-5', 'slds-dropdown_fluid'];
        if (this.dynamicDropdown) classes.push('dynamic-dropdown');
        return classes.join(' ');
    }

    /**
     * Text version of show dropdown, used for ARIA stuff
     */
    get ariaBoxIsExpanded() {
        return this.showDropdown ? 'true' : 'false';
    }

    hasRendered = false;
    queuedEvents = [];
    renderedCallback() {
        for (let i = 0; i < this.queuedEvents.length; i++) {
            let evnt = this.queuedEvents[i];
            this.dispatchEvent(evnt);
        }
        this.queuedEvents = [];
        this.hasRendered = true;

        if (this.dynamicDropdown) this.regenerateDropdownAlignmentCss();
    }

    /**
     * When the dropdown is within a modal we need to do some magic to make sure the dropdown can drop outside the modal
     */
    regenerateDropdownAlignmentCss() {
        let css = this.template.host.style;
        const inputBox = this.template.querySelector('.inputBox');

        const cTop = inputBox.getBoundingClientRect().top;
        const cHeight = inputBox.getBoundingClientRect().height;
        const cWidth = inputBox.getBoundingClientRect().width;

        const zeroedYOffset = getFixedYOffset(inputBox);

        css.setProperty('--dynamicDropdownOffsetTop', `${cTop + cHeight - zeroedYOffset}px`);
        css.setProperty('--dynamicDropdownWidth', `${cWidth}px`);
    }

    /**
     * Select this value (semi-colon separated) but don't raise related events
     * @param {string} val
     */
    @api quietSelect(val) {
        this.value = val;
    }

    /**
     * Select this value (semi-colon separated) and raise related events
     * @param {string} val
     */
    @api loudSelect(val) {
        this.value = val;
        this.sendChangeEvent();
        this.sendCommitEvent();
    }

    /**
     * Give focus to the .focusCapture element
     * this triggers opening the dropdown and allows us to detect onblur/handle keyboard controls
     */
    @api focus() {
        this.template.querySelector('.focusCapture').focus();
    }

    /**
     * Check if the dropdown state is valid and report errors
     * @returns if valid
     */
    @api reportValidity() {
        this.updateErrorState();
        let valid = this.checkValidity();
        return valid;
    }

    /**
     * Check if the dropdown state is valid
     * @returns if valid
     */
    @api checkValidity() {
        let valid = true;

        if (this.required && this.value.length === 0) {
            valid = false;
        }

        return valid;
    }

    /**
     * Toggle the state of this item in the dropdown
     * @param {Event} e
     */
    toggleItem(e) {
        let toggleIndex = parseInt(e.currentTarget.dataset.index, 10);
        this.toggleItemByIndex(toggleIndex);
        e.preventDefault();
    }
    /**
     * Toggle the state of this item in the dropdown
     * @param {int} indx
     */
    toggleItemByIndex(indx) {
        if (this._options[indx].isLabel) return; // refuse to select a label element

        let itemValue = this._options[indx].value;

        // eslint-disable-next-line no-undef
        let newSelectedSet = new Set(this.selectedValues);

        if (this.multiSelect) {
            // Select or deselect in multiselect mode
            if (newSelectedSet.has(itemValue)) {
                newSelectedSet.delete(itemValue);
            } else {
                newSelectedSet.add(itemValue);
            }
        } else {
            // Only allow one selected at a time in singleselect mode
            if (newSelectedSet.has(itemValue)) {
                newSelectedSet.delete(itemValue);
            } else {
                newSelectedSet.clear(); // remove existing before selecting new
                newSelectedSet.add(itemValue);
            }
        }
        this.selectedValues = [...newSelectedSet];

        this.sendChangeEvent();

        // In single select mode, close automatically upon selecting an option
        if (!this.multiSelect) {
            this.closeDropdown();
        }
    }

    /**
     * Handle a mouse click on the dropdown header
     * Toggles the dropdown state
     */
    toggleDropdown(e) {
        if (this.showDropdown) {
            this.closeDropdown();
        } else {
            this.openDropdown();
            this.focus(); // also force the element to get focus so we can do keyboard controls
        }
        e.stopPropagation();
    }
    /**
     * Close the dropdown, remove the active border, and commit changes
     */
    closeDropdown() {
        this.hoveredIndex = -1;
        this.updateErrorState();
        this.showDropdown = false;
        this.template.querySelector('.inputBox').classList.remove('active');
        this.sendCommitEvent();
    }
    /**
     * Open the dropdown and add the active border
     */
    openDropdown() {
        if (this.disabled) return;

        this.hoveredIndex = -1;
        this.showDropdown = true;
        this.template.querySelector('.inputBox').classList.add('active');
        this.sendFocusEvent();
    }

    /**
     * When the .focusCapture element receives focus (usually via tab), open the dropdown
     * @param {Event} e
     */
    handleFocusEvent() {
        this.openDropdown();
    }

    /**
     * When the .focusCapture element loses focus (usually by clicking outside the element), close the dropdown
     * @param {Event} e
     */
    handleBlurEvent() {
        this.sendBlurEvent();
        this.closeDropdown();
    }

    /**
     * General keyboard controls
     * @param {Event} e
     */
    keyboardController(e) {
        if (KeyboardController.isSelectionKey(e.which)) {
            if (this.hoveredIndex === -1) this.toggleDropdown(e);
            else this.toggleItemByIndex(this.hoveredIndex);
            e.preventDefault();
            e.stopPropagation();
        } else if (KeyboardController.isDownKey(e.which)) {
            if (this.showDropdown) {
                this.moveWithinDropdown(1);
                e.preventDefault();
                e.stopPropagation();
            }
        } else if (KeyboardController.isUpKey(e.which)) {
            if (this.showDropdown) {
                this.moveWithinDropdown(-1);
                e.preventDefault();
                e.stopPropagation();
            }
        } else if (KeyboardController.isCloseKey(e.which)) {
            if (this.showDropdown) {
                this.closeDropdown();
                e.preventDefault();
                e.stopPropagation();
            }
        } else if (KeyboardController.isTabKey(e.which)) {
            // We need to manually handle tab so we close the dropdown (if we don't then we end up focusing on an element in the dropdown)
            // which then causes the tab-cursor to reset to top of page when it closes the dropdown
            this.closeDropdown();
        } else if (KeyboardController.isHomeKey(e.which)) {
            if (this.showDropdown) {
                this.moveWithinDropdown(-1 * this._options.length);
                e.preventDefault();
                e.stopPropagation();
            }
        } else if (KeyboardController.isEndKey(e.which)) {
            if (this.showDropdown) {
                this.moveWithinDropdown(this._options.length);
                e.preventDefault();
                e.stopPropagation();
            }
        } else if (KeyboardController.isPageUpKey(e.which)) {
            if (this.showDropdown) {
                this.moveWithinDropdown(-6);
                e.preventDefault();
                e.stopPropagation();
            }
        } else if (KeyboardController.isPageDownKey(e.which)) {
            if (this.showDropdown) {
                this.moveWithinDropdown(6);
                e.preventDefault();
                e.stopPropagation();
            }
        }
    }

    /**
     * Move the simulated cursor inside the dropdown, scroll as needed
     * @param {Number} direction How many to scroll, either up (negative) or down (positive)
     * @returns
     */
    moveWithinDropdown(direction) {
        if (typeof direction !== 'number') return; // only moves using numbers
        if (!this.showDropdown) return; // cannot move within if dropdown is closed

        // Where are we moving to?
        const prevHoverIndex = this.hoveredIndex;
        this.hoveredIndex += direction;

        // cap both ends
        if (this.hoveredIndex < 0) this.hoveredIndex = 0;
        if (this.hoveredIndex >= this._options.length) this.hoveredIndex = this._options.length - 1;
        // unless we were already at the top, then allow moving even further to get outside selections
        if (prevHoverIndex <= 0 && direction < 0) this.hoveredIndex = -1;

        // At index -1 we have selected the dropbox itself and don't need to do anything more
        if (this.hoveredIndex === -1) return;
        // otherwise we need to scroll to get the current option into the viewport

        const currentTopOfViewport = this.template.querySelector('.slds-dropdown').scrollTop;
        const heightOfViewport = this.template.querySelector('.slds-dropdown').getBoundingClientRect().height;
        const currentBottomOfViewport = currentTopOfViewport + heightOfViewport;
        const hoveredElement = this.template.querySelector(`li[data-index="${this.hoveredIndex}"]`);

        // Calculate how far down the top of the dropdown the current hovered element is
        let positionOfTopOfElement = 0;
        for (let child of hoveredElement.parentElement.children) {
            if (child === hoveredElement) break;
            positionOfTopOfElement += child.getBoundingClientRect().height;
        }
        let positonOfBottomOfElement = positionOfTopOfElement + hoveredElement.getBoundingClientRect().height;

        if (prevHoverIndex !== this.hoveredIndex) {
            if (positonOfBottomOfElement > currentBottomOfViewport) {
                // If next element's bottom is lower than the current viewport bottom, scroll it down
                this.template.querySelector('.slds-dropdown').scrollTop = Math.floor(
                    positonOfBottomOfElement - heightOfViewport
                );
            } else if (positionOfTopOfElement < currentTopOfViewport) {
                // If next element's bottom is lower than the current viewport bottom, scroll it down
                this.template.querySelector('.slds-dropdown').scrollTop = Math.floor(positionOfTopOfElement);
            } else {
                // within current viewport
            }
        }
    }
    /**
     * Keep track of which index is currently being hovered above
     * @param {mouseenterevent} e
     */
    hoverElement(e) {
        this.hoveredIndex = parseInt(e.currentTarget.dataset.index, 10);
    }

    /**
     * When both the options and value are both set by the parent and neither is null/undefined
     * We need to make sure the selected value matchs only options that actually exist in options
     */
    initialValueOptionsSelect() {
        // can't continue if either is null
        if (this._options == null || this._value == null) return;

        // Calculate all elements the parent wants us to select
        const parentDeclaredValues = this._value.split(';');
        const options = this._options;

        // eslint-disable-next-line no-undef
        let newSelectedSet = new Set();

        for (let opt of options) {
            // Select each option the parent declared
            if (parentDeclaredValues.includes(opt.value)) {
                newSelectedSet.add(opt.value);

                // Quit after first selection if multiselect is off
                if (!this.multiSelect) break;
            }
        }

        // Save selected values to state variable
        this.selectedValues = [...newSelectedSet];

        // If any of the parentDeclaredValues are not in the selectedValues that means the parent
        // declard a value that did not exist and we need to raise a change event
        if (
            !parentDeclaredValues.reduce((prev, cur) => {
                return prev && newSelectedSet.has(cur);
            }, true)
        ) {
            if (this.hasRendered) {
                this.sendCommitEvent();
            } else {
                this.queueCommitEvent();
            }
        }
    }

    /**
     * Update the error display if needed
     */
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
    hasError = false;

    /**
     * Prevent the default actions for this event
     * @param {Event} e
     */
    preventDefault(e) {
        e.preventDefault();
    }

    /**
     * Send a commit event (usually when dropdown closes)
     */
    sendCommitEvent() {
        this.dispatchEvent(this.getCommitEvent());
    }

    /**
     * Queue a commit event (usually during the initial load of default value)
     */
    queueCommitEvent() {
        this.queuedEvents.push(this.getCommitEvent());
    }

    /**
     * Generate a commit event
     * @returns {commitevent}
     */
    getCommitEvent() {
        return new CustomEvent('commit', {
            detail: {
                value: this.value,
            },
        });
    }

    /**
     * Send a change event
     */
    sendChangeEvent() {
        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: this.value,
                },
            })
        );
    }

    /**
     * Send a focus event
     */
    sendFocusEvent() {
        this.dispatchEvent(
            new CustomEvent('focus', {
                detail: {},
            })
        );
    }

    /**
     * Send a blur event
     */
    sendBlurEvent() {
        this.dispatchEvent(
            new CustomEvent('blur', {
                detail: {},
            })
        );
    }
}
