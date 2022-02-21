import {LightningElement, api, track} from 'lwc';

export default class AdvisorPortalFilters extends LightningElement {
    @api
    defaultFilter;

    @api set currentFilter(val) {
        this._currentFilter = val;
    }
    get currentFilter() {
        return this._currentFilter;
    }
    _currentFilter = {};

    get isGraduateOnly() {
        if (this.currentFilter == null) return false;
        else if (this.currentFilter.gradStudentsOnly == null) return false;
        return this.currentFilter.gradStudentsOnly;
    }

    triggerCurrentFilterChanges() {
        this._currentFilter = {...this._currentFilter};
    }
}
