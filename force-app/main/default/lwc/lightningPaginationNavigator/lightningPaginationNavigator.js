import {LightningElement, api} from 'lwc';

export default class LightningPaginationNavigator extends LightningElement {
    /**
     * The total number of results to display
     */
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

    /**
     * The number of results that should be shown on each page
     */
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

    /**
     * The term to use when referring to items (e.g. contact/cases/etc).
     */
    @api itemType = 'items';

    /**
     * True if should show a dropdown to change the number of results per page.  False if just should show navigation buttons.
     */
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

    /**
     * Jump to a specific page
     */
    @api set currentPage(val) {
        let newVal = val;
        if (typeof newVal === 'string') newVal = parseInt(newVal, 10);
        this._currentPage = newVal;
    }
    get currentPage() {
        return this._currentPage;
    }
    _currentPage = 0;

    // What options are shown for page sizes
    pageSizeOptions = [
        {label: '20', value: 20},
        {label: '50', value: 50},
        {label: '100', value: 100},
        {label: '200', value: 200},
    ];

    // The first page number (always 0)
    get firstPage() {
        return 0;
    }
    // The last page number (depends on number of results and page size)
    get lastPage() {
        return Math.max(Math.ceil(this.resultsCount / this.pageSize) - 1, 0);
    }

    // True when on the first page, false otherwise
    get onFirstPage() {
        return this.currentPage === this.firstPage;
    }
    // True when on the last page, false otherwise
    get onLastPage() {
        return this.currentPage === this.lastPage;
    }

    // String that represents the current page (converts from 0-index to 1-index)
    get currentPageStr() {
        return this.currentPage + 1;
    }
    // String that represents the last page number (converts from 0-index to 1-index)
    get lastPageStr() {
        return this.lastPage + 1;
    }

    // String that indicaites the start indice of which results are on the current page (converts from 0-index to 1-index)
    get startIndexOfViewingResults() {
        if (this.resultsCount === 0) return 0;
        return this.pageSize * this.currentPage + 1;
    }
    // String that indicaites the end indice of which results are on the current page (converts from 0-index to 1-index)
    get endIndexOfViewingResults() {
        let upperLimit = this.pageSize * (this.currentPage + 1);
        if (upperLimit > this.resultsCount) upperLimit = this.resultsCount;
        return upperLimit;
    }

    /**
     * Jump to the first page. If this changes the current page, raise an event indicating the page number has changed.
     */
    navigateToFirstPage() {
        const oldCurrentPage = this.currentPage;
        this.currentPage = this.firstPage;
        if (oldCurrentPage !== this.currentPage) this.sendChangePageEvent();
    }
    /**
     * Go to the previous page. If this changes the current page, raise an event indicating the page number has changed.
     */
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
    /**
     * Go to the next page. If this changes the current page, raise an event indicating the page number has changed.
     */
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
    /**
     * Jump to the final page. If this changes the current page, raise an event indicating the page number has changed.
     */
    navigateToLastPage() {
        const oldCurrentPage = this.currentPage;
        this.currentPage = this.lastPage;
        if (oldCurrentPage !== this.currentPage) this.sendChangePageEvent();
    }

    /**
     * When the page size is changed, record this, raise the page size change event, and reset to the first page (and raise a page change event)
     * @param {ChangeEvent} e onchange event
     */
    changePageSize(e) {
        this.pageSize = e.detail.value;
        this.sendChangePageSizeEvent();
        this.currentPage = 0;
        this.sendChangePageEvent();
    }

    /**
     * Raises an event for changing the page, this should be handled by the parent LWC to determine which items to display.
     */
    sendChangePageEvent() {
        this.dispatchEvent(new CustomEvent('changepage', {detail: this.currentPage, bubbles: true, composed: true}));
    }

    /**
     * Raises an event for changing the page size, this should be handled by the parent LWC to determine which items to display.
     */
    sendChangePageSizeEvent() {
        this.dispatchEvent(new CustomEvent('changepagesize', {detail: this.pageSize}));
    }

    // @api to expose fields for testing purposes - really should only use this for tests
    @api test__getField(fieldName) {
        return this[fieldName];
    }
}
