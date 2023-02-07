// Imports
import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getClassifications from '@salesforce/apex/CaseClassificationLWCService.getClassifications';

// Case fields
import FUNCTIONAL_GROUP_ID_FIELD from '@salesforce/schema/Case.CC_Functional_Group__c';
import CATEGORY_ID_FIELD from '@salesforce/schema/Case.CC_Category__c';
import SUB_CATEGORY_ID_FIELD from '@salesforce/schema/Case.CC_Sub_Category__c';

const fields = [FUNCTIONAL_GROUP_ID_FIELD, CATEGORY_ID_FIELD, SUB_CATEGORY_ID_FIELD];

export default class CaseClassification extends LightningElement {
    @api recordId;
    @api lwcComponentIconName = 'standard:decision';
    @api lwcComponentName = 'Case Classification';
    @api lwcRecordSubmitButtonLabel = 'Update';
    @api lwcRecordSubmitButtonVariant = 'brand';
    @api lwcToastSuccessTitle = 'Success!';
    @api lwcToastSuccessMessage = 'Case classification has been updated.';

    isEditFormVisible = false;
    isLoading = true;
    isLaunchButtonVisible = true;
    errorDetail = '';
    record;
    rawClassificationData;
    validationError;

    // Holds selectable options
    categoryOptions = [];
    subCategoryOptions = [];

    // Current state
    selectedFunctionalGroupValue = '';
    selectedCategoryValue = '';
    selectedSubCategoryValue = '';
    categoryFieldDisabled = true;
    subCategoryFieldDisabled = true;

    // Launch Button (this.lwcEditButtonLabel)
    get launchButtonVisible() {
        return this.isLaunchButtonVisible;
    }
    set launchButtonVisible(isVisible) {
        this.isLaunchButtonVisible = isVisible;
    }

    // Component Name (this.componentName)
    get componentName() {
        return this.lwcComponentName;
    }

    // Component Icon Name (this.componentIconName)
    get componentIconName() {
        return this.lwcComponentIconName;
    }

    // Loading Indicator
    get loading() {
        return this.isLoading;
    }
    set loading(status) {
        this.isLoading = status;
    }

    // Edit Form Visible
    get editFormVisible() {
        return this.isEditFormVisible;
    }
    set editFormVisible(isVisible) {
        this.isEditFormVisible = isVisible;
    }

    // Category field disabled attribute
    get categoryDisabled() {
        return this.categoryFieldDisabled;
    }
    set categoryDisabled(status) {
        this.categoryFieldDisabled = status;
    }

    // Sub-Category field disabled attribute
    get subCategoryDisabled() {
        return this.subCategoryFieldDisabled;
    }
    set subCategoryDisabled(status) {
        this.subCategoryFieldDisabled = status;
    }

    // The selected functional group
    get selectedFunctionalGroup() {
        return this.selectedFunctionalGroupValue;
    }
    set selectedFunctionalGroup(fg) {
        this.selectedFunctionalGroupValue = fg;
    }

    // The selected category
    get selectedCategory() {
        return this.selectedCategoryValue;
    }
    set selectedCategory(cat) {
        this.selectedCategoryValue = cat;
    }

    // The selected sub-category
    get selectedSubCategory() {
        return this.selectedSubCategoryValue;
    }
    set selectedSubCategory(sub) {
        this.selectedSubCategoryValue = sub;
    }

    // Error Message
    get errorMessage() {
        return this.errorDetail;
    }
    set errorMessage(detail) {
        this.errorDetail = this.reduceErrors(detail);
    }

    // Validation Error Override
    get hasValidationError() {
        return this.validationError ? true : false;
    }
    set hasValidationError(error) {
        this.validationError = error;
    }

    /**
     * Wire method for getting the case details
     * @param {*} recordId
     */
    @wire(getRecord, {recordId: '$recordId', fields}) wiredCase({error, data}) {
        if (error) {
            this.record = undefined;
            this.errorMessage = error;
            this.loading = false;
        }
        if (data) {
            // Case data
            this.record = JSON.parse(JSON.stringify(data)); // deep clone

            // Set the current fields
            this.selectedFunctionalGroup = getFieldValue(this.record, FUNCTIONAL_GROUP_ID_FIELD);
            this.selectedCategory = getFieldValue(this.record, CATEGORY_ID_FIELD);
            this.selectedSubCategory = getFieldValue(this.record, SUB_CATEGORY_ID_FIELD);

            // Load Classifications
            this.loadClassifications();
        }
    }

    /**
     * Imperatively load case classifications
     */
    loadClassifications() {
        // Get all classifications
        getClassifications()
            .then((result) => {
                this.rawClassificationData = result;
                this.renderDropdowns();
                this.loading = false;
            })
            .catch((error) => {
                this.rawClassificationData = undefined;
                this.errorMessage = error;
                this.loading = false;
            });
    }

