import {LightningElement, api, track} from 'lwc';

export default class AsuBrandViewAs extends LightningElement {
    @api firstName;
    @api lastName;
    @api emplId;
    @api viewingAs;
    @api viewAsUrl;
    @api stopViewAsUrl;

    @track viewAsUrlText;
    @track stopViewAsUrlText;

    connectedCallback() {
        this.viewAsUrlText = 'View as someone else';
        this.stopViewAsUrlText = 'Logout as ' + this.firstName + ' ' + this.lastName;
        console.log(this.viewAsUrlText);
        console.log(this.stopViewAsUrlText);
        console.log(this.firstName);
        console.log(this.lastName);
        console.log(this.emplId);
        console.log(this.viewingAs);
        console.log(this.viewAsUrl);
        console.log(this.stopViewAsUrl);
    }
}
