import {LightningElement, api} from 'lwc';
import LightningModal from 'lightning/modal';
import searchContact from '@salesforce/apex/CampusVisitWalkInFormController.searchContact';
import getOpportunities from '@salesforce/apex/CampusVisitWalkInFormController.getOpportunities';
import searchCampaign from '@salesforce/apex/CampusVisitWalkInFormController.searchCampaign';
import submitRecords from '@salesforce/apex/CampusVisitWalkInFormController.submitRecordsForWalkin';

const oppColumns = [
    {label: 'Name', fieldName: 'Name'},
    {label: 'Career', fieldName: 'Career__c'},
    {label: 'Type', fieldName: 'Type'},
    {label: 'International Flag', fieldName: 'International_Student__c'},
    {label: 'Stage', fieldName: 'StageName'},
    {label: 'Term', fieldName: 'Term__r_Name'},
    {label: 'College', fieldName: 'College__r_Name'},
    {label: 'Plan', fieldName: 'Plan__c'},
];

const conColumns = [
    {label: 'Name', fieldName: 'Name'},
    {label: 'ASURITE', fieldName: 'ASURite_ID__c'},
    {label: 'Phone Number', fieldName: 'Phone'},
    {label: 'Zip Code', fieldName: 'MailingPostalCode'},
    {label: 'Email Address', fieldName: 'Email'},
    {label: 'Date of Birth', fieldName: 'Birthdate'},
];

export default class CampusVisitWalkInForm extends LightningModal {
    @api content;

    pageOne = true;
    pageTwo = false;
    pageThree = false;

    oppData = [];
    multipleConData;
    missingFields = [];
    invalidSubmissionParameters = false;
    oppColumns = oppColumns;
    conColumns = conColumns;
    selectedOpp;
    contactRecordId;
    invalidParameters = false;
    noOpportunityResults = false;
    noContactResults = false;
    isUndergrad = true;
    isContactSelected = false;
    isOpportunitySelected = false;

    error;
    submissionError;
    loading = false;

    campaignRecord = {};
    contactRecord = {};
    opportunityRecord = {};
    campaignMemberRecord = {
        Status: 'Not Registered - Attended',
    };

    careerOptions = [
        {label: 'Undergraduate', value: 'Undergraduate'},
        {label: 'Graduate', value: 'Graduate'},
        {label: 'Law', value: 'Law'},
    ];

    opportunityUndergradTypeOptions = [
        {label: 'First Time Freshman', value: 'First Time Freshman'},
        {label: 'Readmission', value: 'Readmission'},
        {label: 'Transfer', value: 'Transfer'},
    ];

    opportunityGradTypeOptions = [
        {label: 'Certificate', value: 'Certificate'},
        {label: 'Doctoral', value: 'Doctoral'},
        {label: 'Juris Doctor', value: 'Juris Doctor'},
        {label: 'Masters', value: 'Masters'},
        {label: 'Non-Degree', value: 'Non-Degree'},
    ];

    goToPageOne() {
        this.pageOne = true;
        this.pageTwo = false;
        this.pageThree = false;

        this.isContactSelected = false;
        this.isOpportunitySelected = false;

    }

    goToPageTwo() {
        if (this.verifyContactSearchInputs()) {
            this.invalidParameters = false;
            this.isContactSelected = false;
            this.isOpportunitySelected = false;
        } else {
            this.invalidParameters = true;
            return;
        }
        searchContact({conToSearch: this.contactRecord})
            .then((result) => {
                if (result === null || result.length < 1) {
                    this.noContactResults = true;
                    this.goToPageThree();

                } else {
                    this.multipleConData = result;
                    this.noContactResults = false; 
                    this.pageOne = false;
                    this.pageTwo = true;
                    this.pageThree = false;                   
                }
            })
            .catch((error) => {
                this.error = error;
                this.goToPageThree();
            });        
    }

    goToPageThree() {
        searchCampaign({campaignRecordId: this.content})
            .then((result) => {
                result.Event_Start_Date__c = new Date(result.Event_Start_Date__c + 'UTC-08:00').toLocaleDateString('en-US');
                this.campaignRecord = result;
                this.campaignMemberRecord.CampaignId = result.Id;
            })
            .catch((error) => {
                this.error = error;
            });

        this.pageOne = false;
        this.pageTwo = false;
        this.pageThree = true;
    }

