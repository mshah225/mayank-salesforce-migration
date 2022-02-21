import {LightningElement} from 'lwc';

export default class AdvisorPortalWrapper extends LightningElement {
    defaultFilter = {caseTypeState: 'AllCasesState'};
    currentFilter = {caseTypeState: 'AllCasesState'};

    updateFilterCareerSelection(e) {
        this.currentFilter.gradStudentsOnly = e.detail.value;
        this.printCurrentFilter();
    }
    updateFilterContactCaseSelection(e) {
        this.currentFilter.caseTypeState = e.detail.value;
        this.printCurrentFilter();
    }

    printCurrentFilter() {
        console.log(this.currentFilter);
    }
}
