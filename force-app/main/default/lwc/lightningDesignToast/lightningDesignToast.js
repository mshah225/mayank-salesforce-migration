import {LightningElement, api} from 'lwc';

export default class LightningDesignToast extends LightningElement {
    @api set variant(val) {
        this._variant = val;
        this._icon = 'utility:' + val;
        this._classList = 'slds-notify slds-notify_toast slds-theme_' + val;
        if (val === 'loading') {
            this._loadingToast = true;
        } else {
            this._loadingToast = false;
        }
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

    _variant = 'info'; // info, success, warning, error, loading
    _title = 'Example Title';
    _body = 'Example body';
    _duration = 3000;
    _loadingToast = false;
    _icon = 'utility:info';
    _classList = 'slds-notify slds-notify_toast slds-theme_info';
    _hide = true;
    _timeoutToClose = null;
    _timeoutToDisplayNone = null;
    _wrapperClassListStr = 'slds-notify_container slds-hide fadeOutTransition slds-is-fixed slds-align_absolute-center';

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

        const classList = this._wrapperClassListStr.split(' ');
        this.removeFromArray(classList, 'slds-hide');
        this.removeFromArray(classList, 'fadeOutTransition');
        this.insertIntoArray(classList, 'fadeInTransition');
        this._wrapperClassListStr = classList.join(' ');

        this.template.querySelector('.slds-notify_container').focus();
    }
    closeToast() {
        this._hide = true;

        const classList = this._wrapperClassListStr.split(' ');
        this.removeFromArray(classList, 'fadeInTransition');
        this.insertIntoArray(classList, 'fadeOutTransition');
        this._wrapperClassListStr = classList.join(' ');

        // Display set to none after fade out
        if (this._timeoutToDisplayNone) {
            clearTimeout(this._timeoutToDisplayNone);
            this._timeoutToDisplayNone = null;
        }
        this._timeoutToDisplayNone = setTimeout(() => {
            this.insertIntoArray(classList, 'slds-hide');
            this._wrapperClassListStr = classList.join(' ');
        }, 2000); //2000ms aligns with 2s fade out transition
    }

    removeFromArray(arr, val) {
        const indx = arr.indexOf(val);
        if (indx !== -1) {
            arr.splice(indx, 1);
        }
    }
    insertIntoArray(arr, val) {
        const indx = arr.indexOf(val);
        if (indx === -1) {
            arr.push(val);
        }
    }
}
