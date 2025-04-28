import {LightningElement, api} from 'lwc';

export default class Combobox extends LightningElement {
    @api reportValidity() {
        return true;
    }

    @api label;
    @api placeholder;
    @api value;
    @api options;
    @api required;
}
