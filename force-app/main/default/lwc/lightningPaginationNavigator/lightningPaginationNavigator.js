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

    @api set pageSize(val) {
        let newVal = val;
        if (typeof newVal === 'string') {
            newVal = parseInt(newVal, 10);
        }
        this._pageSize = newVal;
    }
    get pageSize() {
        return this._pageSize;
    }
    _pageSize = 20;

    @api itemType = 'items';

    @api set extended(val) {
        let newVal = val;
        if (newVal === 'true') newVal = true;
        else if (newVal === 'false') newVal = false;
        this._extended = newVal;
    }
    get extended() {
        return this._extended;
    }
    _extended;

    @api set currentPage(val) {
        let newVal = val;
        if (typeof newVal === 'string') newVal = parseInt(newVal, 10);
        this._currentPage = newVal;
    }
    get currentPage() {
        return this._currentPage;
    }
    _currentPage = 0;

    pageSizeOptions = [
        {label: '20', value: 20},
        {label: '50', value: 50},
        {label: '100', value: 100},
        {label: '200', value: 200},
    ];

    get firstPage() {
        return 0;
    }
    get lastPage() {
        return Math.max(Math.ceil(this.resultsCount / this.pageSize) - 1, 0);
    }

    get onFirstPage() {
        return this.currentPage === this.firstPage;
    }
    get onLastPage() {
        return this.currentPage === this.lastPage;
    }

    get currentPageStr() {
        return this.currentPage + 1;
    }
    get lastPageStr() {
        return this.lastPage + 1;
    }

    get startIndexOfViewingResults() {
        if (this.resultsCount === 0) return 0;
        return this.pageSize * this.currentPage + 1;
    }
    get endIndexOfViewingResults() {
        let upperLimit = this.pageSize * (this.currentPage + 1);
        if (upperLimit > this.resultsCount) upperLimit = this.resultsCount;
        return upperLimit;
    }

    navigateToFirstPage() {
        const oldCurrentPage = this.currentPage;
        this.currentPage = this.firstPage;
        if (oldCurrentPage !== this.currentPage) this.sendChangePageEvent();
    }
    navigateToPreviousPage() {
        const oldCurrentPage = this.currentPage;
        let prevPage = this.currentPage;
        prevPage -= 1;
        if (prevPage < this.firstPage) {
            prevPage = this.firstPage;
        }
        this.currentPage = prevPage;
        if (oldCurrentPage !== this.currentPage) this.sendChangePageEvent();
    }
    navigateToNextPage() {
        const oldCurrentPage = this.currentPage;
        let nextPage = this.currentPage;
        nextPage += 1;
        if (nextPage > this.lastPage) {
            nextPage = this.lastPage;
        }
        this.currentPage = nextPage;
        if (oldCurrentPage !== this.currentPage) this.sendChangePageEvent();
    }
    navigateToLastPage() {
        const oldCurrentPage = this.currentPage;
        this.currentPage = this.lastPage;
        if (oldCurrentPage !== this.currentPage) this.sendChangePageEvent();
    }

    changePageSize(e) {
        this.pageSize = e.detail.value;
        this.sendChangePageSizeEvent();
        this.currentPage = 0;
        this.sendChangePageEvent();
    }

    sendChangePageEvent() {
        this.dispatchEvent(new CustomEvent('changepage', {detail: this.currentPage}));
    }

    sendChangePageSizeEvent() {
        this.dispatchEvent(new CustomEvent('changepagesize', {detail: this.pageSize}));
    }
}
