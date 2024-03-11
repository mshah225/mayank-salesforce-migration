import {LightningElement, wire, api} from 'lwc';
import {EnclosingTabId, setTabLabel, setTabIcon} from 'lightning/platformWorkspaceApi';

import getCampaignMembers from '@salesforce/apex/CampusVisitHomePageController.getCampaignMembers';
import searchCampaignMembers from '@salesforce/apex/CampusVisitHomePageController.searchCampaignMembers';
import updateCampaignMembers from '@salesforce/apex/CampusVisitHomePageController.updateCampaignMembers';
import CheckInFormModal from 'c/campusVisitCheckInForm';
import WalkInFormModal from 'c/campusVisitWalkInForm';

import {NavigationMixin} from 'lightning/navigation';
import {refreshApex} from '@salesforce/apex';

const ACTIONS = [{label: 'Check-In', name: 'Check-In'}];

const COLS = [
    {label: 'Name', fieldName: 'link', type: 'url', typeAttributes: {label: {fieldName: 'FullName'}}},
    {label: 'Email', fieldName: 'Email'},
    {label: 'Account', fieldName: 'accountLink', type: 'url', typeAttributes: {label: {fieldName: 'AccountName'}}},
    {label: 'Mailing Address', fieldName: 'MailingAddress'},
    {fieldName: 'actions', type: 'action', typeAttributes: {rowActions: ACTIONS}},
];

const COLMS = [
    {label: 'Type', fieldName: 'parentLink', type: 'url', typeAttributes: {label: {fieldName: 'Type'}}},
    {label: 'Name', fieldName: 'recordLink', type: 'url', typeAttributes: {label: {fieldName: 'FullName'}}},
    {label: 'Mailing State', fieldName: 'State'},
    {label: 'Status', fieldName: 'Status'},
    {label: 'Number of Guests', fieldName: 'numberOfGuests'},
    {label: 'Number of Attendees', fieldName: 'numberofAttendees'},
    {fieldName: 'actions', type: 'action', typeAttributes: {rowActions: ACTIONS}},
];

export default class CampusVisitHomePage extends NavigationMixin(LightningElement) {
    @api propertyValue;
    @wire(EnclosingTabId) enclosingTabId;

    cols = COLMS;
    contacts;
    wiredContacts;
    selectedContacts;
    baseData;
    nameSearchString = '';
    statusSearchString;
    isModalOpen = false;
    value = ['Registered', 'Registered - Late'];

    get selectedContactsLen() {
        if (this.selectedContacts == undefined) return 0;
        return this.selectedContacts.length;
    }

    @wire(getCampaignMembers, {recordId: '$propertyValue', searchStatus: '$value'})
    contactsWire(result) {
        this.wiredContacts = result;
        if (result.data) {
            this.contacts = result.data.map((row) => {
                return this.mapContacts(row);
            });
            this.baseData = this.contacts;
            setTabLabel(this.enclosingTabId, 'Check-In Form');
            setTabIcon(this.enclosingTabId, 'utility:checkin');
        }
        if (result.error) {
            console.error(result.error);
        }
    }

    mapContacts(row) {
        var mailingState;
        var numOfGuests;

        if (row.State == undefined || row.State == '') {
            if (row.Contact != undefined && row.Contact.MailingState != undefined) {
                mailingState = row.Contact.MailingState;
            } else {
                mailingState = '--';
            }
        }

        if (row.Number_of_Guests__c == undefined) {
            numOfGuests = '0';
        } else {
            numOfGuests = row.Number_of_Guests__c;
        }

        return {
            ...row,
            FullName: `${row.Name}`,
            recordLink: `/${row.Id}`,
            parentLink: `/${row.LeadOrContactID__c}`,
            Type: `${row.Type}`,
            State: mailingState,
            Status: `${row.Status}`,
            numberOfGuests: numOfGuests,
            numberofAttendees: `${row.Number_of_Attendees__c}`,
        };
    }

    handleRowSelection(event) {
        this.selectedContacts = event.detail.selectedRows;
    }

    async handleSearch(event) {
        this.nameSearchString = event.target.value;

        this.fetchFilteredRecords();
    }

    async fetchFilteredRecords() {
        const searchContacts = await searchCampaignMembers({
            searchString: this.nameSearchString,
            searchStatus: this.value,
            recordId: this.propertyValue,
        });

        this.contacts = searchContacts.map((row) => {
            return this.mapContacts(row);
        });
    }

    navigateToNewRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new',
            },
        });
    }

    updateSelectedCampaignMembers() {
        const idList = this.selectedContacts.map((row) => {
            return row.Id;
        });
        updateCampaignMembers({campaignMemberIds: idList}).then(() => {
            refreshApex(this.wiredContacts);
        });
        this.template.querySelector('lightning-datatable').selectedRows = [];
        this.selectedContacts = undefined;
    }

    refreshTable() {
        console.log('refreshing table');
        refreshApex(this.wiredContacts);
        this.template.querySelector('lightning-datatable').selectedRows = [];
        this.selectedContacts = undefined;
    }

    async createCampaignMember() {
        const result = await WalkInFormModal.open({
            size: 'large',
            description: "Accessible description of modal's purpose",
            content: this.propertyValue,
        });

        this.refreshTable();
    }

    get options() {
        return [
            {label: 'Invited', value: 'Invited'},
            {label: 'Registered', value: 'Registered'},
            {label: 'Registered - Attended', value: 'Registered - Attended'},
            {label: 'Not Registered - Attended', value: 'Not Registered - Attended'},
            {label: 'Registered - Not Attended', value: 'Registered - Not Attended'},
            {label: 'Registered - Cancelled', value: 'Registered - Cancelled'},
            {label: 'Registered - Late', value: 'Registered - Late'},
        ];
    }

    get selectedValues() {
        return this.value.join(',');
    }

    handleChange(e) {
        this.value = e.detail.value;
        this.fetchFilteredRecords();
    }

    async handleRowAction(event) {
        const result = await CheckInFormModal.open({
            size: 'large',
            description: "Accessible description of modal's purpose",
            content: event.detail.row.Id,
        });

        this.refreshTable();
    }
}