/* eslint-disable no-useless-return */
/* eslint-disable no-console */
/* eslint-disable no-unused-expressions */
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
    'Case.CC_Functional_Group__c',
];

export default class LightningCloneCaseModal extends NavigationMixin(LightningElement) {
    @api recordId;

    /* set this variable to false, to avoid debug statements */
    DEBUG_LEVEL = false;

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
    selectedFunctionalGroup = '';
    selectedOrigin = 'Clone';
    selectedStatus = 'New';
    selectedSubject = '';
    selectedDescription = '';

    // credits: https://salesforce.stackexchange.com/questions/304495/controlling-the-height-of-a-lightning-combobox-dropdown
    constructor() {
        super();

        // reducing the default height for picklist dropdowns
        const style = document.createElement('style');
        // below you specify the CSS selector to be changed in the combobox
        style.innerText = `.slds-listbox.slds-listbox_vertical.slds-dropdown.slds-dropdown_fluid.slds-dropdown_left {
            height: 220px !important;
        }`;
        document.querySelector('head').appendChild(style);
    }

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    caseHandler({error, data}) {
        if (data) {
            this.case = data;
            this.error = undefined;

            this.setCloneData();

            this.loadClassifications();

            if (this.DEBUG_LEVEL) {
                console.log('case: ', this.case);
                console.log('raw classification data: ', this.rawClassificationData);
            }
        } else if (error) {
            this.error = error;
            this.case = undefined;
            console.log(this.error);
            this.loading = false;
        }
    }

    setCloneData() {
        this.selectedSubject = 'Cloned: ' + getFieldValue(this.case, 'Case.Subject');
        this.selectedContact = getFieldValue(this.case, 'Case.ContactId');
        this.selectedCategory = getFieldValue(this.case, 'Case.CC_Category__c');
        this.selectedSubCategory = getFieldValue(this.case, 'Case.CC_Sub_Category__c');
        this.selectedDescription = getFieldValue(this.case, 'Case.Description');
        this.selectedFunctionalGroup = getFieldValue(this.case, 'Case.CC_Functional_Group__c');
    }

    get debug() {
        if (this.DEBUG_LEVEL) {
            console.log('loader status: ', this.isLoading);
            console.log('record id: ', this.recordId);
            console.log('case: ', this.case);
        }

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

    get getCategory() {
        return this.selectedCategory;
    }

    get getSubCategory() {
        return this.selectedSubCategory;
    }

    get getDescription() {
        return this.selectedDescription;
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
        if (this.DEBUG_LEVEL) {
            console.log('-- Printing category and sub category options from renderDropdowns() --');
            console.log('category options: ', this.categoryOptions);
            console.log('sub category options', this.subCategoryOptions);
        }
    }

    renderCategories() {
        if (this.selectedFunctionalGroup) {
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

    renderSubCategories() {
        // Show appropriate subcategories based on selected category option
        if (this.selectedCategory) {
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

    handleLoad() {
        this.isLoading = false;
    }

    handleContactChange(event) {
        const selectedContact = event.target.value;
        this.selectedContact = selectedContact;
        if (this.DEBUG_LEVEL) console.log('Updated contact: ', this.selectedContact);
    }

    handleOriginChange(event) {
        const selectedOrigin = event.target.value;
        this.selectedOrigin = selectedOrigin;
        if (this.DEBUG_LEVEL) console.log('Updated origin: ', this.selectedOrigin);
    }

    handleStatusChange(event) {
        const selectedStatus = event.target.value;
        this.selectedStatus = selectedStatus;
        if (this.DEBUG_LEVEL) console.log('Updated status: ', this.selectedStatus);
    }

    handleSubjectChange(event) {
        const selectedSubject = event.target.value;
        this.selectedSubject = selectedSubject;
        if (this.DEBUG_LEVEL) console.log('Updated subject: ', this.selectedSubject);
    }

    handleDescriptionChange(event) {
        const selectedDescription = event.target.value;
        this.selectedDescription = selectedDescription;
        if (this.DEBUG_LEVEL) console.log('Updated description: ', this.selectedDescription);
    }

    handleCategoryChange(event) {
        // Reset the sub-category selection
        this.clearSubCategory();

        // Set category
        const selectedCategory = event.target.value;
        this.selectedCategory = selectedCategory;
        if (this.DEBUG_LEVEL) console.log('Updated category: ', this.selectedCategory);
        this.renderSubCategories();
    }

    handleSubCategoryChange(event) {
        const selectedSubCategory = event.target.value;
        this.selectedSubCategory = selectedSubCategory;
        if (this.DEBUG_LEVEL) console.log('Updated sub category: ', this.selectedSubCategory);
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

    handleSubmit() {
        const fields = {
            ContactId: this.selectedContact,
            CC_Category__c: this.selectedCategory,
            CC_Sub_Category__c: this.selectedSubCategory,
            Origin__c: this.selectedOrigin,
            Status: this.selectedStatus,
            Subject: this.selectedSubject,
            Description: this.selectedDescription,
            CC_Functional_Group__c: this.selectedFunctionalGroup,
        };

        if (this.DEBUG_LEVEL) console.log(`Printing cloned case fields before submitting :`, fields);

        // Make sure our fields are validated
        if (!this.validateFields()) {
            return;
        }

        this.loading = true;

        this.template.querySelector('lightning-record-edit-form').submit(fields);
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

    /**
     * Validate input fields
     */
    validateFields() {
        return [...this.template.querySelectorAll('lightning-combobox')].reduce((validSoFar, field) => {
            // Return whether all fields up to this point are valid and whether current field is valid
            // reportValidity returns validity and also displays/clear message on element based on validity
            return validSoFar && field.reportValidity();
        }, true);
    }
}
