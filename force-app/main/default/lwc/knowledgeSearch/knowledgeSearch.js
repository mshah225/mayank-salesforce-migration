import {LightningElement, wire} from 'lwc';
import {NavigationMixin, CurrentPageReference} from 'lightning/navigation';
import searchArticles from '@salesforce/apex/GlobalKnowledgeSearchController.searchArticles';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {IsConsoleNavigation, getFocusedTabInfo, setTabLabel, setTabIcon} from 'lightning/platformWorkspaceApi';

// Constants
const TAB_LABEL = 'Knowledge Search';
const TAB_ICON = 'utility:search';
const PAGE_SIZE = 10;

export default class KnowledgeSearch extends NavigationMixin(LightningElement) {
    // Component state variables
    selectedSearchTerm = ''; // Search term at time of clicking 'Search' button or clicking ENTER
    desiredSearchTerm = ''; // Current search term entered by the user, irregardless of search state
    selectedFilter = '*'; // Search filter at time of clicking 'Search' button or clicking ENTER
    desiredFilter = '*'; // Current search filter selected by the user, irregardless of search state

    articles = []; // All articles fetched from Apex global search
    filteredArticles = []; // Filtered articles to display to the user

    currentPage = 1;
    nextPageAvailable = false;
    previousPageAvailable = false;

    noResults = false; // Whether there are no articles in the search results
    error = null; // Error message, if any
    hasSearched = false; // Tracks whether a search has been performed

    isLoading = false; // Loading indicator

    // Dropdown filter options for category groups
    filterOptions = [
        {label: 'All Category Groups', value: '*'},
        {label: 'Academics', value: 'Academics'},
        {label: 'Campus Services', value: 'Campus_Services'},
        {label: 'Finances', value: 'Finances'},
        {label: 'Internal Knowledge', value: 'Internal_Knowledge'},
    ];

    @wire(CurrentPageReference)
    currentPageReference;

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
     * @description Handles user input in the search field.
     * @param {Event} event - The input event from the search field.
     */
    handleSearchInput(event) {
        this.searchTerm = event.target?.value;
    }

    /**
     * @description Handles changes in the filter dropdown.
     * @param {Event} event - The change event from the filter dropdown.
     */
    handleFilterChange(event) {
        this.desiredFilter = event.target.value;

        if (this.hasSearched) {
            this.selectedFilter = this.desiredFilter;
            this.currentPage = 1;
            this.fetchArticles();
        }
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
     * @description Executes the search based on the current search term and category filter.
     */
    handleSearch() {
        const hasValidSearch = /\S/.test(this.desiredSearchTerm);
        const searchTermChanged = this.selectedSearchTerm !== this.desiredSearchTerm;
        const filterChanged = this.selectedFilter !== this.desiredFilter;

        if (!hasValidSearch) {
            this.template.querySelector('.search-input')?.focus();
            return;
        }

        // Only do the heavy lifting if something changed
        if (searchTermChanged || filterChanged) {
            this.hasSearched = true;
            this.selectedSearchTerm = this.desiredSearchTerm;
            this.selectedFilter = this.desiredFilter;
            this.currentPage = 1; // Reset page on new search
            this.fetchArticles();
        }
    }

    /**
     * @description Calls the Apex controller to fetch articles using global search.
     */
    fetchArticles() {
        this.isLoading = true;

        searchArticles({
            searchTerm: this.selectedSearchTerm,
            pageSize: PAGE_SIZE,
            pageNumber: this.currentPage,
            categoryFilter: this.selectedFilter,
        })
            .then((result) => {
                this.articles = result.articles.map((article) => {
                    // Strip HTML tags
                    const cleanAnswer = article.Answer ? article.Answer.replace(/<[^>]*>/g, '') : '';

                    // Truncate to 150 chars, without cutting a word
                    let truncatedAnswer = cleanAnswer;
                    if (cleanAnswer.length > 150) {
                        const cutPoint = cleanAnswer.lastIndexOf(' ', 150);
                        truncatedAnswer = cleanAnswer.substring(0, cutPoint !== -1 ? cutPoint : 150) + '...';
                    }

                    return {
                        ...article,
                        Category: article.FunctionalGroup,
                        LastPublishedDate: this.formatDate(article.LastPublishedDate),
                        AnswerPreview: truncatedAnswer,
                    };
                });

                this.nextPageAvailable = result.hasNextPage;
                this.previousPageAvailable = result.hasPreviousPage;
                this.currentPage = result.currentPage;

                this.filteredArticles = [...this.articles];
                this.noResults = this.articles.length === 0;
                this.error = null;

                // Log metadata to console
                this.debugSearchResult(result);
            })
            .catch((error) => {
                console.error(error);
                this.showErrorToast('Error fetching articles.');
                this.error = error;
                this.articles = [];
                this.filteredArticles = [];
                this.noResults = true;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    /**
     * @description Filters articles based on the selected data category group name.
     */
    filterByCategory() {
        if (this.selectedFilter === '*') {
            this.filteredArticles = [...this.articles];
        } else {
            this.filteredArticles = this.articles.filter((article) =>
                article.Categories?.some((cat) => cat.startsWith(this.selectedFilter + ':'))
            );
        }

        this.noResults = this.filteredArticles.length === 0;
    }

    /**
     * @description Goes to the next page of results.
     */
    handleNextPage() {
        if (this.nextPageAvailable) {
            this.currentPage += 1;
            this.fetchArticles();
        }
    }

    /**
     * @description Goes to the previous page of results.
     */
    handlePreviousPage() {
        if (this.previousPageAvailable && this.currentPage > 1) {
            this.currentPage -= 1;
            this.fetchArticles();
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
     * @description Keeps the existing searchTerm property bound to the UI.
     */
    get searchTerm() {
        return this.desiredSearchTerm;
    }

    set searchTerm(value) {
        this.desiredSearchTerm = value?.trim().toLowerCase();
    }

    get disableSearchButton() {
        const searchTerm = this.desiredSearchTerm?.trim();
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

    debugSearchResult(result) {
        if (!this.currentPageReference?.state?.c__debug) return;

        console.log('🔎 Knowledge Search Debug Info:');
        console.log('  • Search Term:', this.selectedSearchTerm);
        console.log('  • Category Filter:', this.selectedFilter);
        console.log('  • Total Results:', result.totalResults);
        console.log('  • Total Pages:', result.totalPages);
        console.log('  • Current Page:', result.currentPage);
        console.log('  • Page Size:', PAGE_SIZE);
        console.log(JSON.stringify(this.articles, null, 2));
    }
}
