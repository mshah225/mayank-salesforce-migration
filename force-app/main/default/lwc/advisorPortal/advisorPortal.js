import {LightningElement} from 'lwc';

export default class AdvisorPortal extends LightningElement {
    defaultFilter = {};
    currentFilter = {};
    selectedUsers = [];
    allResults = [
        {
            isSelected: true,
            isOpen: true,
            portalContact: {
                Id: '001',
                Name: 'Robert Nordman',
                Preferred_First_Name__c: 'Robert',
                LastName: 'Nordman',
                Curr_Cont_Prediction_Level__c: 6,
                Most_Recent_Outlook_Change_Direction__c: 1,
                Change_Date__c: 1547250828000,
            },
            hasCases: true,
            hasMultipleCases: false,
            isOutreachCustomer: true,
            cases: [
                {
                    isSelected: true,
                    hasFollowupDate: true,
                    portalCase: {
                        Id: '301',
                        Priority: 'Normal',
                        CaseNumber: '16317868',
                        Subject: '2217 Applied to Graduate',
                        Status: 'Outreach Required',
                        Followup_Date__c: 1547250828000,
                        Owner: {
                            Name: 'UGBA16',
                        },
                        CreatedDate: 1547250828000,
                    },
                },
            ],
        },
    ];
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
        //this.allResults = e.detail;
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

    navigate(e) {
        console.log('navigate', e);
    }
}
