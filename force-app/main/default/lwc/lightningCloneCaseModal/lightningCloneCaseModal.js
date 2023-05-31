import {LightningElement, api, wire} from 'lwc';
import {CloseActionScreenEvent} from 'lightning/actions';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import getClassifications from '@salesforce/apex/CaseClassificationLWCService.getClassifications';

const FIELDS = [
    'Case.ContactId',
    'Case.Subject',
    'Case.Description',
    'Case.CC_Category__c',
    'Case.CC_Sub_Category__c',
    'Case.Case_Owner__c',
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

    categoryOptions = [];
    subCategoryOptions = [];
    isLoading = true;
    rawClassificationData;
    error;
    categoryFieldDisabled = true;
    subCategoryFieldDisabled = true;

    /* Cloned data */

    selectedContact;
    selectedCategory = '';
    selectedSubCategory = '';
    selectedOwner = '';
    selectedFunctionalGroup = '';
    selectedOrigin = 'Clone';
    selectedStatus = 'New';
    selectedSubject = '';
    selectedDescription = '';
    selectedNeedsAttentionStatus = '';
    selectedEscalationSource = '';
    selectedProcessingStatus = '';
    selectedOpportunity = '';
    selectedCaseSource = '';
    selectedInitialRequestAddress = '';

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
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

    setCloneData() {
        this.selectedSubject = 'Cloned: ' + getFieldValue(this.case, 'Case.Subject');
        this.selectedContact = getFieldValue(this.case, 'Case.ContactId');
        this.selectedCategory = getFieldValue(this.case, 'Case.CC_Category__c');
        this.selectedSubCategory = getFieldValue(this.case, 'Case.CC_Sub_Category__c');
        this.selectedOwner = getFieldValue(this.case, 'Case.Case_Owner__c');
        this.selectedDescription = getFieldValue(this.case, 'Case.Description');
        this.selectedFunctionalGroup = getFieldValue(this.case, 'Case.CC_Functional_Group__c');
        this.selectedNeedsAttentionStatus = getFieldValue(this.case, 'Case.Needs_Attention__c');
        this.selectedEscalationSource = getFieldValue(this.case, 'Case.Escalated_From__c');
        this.selectedProcessingStatus = getFieldValue(this.case, 'Case.Processing_Status__c');
        this.selectedOpportunity = getFieldValue(this.case, 'Case.Opportunity__c');
        this.selectedCaseSource = getFieldValue(this.case, 'Case.Case_Source__c');
        this.selectedInitialRequestAddress = getFieldValue(this.case, 'Case.Initial_Request_Sent_To_Addresses__c');
    }

    get debug() {
        console.log('loader status: ', this.isLoading);
        console.log('record id: ', this.recordId);
        console.log('case: ', this.case);

        return 'test: v3';
    }

    closeModal() {
        this.isLoading = true;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    get getSubject() {
        return this.selectedSubject;
    }

    get getOrigin() {
        return this.selectedOrigin;
    }

    get getStatus() {
        return this.selectedStatus;
    }

    get getContact() {
        return this.selectedContact;
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

    get getOwner() {
        return this.selectedOwner;
    }

    get getDescription() {
        return this.selectedDescription;
    }

    get getNeedsAttentionStatus() {
        return this.selectedNeedsAttentionStatus;
    }

    get getEscalationSource() {
        return this.selectedEscalationSource;
    }

    get getProcessingStatus() {
        return this.selectedProcessingStatus;
    }

    get getOpportunity() {
        return this.selectedOpportunity;
    }

    get getCaseSource() {
        return this.selectedCaseSource;
    }

    get getInitialRequestAddress() {
        return this.selectedInitialRequestAddress;
    }

    get categoryDisabled() {
        return this.categoryFieldDisabled;
    }

    set categoryDisabled(status) {
        this.categoryFieldDisabled = status;
    }

    get subCategoryDisabled() {
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

    clearSubCategory() {
        this.selectedSubCategory = '';
        this.subCategoryDisabled = true;
    }

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

    handleLoad() {
        this.isLoading = false;
    }

    handleCategoryChange(event) {
        // Reset the sub-category selection
        this.clearSubCategory();

        // Set category
        const selectedCategory = event.target.value;
        this.selectedCategory = selectedCategory;
        this.renderSubCategories();
    }

    handleSubCategoryChange(event) {
        const selectedSubCategory = event.target.value;
        this.selectedSubCategory = selectedSubCategory;
    }

    handleSuccess(event) {
        var newRecordId = event.detail.id;
        const evt = new ShowToastEvent({
            title: 'Case Cloned',
            message: 'Record ID: ' + newRecordId,
            variant: 'success',
        });

        this.dispatchEvent(evt);

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
