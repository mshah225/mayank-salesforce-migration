import {LightningElement, wire, api} from 'lwc';
import {EnclosingTabId, setTabLabel, setTabIcon} from 'lightning/platformWorkspaceApi';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';

import getCampaignMembers from '@salesforce/apex/CampusVisitHomePageController.getCampaignMembers';
import getAllCampaignMembers from '@salesforce/apex/CampusVisitHomePageController.getAllCampaignMembers';
import searchCampaignMembers from '@salesforce/apex/CampusVisitHomePageController.searchCampaignMembers';
import updateCampaignMembers from '@salesforce/apex/CampusVisitHomePageController.updateCampaignMembers';
import CheckInFormModal from 'c/campusVisitCheckInForm';
import WalkInFormModal from 'c/campusVisitWalkInForm';
import TourSplitModal from 'c/campusVisitTourGroupSplit';

import reportId from '@salesforce/label/c.Tour_Split_Report_Id';
import NAME from '@salesforce/schema/Campaign.Name';

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
    {label: 'Opportunity Type', fieldName: 'oppType'},
    {fieldName: 'actions', type: 'action', typeAttributes: {rowActions: ACTIONS}},
];

export default class CampusVisitHomePage extends NavigationMixin(LightningElement) {
    @api propertyValue;
    @wire(EnclosingTabId) enclosingTabId;

    cols = COLMS;
    campaignName;
    contacts;
    wiredContacts;
    wiredAllCampaignMembers;
    selectedContacts;
    baseData;
    nameSearchString = '';
    statusSearchString;
    isModalOpen = false;
    memberStatusCounts;
    memberStatusOptions;
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

    @wire(getAllCampaignMembers, {recordId: '$propertyValue'})
    setStatusCount(result) {
        this.wiredAllCampaignMembers = result;
        if(result && result.data) {
            this.memberStatusOptions = this.countStatusGroups(result?.data);
        }
    }

    @wire(getRecord, { recordId:'$propertyValue', fields: [NAME]})
    loadCampaignName({error, data}){
        console.log('loadFields, recordId: ', this.propertyValue);
        if(error){
            console.log('error', JSON.parse(JSON.stringify(error)));
        }else if(data){
            console.log('data', JSON.parse(JSON.stringify(data)));
            const paramField1 = getFieldValue(data, NAME);
            console.log('paramField1', paramField1);
            this.campaignName = paramField1;
        }
    }


    mapContacts(row) {
        var mailingState;
        var numOfGuests;
        var oppType;

        if (row.State == undefined || row.State == '') {
            if (row.Contact != undefined && row.Contact.MailingState != undefined) {
                mailingState = row.Contact.MailingState;
            } else {
                mailingState = '--';
            }
        }

        if (row.Opportunity__c == null || row.Opportunity__r.Type == null) {
            oppType = '--';
        } else {
            oppType = row.Opportunity__r.Type;
        }

        console.log(row);

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
            oppType: oppType,
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

    navigateToCampaignPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.propertyValue,
                objectApiName: 'Campaign',
                actionName: 'view'
            },
        });
    }

    updateSelectedCampaignMembers() {
        const idList = this.selectedContacts.map((row) => {
            return row.Id;
        });
        updateCampaignMembers({campaignMemberIds: idList}).then(() => {
            refreshApex(this.wiredContacts);
            refreshApex(this.wiredAllCampaignMembers);
        });
        this.template.querySelector('lightning-datatable').selectedRows = [];
        this.selectedContacts = undefined;
    }

    refreshTable() {
        refreshApex(this.wiredContacts);
        refreshApex(this.wiredAllCampaignMembers);
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
        return this.memberStatusOptions;
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

    countStatusGroups(allCampaignMembers) {

        this.memberStatusCounts = new Map();

        this.memberStatusCounts.set('Invited', 0);
        this.memberStatusCounts.set('Registered', 0);
        this.memberStatusCounts.set('Registered - Attended', 0);
        this.memberStatusCounts.set('Not Registered - Attended', 0);
        this.memberStatusCounts.set('Registered - Not Attended', 0);
        this.memberStatusCounts.set('Registered - Cancelled', 0);
        this.memberStatusCounts.set('Registered - Late', 0);
        
        for (let x = 0; x < allCampaignMembers.length; x++) {
            let statusCount = this.memberStatusCounts.get(allCampaignMembers[x].Status);
            this.memberStatusCounts.set(allCampaignMembers[x].Status, ++statusCount);
        }

        return [
            {label: 'Invited (' + this.memberStatusCounts.get('Invited') + ')', value: 'Invited'},
            {label: 'Registered (' + this.memberStatusCounts.get('Registered') + ')', value: 'Registered'},
            {label: 'Registered - Attended (' + this.memberStatusCounts.get('Registered - Attended') + ')', value: 'Registered - Attended'},
            {label: 'Not Registered - Attended (' + this.memberStatusCounts.get('Not Registered - Attended') + ')', value: 'Not Registered - Attended'},
            {label: 'Registered - Not Attended (' + this.memberStatusCounts.get('Registered - Not Attended') + ')', value: 'Registered - Not Attended'},
            {label: 'Registered - Cancelled (' + this.memberStatusCounts.get('Registered - Cancelled') + ')', value: 'Registered - Cancelled'},
            {label: 'Registered - Late (' + this.memberStatusCounts.get('Registered - Late') + ')', value: 'Registered - Late'},
        ];
        
    }

    async splitIntoTourGroups() {
        const result = await TourSplitModal.open({
            size: 'large',
            description: "Accessible description of modal's purpose",
            content: this.propertyValue,
        });

        this.refreshTable();

        if (result) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: reportId,
                    objectApiName: 'Report',
                    actionName: 'view'
                },
                state : {
                    fv0: this.propertyValue
                }
            });
        }
    }
}