import {LightningElement, api} from 'lwc';

export default class AsuBrandViewAs extends LightningElement {
    @api firstName;
    @api lastName;
    @api viewingAs;
    @api emplId;
    @api stopViewAsUrl;
    @api viewAsUrl;
}
