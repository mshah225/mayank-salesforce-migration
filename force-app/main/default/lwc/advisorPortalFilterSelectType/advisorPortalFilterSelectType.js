import {LightningElement, api} from 'lwc';

export default class AdvisorPortalFilterSelectType extends LightningElement {
    @api
    get currentFilter() {
        return this._currentFilter;
    }
    set currentFilter(val) {
        this._currentFilter = val;
        if (val != null && val.caseTypeState != null) {
            this.quietSelect(val.caseTypeState);
        }
    }
    _currentFilter = null;

    options = [
        {label: 'All Students', value: 'AllCasesState'},
        {label: 'Proactive Cases', value: 'ProactiveCasesState'},
        {label: 'Watchlist Cases', value: 'WatchlistCasesState'},
    ];
    value = 'ProactiveCasesState';

    @api
    quietSelect(val) {
        this.value = val;
    }

    @api
    loudSelect(val) {
        this.value = val;
        this.sendEvent();
    }

    updateShowResultsFor(event) {
        event.stopPropagation();
        event.stopImmediatePropagation();
        event.preventDefault();

        this.value = event.detail.value;
        this.sendEvent();
    }

    sendEvent() {
        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {name: 'caseTypeState', value: this.value},
            })
        );
    }
}
