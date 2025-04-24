/**
 * Author: Created by Tommy Nordman
 * Date: 03/21/2025
 * Description:
 *   A Lightning Design styled combobox.  Has multiple flags to enable/disable functionality.
 *
 * @param disabled If true, the combobox is disabled and users cannot interact with it.
 * @param label Label shown for this input field
 * @param multiSelect Can the user select multiple options?
 * @param name A name for this field, raised in change events
 * @param options A list of options to show in the dropdown
 * @param placeholder What to show in the dropdown when no options are selected
 * @param required Is this field required?
 * @param searchable Is this a searchable input box?
 * @param spinnerActive Should we show a loading icon and prevent opening the dropdown?
 * @param value The currently selected value(s), if multiple they must be separated by semicolons
 * @param dynamicDropdown Dynamically position the dropdown. Needed when in modal.
 *
 * @function focus() Give focus to the dropdown
 * @function reportValidity() Reports if the field is valid (error shown if not valid)
 * @function checkValidity() Check if the field is valid (i.e. if it is required, then it must have a value selected)
 */

import {LightningElement, api} from 'lwc';
import {parseBoolean, getFixedYOffset} from 'c/helperFunctions';
import {KeyboardController} from 'c/keyboardController';

/**
 * @typedef {Object} ComboboxOption
 * @property {String} label Dropdown option label
 * @property {String} value Dropdown option value
 * @property {Boolean} isLabel Indicates if this is a header option
 */

export default class LightningComboBox extends LightningElement {
    /**
     * If true, the combobox is disabled and users cannot interact with it.
     * @type {Boolean}
     */
    @api set disabled(v) {
        this._disabled = parseBoolean(v);
    }
    get disabled() {
        return this._disabled;
    }
    _disabled = false;

    /**
     * Text label for the combobox.
     * @type {String}
     */
    @api label;

    /**
     * If true, multiple options can be selected at the same time
     * @type {Boolean}
     */
    @api set multiSelect(v) {
        this._multiSelect = parseBoolean(v);
    }
    get multiSelect() {
        return this._multiSelect;
    }
    _multiSelect = false;

    /**
     * Specifies the name of the combobox.
     * This is raised in change events.
     * @type {String}
     */
    @api name;

    /**
     * A list of options that are available for selection. Each option has the following attributes: label, value, and type.
     * @type {ComboboxOption[]}
     */
    @api set options(v) {
        this._options = v;
        // After first render - make sure to always sync value with valid options
        if (!this.firstRender) this.alignValueToOptions();
    }
    get options() {
        return this._options;
    }
    _options;

    /**
     * Text that is displayed before an option is selected, to prompt the user to select an option. The default is "Select an Option".
     * @type {String}
     */
    @api set placeholder(v) {
        this._placeholder = v;
    }
    get placeholder() {
        return this._placeholder ?? 'Select an Option';
    }
    _placeholder;

    /**
     * If true, a value must be selected before the form can be submitted.
     * @type {Boolean}
     */
    @api set required(v) {
        this._required = parseBoolean(v);
    }
    get required() {
        return this._required;
    }
    _required = false;

    /**
     * If true, the input field allows text to be entered, and the options will be filtered according to that text
     * @type {Boolean}
     */
    @api
    set searchable(v) {
        this._searchable = parseBoolean(v);
    }
    get searchable() {
        return this._searchable;
    }
    _searchable = false;

    /**
     * If true, a spinner is displayed on the dropdown to indicate its values are loading
     * @type {Boolean}
     */
    @api
    set spinnerActive(v) {
        this._spinnerActive = parseBoolean(v);
    }
    get spinnerActive() {
        return this._spinnerActive;
    }
    _spinnerActive = false;

    /**
     * Specifies the value of an input element.
     * If multiple options are selected, this should be a semicolon-separated list
     * @type {String}
     */
    @api set value(v) {
        this._parentValue = v;
        this._value = v;
        // After first render - make sure to always sync value with valid options
        if (!this.firstRender) this.alignValueToOptions();
    }
    get value() {
        return this._value;
    }
    _value = null;
    _parentValue = null;
    // Get as a list
    get valueList() {
        if (this._value == null) return [];
        if (this._value === '') return [];
        return this._value.split(';');
    }

    /**
     * Should the dropdown of the combobox utilize position:fixed and self-update its position?
     * This is needed whenever the dropdown is being used in a modal and you want the contents of
     * the dropdown to drop outside of the modal
     * @type {Boolean}
     */
    @api
    set dynamicDropdown(v) {
        this._dynamicDropdown = parseBoolean(v);
    }
    get dynamicDropdown() {
        return this._dynamicDropdown;
    }
    _dynamicDropdown = false;

