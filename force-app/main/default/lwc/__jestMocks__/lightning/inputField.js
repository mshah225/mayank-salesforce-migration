import {LightningElement, api} from 'lwc';

export default class InputField extends LightningElement {
    @api reportValidity() {
        return true;
    }

    @api fieldName;
    @api key;
    @api id;
    @api required;
}
