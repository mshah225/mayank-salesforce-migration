import { LightningElement, wire, track, api } from 'lwc';
import LightningModal from 'lightning/modal';
import { getPicklistValues } from 'lightning/uiObjectInfoApi'

import getCampaignMembers from "@salesforce/apex/CampusVisitCheckInController.getCampaignMember"
import getOtherEvents from "@salesforce/apex/CampusVisitCheckInController.getOtherEvents"
import saveCampaignMember from "@salesforce/apex/CampusVisitCheckInController.saveCampaignMember"
import campaignMemberStatusPicklist from '@salesforce/schema/CampaignMember.Status'

const otherEventColumns = [
    { label: 'Event Name', fieldName: 'eventName' },
    { label: 'Status', fieldName: 'eventMemberStatus'},
    { label: 'Event Start Date', fieldName: 'eventStartTime'}
];


export default class CampusVisitCheckInForm extends LightningModal {
    @api content;    

    otherEventColumns = otherEventColumns;

    campMem = {};
    otherEvents = [];
    memberStatusPicklistValues = [];

    campaignMemberStatus;
    campaignMemberBadgeName;
    campaignMemberGuests;
    campaignMemberAcademicSession;
    campaignMemberComments;
    campaignMemberBarretts;
    campaignMemberHousingTour;
    campaignMemberAddTourInfo;

    @wire(getCampaignMembers, {recordId: '$content'})
    campaignMember(result) {
        this.campMem = result.data;

        console.log(result.data);
        getOtherEvents({personId: this.campMem?.LeadOrContactID__c, currentCampaignMemberId: this.campMem?.Id, eventDate: this.campMem?.Campaign?.Event_Start_Date__c})
        .then(eventResults => {
            this.otherEvents = eventResults;
            console.log(eventResults);
        })
        .catch(error => {
            this.error = error;
        });
    }

    @wire(getPicklistValues, {
        recordTypeId: '012d0000000sXUVAA2',
        fieldApiName: campaignMemberStatusPicklist,
      })
      getPicklistValuesForField({ data, error }) {
        if (error) {
          console.error(error)
        } else if (data) {
          this.memberStatusPicklistValues = [...data.values]
        }
      }

    handleOkay() {
        console.log(this.campMem.Status);
        this.saveRecord();
        this.close('okay');
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
        this.campaignMemberAcademicSession = e.detail.value;
    }
    
    handleCommentsChange(e) {
        this.campaignMemberComments = e.detail.value;
    }
    
    handleBarrettChange(e) {
        this.campaignMemberBarretts = e.detail.value;
    }
    
    handleHousingTourChange(e) {
        this.campaignMemberHousingTour = e.detail.value;
    }
    
    handleAddTourChange(e) {
        this.campaignMemberAddTourInfo = e.detail.value;
    }
    

    saveRecord() {
        console.log('Saving');
        let camMem = {}
        camMem.Id = this.content;

        camMem.Status = this.campaignMemberStatus;
        camMem.Badge_Name__c = this.campaignMemberBadgeName;
        camMem.Number_of_Guests__c = this.campaignMemberGuests;
        camMem.Academic_Session__c = this.campaignMemberAcademicSession;
        camMem.Comments__c = this.campaignMemberComments;
        camMem.Barrett_Session__c = this.campaignMemberBarretts;
        camMem.Housing_Tour__c = this.campaignMemberHousingTour;
        camMem.Additional_Tour_Information__c = this.campaignMemberAddTourInfo;
        
        saveCampaignMember({cm: camMem})
        .then(result => {
            console.log(result);
        })
        .catch(error => {
            this.error = error;
        });
    }
}