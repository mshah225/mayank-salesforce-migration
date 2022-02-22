import {LightningElement} from 'lwc';

export default class AdvisorPortalWrapper extends LightningElement {
    defaultFilter = {caseTypeState: 'AllCasesState'};
    currentFilter = {caseTypeState: 'AllCasesState'};
    selectedUsers = [];

    updateFilter(e) {
        this.currentFilter[e.detail.name] = e.detail.value;
        this.triggerCurrentFilterChanges();
        this.printCurrentFilter();
    }
    updateFilterCareerSelection(e) {
        this.currentFilter.gradStudentsOnly = e.detail.value;
        this.triggerCurrentFilterChanges();
        this.printCurrentFilter();
    }
    updateFilterContactCaseSelection(e) {
        this.currentFilter.caseTypeState = e.detail.value;
        this.triggerCurrentFilterChanges();
        this.printCurrentFilter();
    }

    changeSelectedUsers(e) {
        this.selectedUsers = e.detail;
    }

    triggerCurrentFilterChanges() {
        this.currentFilter = {...this.currentFilter};
    }

    printCurrentFilter() {
        console.log(this.currentFilter);
    }
}
