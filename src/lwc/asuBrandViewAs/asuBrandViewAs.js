import {LightningElement, api, track} from 'lwc';

export default class AsuBrandViewAs extends LightningElement {
    @api firstName;
    @api lastName;
    @api viewingAs;
    @api emplId;
    @api stopViewAsUrl;
    @api viewAsUrl;

    @track stop;

    connectedCallback() {
        this.stop = 'Logout as ' + this.firstName + ' ' + this.lastName;
        console.log(this.stop);
        console.log(this.firstName);
        console.log(this.lastName);
        console.log(this.viewingAs);
        console.log(this.emplId);
        console.log(this.stopViewAsUrl);
        console.log(this.viewAsUrl);
    }
}
