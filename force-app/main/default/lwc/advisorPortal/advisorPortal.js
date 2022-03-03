import {LightningElement, wire} from 'lwc';
import checkIfAllowedToUse from '@salesforce/apex/AdvisorPortalMassTransferController.checkIfAllowedToUse';

export default class AdvisorPortal extends LightningElement {
    defaultFilter = {};
    currentFilter = {};
    allUsers = [];
    selectedUsers = [];
    allResults = [];
    selectedResults = [];

    loadingCounter = 0;

    get isLoading() {
        return this.loadingCounter > 0;
    }

    allowedToUseMassTransfer;
    @wire(checkIfAllowedToUse, {})
    checkedIfAllowedToUse(result) {
        let {data, error} = result;
        if (data != null) {
            this.allowedToUseMassTransfer = data;
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
        this.loadLess();
    }

    // One loading for each wire
    connectedCallback() {
        this.loadMore();
    }

    // Should only run once on page load
    setDefaultFilter(e) {
        this.defaultFilter = JSON.parse(e.detail.filter);
        this.currentFilter = this.defaultFilter;
    }

    updateFilter(e) {
        console.log('updateFilter', e);
        this.currentFilter[e.detail.name] = e.detail.value;
        this.triggerCurrentFilterChanges();
        this.printCurrentFilter();
    }

    updateResults(e) {
        console.log('updateResults', e);
        this.allResults = e.detail;
    }

    changeAllUsers(e) {
        console.log('changeAllUsers', e);
        this.allUsers = [...e.detail];
    }
    changeSelectedUsers(e) {
        console.log('changeSelectedUsers', e);
        this.selectedUsers = [...e.detail];
    }

    updateSelectedResults(e) {
        console.log('updateSelectedResults', e);
        this.selectedResults = [...e.detail];
    }

    triggerCurrentFilterChanges() {
        this.currentFilter = {...this.currentFilter};
    }

    printCurrentFilter() {
        console.log(this.currentFilter);
    }

    navigate(e) {
        console.log('navigate', e);
    }

    reloadContacts() {
        this.template.querySelector('c-advisor-portal-filter-section').forceRefresh();
    }

    openModalMassEmail() {
        if (this.selectedResults.length === 0) {
            this.showToast('Error', 'You must select some contacts/cases before using this', 'error', 5000);
        } else {
            this.template.querySelector('c-advisor-portal-modal-mass-email').openModal();
        }
    }
    openModalMassTransfer() {
        if (this.selectedResults.length === 0) {
            this.showToast('Error', 'You must select some contacts/cases before using this', 'error', 5000);
        } else {
            this.template.querySelector('c-advisor-portal-modal-mass-transfer').openModal();
        }
    }

    handleLoading(e) {
        const loadMore = e.detail;
        if (loadMore) {
            this.loadMore();
        } else {
            this.loadLess();
        }
    }
    loadMore() {
        this.loadingCounter++;
    }
    loadLess() {
        this.loadingCounter--;
        if (this.loadingCounter < 0) this.loadingCounter = 0;
    }

    handleToast(e) {
        const title = e.detail.title;
        const message = e.detail.message;
        const type = e.detail.type;
        const duration = e.duration ? e.duration : 5000;
        this.showToast(title, message, type, duration);
    }
    showToast(title, message, type, duration) {
        const toastLWC = this.template.querySelector('c-lightning-design-toast');
        toastLWC.fireParams(title, message, type, duration);
    }
}
