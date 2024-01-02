import { LightningElement, wire, api } from 'lwc';

import getCampaignMembers from "@salesforce/apex/CampusVisitController.getCampaignMembers"
import searchCampaignMembers from "@salesforce/apex/CampusVisitController.searchCampaignMembers"
import updateCampaignMembers from "@salesforce/apex/CampusVisitController.updateCampaignMembers"
import CheckInFormModal from "c/campusVisitCheckInForm"

import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';


const ACTIONS = [{label: 'Check-In', name: 'Check-In'}]

const COLS = [{label: 'Name', fieldName: 'link', type: 'url', typeAttributes: {label: {fieldName: 'FullName'}}},
            {label: 'Email', fieldName: 'Email'},
            {label: 'Account', fieldName: "accountLink", type: 'url', typeAttributes: {label: {fieldName: 'AccountName'}}},
            {label: "Mailing Address", fieldName: 'MailingAddress'},
            { fieldName: "actions", type: 'action', typeAttributes: {rowActions: ACTIONS}}
]

const COLMS = [
            {label: 'Type', fieldName: 'parentLink', type: 'url', typeAttributes: {label: {fieldName: 'Type'}}},
            {label: 'Name', fieldName: 'recordLink', type: 'url', typeAttributes: {label: {fieldName: 'FullName'}}},
            {label: 'Mailing State', fieldName: 'State'},
            {label: 'Status', fieldName: 'Status'},
            {label: "Number of Guests", fieldName: 'numberOfGuests'},
            {label: "Number of Attendees", fieldName: 'numberofAttendees'},
            { fieldName: "actions", type: 'action', typeAttributes: {rowActions: ACTIONS}}
]

export default class CampusVisitHomePage extends NavigationMixin(LightningElement) {
    @api propertyValue;
    
    cols = COLMS;
    contacts;
    wiredContacts;
    selectedContacts;
    baseData;
    nameSearchString = '';
    statusSearchString;
    isModalOpen = false;
    value = ['Responded', 'Sent'];

    get selectedContactsLen() {
        if(this.selectedContacts == undefined) return 0;
        return this.selectedContacts.length
    }

    @wire(getCampaignMembers)
    contactsWire(result) {
        this.wiredContacts = result;
        if(result.data){
            this.contacts = result.data.map((row) => {
                return this.mapContacts(row);
            })
            this.baseData = this.contacts;
        }
        if(result.error){
            console.error(result.error);
        }
    }

    mapContacts(row){

        var mailingState; 
        
        if (row.State == undefined) {
            if (row.Contact != undefined) {
                mailingState = row.Contact.SF_Mailing_State__c;
            } else {
                mailingState = '--';
            }
        }

        return {...row,
            FullName: `${row.Name}`,
            recordLink: `/${row.Id}`,
            parentLink: `/${row.LeadOrContactID__c}`,
            Type: `${row.Type}`,
            State: mailingState,
            Status: `${row.Status}`,
            numberOfGuests: `${row.Number_of_Guests__c}`,
            numberofAttendees: `${row.Number_of_Attendees__c}`
        };
    }

    handleRowSelection(event) {
        this.selectedContacts = event.detail.selectedRows;
    }

    async handleSearch(event){
        this.nameSearchString = event.target.value;

        this.fetchFilteredRecords();
    }

    async fetchFilteredRecords() {
        const searchContacts = await searchCampaignMembers({searchString: this.nameSearchString, searchStatus: this.value})

        this.contacts = searchContacts.map(row => {
            return this.mapContacts(row);
        })
    }


    navigateToNewRecordPage() {

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new'
            }
        });
    }

    updateSelectedCampaignMembers(){
        const idList = this.selectedContacts.map( row => { return row.Id })
        updateCampaignMembers({campaignMemberIds : idList}).then( () => {
            refreshApex(this.wiredContacts);
        })
        this.template.querySelector('lightning-datatable').selectedRows = [];
        this.selectedContacts = undefined;
    }

    async createCampaignMember() {      
        const result = await CheckInFormModal.open({
            size: 'large',
            description: 'Accessible description of modal\'s purpose',
            content: 'Passed into content api',
        });
        console.log(result);
    }

    get options() {
        return [
            { label: 'Responded', value: 'Responded' },
            { label: 'Sent', value: 'Sent' },
            { label: 'Checked-In', value: 'Checked-In'}
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
            description: 'Accessible description of modal\'s purpose',
            content: event.detail.row.Id,
        });
        console.log(result);
    }

}