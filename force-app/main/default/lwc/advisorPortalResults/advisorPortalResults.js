import {LightningElement, api} from 'lwc';
import persistenceChart from '@salesforce/resourceUrl/PersistenceChart';

export default class AdvisorPortalResults extends LightningElement {
    @api allResults = [];
    currentPage = 0;

    get shownContactWrappers() {
        const shownResults = [
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

        return shownResults;
    }

    openSections = [];

    get allResultsIsEmpty() {
        return this.sizeOfAllResults === 0;
    }

    get persistenceIconVeryLow() {
        return persistenceChart + '/icon-1.png';
    }
    get persistenceIconLow() {
        return persistenceChart + '/icon-2.png';
    }
    get persistenceChartModerate() {
        return persistenceChart + '/icon-3.png';
    }
    get persistenceIconHigh() {
        return persistenceChart + '/icon-4.png';
    }
    get persistenceIconVeryHigh() {
        return persistenceChart + '/icon-5.png';
    }

    changePage(e) {
        const newPage = e.detail;
        this.currentPage = newPage;
    }

    openDropdown(e) {
        console.log(e);
        //const contactId = e.originalTarget.data.contactId;
    }
    closeDropdown(e) {
        console.log(e);
        //const contactId = e.originalTarget.data.contactId;
    }
}
