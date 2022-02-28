import {LightningElement} from 'lwc';

export default class AdvisorPortal extends LightningElement {
    defaultFilter = {};
    currentFilter = {};
    selectedUsers = [];
    allResults = [];
    selectedResults = [];

    // Should only run once on page load
    setDefaultFilter(e) {
        this.defaultFilter = JSON.parse(e.detail.filter);
        this.currentFilter = this.defaultFilter;
    }

    updateFilter(e) {
        this.currentFilter[e.detail.name] = e.detail.value;
        this.triggerCurrentFilterChanges();
        this.printCurrentFilter();
    }

    updateResults(e) {
        console.log(e);
        this.allResults = e.detail;
    }

    changeSelectedUsers(e) {
        this.selectedUsers = [...e.detail];
        console.log(this.selectedUsers);
    }

    triggerCurrentFilterChanges() {
        this.currentFilter = {...this.currentFilter};
    }

    printCurrentFilter() {
        console.log(this.currentFilter);
    }
}
