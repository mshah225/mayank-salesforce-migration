import {LightningElement, api} from 'lwc';

export default class LightningDesignToast extends LightningElement {
    /**
     * @param {"info"|"success"|"warning"|"error"|"loading"} val The type of message this is
     */
    @api set variant(val) {
        this._variant = val;
        this._icon = 'utility:' + val;
        this._classList = 'yes-clicks slds-notify slds-notify_toast slds-theme_' + val;
        if (val === 'loading') {
            this._loadingToast = true;
        } else {
            this._loadingToast = false;
        }
    }
    get variant() {
        return this._variant;
    }

    /**
     * @param {String} val Title for the toast
     */
    @api set title(val) {
        this._title = val;
    }
    get title() {
        return this._title;
    }

    /**
     * @param {String} val Body of the toast
     */
    @api set body(val) {
        this._body = val;
    }
    get body() {
        return this._body;
    }

    /**
     * @param {Integer} val How long to keep the toast open before auto-closing
     */
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
    _classList = 'yes-clicks slds-notify slds-notify_toast slds-theme_info';
    _hide = true;
    _timeoutToClose = null; // timeout until auto-close toast (until start to fade-out)
    _timeoutToDisplayNone = null; // timeout until settings the display:none style (only once closed and not fading)
    _wrapperClassListStr =
        'slds-notify_container slds-hide fadeOutTransition slds-is-fixed slds-align_absolute-center no-clicks';

    /**
     * Open the toast
     */
    @api fire() {
        this.openToast();

        // auto close in duration milliseconds
        if (this._timeoutToClose) {
            clearTimeout(this._timeoutToClose);
            this._timeoutToClose = null;
        }

        // Loading toast persists until replaced
        if (!this._loadingToast) {
            this._timeoutToClose = setTimeout(() => {
                if (!this._hide) {
                    this.closeToast();
                }
            }, this._duration);
        }
    }
    /**
     *
     * @param {String} title Title for the toast
     * @param {String} body Bdoy for the toast
     * @param {"info"|"success"|"warning"|"error"|"loading"} variant The type of message this is
     * @param {Integer} duration How long to keep the toast open
     */
    @api fireParams(title, body, variant, duration) {
        this.title = title;
        this.body = body;
        this.variant = variant;
        this.duration = duration;
        this.fire();
    }

    // Adds needed classes to fade the toast in and give it focus
    openToast() {
        this._hide = false;

        const classList = this._wrapperClassListStr.split(' ');
        this.removeFromArray(classList, 'slds-hide');
        this.removeFromArray(classList, 'fadeOutTransition');
        this.insertIntoArray(classList, 'fadeInTransition');
        this._wrapperClassListStr = classList.join(' ');

        this.template.querySelector('.slds-notify_container').focus();
    }
    // Adds the needed classes to fade the toast out
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

    // @api to expose fields for testing purposes - really should only use this for tests
    @api test__getField(fieldName) {
        return this[fieldName];
    }
}
