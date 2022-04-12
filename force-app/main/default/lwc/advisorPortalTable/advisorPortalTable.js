import {LightningElement, api} from 'lwc';
import persistenceChart from '@salesforce/resourceUrl/PersistenceChart';

export default class AdvisorPortalTable extends LightningElement {
    @api set currentFilter(val) {
        this._currentFilter = val;

        if (this._currentFilter != null) {
            // Only really care about this one field
            if (this._currentFilter.career === 'GRD') this.showPersistenceLegend = false;
            else this.showPersistenceLegend = true;
        }
    }
    get currentFilter() {
        return this._currentFilter;
    }
    _currentFilter = null;

    @api set allResults(val) {
        // deep copy the results to allow us to modify our copy
        const newVal = JSON.parse(JSON.stringify(val));
        for (let i = 0; i < newVal.length; i++) {
            const v = newVal[i];

            // Expand all if needed
            if (this.expandedAll) {
                v.isOpen = true;
            } else {
                v.isOpen = false;
            }

            // Select all if needed
            if (this.selectedAll) {
                v.isSelected = true;
            } else {
                v.isSelected = false;
            }

            // mark states about how many cases
            if (v.cases.length > 0) {
                v.hasCases = true;
                if (v.cases.length > 1) {
                    v.hasMultipleCases = true;
                } else {
                    v.hasMultipleCases = false;
                }
            } else {
                v.hasCases = false;
            }

            // Select cases if needed
            for (let j = 0; j < v.cases.length; j++) {
                const c = v.cases[j];
                if (this.selectedAll) {
                    c.isSelected = true;
                } else {
                    c.isSelected = false;
                }
            }
        }

        this._allResults = newVal;
        this.determineShownContactWrappers();
        this.sendSelectedEvent();
    }
    get allResults() {
        return this._allResults;
    }
    _allResults = [];

    currentPage = 0;
    pageSize = 20;

    expandedAll = true;
    selectedAll = false;
    showPersistenceLegend = true;

    shownContactWrappers = [];

    get sizeOfResults() {
        return this.allResults.length;
    }

    get allResultsIsEmpty() {
        return false && this.allResults.length === 0;
    }

    get persistenceIconVeryLow() {
        return persistenceChart + '/icon-1.png';
    }
    get persistenceIconLow() {
        return persistenceChart + '/icon-2.png';
    }
    get persistenceChartModerate() {
        return persistenceChart + '/icon-3.png';
    }
    get persistenceIconHigh() {
        return persistenceChart + '/icon-4.png';
    }
    get persistenceIconVeryHigh() {
        return persistenceChart + '/icon-5.png';
    }

    changePage(e) {
        const newPage = e.detail;
        this.currentPage = newPage;
        this.determineShownContactWrappers();
    }

    changePageSize(e) {
        const newSize = e.detail;
        this.pageSize = newSize;
        this.determineShownContactWrappers();
    }

    updateExpandedAll(e) {
        this.expandedAll = e.detail.checked;

        for (let i = 0; i < this._allResults.length; i++) {
            const v = this._allResults[i];

            // Exapnd all contacts
            if (this.expandedAll) {
                v.isOpen = true;
            } else {
                v.isOpen = false;
            }
        }

        this.determineShownContactWrappers();
    }

    updateSelectedAll(e) {
        this.selectedAll = e.detail.checked;

        for (let i = 0; i < this._allResults.length; i++) {
            const v = this._allResults[i];

            // Set for all contacts
            if (this.selectedAll) {
                v.isSelected = true;
            } else {
                v.isSelected = false;
            }

            // Set for all cases
            for (let j = 0; j < v.cases.length; j++) {
                const c = v.cases[j];
                if (this.selectedAll) {
                    c.isSelected = true;
                } else {
                    c.isSelected = false;
                }
            }
        }

        this.sendSelectedEvent();
        this.determineShownContactWrappers();
    }

    determineShownContactWrappers() {
        const shownResults = [];

        for (let i = 0; i < this.allResults.length; i++) {
            const result = this.allResults[i];
            if (i < this.currentPage * this.pageSize) {
                continue; // these are on a previous page
            } else if (i >= (this.currentPage + 1) * this.pageSize) {
                continue; // these are on a next page
            } else {
                shownResults.push(result);
            }
        }

        this.shownContactWrappers = JSON.parse(JSON.stringify(shownResults));
    }

    updateSelected(e) {
        const changedContact = e.detail.contact;
        const changedCases = e.detail.cases;
        for (let i = 0; i < this.allResults.length; i++) {
            const contactWrapper = this.allResults[i];

            if (contactWrapper.portalContact.Id === changedContact.Id) {
                contactWrapper.isSelected = changedContact.selected;
                for (let j = 0; j < contactWrapper.cases.length; j++) {
                    const caseWrapper = contactWrapper.cases[j];
                    if (changedCases.includes(caseWrapper.portalCase.Id)) {
                        caseWrapper.isSelected = true;
                    } else {
                        caseWrapper.isSelected = false;
                    }
                }
                break;
            }
        }
        this.sendSelectedEvent();
        this.determineShownContactWrappers();
    }

    updateToggleAccordian(e) {
        const changedContactId = e.detail.contactId;
        const newState = e.detail.open;

        for (let i = 0; i < this.allResults.length; i++) {
            const res = this.allResults[i];
            if (res.portalContact.Id === changedContactId) {
                res.isOpen = newState;
                break;
            }
        }
        this.determineShownContactWrappers();
    }

    bubbleEvent(e) {
        this.dispatchEvent(
            new CustomEvent(e.type, {
                detail: e.detail,
            })
        );
    }

    sendSelectedEvent() {
        // Make a list of all contacts and cases that are selected
        const selectedContactCaseWrappers = [];
        for (let i = 0; i < this.allResults.length; i++) {
            const res = this.allResults[i];
            const wrapper = {contactId: res.portalContact.Id, selected: false, cases: []};
            let somethingSelected = false;
            if (res.isSelected) {
                wrapper.selected = true;
                somethingSelected = true;
            }
            for (let j = 0; j < res.cases.length; j++) {
                const c = res.cases[j];
                if (c.isSelected) {
                    wrapper.cases.push({caseId: c.portalCase.Id, selected: true});
                    somethingSelected = true;
                }
            }
            if (somethingSelected) selectedContactCaseWrappers.push(wrapper);
        }

        // Send it
        this.dispatchEvent(new CustomEvent('setselected', {detail: selectedContactCaseWrappers}));
    }
}