    goBackFromPageThree() {
        this.opportunityRecord = {};
        if (this.contactRecord?.Id != null) {
            this.pageOne = false;
            this.pageTwo = true;
            this.pageThree = false;
        } else {
            this.pageOne = true;
            this.pageTwo = false;
            this.pageThree = false;
        }
    }

    handleSave() {
        let valid = this.isValidSubmission();

        if (!valid) {
            this.invalidSubmissionParameters = true;
            return;
        }

        this.invalidSubmissionParameters = false;

        this.loading = true;
        this.submissionError = null;
        this.submitWalkIn().then((result) => {

            this.loading = false;
            if (this.submissionError == null) {
                this.close('okay');
            }
        });
    }

    submitWalkIn() {

        return submitRecords({
            contactRecordSubmitted: this.contactRecord,
            campaignMemberSubmitted: this.campaignMemberRecord,
            opportunityRecordSubmitted: this.opportunityRecord,
        })
            .then((result) => {
                if (result != null) {
                    this.submissionError = result;
                }
            })
            .catch((error) => {
                this.submissionError = error;
            });
    }

    handleAsuriteChange(e) {
        this.ASURite_ID__c = e.detail.value;
        this.contactRecord.ASURite_ID__c = e.detail.value;
    }

    handleFirstNameChange(e) {
        this.contactRecord.FirstName = e.detail.value;
        this.contactRecord.SF_First_Name__c = e.detail.value;
    }

    handleLastNameChange(e) {
        this.contactRecord.LastName = e.detail.value;
        this.contactRecord.SF_Last_Name__c = e.detail.value;
    }

    handleEmailChange(e) {
        this.contactRecord.Email = e.detail.value;
        this.contactRecord.Lead_Email__c = e.detail.value;
    }

    handlePhoneChange(e) {
        this.contactRecord.Phone = e.detail.value;
    }

    handleZipCodeChange(e) {
        this.contactRecord.MailingPostalCode = e.detail.value;
    }

    handleDateOfBirthChange(e) {
        this.contactRecord.Birthdate = e.detail.value;
        this.contactRecord.SF_Birthdate__c = e.detail.value;
    }

    handleBadgeNameChange(e) {
        this.campaignMemberRecord.Badge_Name__c = e.detail.value;
    }

    handleMailingStateChange(e) {
        this.contactRecord.MailingState = e.detail.value;
    }

    handleCareerChange(e) {
        this.opportunityRecord.Career__c = e.detail.value;
        if (this.opportunityRecord.Career__c == 'Undergraduate') {
            this.isUndergrad = true;
        } else {
            this.isUndergrad = false;
        }
    }

    handleTypeChange(e) {
        this.opportunityRecord.Type = e.detail.value;
    }

    handleTermChange(e) {
        this.opportunityRecord.Term__c = e.detail.recordId;
    }

    handleCountryChange(e) {
        this.contactRecord.Country_of_Citizenship__c = e.detail.recordId;
    }

    handleNumOfGuestsChange(e) {
        this.campaignMemberRecord.Number_of_Guests__c = e.detail.value;
    }

    handleNumOfAttendeesChange(e) {
        this.campaignMemberRecord.Number_of_Attendees__c = e.detail.value;
    }

    handleAcaSessionChange(e) {
        this.campaignMemberRecord.Academic_Session__c = e.detail.value[0];
    }

    handleCommentsChange(e) {
        this.campaignMemberRecord.Comments__c = e.detail.value;
    }

    handleBarrettChange(e) {
        this.campaignMemberRecord.Barrett_Session__c = e.detail.checked;
    }

    handleIntStudentChange(e) {
        this.opportunityRecord.International_Student__c = e.detail.checked;
    }

    handleHousingTourChange(e) {
        this.campaignMemberRecord.Housing_Tour__c = e.detail.checked;
    }

    handleAddTourInfoChange(e) {
        this.campaignMemberRecord.Additional_Tour_Information__c = e.detail.value;
    }

    handleMailingAddressChange(e) {
        this.contactRecord.MailingCity = e.detail.city;
        this.contactRecord.MailingCountryCode = e.detail.country;
        this.contactRecord.MailingPostalCode = e.detail.postalCode;
        this.contactRecord.MailingStateCode = e.detail.province;
        this.contactRecord.MailingStreet = e.detail.street;

        this.contactRecord.SF_Mailing_City__c = e.detail.city;
        this.contactRecord.SF_Mailing_Country__c = e.detail.country;
        this.contactRecord.SF_Mailing_ZIP__c = e.detail.postalCode;
        this.contactRecord.SF_Mailing_State__c = e.detail.province;
        this.contactRecord.SF_Mailing_Street__c = e.detail.street;
    }

