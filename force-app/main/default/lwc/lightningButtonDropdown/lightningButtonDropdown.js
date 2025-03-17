import {LightningElement, api} from 'lwc';
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
 * Author: Tommy Nordman
 * Created: 2025-03-17
 */
export default class LightningButtonDropdown extends LightningElement {
    @api label;

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

        return classList.join(' ');
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
