import {LightningElement, api} from 'lwc';

export default class Combobox extends LightningElement {
    @api reportValidity() {
        return true;
    }

    @api label;
    @api options;
    @api placeholder;
    @api required;
    @api value;
    @api variant;
}
