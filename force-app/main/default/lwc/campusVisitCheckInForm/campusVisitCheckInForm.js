import { LightningElement, wire, track, api } from 'lwc';
import LightningModal from 'lightning/modal';
import { getPicklistValues } from 'lightning/uiObjectInfoApi'

import getCampaignMembers from "@salesforce/apex/CampusVisitCheckInController.getCampaignMember"
import campaignMemberStatusPicklist from '@salesforce/schema/CampaignMember.Status'

export default class CampusVisitCheckInForm extends LightningModal {
    @api content;    

    campMem = {};
    memberStatusPicklistValues = [];

    @wire(getCampaignMembers, {recordId: '$content'})
    campaignMember(result) {
        this.campMem = result.data;
    }

    @wire(getPicklistValues, {
        recordTypeId: '012d0000000sXUVAA2',
        fieldApiName: campaignMemberStatusPicklist,
      })
      getPicklistValuesForField({ data, error }) {
        if (error) {
          // TODO: Error handling
          console.error(error)
        } else if (data) {
          this.memberStatusPicklistValues = [...data.values]
        }
      }

    get campaignMemberName() {
        return this.campMem?.data?.Name;
    }

    handleOkay() {
        console.log(this.content);
        console.log(this.campMem);
        console.log(this.campMem.data);
        console.log(this.campMem.data.Name);
        this.close('okay');
    }
}