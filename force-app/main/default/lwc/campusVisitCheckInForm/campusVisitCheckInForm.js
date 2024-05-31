import {LightningElement, wire, track, api} from 'lwc';
import LightningModal from 'lightning/modal';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';

import getCampaignMembers from '@salesforce/apex/CampusVisitCheckInController.getCampaignMember';
import getOtherEvents from '@salesforce/apex/CampusVisitCheckInController.getOtherEvents';
import saveCampaignMember from '@salesforce/apex/CampusVisitCheckInController.saveCampaignMember';
import campaignMemberStatusPicklist from '@salesforce/schema/CampaignMember.Status';

const otherEventColumns = [
    {label: 'Event Name', fieldName: 'eventName'},
    {label: 'Status', fieldName: 'eventMemberStatus'},
    {label: 'Event Start Date', fieldName: 'eventStartTime'},
];

export default class CampusVisitCheckInForm extends LightningModal {
    @api content;

    otherEventColumns = otherEventColumns;

    campMem = {};
    otherEvents = [];
    memberStatusPicklistValues = [
        {label: 'Invited', value: 'Invited'},
        {label: 'Registered', value: 'Registered'},
        {label: 'Registered - Attended', value: 'Registered - Attended'},
        {label: 'Not Registered - Attended', value: 'Not Registered - Attended'},
        {label: 'Registered - Not Attended', value: 'Registered - Not Attended'},
        {label: 'Registered - Cancelled', value: 'Registered - Cancelled'},
        {label: 'Registered - Late', value: 'Registered - Late'},
    ];

    campaignMemberStatus;
    campaignMemberBadgeName;
    campaignMemberGuests;
    campaignMemberAcademicSession;
    campaignMemberComments;
    campaignMemberBarretts;
    campaignMemberHousingTour;
    campaignMemberAddTourInfo;
    campaignDate;

    @wire(getCampaignMembers, {recordId: '$content'})
    campaignMember(result) {
        if (result?.data?.Campaign != null) {
            this.campaignDate = new Date(result.data.Campaign.Event_Start_Date__c + 'UTC-08:00').toLocaleDateString('en-US');
        }
        this.campMem = result.data;
        this.campaignMemberStatus = 'Registered - Attended';
        getOtherEvents({
            personId: this.campMem?.LeadOrContactID__c,
            currentCampaignMemberId: this.campMem?.Id,
            eventDate: this.campMem?.Campaign?.Event_Start_Date__c,
        })
            .then((eventResults) => {
                this.otherEvents = eventResults;
                console.log(eventResults);
            })
            .catch((error) => {
                this.error = error;
            });
    }

    handleOkay() {
        this.saveRecord().then(() => {
            this.close('okay');
        });
    }

    handleStatusChange(e) {
        this.campaignMemberStatus = e.detail.value;
    }

    handleBadgeNameChange(e) {
        this.campaignMemberBadgeName = e.detail.value;
    }

    handleGuestsChange(e) {
        this.campaignMemberGuests = e.detail.value;
    }

    handleAcaSessionChange(e) {
        this.campaignMemberAcademicSession = e.detail.value[0];
    }

    handleCommentsChange(e) {
        this.campaignMemberComments = e.detail.value;
    }

    handleBarrettChange(e) {
        this.campaignMemberBarretts = e.detail.checked;
    }

    handleHousingTourChange(e) {
        this.campaignMemberHousingTour = e.detail.checked;
    }

    handleAddTourChange(e) {
        this.campaignMemberAddTourInfo = e.detail.value;
    }

    printBadge() {
        let displayName = '';

        if (this.campaignMemberBadgeName) {
            displayName = encodeURIComponent(this.campaignMemberBadgeName.trim());
        } else if (this.campMem.Badge_Name__c) {
            displayName = encodeURIComponent(this.campMem.Badge_Name__c.trim());
        } else {
            displayName = encodeURIComponent(this.campMem.Name.trim());
        }

        let url = '/apex/CampusVisitBadge?name=' + displayName + '&campaign=' + this.campMem.Campaign.Id;
        window.open(url, "_blank");
    }

    saveRecord() {
        let camMem = {};
        camMem.Id = this.content;

        camMem.Status = this.campaignMemberStatus;
        camMem.Badge_Name__c = this.campaignMemberBadgeName;
        camMem.Number_of_Guests__c = this.campaignMemberGuests;
        camMem.Academic_Session__c = this.campaignMemberAcademicSession;
        camMem.Comments__c = this.campaignMemberComments;
        camMem.Barrett_Session__c = this.campaignMemberBarretts;
        camMem.Housing_Tour__c = this.campaignMemberHousingTour;
        camMem.Additional_Tour_Information__c = this.campaignMemberAddTourInfo;

        return saveCampaignMember({cm: camMem})
            .then((result) => {
                console.log(result);
            })
            .catch((error) => {
                this.error = error;
            });
    }
}