import {LightningElement, api} from 'lwc';
import {parseBoolean} from 'c/helperFunctions';

export default class LightningErrorOrRetry extends LightningElement {
    @api set hasError(val) {
        this._hasError = parseBoolean(val);
    }
    get hasError() {
        return this._hasError;
    }
    _hasError = false;

    @api set retryEnabled(val) {
        this._retryEnabled = parseBoolean(val);
    }
    get retryEnabled() {
        return this._retryEnabled;
    }
    _retryEnabled = true;

    @api message;

    sendRetryEvent() {
        this.dispatchEvent(new CustomEvent('retry', {}));
    }

    get multipleLines() {
        return (this.message || '').includes('\n');
    }
}
