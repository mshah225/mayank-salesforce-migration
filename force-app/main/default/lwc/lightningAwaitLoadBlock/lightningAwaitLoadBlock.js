import {LightningElement, api} from 'lwc';
import {parseBoolean} from 'c/helperFunctions';

export default class LightningAwaitLoadBlock extends LightningElement {
    @api set loading(val) {
        this._loading = parseBoolean(val);
    }
    get loading() {
        return this._loading;
    }
    _loading = false;

    @api set hasContent(val) {
        this._hasContent = parseBoolean(val);
    }
    get hasContent() {
        return this._hasContent;
    }
    _hasContent = false;

    @api set notFoundMessage(val) {
        this._notFoundMessage = val;
    }
    get notFoundMessage() {
        return this._notFoundMessage;
    }
    _notFoundMessage = null;

    @api set iconSize(v) {
        if (['xx-small', 'x-small', 'small', 'medium', 'large'].includes(String(v).toLowerCase())) {
            this._iconSize = v;
        } else {
            throw TypeError(
                'Icon size invalid. It should be one of (xx-small, x-small, small, medium, large) but was instead ' +
                    String(v)
            );
        }
    }
    get iconSize() {
        return this._iconSize;
    }
    _iconSize = 'small';
}
