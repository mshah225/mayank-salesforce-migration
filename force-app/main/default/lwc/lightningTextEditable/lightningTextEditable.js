import {parseBoolean} from 'c/helperFunctions';
import {LightningElement, api} from 'lwc';

export default class LightningTextEditable extends LightningElement {
    @api value;
    @api buttonVariant = 'base';
    @api buttonSize = 'medium';
    @api set hideEdit(v) {
        this._hideEdit = parseBoolean(v);
    }
    get hideEdit() {
        return this._hideEdit;
    }
    _hideEdit = false;

    /**
     * Should the user be allowed to edit this value?
     */
    get showEditButton() {
        return !this.hideEdit;
    }

    /**
     * Toggle between edit and view mode
     */
    editMode = false;

    /**
     * New value when editting
     */
    newValue;

    get displayValue() {
        return this.newValue || this.value || '';
    }

    editHandler() {
        this.editMode = true;
        this.newValue = this.value;
    }
    saveChanges() {
        this.editMode = false;
        this.dispatchEvent(new CustomEvent('change', {detail: {value: this.newValue}}));
    }
    cancelChanges() {
        this.editMode = false;
        this.newValue = this.value;
    }
    changeHandler(evnt) {
        evnt.stopPropagation();
        evnt.stopImmediatePropagation();
        evnt.preventDefault();

        this.newValue = evnt.detail.value;
    }
    keydownHandler(evnt) {
        if (evnt.key === 'Enter') {
            evnt.stopPropagation();
            evnt.stopImmediatePropagation();
            evnt.preventDefault();

            this.saveChanges();
            return false;
        } else if (evnt.key === 'Escape') {
            evnt.stopPropagation();
            evnt.stopImmediatePropagation();
            evnt.preventDefault();

            this.cancelChanges();
            return false;
        }

        return true;
    }

    renderedCallback() {
        if (this.editMode) {
            this.refs.inputField.focus();
        }
    }
}