    /**
     * Give this element focus
     */
    @api focus() {
        if (this.disabled) return;
        this.refs.primaryInput.focus();
    }

    /**
     * Checks if this input field is valid and respects the "required" flag or not.
     * Show an error message if the field is required and not entered
     * @returns {Boolean} True if valid, false otherwise
     */
    @api reportValidity() {
        let isValid = this.checkValidity();
        this.hasError = !isValid;
        return isValid;
    }

    /**
     * Check if this input field is valid and respects the "required" flag or not
     * @returns {Boolean} True if valid, false otherwise
     */
    @api checkValidity() {
        if (!this.required) return true;
        if (this._value == null || this._value === '') return false;
        return true;
    }

    /** Is there an error? */
    hasError = false;

    /**
     * Is the dropdown open right now?
     */
    isOpen = false;
    toggleDropdown() {
        if (this.isOpen) {
            this.closeDropdown();
        } else {
            this.openDropdown();
        }
    }
    openDropdown() {
        // Don't open if disabled
        if (this.disabled) return;
        // Don't open if options are loading
        if (this.spinnerActive) return;
        if (!this.isOpen) this.isOpen = true;
    }
    closeDropdown() {
        if (this.isOpen) {
            this.isOpen = false;
            if (this.didMakeAChange) {
                this.didMakeAChange = false;
                this.sendCommitEvent();
            }
        }
    }

    /**
     * Class list - this controls if the combobox is shown as open or closed
     */
    get sldsComboboxClasses() {
        const classList = ['slds-combobox', 'slds-dropdown-trigger', 'slds-dropdown-trigger_click'];

        if (this.isOpen) classList.push('slds-is-open');

        return classList.join(' ');
    }
    /**
     * Class list - this controls if the dropdown is dynamically positioned or not
     */
    get sldsDropdownClasses() {
        const classList = ['slds-dropdown', 'slds-dropdown_length-5', 'slds-dropdown_fluid'];

        if (this.dynamicDropdown) classList.push('fixed-dropdown');

        return classList.join(' ');
    }
    /** Tab index for input field */
    get inputTabIndex() {
        return this.disabled ? '-1' : '0';
    }
    /** Dropdown icon */
    get dropdownIconName() {
        return this.searchable ? 'utility:search' : this.isOpen ? 'utility:down' : 'utility:right';
    }
    /** ARIA Expanded */
    get airaExpanded() {
        return this.isOpen ? 'true' : 'false';
    }
    /** ARIA Disabled */
    get ariaDisabled() {
        return this.disabled ? 'true' : 'false';
    }
    /**
     * Determine what to display on closed combo box
     * If nothing is selected, show the placeholder
     * If multiselect combobox, show number of options selected
     * If singleselect combobox, show the label that is selected
     */
    get placard() {
        if (this.valueList.length > 0) {
            if (this.multiSelect) {
                // In multiselect mode, show number of options selected
                let countSelected = this.dropdownOptions.filter((v) => this.valueList.includes(v.value)).length;
                return countSelected > 1 ? `${countSelected} Options Selected` : '1 Option Selected';
            }

            // Single select mode, show label
            return this.dropdownOptions.filter((v) => v.value === this._value)[0]?.label;
        }

        // No options selected
        return this.placeholder;
    }

    /**
     * Add top-level event listeners to this object
     */
    connectedCallback() {
        this.addFocusEventHandlers();
    }

    /**
     * On render we need to do 2 main things. One we need to realign the dropdowns position to align with the combobox input.
     * And second, we need to set the required/readonly attribtues on the input field
     *
     * On the first render, we also need to make sure the value match the valid options and raise events if not
     */
    renderedCallback() {
        if (this.firstRender) {
            this.firstRender = false;
            this.alignValueToOptions();
        }

        // If this re-renders due to the options list changing (such as because it is being resorted)
        // the element that was clicked on might stop existing (this is browser dependent). When this happens
        // we need to set focus on some other element as to prevent the dropdown from automatically
        // closing due to the focusout event
        if (this.isOpen) {
            if (this.template?.activeElement == null) {
                this.refs.primaryInput.focus();
            }
        }

        if (this.dynamicDropdown) {
            // Every rerender, update alignment CSS
            this.regenerateDropdownAlignmentCss();

            // If we don't have an interval already, create one to keep CSS alignment updated
            if (this.isOpen && this.cssRegenInterval === undefined) {
                this.cssRegenInterval = setInterval(() => {
                    if (this.isOpen) {
                        this.regenerateDropdownAlignmentCss();
                    } else {
                        // if it is now closed - remove the interval to not waste resources
                        clearInterval(this.cssRegenInterval);
                        this.cssRegenInterval = undefined;
                    }
                }, 300);
            }
        }

        // Mark any presense-based attributes for input field
        this.updateInputFieldFlags();
    }
    firstRender = true;
    /**
     * Update the CSS variables responsible for positioning the dropdown
     */
    regenerateDropdownAlignmentCss() {
        let css = this.template.host.style;
        const cTop = this.refs.attachRef.getBoundingClientRect().top;
        const cHeight = this.refs.attachRef.getBoundingClientRect().height;
        const cWidth = this.refs.primaryInputFormElement.getBoundingClientRect().width;
        const zeroedYOffset = getFixedYOffset(this.refs.attachRef);
        let comboboxContainerOffsetTop = cTop + cHeight - zeroedYOffset;

        css.setProperty('--dynamicDropdownOffsetTop', `${comboboxContainerOffsetTop}px`);
        css.setProperty('--dynamicDropdownWidth', `${cWidth}px`);
    }
    cssRegenInterval = undefined;

