import {LightningElement, api} from 'lwc';

export default class AdvisorPortalOutlookChangeDirection extends LightningElement {
    @api set changeDirection(val) {
        this._changeDirection = val;
    }
    get changeDirection() {
        return this._changeDirection;
    }
    _changeDirection = null;

    @api set changeDate(val) {
        this._changeDate = val;
    }
    get changeDate() {
        return this._changeDate;
    }
    _changeDate = null;

    get directionString() {
        if (this.changeDirection === 0) return 'Down,';
        if (this.changeDirection === 1) return 'Up,';
        return '';
    }

    get notEmptyChangeDirection() {
        return this._changeDirection != null;
    }

    get hasDate() {
        return this.changeDate !== null;
    }
}
