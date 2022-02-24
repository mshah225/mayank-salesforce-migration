import {LightningElement} from 'lwc';

export default class AdvisorPortalWrapper extends LightningElement {
    defaultFilter = {};
    currentFilter = {};
    selectedUsers = [];
    shownResults = [];
    selectedResults = [];

    // Should only run once on page load
    setDefaultFilter(e) {
        this.defaultFilter = JSON.parse(e.detail.filter);
    }

    updateFilter(e) {
        this.currentFilter[e.detail.name] = e.detail.value;
        this.triggerCurrentFilterChanges();
        this.printCurrentFilter();
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
