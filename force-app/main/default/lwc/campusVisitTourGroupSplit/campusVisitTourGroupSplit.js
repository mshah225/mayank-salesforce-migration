import {LightningElement, api, wire} from 'lwc';
import LightningModal from 'lightning/modal';
import updateCampaignMembers from '@salesforce/apex/CampusVisitTourSplitController.updateCampaignMembers';
import getCampaignMemberSessions from '@salesforce/apex/CampusVisitTourSplitController.getCampaignMemberAcademicSessions';
import splitGroupsByAcademicSession from '@salesforce/apex/CampusVisitTourSplitController.splitGroupsByAcademicSession';


const memberColumns = [
    {label: 'Name', fieldName: 'Name'},
    {label: 'Attendees + Guests', fieldName: 'Number_of_Attendees__c'},
    {label: 'Academic Session', fieldName: 'Academic_Session_Name__c'},
    {label: 'Comments', fieldName: 'Comments__c'},
    {label: 'Barrett', type: 'boolean', fieldName: 'Barrett_Session__c'},
    {label: 'Housing', type: 'boolean', fieldName: 'Housing_Tour__c'},
    {label: 'Additional Tour', fieldName: 'Additional_Tour_Information__c'},
    {label: 'Tour Group Number', fieldName: 'Tour_Group_Id__c', editable: true},
];

export default class CampusVisitTourGroupSplit extends LightningModal {
    @api content;

    pageOne = true;
    pageTwo = false;
    mapData;
    
    tourGuideSize = [];
    campaignMemberColumns = memberColumns;

    editedColumns;
    overflowGroup;
    tourGroups;
    changedGroups = new Map();

    results;

    @wire(getCampaignMemberSessions, {campaignId: '$content'})
    setStatusCount(result) {

        if (result.data) {            
            this.mapData = [];

            for (let key in result.data) {
                let sessionName = key;

                if (key == 'null') {
                    sessionName = 'No Academic Session';
                }

                let campaignMemberPair = {key: sessionName, value: result.data[key]};
                this.mapData.push(campaignMemberPair);

                this.tourGuideSize.push({key: sessionName, value: 1});
            }

        }
    }

    goToPageOne() {
        this.pageOne = true;
        this.pageTwo = false;
    }

    goToPageTwo() {
        this.pageOne = false;
        this.pageTwo = true;


        let jSonOfTourGuideMap = "{";

        for (let i = 0; i < this.tourGuideSize.length; i++) {
            if (this.tourGuideSize[i].key == 'No Academic Session') {
                this.tourGuideSize[i].key = 'null';
            }
            jSonOfTourGuideMap += "\"" + this.tourGuideSize[i].key + "\": \"" + this.tourGuideSize[i].value + "\",";
        }

        jSonOfTourGuideMap = jSonOfTourGuideMap.slice(0, -1);

        jSonOfTourGuideMap += "}";


        console.log(jSonOfTourGuideMap);

        splitGroupsByAcademicSession({academicSessionGuideNumbers: jSonOfTourGuideMap, campaignId: this.content})
        .then((result) => {
            this.tourGroups = result;
            
        })
        .catch((error) => {
            this.error = error;
        });
            
    }

    handleTourGuideChange(e) {
        let targetName = e.target.dataset.id;

        if (targetName) {
            for (let i = 0; i < this.tourGuideSize.length; i++) {
                if (this.tourGuideSize[i].key == targetName) {
                    this.tourGuideSize[i].value = e.detail.value;
                }
            }
        }
    }

    updateTourGroupNumber(e) {
        this.changedGroups.set(e.detail.draftValues[0].Id, e.detail.draftValues[0].Tour_Group_Id__c);
    }

    handleSave() {
        var campaignMembers = [];
        for (let i = 0; i < this.tourGroups.length; i++) {
            for (let j = 0; j < this.tourGroups[i].membersForTour.length; j++) {

                var cm = JSON.parse(JSON.stringify(this.tourGroups[i].membersForTour[j]));

                var foundInMap = this.changedGroups.get(cm.Id);

                if (foundInMap) {
                    cm.Tour_Group_Id__c = foundInMap;
                }

                campaignMembers.push(cm)
            }
        }

        updateCampaignMembers({cmsToUpdate: campaignMembers})
            .then((result) => {
                this.close(true);
            })
            .catch((error) => {
                this.error = error;
            }); 
    }
}