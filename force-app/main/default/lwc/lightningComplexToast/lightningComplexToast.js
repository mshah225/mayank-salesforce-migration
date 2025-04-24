import {LightningElement, api} from 'lwc';

/**
 * This is meant to be used as a one-off toast, used whenever we need the body of the toast to contain
 * complex structures, such as buttons.
 *
 * You can set the variant, mode, and duration using the respective @api parameters
 * You should set the header and body by passing the `header` and `body` slots in markup
 *
 * You can then open the toast by calling `.show()` - it will automatically close (unless
 * mode is sticky, after `duration` seconds)
 *
 */
export default class LightningComplexToast extends LightningElement {
    @api variant = 'info';
    @api mode = 'dismissable';
    @api set duration(v) {
        this._duration = Number(v);
    }
    get duration() {
        return this._duration;
    }
    _duration = 3000;

    get icon() {
        return 'utility:' + this.variant;
    }
    get sldsNotifyClasses() {
        let classList = ['slds-notify', 'slds-notify_toast'];
        if (this.variant) classList.push(`slds-theme_${this.variant}`);

        return classList.join(' ');
    }
    get showCloseButton() {
        return this.mode !== 'pester';
    }

    isOpen = false;

    @api show() {
        this.isOpen = true;

        if (this.mode === 'dismissable' || this.mode === 'pester') {
            setTimeout(() => {
                this.hideToast();
            }, this._duration);
        }
    }
    hideToast() {
        this.isOpen = false;
    }
}
