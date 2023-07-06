/*
Author: Vignesh Iyer
Last Updated: 07/05/2023
*/
import {LightningElement, api, wire} from 'lwc';
import {CloseActionScreenEvent} from 'lightning/actions';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import getClassifications from '@salesforce/apex/CaseClassificationLWCService.getClassifications';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

// Case fields to obtain
const FIELDS = [
    'Case.ContactId',
    'Case.Subject',
    'Case.Description',
    'Case.CC_Category__c',
    'Case.CC_Sub_Category__c',
    'Case.CC_Functional_Group__c',
    'Case.Needs_Attention__c',
    'Case.Escalated_From__c',
    'Case.Processing_Status__c',
    'Case.Opportunity__c',
    'Case.Case_Source__c',
    'Case.Initial_Request_Sent_To_Addresses__c',
];

export default class LightningCloneCaseModal extends NavigationMixin(LightningElement) {
    @api recordId;
    
    visibleFields = [];
    categoryOptions = [];
    subCategoryOptions = [];
    isLoading = true;
    rawClassificationData;
    error;
    categoryFieldDisabled = true;
    subCategoryFieldDisabled = true;

    /* Cloned data */

    selectedCase = {}
    selectedCategory;
    selectedSubCategory;
    selectedFunctionalGroup;

    // retrieving field level permission for current user
    @wire(getObjectInfo, { objectApiName: 'Case' })
    objectInfo({ error, data }) {
        if(data) {
            FIELDS.forEach(field => {
                let fieldApiName = field.split('.')[1];
                
                // checking field visibility
                if (this.checkFieldVisibility(data, fieldApiName)) {
                    this.selectedCase[`${fieldApiName}_Visibility`] = true;
                    this.selectedCase[`${fieldApiName}_isDisabled`] = !data.fields[fieldApiName].updateable;
                    this.visibleFields.push(field)
                } else {
                    this.selectedCase[`${fieldApiName}_Visibility`] = false;
                    console.log(field, ' not visible!');
                }
            });
        } else if (error) {
            this.error = error;
            const event = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(event);

            this.loading = false;
        }
    }

