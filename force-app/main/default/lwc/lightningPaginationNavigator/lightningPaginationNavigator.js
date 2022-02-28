import {LightningElement, api} from 'lwc';

export default class LightningPaginationNavigator extends LightningElement {
    @api set resultsCount(val) {
        let newVal = val;
        if (typeof newVal === 'string') {
            newVal = parseInt(newVal, 10);
        }
        this._resultsCount = newVal;
    }
    get resultsCount() {
        return this._resultsCount;
    }
    _resultsCount = 0;

    @api set numberResultsPerPage(val) {
        let newVal = val;
        if (typeof newVal === 'string') {
            newVal = parseInt(newVal, 10);
        }
        this._numberResultsPerPage = newVal;
    }
    get numberResultsPerPage() {
        return this._numberResultsPerPage;
    }
    _numberResultsPerPage = 10;

    @api itemType = 'items';

    currentPage = 0;

    get firstPage() {
        return 0;
    }
    get lastPage() {
        return Math.ceil(this.resultsCount / this.numberResultsPerPage) - 1;
    }

    get onFirstPage() {
        return this.currentPage === this.firstPage;
    }
    get onLastPage() {
        return this.currentPage === this.lastPage;
    }

    get startIndexOfViewingResults() {
        return this.numberResultsPerPage * this.currentPage + 1;
    }
    get endIndexOfViewingResults() {
        let upperLimit = this.numberResultsPerPage * (this.currentPage + 1);
        if (upperLimit > this.resultsCount) upperLimit = this.resultsCount;
        return upperLimit;
    }

    navigateToFirstPage() {
        const oldCurrentPage = this.currentPage;
        this.currentPage = this.firstPage;
        if (oldCurrentPage !== this.currentPage) this.sendEvent();
    }
    navigateToPreviousPage() {
        const oldCurrentPage = this.currentPage;
        let prevPage = this.currentPage;
        prevPage -= 1;
        if (prevPage < this.firstPage) {
            prevPage = this.firstPage;
        }
        this.currentPage = prevPage;
        if (oldCurrentPage !== this.currentPage) this.sendEvent();
    }
    navigateToNextPage() {
        const oldCurrentPage = this.currentPage;
        let nextPage = this.currentPage;
        nextPage += 1;
        if (nextPage > this.lastPage) {
            nextPage = this.lastPage;
        }
        this.currentPage = nextPage;
        if (oldCurrentPage !== this.currentPage) this.sendEvent();
    }
    navigateToLastPage() {
        const oldCurrentPage = this.currentPage;
        this.currentPage = this.lastPage;
        if (oldCurrentPage !== this.currentPage) this.sendEvent();
    }

    sendEvent() {
        this.dispatchEvent(new CustomEvent('changepage', {detail: this.currentPage}));
    }
}
