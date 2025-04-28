import {LightningElement, api} from 'lwc';

/**
 * The `c-lightning-button-dropdown-item` is a custom component designed to be used alongside `c-lightning-button-dropdown`.
 * Each sub button in the menu should be defined using this element.
 *
 * Attributes
 * `label`: Label of the button
 * `name`: Name of the button (included in `select` event)
 * `iconName`: Name of icon to use for this button (defaults to utility:fallback)
 *
 * Example:
 * ```
 * <c-lightning-button-dropdown-item label="Pin" name="pin" icon-name="utility:pin"></c-lightning-button-dropdown-item>
 * ```
 *
 * Author: Tommy Nordman
 * Created: 2025-03-17
 */
export default class LightningButtonDropdownItem extends LightningElement {
    @api label;
    @api name;

    @api set iconName(v) {
        this._iconName = v;
    }
    get iconName() {
        return this._iconName ?? 'utility:fallback';
    }
    _iconName;

    buttonPressed(evnt) {
        evnt.stopPropagation();
        evnt.stopImmediatePropagation();
        evnt.preventDefault();

        this.dispatchEvent(
            new CustomEvent('select', {
                detail: {
                    name: this.name,
                },
                bubbles: true,
                composed: true,
            })
        );
    }
}
