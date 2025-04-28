import {LightningElement, api} from 'lwc';
import {parseBoolean, getFixedYOffset} from 'c/helperFunctions';
/**
 * The `c-lightning-button-dropdown` is a custom component designed to act as a button, with a submenu of additional buttons.
 *
 * You can set the label of the primary button using the `label` field.
 * Sub buttons use `<slot></slot>`-functionality and should be `c-lightning-button-dropdown-item` elements
 *
 * You should handle two types of events `click` events occur whenever a user presses the primary button
 * and `select` events occur whenever users press one of the sub buttons (which sub button is pressed can be determined by referring to `event.detail.name`).
 *
 * Example of how to use this:
 * ```
 * <c-lightning-button-dropdown label="Apply filter set" onclick={applyFilter} onselect={handleOtherAction}>
 *     <c-lightning-button-dropdown-item label="Pin" name="pin"></c-lightning-button-dropdown-item>
 *     <c-lightning-button-dropdown-item label="View" name="view"></c-lightning-button-dropdown-item>
 *     <c-lightning-button-dropdown-item label="Remove" name="remove"></c-lightning-button-dropdown-item>
 * </c-lightning-button-dropdown>
 * ```
 *
 * `dynamicDropdown` is a flag you should set whenever rendering inside of a modal, and when you want the dropdown options to exapnd outside the modal.
 * This does come with the limitation of odd behavior when scrolling in the modal. This does come with some CPU-cost, as it requires us to update the position
 * of the dropdown using JS every time the element rerenders
 *
 *
 *
 * NOTE::
 *
 * You can get similar results by using the built-in, lightning-button-group component, however, the dropdown in lightning-button-group
 * is not designed to support dropping outside of modals, which this one it able to dropdown outside modals.
 * ```
 * <lightning-button-group>
 *      <lightning-button label="Apply filter set" onclick={applyFilterSet}></lightning-button>
 *      <lightning-button-menu alternative-text="Show menu" variant="border-filled">
 *          <lightning-menu-item label="Pin" prefix-icon-name="utility:pin" value="pin"></lightning-menu-item>
 *          <lightning-menu-item label="View" prefix-icon-name="utility:preview" value="view"></lightning-menu-item>
 *          <lightning-menu-item label="Remove" prefix-icon-name="utility:delete" value="remove"></lightning-menu-item>
 *      </lightning-button-menu>
 * </lightning-button-group>
 * ```
 *
 *
 * Author: Tommy Nordman
 * Created: 2025-03-17
 */
export default class LightningButtonDropdown extends LightningElement {
    @api label;

    @api set dynamicDropdown(val) {
        this._dynamicDropdown = parseBoolean(val);
    }
    get dynamicDropdown() {
        return this._dynamicDropdown;
    }
    _dynamicDropdown = false;

    dropdownOpen = false;

    // Clicked main button
    primaryAction() {
        this.dispatchEvent(new Event('click'));
        this.closeDropdown();
    }

    // Toggle dropdown
    toggleDropdown() {
        this.dropdownOpen = !this.dropdownOpen;
    }

    // Close dropwon (whenever we see a select event)
    closeDropdown() {
        this.dropdownOpen = false;
    }

    // Prevent events from propagating up
    stopEvent(evnt) {
        evnt.stopPropagation();
        evnt.stopImmediatePropagation();
        evnt.preventDefault();
    }

    get dropdownIcon() {
        return this.dropdownOpen ? 'utility:down' : 'utility:right';
    }
    get dropdownIconText() {
        return this.dropdownOpen ? 'Close action dropdown' : 'See more actions';
    }

    get dropdownClasses() {
        let classList = ['dropdown-menu'];

        if (this.dropdownOpen) classList.push('dropdown-open');
        if (this.dynamicDropdown) classList.push('dynamic-dropdown');

        return classList.join(' ');
    }

    cssRegenInterval = undefined;
    renderedCallback() {
        if (this.dynamicDropdown) {
            // Every rerender, update align CSS
            this.regenerateDropdownAlignmentCss();

            // If we don't have an interval already, create one to keep CSS alsgnment updated
            if (this.dropdownOpen && this.cssRegenInterval === undefined) {
                this.cssRegenInterval = setInterval(() => {
                    if (this.dropdownOpen) {
                        this.regenerateDropdownAlignmentCss();
                    } else {
                        // if it is now closed - remove the interval to not waste resources
                        clearInterval(this.cssRegenInterval);
                        this.cssRegenInterval = undefined;
                    }
                }, 300);
            }
        }
    }
    regenerateDropdownAlignmentCss() {
        let css = this.template.host.style;

        const dropdownButton = this.refs.attachRef;

        const cTop = dropdownButton.getBoundingClientRect().top;
        const cHeight = dropdownButton.getBoundingClientRect().height;

        const zeroedYOffset = getFixedYOffset(dropdownButton);

        let comboboxContainerOffsetTop = cTop + cHeight - zeroedYOffset + 'px';

        css.setProperty('--dynamicDropdownOffsetTop', comboboxContainerOffsetTop);
    }
}

export class LightningButtonDropdownTest extends LightningButtonDropdown {
    @api set label(v) {
        super.label = v;
    }
    get label() {
        return super.label;
    }

    @api set dropdownOpen(v) {
        super.dropdownOpen = v;
    }
    get dropdownOpen() {
        return super.dropdownOpen;
    }

    @api get dropdownIcon() {
        return super.dropdownIcon;
    }

    @api get dropdownIconText() {
        return super.dropdownIconText;
    }
}
