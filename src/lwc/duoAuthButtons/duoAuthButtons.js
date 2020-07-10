import {LightningElement, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import authenticate from '@salesforce/apex/DuoAuthButtonController.authenticate';

export default class DuoAuthButtons extends LightningElement {
    @track authenticated;
    @track nonAuthenticated;

    @api userId;
    @api deviceId;

    /**
     * Performs a Duo check on load
     */
    connectedCallback() {
        this.checkAuthStatus();
    }

    /**
     * Performs a Duo check from the DUO button
     *
     * @param event
     */
    push(event) {
        this.checkAuthStatus();
    }

    /**
     * Performs an authentication request to Duo with the provided user
     * information
     */
    checkAuthStatus() {
        authenticate({
            user: this.userId,
            device: this.deviceId
        }).then(result => {
            this.authenticated = result;
            this.nonAuthenticated = !result;
        }).catch(error => {
            console.error(error);
            this.authenticated = false;
            this.nonAuthenticated = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: JSON.stringify(error)
                })
            );
        });
    }
}