    /**
     * There are a few attributes we need to set on the input field.  These attributes are not able to be set to true or false, they must
     * be added or removed. We need to do this in JS or by using <template lwc:if>. But if we use template lwc:if, then we'll have large
     * amount of duplicated markup - and since the input field  MUST have a a label that is linked via id (and ids MUST be unique in the
     * template) it would require extra labels as well
     */
    updateInputFieldFlags() {
        // Set or unset disabled flag
        if (this.disabled) this.refs.primaryInput.setAttribute('disabled', '');
        else this.refs.primaryInput.removeAttribute('disabled');

        // Set or unset readonly flag
        if (!this.searchable) this.refs.primaryInput.setAttribute('readonly', '');
        else this.refs.primaryInput.removeAttribute('readonly');
    }

    /**
     * Get all dropdown options
     */
    get dropdownOptions() {
        return (this.options ?? []).map((opt) => {
            return {
                label: opt.label,
                value: opt.value,
                isHeader: opt.isLabel ?? false,
                isSelected: this.valueList.includes(opt.value),
            };
        });
    }

    /**
     * Do any required filtering to only include those that match
     */
    get shownDropdownOptions() {
        return this.dropdownOptions.filter((opt) => {
            return (
                // Always include headers
                opt.isHeader ||
                // Either not searchable in which case return all
                !this.searchable ||
                // Or no search has been entered
                !this.searchText ||
                // Or matches search text
                opt.label.toLowerCase().includes(this.searchText.toLowerCase())
            );
        });
    }

    /**
     * Toggle a single item in the list
     *
     * In single select mode only one option can be selected at a time
     * In multi select mode any number of options can be selected
     */
    toggleOption(evnt) {
        const value = evnt.currentTarget.dataset.key;
        const currentSelected = this.valueList;

        const startingValue = this._value;

        if (this.multiSelect) {
            if (currentSelected.includes(value)) {
                currentSelected.splice(currentSelected.indexOf(value), 1);
            } else {
                currentSelected.push(value);
            }
            this._value = currentSelected.join(';');
        } else {
            // Single select mode, just select or unselect the one option
            if (this.value === value) {
                this._value = '';
            } else {
                this._value = value;
            }
            // reset focus to primary element
            this.refs.primaryInput.focus();
            // clear any search text
            this.searchText = '';
        }

        // If changed - raise an event
        if (startingValue !== this._value) {
            this.sendChangeEvent();
            this.didMakeAChange = true;
        }

        // Lastly, close the dropdown in singleselect mode
        if (!this.multiSelect) {
            this.closeDropdown();
        }
    }
    didMakeAChange = false;

    /**
     * Move within the dropdown a certain number of spaces
     * This is similar to pressing tab or shift tab that number of times, but it is restricted to the bounds of the dropdown
     */
    moveWithinDropdown(count) {
        const parentUl = this.template.activeElement.parentElement;
        const allLi = [...parentUl.children].filter((v) => v.getAttribute('tabindex') === '0');
        const currentIndex = allLi.findIndex((e) => e === this.template.activeElement);

        if (currentIndex === 0 && count < 0) {
            // At top and navigating up
            this.refs.primaryInput.focus();
        } else {
            // Navigating within dropdown
            this.moveToDropdown(currentIndex + count);
        }
    }
    /** Move to a specific indexwithin the dropdown */
    moveToDropdown(indx) {
        let listElement = this.refs.list;
        let allSelectableChildElements = [...listElement.children].filter((v) => v.getAttribute('tabindex') === '0');

        // Clamp index within bounds
        indx = Math.max(0, Math.min(indx, allSelectableChildElements.length - 1));

        allSelectableChildElements[indx].focus();
    }

    /**
     * Whenever the user enters text in the dropdown we need to filter the results
     */
    filterDropdown(evnt) {
        if (this.disabled) return;
        if (!this.searchable) return;
        this.searchText = evnt.target.value;
    }
    searchText = '';