    handleRowSelection(event) {
        this.selectedOpp = event.detail.selectedRows[0];
        this.opportunityRecord = event.detail.selectedRows[0];
        this.isOpportunitySelected = true;
        if (this.opportunityRecord.Career__c != 'Undergraduate') {
            this.isUndergrad = false;
        } else {
            this.isUndergrad = true;
        }
    }

    handleContactRowSelection(event) {
        this.contactRecord = event.detail.selectedRows[0];
        this.contactRecordId = this.contactRecord.Id;
        this.isContactSelected = true;
        getOpportunities({contactId: this.contactRecord.Id})
            .then((oppResult) => {
                if (oppResult === null || oppResult.length < 1) {
                    this.noOpportunityResults = true;
                    this.goToPageThree();
                } else {
                    this.noOpportunityResults = false;
                    this.prepareData(oppResult);
                }
            })
            .catch((error) => {
                this.error = error;
            });
        this.multipleConData = null;
    }

    prepareData(oppData) {
        let preparedOpportunityList = [];
        oppData.forEach((oppInfo) => {
            let preparedOpportunity = {};
            preparedOpportunity.Name = oppInfo.Name;
            preparedOpportunity.Career__c = oppInfo.Career__c;
            preparedOpportunity.Type = oppInfo.Type;
            preparedOpportunity.International_Student__c = oppInfo.International_Student__c;
            preparedOpportunity.StageName = oppInfo.StageName;
            preparedOpportunity.Term__r_Name = oppInfo.Term__r.Name;
            preparedOpportunity.Term__c = oppInfo.Term__r.Id;
            if (oppInfo.College__r == null) {
                preparedOpportunity.College__r_Name = '--';
                preparedOpportunity.College__c = null;
            } else {
                preparedOpportunity.College__r_Name = oppInfo.College__r.Name;
                preparedOpportunity.College__c = oppInfo.College__r.Id;
            }
            preparedOpportunity.Plan__c = oppInfo.Plan__c;
            preparedOpportunity.Id = oppInfo.Id;
            preparedOpportunityList.push(preparedOpportunity);
        });

        this.oppData = preparedOpportunityList;
    }

    refreshTable() {
        this.template.querySelector('lightning-datatable').selectedRows = [];
        this.selectedOpp = {};
        this.opportunityRecord = {};
    }

    verifyContactSearchInputs() {
        
        if (this.contactRecord.ASURite_ID__c) {
            return true;
        }

        if (this.contactRecord.FirstName  && this.contactRecord.LastName) {
            return true;
        }

        return false;
    }

    isValidSubmission() {
        var valid = true;
        this.missingFields = [];

        if (this.contactRecord.FirstName == null) {
            valid = false;
            this.missingFields.push('First Name');
        }
        if (this.contactRecord.LastName == null) {
            valid = false;
            this.missingFields.push('Last Name');
        }
        if (this.contactRecord.Email == null) {
            valid = false;
            this.missingFields.push('Email');
        }

        if (this.opportunityRecord.Career__c == null) {
            valid = false;
            this.missingFields.push('Career');
        }
        if (this.opportunityRecord.Term__c == null) {
            valid = false;
            this.missingFields.push('Opportunity Term');
        }
        if (this.opportunityRecord.Type == null) {
            valid = false;
            this.missingFields.push('Opportunity Type');
        }
        if (this.contactRecord.MailingPostalCode == null) {
            valid = false;
            this.missingFields.push('Mailing Postal Code');
        }
        if (this.contactRecord.MailingCountryCode == null && this.contactRecord.MailingCountry == null) {
            valid = false;
            this.missingFields.push('Mailing Country');
        }
        if (
            this.contactRecord.MailingPostalCode == null &&
            this.contactRecord.Birthdate == null &&
            this.contactRecord.Phone == null
        ) {
            valid = false;
            this.missingFields.push('One of the following: Mailing Zip, Date of Birth, OR Phone');
        }
        if (this.campaignMemberRecord.Number_of_Guests__c == null) {
            valid = false;
            this.missingFields.push('Number of Guests');
        }

        return valid;
    }
}