    // retrieve opened case data
    @wire(getRecord, {recordId: '$recordId', fields: '$visibleFields'})
    caseHandler({error, data}) {
        if (data) {
            this.case = data;
            this.error = undefined;

            this.setCloneData();

            this.loadClassifications();
        } else if (error) {
            this.error = error;
            this.case = undefined;
            const event = new ShowToastEvent({
                title: 'Error',
                
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.loading = false;
        }
    }
    
    /* Getters & Setters */

    setCloneData() {
        this.selectedCase.Subject = 'Cloned: ' + getFieldValue(this.case, 'Case.Subject');
        this.selectedCase.Contact = getFieldValue(this.case, 'Case.ContactId');
        this.selectedCategory = getFieldValue(this.case, 'Case.CC_Category__c');
        this.selectedSubCategory = getFieldValue(this.case, 'Case.CC_Sub_Category__c');
        this.selectedCase.Description = getFieldValue(this.case, 'Case.Description');
        this.selectedFunctionalGroup = getFieldValue(this.case, 'Case.CC_Functional_Group__c');
        this.selectedCase.Needs_Attention_Status = getFieldValue(this.case, 'Case.Needs_Attention__c');
        this.selectedCase.Escalation_Source = getFieldValue(this.case, 'Case.Escalated_From__c');
        this.selectedCase.Processing_Status = getFieldValue(this.case, 'Case.Processing_Status__c');
        this.selectedCase.Opportunity = getFieldValue(this.case, 'Case.Opportunity__c');
        this.selectedCase.Case_Source = getFieldValue(this.case, 'Case.Case_Source__c');
        this.selectedCase.Initial_Address_Source = getFieldValue(this.case, 'Case.Initial_Request_Sent_To_Addresses__c');
        this.selectedCase.Origin = 'Clone';
        this.selectedCase.Status = 'New';
    }

    get debug() {
        console.log('loader status: ', this.isLoading);
        console.log('record id: ', this.recordId);
        console.log('case: ', this.case);

        return 'test: v1';
    }

    get getSubject() {
        return !this.selectedCase.Subject_isDisabled ? this.selectedCase.Subject : '';
    }

    get getOrigin() {
        return !this.selectedCase.Origin_isDisabled ? this.selectedCase.Origin : '';
    }

    get getStatus() {
        return !this.selectedCase.Status_isDisabled ? this.selectedCase.Status : '';
    }

    get getContact() {
        return !this.selectedCase.ContactId_isDisabled ? this.selectedCase.Contact : '';
    }

    get getFunctionalGroup() {
        return this.selectedFunctionalGroup;
    }

    get getCategory() {
        return this.selectedCategory;
    }

    get getSubCategory() {
        return this.selectedSubCategory;
    }

    get getDescription() {
        return !this.selectedCase.Description_isDisabled ? this.selectedCase.Description : '';
    }

    get getNeedsAttentionStatus() {
        return !this.selectedCase.Needs_Attention__c_isDisabled ? this.selectedCase.Needs_Attention_Status : '';
    }

    get getEscalationSource() {
        return !this.selectedCase.Escalated_From__c_isDisabled ? this.selectedCase.Escalation_Source : '';
    }

    get getProcessingStatus() {
        return !this.selectedCase.Processing_Status__c_isDisabled ? this.selectedCase.Processing_Status : '';
    }

    get getOpportunity() {
        return !this.selectedCase.Opportunity__c_isDisabled ? this.selectedCase.Opportunity : '';
    }

    get getCaseSource() {
        return !this.selectedCase.Case_Source__c_isDisabled ? this.selectedCase.Case_Source : '';
    }

    get getInitialRequestAddress() {
        return !this.selectedCase.Initial_Request_Sent_To_Addresses__c_isDisabled ? this.selectedCase.Initial_Address_Source : '';
    }

    get isCategoryDisabled() {
        return this.categoryFieldDisabled;
    }

    set categoryDisabled(status) {
        this.categoryFieldDisabled = status;
    }

    get isSubCategoryDisabled() {
        return this.subCategoryFieldDisabled;
    }

    set subCategoryDisabled(status) {
        this.subCategoryFieldDisabled = status;
    }

    get loading() {
        return this.isLoading;
    }

    set loading(status) {
        this.isLoading = status;
    }

    // clear category fields
    clearSubCategory() {
        this.selectedSubCategory = '';
        this.subCategoryDisabled = true;
    }

    // Function to check the visibility of the fields
    checkFieldVisibility(data, fieldName) {
        if (data.fields[fieldName] != undefined) {
            return true;
        } 
        return false;
    }

    // get classification data
    loadClassifications() {
        getClassifications()
            .then((result) => {
                this.rawClassificationData = result;
                this.renderDropdowns();
                this.loading = false;
            })
            .catch((error) => {
                this.rawClassificationData = undefined;
                this.error = error;
                this.loading = false;
            });
    }

    // render dropdown options
    renderDropdowns() {
        this.renderCategories();
        this.renderSubCategories();
    }

    renderCategories() {
        if (this.selectedFunctionalGroup) {
            if (this.rawClassificationData) {
                // set options
                this.categoryOptions = this.rawClassificationData
                    // filter options by selected fuctional group
                    .filter((f) => f.Parent__c === this.selectedFunctionalGroup)
                    .map((element) => {
                        return {
                            label: element.Name,
                            value: element.Id,
                        };
                    });
                // enable this dropdown
                this.categoryDisabled = false;

                // Add empty option to remove category
                this.categoryOptions.unshift({label: '--', value: ''});
            }
        }
    }

    renderSubCategories() {
        // Show appropriate subcategories based on selected category option
        if (this.selectedCategory) {
            if (this.rawClassificationData) {
                // set options
                this.subCategoryOptions = this.rawClassificationData
                    // filter options by selected category
                    .filter((f) => f.Parent__c === this.selectedCategory)
                    .map((element) => {
                        return {
                            label: element.Name,
                            value: element.Id,
                        };
                    });
                // enable this dropdown
                this.subCategoryDisabled = false;

                // Add empty option to remove sub-category
                this.subCategoryOptions.unshift({label: '--', value: ''});
            }
        }
    }

    // close
    closeModal() {
        this.isLoading = true;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    // submit
    submitForm() {
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    handleLoad() {
        this.isLoading = false;
    }

    // onchange event for category options
    handleCategoryChange(event) {
        // Reset the sub-category selection
        this.clearSubCategory();

        // Set category
        const selectedCategory = event.target.value;
        this.selectedCategory = selectedCategory;
        this.renderSubCategories();
    }

    // handle dependent field
    handleSubCategoryChange(event) {
        const selectedSubCategory = event.target.value;
        this.selectedSubCategory = selectedSubCategory;
    }

    // on successful case creation
    handleSuccess(event) {
        var newRecordId = event.detail.id;
        const evt = new ShowToastEvent({
            title: 'Case Cloned',
            message: 'Record ID: ' + newRecordId,
            variant: 'success',
        });

        this.dispatchEvent(evt);

        // redirect to newly created case record
        this.redirectToClonedCase(newRecordId);

        this.closeModal();
    }

    redirectToClonedCase(recordId) {
        // open newly created record on new page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Case',
                actionName: 'view',
            },
        });
    }
}
