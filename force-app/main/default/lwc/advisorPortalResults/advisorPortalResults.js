import {LightningElement, api} from 'lwc';
import persistenceChart from '@salesforce/resourceUrl/PersistenceChart';

export default class AdvisorPortalResults extends LightningElement {
    @api allResults = [];
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

    openSections = [];

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

    toggleSelectRelatedCases(e) {
        console.log('toggleSelectRelatedCases', e);
    }

    openDropdown(e) {
        console.log('openDropdown', e, e.target, JSON.stringify(e.target.dataset));
        const contactIdToToggleFor = e.target.dataset.contactId;
        for (let i = 0; i < this.allResults; i++) {
            const contactWrapper = this.allResults[i];
            if (contactWrapper.portalContact.Id === contactIdToToggleFor) {
                contactWrapper.isOpen = true;
                this.allResults = [...this.allResults];
                break;
            }
        }
    }
    closeDropdown(e) {
        console.log('closeDropdown', e, e.target, JSON.stringify(e.target.dataset));
        const contactIdToToggleFor = e.target.dataset.contactId;
        for (let i = 0; i < this.allResults; i++) {
            const contactWrapper = this.allResults[i];
            if (contactWrapper.portalContact.Id === contactIdToToggleFor) {
                contactWrapper.isOpen = false;
                this.allResults = [...this.allResults];
                break;
            }
        }
    }

    openStudentProfile(e) {
        console.log('openStudentProfile', e);
    }
}
