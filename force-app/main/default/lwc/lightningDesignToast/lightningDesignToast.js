import {LightningElement, api} from 'lwc';

export default class LightningDesignToast extends LightningElement {
    @api set variant(val) {
        this._variant = val;
        this._icon = 'utility:' + val;
        this._classList = 'slds-notify slds-notify_toast slds-theme_' + val;
    }
    get variant() {
        return this._variant;
    }
    @api set title(val) {
        this._title = val;
    }
    get title() {
        return this._title;
    }
    @api set body(val) {
        this._body = val;
    }
    get body() {
        return this._body;
    }
    @api set duration(val) {
        this._duration = val;
    }
    get duration() {
        return this._duration;
    }

    _variant = 'info'; // info, success, warning, error
    _title = 'Example Title';
    _body = 'Example body';
    _duration = 3000;
    _icon = 'utility:info';
    _classList = 'slds-notify slds-notify_toast slds-theme_info';
    _hide = true;
    _timeoutToClose = null;
    _timeoutToDisplayNone = null;

    @api fire() {
        this.openToast();

        // auto close in duration milliseconds
        if (this._timeoutToClose) {
            clearTimeout(this._timeoutToClose);
            this._timeoutToClose = null;
        }
        this._timeoutToClose = setTimeout(() => {
            if (!this._hide) {
                this.closeToast();
            }
        }, this._duration);
    }
    @api fireParams(title, body, variant, duration) {
        this.title = title;
        this.body = body;
        this.variant = variant;
        this.duration = duration;
        this.fire();
    }

    openToast() {
        this._hide = false;
        this.template.querySelector('.slds-notify_container').classList.remove('slds-hide');
        this.template.querySelector('.slds-notify_container').classList.remove('fadeOutTransition');
        this.template.querySelector('.slds-notify_container').classList.add('fadeInTransition');
        this.template.querySelector('.slds-notify_container').focus();
    }
    closeToast() {
        this._hide = true;
        this.template.querySelector('.slds-notify_container').classList.remove('fadeInTransition');
        this.template.querySelector('.slds-notify_container').classList.add('fadeOutTransition');

        // Display set to none after fade out
        if (this._timeoutToDisplayNone) {
            clearTimeout(this._timeoutToDisplayNone);
            this._timeoutToDisplayNone = null;
        }
        this._timeoutToDisplayNone = setTimeout(() => {
            this.template.querySelector('.slds-notify_container').classList.add('slds-hide');
        }, 2000); //2000ms aligns with 2s fade out transition
    }
}
