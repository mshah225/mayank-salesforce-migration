/**
 * Author: Created by Robert Nordman
 * Date: 10/17/2022
 * Description:
 *   A Lightning Design styled combobox.  Has multiple flags to enable/disable functionality.
 *
 *  @param label What label to use for the dropdown
 *  @param placeholder What to show in the dropdown when no options are selected
 *  @param required Is this dropdown a required field for whatever form it is on?
 *  @param multiSelect Can more than one option be selected in the dropdown
 *  @param value Semicolon separated list of values for each option that should be selected
 *  @param options An array of options to show  [ { label: "John", value: "c-01", isLabel: false }, ... ]
 *  @function quietSelect(val) Set the value without triggering change events
 *  @function loudSelect(val) Set the value and trigger change events
 *  @function focus() Give focus to the dropdown
 *  @function reportValidity() Reports if the field is valid (error shown if not valid)
 *  @function checkValidity() Check if the field is valid (i.e. if it is required, then it must have a value selected)
 */
import {LightningElement, api} from 'lwc';
import {cloneObj} from 'c/helperFunctions';

export default class LightningComboBox extends LightningElement {
    @api label;
    @api placeholder = 'Select an Option';

    @api set required(val) {
        if (typeof val === 'string') this._required = val === 'true';
        else this._required = val;
    }
    get required() {
        return this._required;
    }
    _required = false;

    @api set multiSelect(val) {
        if (typeof val === 'string') this._multiSelect = val === 'true';
        else this._multiSelect = val;
    }
    get multiSelect() {
        return this._multiSelect;
    }
    _multiSelect = false;

    @api set value(val) {
        this._value = val;
        this.forceSelectedStatesToMatchValue();
    }
    get value() {
        let selectedOptions = [];
        for (let i = 0; i < this._options.length; i++) {
            const opt = this._options[i];
            if (opt.isSelected) {
                selectedOptions.push(opt.value);
            }
        }
        return selectedOptions.join(';');
    }
    _value = '';

    /**
     * option: { label: "John", value: "c-01", isLabel: false }
     * @param {List<option>} val
     *
     * @warning the value should not be a Proxy object of a Proxy object.  More than one layer of Proxies makes JSON.stringify unusably slow
     */
    @api set options(val) {
        const optionsClone = cloneObj(val);

        // add extra attributes
        for (let i = 0; i < optionsClone.length; i++) {
            const opt = optionsClone[i];
            if (opt.isSelected == null) opt.isSelected = false;
            if (opt.isLabel == null) opt.isLabel = false;
            if (opt.isHovered == null) opt.isHovered = false;
            opt.index = i;
        }

        this._options = optionsClone;
        this.forceSelectedStatesToMatchValue();
    }
    get options() {
        return this._options;
    }
    _options = [];

    placard = '';
    showDropdown = false;

    get comboboxClasses() {
        let classes = ['slds-combobox', 'slds-dropdown-trigger', 'slds-dropdown-trigger_click '];
        if (this.showDropdown) classes.push('slds-is-open');
        return classes.join(' ');
    }

    get ariaBoxIsExpanded() {
        return this.showDropdown ? 'true' : 'false';
    }

