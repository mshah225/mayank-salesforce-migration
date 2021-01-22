import { LightningElement, api, track } from 'lwc';

export default class SimpleToast extends LightningElement {
    @api variant = 'info';
    @api title = 'Example Title';
    @api body = 'Example body';
    @api duration = 3000;
    @track icon = "";
    @track hide = true;
    @track nothide = false;
    timeoutToClose = null;
    timeoutToDisplayNone = null;
 
    @api fire() {
        this.icon = "utility:"+this.variant;
        this.openToast();

        // auto close in duration milliseconds
        if (this.timeoutToClose) {
            clearTimeout(this.timeoutToClose);
            this.timeoutToClose = null;
        }
        this.timeoutToClose = setTimeout(() => {
            if (!this.hide) {
                this.closeToast();
            }
        }, this.duration)
    }
    @api fireParams(title, body, variant, duration) {
        this.title = title;
        this.body = body;
        this.variant = variant;
        this.duration = duration;
        this.fire();
    }

    openToast() {
        this.hide = false;
        this.nothide = true;
        this.template.querySelector('.toastWrapper').classList.remove('displayNone');
        this.template.querySelector('.toastWrapper').classList.remove('fadeOutTransition');
        this.template.querySelector('.toastWrapper').classList.add('fadeInTransition');
        this.template.querySelector('.toastWrapper').focus();
    }
    closeToast() {
        this.hide = true;
        this.nothide = false;
        this.template.querySelector('.toastWrapper').classList.remove('fadeInTransition');
        this.template.querySelector('.toastWrapper').classList.add('fadeOutTransition');

        // Display set to none after fade out
        if (this.timeoutToDisplayNone) {
            clearTimeout(this.timeoutToDisplayNone);
            this.timeoutToDisplayNone = null;
        }
        this.timeoutToDisplayNone = setTimeout(() => {
            this.template.querySelector('.toastWrapper').classList.add('displayNone');
        }, 2000)
    }
}