    /**
     * The value picklist might have options that are not in the options picklist
     * When this happens, we need to update the value to only include values in the
     * options picklist
     */
    alignValueToOptions() {
        // We use _parentValue here (which is only set whenever the parent changes @api value param)
        // This is needed because when the parent is loading dependent picklists, it should ignore
        // changes to @value until it loads the dependent picklist options, and since we don't know that
        // in here, we might prematurely change _value
        const parentValueLs = (this._parentValue ?? '').split(';');
        const optionsValues = (this.options ?? []).map((opt) => opt.value);
        const startingValue = this._value;

        const allValidValues = parentValueLs.filter((val) => optionsValues.includes(val));
        this._value = allValidValues.join(';');

        // If the value differs from the current value we should raise an event
        // we should also raise events if the value differs from the last event
        // this is useful when the parent is ignoring change events
        if (startingValue !== this._value || this.lastChangeValue !== this._value) {
            this.sendChangeEvent();
            this.sendCommitEvent();
        }
    }

    /**
     * Send a change event - this happens whenever the value in the dropdown changes from one value to another
     */
    sendChangeEvent() {
        this.lastChangeValue = this._value;
        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    name: this.name,
                    value: this._value,
                },
            })
        );
    }
    lastChangeValue;

    /**
     * Send a commit event - this happens whenever the dropdown is closed (and a change was made)
     * or if the parent's declared options/value fields change and that caused a change in value
     */
    sendCommitEvent() {
        this.dispatchEvent(
            new CustomEvent('commit', {
                detail: {
                    name: this.name,
                    value: this._value,
                },
            })
        );
    }

    /**
     * Handle keyboard events while focused on primary input field
     */
    inputKeyDownHandler(evnt) {
        // Don't handle keyboard events when disabled
        if (this.disabled) return;

        if (KeyboardController.isCloseKey(evnt.key)) {
            evnt.preventDefault();
            evnt.stopPropagation();
            evnt.stopImmediatePropagation();
            this.closeDropdown();
        } else if (this.searchable && KeyboardController.isCommon(evnt.key)) {
            // Don't override any common search buttons when in search mode
            // And autoopen dropdown when pressing these keys
            this.openDropdown();
        } else if (KeyboardController.isSelectionKey(evnt.key)) {
            evnt.preventDefault(); // prevent scrolling page with Space
            this.toggleDropdown();
        } else if (
            this.isOpen &&
            (KeyboardController.isDownKey(evnt.key) ||
                KeyboardController.isEndKey(evnt.key) ||
                KeyboardController.isPageDownKey(evnt.key))
        ) {
            evnt.preventDefault(); // prevent auto scrolling
            this.moveToDropdown(0);
        }
    }

    /**
     * Handle keyboard events while navigating list
     */
    listKeyDownHandler(evnt) {
        if (KeyboardController.isCloseKey(evnt.key)) {
            this.refs.primaryInput.focus();
            evnt.preventDefault();
            evnt.stopPropagation();
            evnt.stopImmediatePropagation();
            this.closeDropdown();
        } else if (KeyboardController.isSelectionKey(evnt.key)) {
            evnt.preventDefault(); // prevent scrolling page with Space
            this.toggleOption(evnt);
        } else if (KeyboardController.isUpKey(evnt.key)) {
            evnt.preventDefault(); // prevent scrolling page with ArrowUp
            this.moveWithinDropdown(-1);
        } else if (KeyboardController.isDownKey(evnt.key)) {
            evnt.preventDefault(); // prevent scrolling page with ArrowDown
            this.moveWithinDropdown(1);
        } else if (KeyboardController.isHomeKey(evnt.key)) {
            this.moveToDropdown(0);
        } else if (KeyboardController.isEndKey(evnt.key)) {
            this.moveToDropdown(this.dropdownOptions.length - 1);
        } else if (KeyboardController.isPageUpKey(evnt.key)) {
            this.moveWithinDropdown(-6);
        } else if (KeyboardController.isPageDownKey(evnt.key)) {
            this.moveWithinDropdown(6);
        }
    }

    /**
     * Add listeners for handling focus events
     * When it loses focus, it should close, unless it is moving focus to another element inside the element
     * in which case, leave it open
     */
    addFocusEventHandlers() {
        let focusOutTimeout = null;
        this.template.addEventListener('focusin', () => {
            if (focusOutTimeout != null) {
                clearTimeout(focusOutTimeout);
                focusOutTimeout = null;
            }
        });

        this.template.addEventListener('focusout', () => {
            // Wait to ensure, if clicked elsewhere in the dropdown, that the other event can fire before we close
            focusOutTimeout = setTimeout(() => {
                this.closeDropdown();
            }, 10);
        });
    }
}
