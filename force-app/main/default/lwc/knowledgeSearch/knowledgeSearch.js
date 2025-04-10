import {LightningElement, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {getListRecordsByName} from 'lightning/uiListsApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {IsConsoleNavigation, getFocusedTabInfo, setTabLabel, setTabIcon} from 'lightning/platformWorkspaceApi';

// Constants
const TAB_LABEL = 'Knowledge Search';
const TAB_ICON = 'utility:search';
const DEFAULT_LIST_VIEW = 'SEARCH_All_Published_Articles';
const FIELDS = [
    'FAQ__kav.Answer__c',
    'FAQ__kav.ArticleTotalViewCount',
    'FAQ__kav.Functional_Group__c',
    'FAQ__kav.KnowledgeArticleId',
    'FAQ__kav.LastPublishedDate',
    'FAQ__kav.Title',
];
const SORT_BY_FIELDS = ['-FAQ__kav.ArticleTotalViewCount'];
const PAGE_SIZE = 10;

export default class KnowledgeSearch extends NavigationMixin(LightningElement) {
    pageToken = null;
    nextPageToken = null;
    previousPageToken = null;

    // Component state variables
    selectedSearchTerm = ''; // Search term at time of clicking 'Search' button or clicking ENTER
    desiredSearchTerm = ''; // Current search term entered by the user, irregardless of search state
    selectedFilter = DEFAULT_LIST_VIEW; // Search filter at time of clicking 'Search' button or clicking ENTER
    desiredFilter = DEFAULT_LIST_VIEW; // Current search filter selected by the user, irregardless of search state

    articles = []; // All articles fetched from the selected list view
    filteredArticles = []; // Filtered articles to display to the user

    nextPageAvailable = false;
    previousPageAvailable = false;

    noResults = false; // Whether there are no articles in the search results
    error = null; // Error message, if any
    hasSearched = false; // Tracks whether a search has been performed

    // Dropdown filter options for category groups
    filterOptions = [
        {label: 'All Category Groups', value: 'SEARCH_All_Published_Articles'},
        {label: 'Academics', value: 'SEARCH_All_Academics_Articles'},
        {label: 'Campus Services', value: 'SEARCH_All_Campus_Services_Articles'},
        {label: 'Finances', value: 'SEARCH_All_Finances_Articles'},
        {label: 'Internal Knowledge', value: 'SEARCH_All_Internal_Knowledge_Articles'},
    ];

    // Indicates whether the user is in a console navigation environment
    @wire(IsConsoleNavigation) isConsoleNavigation;

    /**
     * @description Sets the label for the current browser tab if in console navigation.
     */
    async setTabLabel() {
        if (!this.isConsoleNavigation) {
            return;
        }
        const {tabId} = await getFocusedTabInfo();
        setTabLabel(tabId, TAB_LABEL);
    }

    /**
     * @description Sets the icon for the current browser tab if in console navigation.
     */
    async setTabIcon() {
        if (!this.isConsoleNavigation) {
            return;
        }
        const {tabId} = await getFocusedTabInfo();
        setTabIcon(tabId, TAB_ICON, {
            iconAlt: TAB_LABEL,
        });
    }

    /**
     * @description Wire adapter to fetch articles based on the selected filter.
     * @param {object} response - The response object containing data or error.
     */
    @wire(getListRecordsByName, {
        objectApiName: 'FAQ__kav',
        fields: FIELDS,
        sortBy: SORT_BY_FIELDS,
        pageSize: PAGE_SIZE,
        pageToken: '$pageToken',
        listViewApiName: '$selectedFilter',
        searchTerm: '$selectedTerm',
    })
    listRelevantArticles({data, error}) {
        if (data) {
            console.log(data);

            this.nextPageToken = data?.nextPageToken;
            this.nextPageAvailable = this.nextPageToken ? true : false;
            this.previousPageToken = data?.previousPageToken;
            this.previousPageAvailable = this.previousPageToken ? true : false;

            // Transform the fetched articles into a usable format
            this.articles = data.records.map((record) => ({
                Id: record.id,
                Answer: record.fields.Answer__c.value,
                ArticleTotalViewCount: record.fields.ArticleTotalViewCount.value,
                Category: record.fields.Functional_Group__c.value,
                KnowledgeArticleId: record.fields.KnowledgeArticleId.value,
                LastPublishedDate: this.formatDate(record.fields.LastPublishedDate.value),
                Title: record.fields.Title.value,
            }));

            this.filteredArticles = [...this.articles];
            this.noResults = this.filteredArticles.length === 0;
            this.error = null;
        } else if (error) {
            console.error(error);

            this.showErrorToast('Error fetching articles.');
            this.error = 'Error fetching articles.';
            this.articles = [];
            this.filteredArticles = [];
        }
    }

    /**
     * @description Formats a date string to 'YYYY-MM-DD'.
     * @param {string} dateString - The raw date string.
     * @returns {string} - The formatted date or an empty string if invalid.
     */
    formatDate(dateString) {
        if (!dateString) {
            return '';
        }

        const date = new Date(dateString);
        return new Intl.DateTimeFormat('en-CA', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
        }).format(date);
    }

    /**
     * @description Displays an error toast notification.
     * @param {string} message - The error message to display.
     */
    showErrorToast(message) {
        const toastEvent = new ShowToastEvent({
            title: 'Error',
            message,
            variant: 'error',
        });
        this.dispatchEvent(toastEvent);
    }

    /**
     * @description Handles user input in the search field.
     * @param {Event} event - The input event from the search field.
     */
    handleSearchInput(event) {
        this.desiredSearchTerm = event.target?.value.trim().toLowerCase();
    }

    /**
     * @description Handles changes in the filter dropdown.
     * @param {Event} event - The change event from the filter dropdown.
     */
    handleFilterChange(event) {
        this.desiredFilter = event.target.value;
    }

    /**
     * @description Handles the Enter keypress in the search input field.
     * @param {Event} event - The keypress event.
     */
    handleEnterKey(event) {
        if (event.which === 13) {
            this.handleSearch();
        }
    }

    /**
     * @description Executes the search based on the current search term.
     */
    handleSearch() {
        const hasValidSearch = /\S/.test(this.desiredSearchTerm);
        const searchTermChanged = this.selectedSearchTerm !== this.desiredSearchTerm.toLowerCase();
        const filterChanged = this.selectedFilter !== this.desiredFilter;

        if (!hasValidSearch) {
            this.template.querySelector('.search-input')?.focus();
            return;
        }

        // Only do the heavy lifting if something changed
        if (searchTermChanged || filterChanged) {
            this.hasSearched = true;
            this.selectedSearchTerm = this.desiredSearchTerm.toLowerCase();
            this.selectedFilter = this.desiredFilter;
            this.pageToken = null; // Reset page on new search
            this.articles = [];
            this.filteredArticles = [];
        }
    }

    handleNextPage() {
        if (this.nextPageToken) {
            this.pageToken = this.nextPageToken;
        }
    }

    handlePreviousPage() {
        if (this.previousPageToken) {
            this.pageToken = this.previousPageToken;
        }
    }

    /**
     * @description Navigates to the record page for the selected article.
     * @param {Event} event - The click event from the article link.
     */
    handleArticleLink(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.recordId,
                objectApiName: 'FAQ__ka',
                actionName: 'view',
            },
        });
    }

    get selectedTerm() {
        return this.hasSearched ? this.selectedSearchTerm : undefined;
    }

    get disableSearchButton() {
        const searchTerm = this.desiredSearchTerm?.trim().toLowerCase();
        const isSameSearch = searchTerm === this.selectedSearchTerm;
        const isSameFilter = this.desiredFilter === this.selectedFilter;
        const isBlank = !searchTerm;

        return isBlank || (isSameSearch && isSameFilter);
    }

    get disableNext() {
        return !this.nextPageAvailable;
    }

    get disablePrevious() {
        return !this.previousPageAvailable;
    }
}