    /**
     * Render the initial dropdowns
     */
    renderDropdowns() {
        this.renderCategories();
        this.renderSubCategories();
    }

    /**
     * Render the category dropdown options
     */
    renderCategories() {
        // If we have a functional group selected, show us appropriate category options
        if (this.selectedFunctionalGroup) {
            // Set options
            this.categoryOptions = this.rawClassificationData
                // Filter options by selected functional group
                .filter((f) => f.Parent__c === this.selectedFunctionalGroup)
                .map((element) => {
                    return {
                        label: element.Name,
                        value: element.Id,
                    };
                });
            // Enable the combo box
            this.categoryDisabled = false;
            // Add empty option to remove category
            this.categoryOptions.unshift({label: '--', value: ''});
        }
    }

    /**
     * Render the Sub Category dropdown options
     */
    renderSubCategories() {
        // If we have a category selected, show us appropriate sub-category options
        if (this.selectedCategory) {
            // Set options
            this.subCategoryOptions = this.rawClassificationData
                // Filter options by selected category
                .filter((f) => f.Parent__c === this.selectedCategory)
                .map((element) => {
                    return {
                        label: element.Name,
                        value: element.Id,
                    };
                });
            // Enable the combo box
            this.subCategoryDisabled = false;
            // Add empty option to remove sub-category
            this.subCategoryOptions.unshift({label: '--', value: ''});
        }
    }

    /**
     * Clear the selected category and disable the input
     */
    clearCategory() {
        this.selectedCategory = '';
        this.categoryDisabled = true;
    }

    /**
     * Clear the selected sub-category and disable the input
     */
    clearSubCategory() {
        this.selectedSubCategory = '';
        this.subCategoryDisabled = true;
    }

    /**
     * Handle change of the category
     * @param {*} event
     */
    handleCategoryChange(event) {
        // Reset the sub-category selection
        this.clearSubCategory();

        // Set category
        const selectedCategory = event.target.value;
        this.selectedCategory = selectedCategory;
        this.renderSubCategories();
    }

    /**
     * Handle change of the sub category
     * @param {*} event
     */
    handleSubCategoryChange(event) {
        const selectedSubCategory = event.target.value;
        this.selectedSubCategory = selectedSubCategory;
    }

    /**
     * Show record edit form
     * @param {*} event
     */
    handleOnEditButtonClick() {
        this.loading = true;
        this.launchButtonVisible = false;
        this.editFormVisible = true;
    }

    /**
     * Record edit form (onsubmit)
     */
    handleOnEditFormSubmit() {
        // Set fields for update
        const fields = {
            CC_Category__c: this.selectedCategory,
            CC_Sub_Category__c: this.selectedSubCategory,
        };

        // Debug
        console.log(`Selected Values:`, fields);

        // Make sure our fields are validated
        if (!this.validateFields()) {
            return;
        }

        // Set loading indicator
        this.loading = true;

        // Custom validation here if needed

        // Submit record edit form
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    /**
     * Record edit form (onsuccess)
     * @param {*} event
     */
    handleOnEditFormSuccess(event) {
        const evt = new ShowToastEvent({
            title: this.lwcToastSuccessTitle,
            message: this.lwcToastSuccessMessage,
            variant: 'success',
        });
        this.dispatchEvent(evt);
        this.handleOnEditFormReset();
    }

    /**
     * Record edit form (onload)
     */
    handleOnEditFormLoad() {
        this.loading = false;
    }

    /**
     * Record edit form (onerror)
     * @param {*} event
     */
    handleOnEditFormError(event) {
        this.loading = false;
        this.hasValidationError = event.detail;
    }

    /**
     * Reset the form
     */
    handleOnEditFormReset() {
        this.loading = false;
        this.editFormVisible = false;
        this.launchButtonVisible = true;
        this.errorMessage = '';
        this.hasValidationError = null;
    }

    /**
     * Reduces one or more LDS errors into a string[] of error messages.
     * @param {*} errors
     * @returns
     */
    reduceErrors(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }

        return (
            errors
                // Remove null/undefined items
                .filter((error) => !!error)
                // Extract an error message
                .map((error) => {
                    // UI API read errors
                    if (Array.isArray(error.body)) {
                        return error.body.map((e) => e.message);
                    }
                    // UI API DML, Apex and network errors
                    else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    }
                    // JS errors
                    else if (typeof error.message === 'string') {
                        return error.message;
                    }
                    // Unknown error shape so try HTTP status text
                    return error.statusText;
                })
                // Flatten
                .reduce((prev, curr) => prev.concat(curr), [])
                // Remove empty strings
                .filter((message) => !!message)
        );
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