    connectedCallback() {
        this.placard = this.placeholder;
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
        let options = cloneObj(this._options);

        for (let i = 0; i < options.length; i++) {
            const opt = options[i];
            if (i === indx) {
                opt.isSelected = !opt.isSelected;
            } else {
                if (!this.multiSelect) opt.isSelected = false;
            }
        }

        this._options = options;
        this.updatePlacard();
        this.sendChangeEvent();
        if (!this.multiSelect) this.closeDropdown();
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
            this.focus();
        }
        e.stopPropagation();
    }
    /**
     * Close the dropdown, remove the active border, and commit changes
     */
    closeDropdown() {
        this.hoveredIndex = -1;
        this.updatePlacard();
        this.updateErrorState();
        this.showDropdown = false;
        this.template.querySelector('.inputBox').classList.remove('active');
        this.sendCommitEvent();
    }
    /**
     * Open the dropdown and add the active border
     */
    openDropdown() {
        this.hoveredIndex = -1;
        this.showDropdown = true;
        this.template.querySelector('.inputBox').classList.add('active');
    }

    /**
     * When the .focusCapture element receives focus (usually via tab), open the dropdown
     */
    handleFocusEvent() {
        this.template.querySelector('.inputBox').classList.add('active');
        this.sendFocusEvent();
        this.openDropdown();
    }
    /**
     * When the .focusCapture element loses focus (usually by clicking outside the element), close the dropdown
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
        if (this.isSelectionKey(e.which)) {
            if (this.hoveredIndex === -1) this.toggleDropdown(e);
            else this.toggleItemByIndex(this.hoveredIndex);
            e.preventDefault();
        } else if (this.isDownKey(e.which)) {
            this.moveWithinDropdown(1);
            e.preventDefault();
        } else if (this.isUpKey(e.which)) {
            this.moveWithinDropdown(-1);
            e.preventDefault();
        } else if (this.isCloseKey(e.which)) {
            this.closeDropdown();
            e.preventDefault();
        }
    }

    /**
     * Move the simulated cursor inside the dropdown, scroll as needed
     * @param {-1 | 1} direction
     * @returns
     */
    moveWithinDropdown(direction) {
        if (direction !== 1 && direction !== -1) return; // only supports moving one item at a time
        if (!this.showDropdown) return; // cannot move within if dropdown is closed

        const unPerSlot = this.template.querySelector('.eachItem').clientHeight;
        const currentTopOfViewport = this.template.querySelector('.slds-dropdown').scrollTop;
        const hieghtOfViewport = this.template.querySelector('.slds-dropdown').clientHeight;
        const currentBottomOfViewport = currentTopOfViewport + hieghtOfViewport;

        const prevHoverIndex = this.hoveredIndex;
        this.hoveredIndex += direction;

        if (this.hoveredIndex < -1) this.hoveredIndex = -1;
        if (this.hoveredIndex >= this.options.length) this.hoveredIndex = this.options.length - 1;

        if (prevHoverIndex !== this.hoveredIndex) {
            const locationOfItem = this.hoveredIndex * unPerSlot;
            if (currentTopOfViewport < locationOfItem && locationOfItem < currentBottomOfViewport - unPerSlot) {
                // within current viewport
            } else if (locationOfItem > currentBottomOfViewport - unPerSlot) {
                this.template.querySelector('.slds-dropdown').scrollTop += unPerSlot;
            } else if (locationOfItem < currentTopOfViewport) {
                this.template.querySelector('.slds-dropdown').scrollTop -= unPerSlot;
            }
            this.updateHoverStates();
        }
    }
    hoveredIndex = -1;
    /**
     * Keep track of which index is currently being hovered above
     * @param {mouseenterevent} e
     */
    hoverElement(e) {
        const prevHoverIndex = this.hoveredIndex;
        let hoveredIndex = e.currentTarget.dataset.index;
        this.hoveredIndex = parseInt(hoveredIndex, 10);
        if (this.hoveredIndex !== prevHoverIndex) this.updateHoverStates();
    }

    /**
     * Update hover data attributes
     */
    updateHoverStates() {
        const options = cloneObj(this._options);
        for (let i = 0; i < options.length; i++) {
            const opt = options[i];
            if (this.hoveredIndex === opt.index) opt.isHovered = true;
            else opt.isHovered = false;
        }
        this._options = options;
    }

    /**
     * Update the options array to ensure selection matches the value set by the parent element
     * and make sure the value only contains values from the options
     */
    forceSelectedStatesToMatchValue() {
        const parentDeclaredValues = this._value == null ? [] : this._value.split(';');
        const options = cloneObj(this._options);
        const newValues = [];
        let madeAChange = false;

        let foundOne = false;
        for (let i = 0; i < options.length; i++) {
            const opt = options[i];
            if (parentDeclaredValues.includes(opt.value) && (this.multiSelect || !foundOne)) {
                if (!opt.isSelected) madeAChange = true;
                opt.isSelected = true;
                foundOne = true;
                newValues.push(opt.value);
            } else {
                if (opt.isSelected) madeAChange = true;
                opt.isSelected = false;
            }
        }

        this._options = options;

        if (madeAChange) {
            this._value = newValues.join(';');
            if (this.hasRendered) {
                this.sendCommitEvent();
            } else {
                this.queueCommitEvent();
            }
        }

        this.updatePlacard();

        // must throwback update one cycle sometimes - seems to be related to conditionally rendering fields (degree level, academic program, etc.)
        this.throwBackARenderCycle(() => {
            this.updatePlacard();
        });
    }

    /**
     * Is this keycode associated with a up type action (e.g. <up>)
     * @param {int} code
     * @returns
     */
    isDownKey(code) {
        return code === 40; // down
    }
    /**
     * Is this keycode associated with a down type action (e.g. <down>)
     * @param {int} code
     * @returns
     */
    isUpKey(code) {
        return code === 38; // up
    }
    /**
     * Is this keycode associated with a select type action (e.g. <enter> or <space>)
     * @param {int} code
     * @returns
     */
    isSelectionKey(code) {
        return code === 13 /*enter*/ || code === 32 /*space*/;
    }
    /**
     * Is this keycode associated with a closing type action (e.g. <esc>)
     * @param {int} code
     * @returns
     */
    isCloseKey(code) {
        return code === 27; // esc
    }

    /**
     * Update the placard being displayed
     */
    updatePlacard() {
        let numberSelected = 0;

        let selectedObj = {};
        for (let i = 0; i < this._options.length; i++) {
            if (this._options[i].isSelected) {
                numberSelected++;
                selectedObj = this._options[i];
            }
        }

        if (numberSelected === 0) this.placard = this.placeholder;
        else if (numberSelected === 1)
            if (this.multiSelect) this.placard = '1 Option Selected';
            else this.placard = selectedObj.label;
        else this.placard = numberSelected + ' Options Selected';
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

    /**
     * Can throw a section of code outside the current rendering cycle - useful if we want to allow our parent LWC to complete a rendering cycle before
     * running this code (this is used to doubly ensure the displayed placard is correct)
     * @param {Function} fn
     */
    throwBackARenderCycle(fn) {
        setTimeout(fn, 1);
    }
}
