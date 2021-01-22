import { LightningElement, api, track } from 'lwc';

export default class SimpleToast extends LightningElement {
    @api variant = 'info';
    @api title = 'Example Title';
    @api body = 'Example body';
    @api duration = 3000;
    @track icon = "";
    @track hide = true;
    @track nothide = false;
 
    @api fire() {
        this.icon = "utility:"+this.variant;
        this.openToast();

        // auto close in duration milliseconds
        setTimeout(() => {
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
        this.template.querySelector('.toastWrapper').classList.remove('fadeOutTransition');
        this.template.querySelector('.toastWrapper').classList.remove('fadedOut');
        this.template.querySelector('.toastWrapper').classList.add('fadeInTransition');
        this.template.querySelector('.toastWrapper').classList.add('fadedIn');
    }
    closeToast() {
        this.hide = true;
        this.nothide = false;
        this.template.querySelector('.toastWrapper').classList.remove('fadeInTransition');
        this.template.querySelector('.toastWrapper').classList.remove('fadedIn');
        this.template.querySelector('.toastWrapper').classList.add('fadeOutTransition');
        this.template.querySelector('.toastWrapper').classList.add('fadedOut');
    }
}