import {LightningElement, api} from 'lwc';
import persistenceChart from '@salesforce/resourceUrl/PersistenceChart';

export default class AdvisorPortalTable extends LightningElement {
    @api set allResults(val) {
        // deep copy the results to allow us to modify our copy
        this._allResults = JSON.parse(JSON.stringify(val));
    }
    get allResults() {
        return this._allResults;
    }
    _allResults = [];
    currentPage = 0;
    pageSize = 20;

    get shownContactWrappers() {
        const shownResults = [];

        for (let i = 0; i < this.allResults.length; i++) {
            const result = this.allResults[i];
            if (i < this.currentPage * this.pageSize) {
                continue; // these are on a previous page
            } else if (i > (this.currentPage + 1) * this.pageSize) {
                continue; // these are on a next page
            } else {
                shownResults.push(result);
            }
        }

        return shownResults;
    }

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
    }

    bubbleEvent(e) {
        this.dispatchEvent(
            new CustomEvent(e.type, {
                detail: e.detail,
            })
        );
    }
}
