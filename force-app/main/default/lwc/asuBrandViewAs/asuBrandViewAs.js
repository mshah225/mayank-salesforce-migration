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

        console.log('--- VIEW AS [BEGIN] ---');
        console.log('Logged in as ' + this.firstName + ' ' + this.lastName + ' (' + this.emplId + ')');
        console.log('Permission to view as: ' + this.viewingAs);
        console.log('View As URL: ' + this.viewAsUrl);
        console.log('Stop View As URL: ' + this.stopViewAsUrl);
        console.log('--- VIEW AS [END] ---');
    }
}
