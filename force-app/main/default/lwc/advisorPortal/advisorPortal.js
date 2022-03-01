import {getListUi} from 'lightning/uiListApi';
import {LightningElement} from 'lwc';

export default class AdvisorPortal extends LightningElement {
    defaultFilter = {};
    currentFilter = {};
    selectedUsers = [];
    allResults = [];
    selectedResults = [];

    loadingCounter = 0;

    get isLoading() {
        return this.loadingCounter > 0;
    }

    get topLevelWrapperClasses() {
        const classes = [];
        if (this.isLoading) classes.push('no-scroll');
        return classes.join(' ');
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

    openModalMassEmail() {
        this.template.querySelector('c-advisor-portal-modal-mass-email').openModal();
    }

    handleLoading(e) {
        const loadMore = e.detail;
        if (loadMore) {
            this.loadingCounter++;
        } else {
            this.loadingCounter--;
            if (this.loadingCounter < 0) this.loadingCounter = 0;
        }
    }
}
