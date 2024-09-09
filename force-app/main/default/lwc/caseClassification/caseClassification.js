// Imports
import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {gql, graphql} from 'lightning/uiGraphQLApi';
import {extractErrorMessages} from 'c/helperFunctions';

// Case fields
import FUNCTIONAL_GROUP_ID_FIELD from '@salesforce/schema/Case.CC_Functional_Group__c';
import CATEGORY_ID_FIELD from '@salesforce/schema/Case.CC_Category__c';
import SUB_CATEGORY_ID_FIELD from '@salesforce/schema/Case.CC_Sub_Category__c';

const CASE_FIELDS = [FUNCTIONAL_GROUP_ID_FIELD, CATEGORY_ID_FIELD, SUB_CATEGORY_ID_FIELD];

export default class CaseClassification extends LightningElement {
    @api recordId;
    @api lwcComponentIconName = 'standard:decision';
    @api lwcComponentName = 'Case Classification';
    @api lwcRecordSubmitButtonLabel = 'Update';
    @api lwcRecordSubmitButtonVariant = 'brand';
    @api lwcToastSuccessTitle = 'Success!';
    @api lwcToastSuccessMessage = 'Case classification has been updated.';

    // Errors state
    validationError;

    // Current state
    selectedFunctionalGroup = null;
    selectedCategory = null;
    selectedSubCategory = null;

    // Loading Indicator
    loadingOverride = false;
    get loading() {
        return this.loadingOverride || this.caseRecord == null || this.caseClassificationWrapper == null;
    }
    set loading(v) {
        this.loadingOverride = v;
    }

    // Cannot select category is functional group is not set
    get categoryDisabled() {
        return this.selectedFunctionalGroup == null;
    }

    // Cannot select subcategory is category dropdown is disabled or if category is not set
    get subCategoryDisabled() {
        return this.categoryFieldDisabled || this.selectedCategory == null;
    }

    // Error Message
    get hasError() {
        return this.caseError !== undefined || this.caseClassificationErrorx;
    }
    get errorMessage() {
        if (this.caseError !== undefined) return extractErrorMessages(this.caseError)[0];
        if (this.caseClassificationError !== undefined) return extractErrorMessages(this.caseClassificationError)[0];
        return '';
    }

    // Validation Error Override
    get hasValidationError() {
        return this.validationError ? true : false;
    }
    set hasValidationError(v) {
        this.validationError = v;
    }

    /**
     * Wire method for getting the case details
     * @param {*} recordId
     */
    @wire(getRecord, {recordId: '$recordId', fields: CASE_FIELDS})
    wiredCase({error, data}) {
        if (error) {
            this.caseRecord = undefined;
            this.caseError = error;
        }

        if (data) {
            // Case data
            this.caseRecord = data;
            this.caseError = undefined;

            // Set the current fields
            this.selectedFunctionalGroup = getFieldValue(this.caseRecord, FUNCTIONAL_GROUP_ID_FIELD);
            this.selectedCategory = getFieldValue(this.caseRecord, CATEGORY_ID_FIELD);
            this.selectedSubCategory = getFieldValue(this.caseRecord, SUB_CATEGORY_ID_FIELD);
        }
    }
    caseRecord = undefined;
    caseError = undefined;

    /**
     * Get the service indicators for this student
     */
    @wire(graphql, {
        query: gql`
            query CaseClassifications($funcGrpId: ID!, $selectedIds: [ID]!) {
                uiapi {
                    query {
                        Case_Classification__c(
                            first: 2000
                            where: {
                                and: [
                                    {or: [{Parent__c: {eq: $funcGrpId}}, {Parent__r: {Parent__c: {eq: $funcGrpId}}}]}
                                    {
                                        or: [
                                            {Id: {in: $selectedIds}}
                                            {and: [{Active__c: {eq: true}}, {Visible__c: {eq: true}}]}
                                        ]
                                    }
                                ]
                            }
                        ) {
                            edges {
                                node {
                                    Id
                                    Name {
                                        value
                                    }
                                    Parent__c {
                                        value
                                    }
                                }
                            }
                        }
                    }
                }
            }
        `,
        variables: '$gqlVariables',
        operationName: 'CaseClassifications',
    })
    gotCaseClassifications({errors, data}) {
        if (errors !== undefined) {
            this.caseClassificationError = errors;
            this.caseClassificationWrapper = undefined;
        }

        // We only care about this after the caseRecord has loaded successfully
        if (this.caseRecord != null && data !== undefined) {
            this.caseClassificationWrapper = data;
            this.caseClassificationError = undefined;
        }
    }
    get gqlVariables() {
        // if caseRecord is not ready return undefined to prevent this from running
        return this.caseRecord == null
            ? undefined
            : {
                  funcGrpId: getFieldValue(this.caseRecord, FUNCTIONAL_GROUP_ID_FIELD),
                  selectedIds: [
                      getFieldValue(this.caseRecord, FUNCTIONAL_GROUP_ID_FIELD),
                      getFieldValue(this.caseRecord, CATEGORY_ID_FIELD),
                      getFieldValue(this.caseRecord, SUB_CATEGORY_ID_FIELD),
                  ].filter((v) => v != null),
              };
    }

    caseClassificationWrapper = undefined;
    caseClassificationError = undefined;

    get caseClassifications() {
        return (this.caseClassificationWrapper?.uiapi?.query?.Case_Classification__c?.edges ?? []).map((cc) => {
            return {
                Id: cc?.node?.Id,
                Name: cc?.node?.Name?.value,
                Parent__c: cc?.node?.Parent__c?.value,
            };
        });
    }

    /**
     * Only the children of the functional group
     */
    get categoryOptions() {
        let categoryOptions = this.caseClassifications
            // Filter options by selected functional group
            .filter(
                (v) =>
                    this.selectedFunctionalGroup !== null &&
                    this.selectedFunctionalGroup !== 'NULL' &&
                    v.Parent__c === this.selectedFunctionalGroup
            )
            // sort the sub categories alphabetically
            .map((element) => {
                return {
                    label: element.Name,
                    value: element.Id,
                };
            })
            .sort((a, b) => a.label.localeCompare(b.label));
        // Add empty option to remove category
        categoryOptions.unshift({label: '--', value: 'NULL'});

        return categoryOptions;
    }

    /**
     * Only the options of the selected category
     */
    get subCategoryOptions() {
        let subCategoryOptions = this.caseClassifications
            // Filter options by selected functional group
            .filter(
                (v) =>
                    this.selectedCategory != null &&
                    this.selectedCategory !== 'NULL' &&
                    v.Parent__c === this.selectedCategory
            )
            // sort the sub categories alphabetically
            .map((element) => {
                return {
                    label: element.Name,
                    value: element.Id,
                };
            })
            .sort((a, b) => a.label.localeCompare(b.label));
        // Add empty option to remove category
        subCategoryOptions.unshift({label: '--', value: 'NULL'});

        return subCategoryOptions;
    }

    /**
     * Handle change of the category
     * @param {*} event
     */
    handleCategoryChange(event) {
        // Unset sub category
        this.selectedSubCategory = null;

        // Set category
        const selectedCategory = event.target.value;
        this.selectedCategory = selectedCategory;
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
     * Record edit form (onsubmit)
     */
    handleOnEditFormSubmit() {
        // Set fields for update
        const fields = {
            CC_Category__c: this.selectedCategory === 'NULL' ? null : this.selectedCategory,
            CC_Sub_Category__c: this.selectedSubCategory === 'NULL' ? null : this.selectedSubCategory,
        };

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
        this.hasValidationError = null;
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

export class CaseClassificationTest extends CaseClassification {
    @api get recordId() {
        return super.recordId;
    }
    set recordId(v) {
        super.recordId = v;
    }

    @api get lwcComponentIconName() {
        return super.lwcComponentIconName;
    }
    set lwcComponentIconName(v) {
        super.lwcComponentIconName = v;
    }

    @api get lwcComponentName() {
        return super.lwcComponentName;
    }
    set lwcComponentName(v) {
        super.lwcComponentName = v;
    }

    @api get lwcRecordSubmitButtonLabel() {
        return super.lwcRecordSubmitButtonLabel;
    }
    set lwcRecordSubmitButtonLabel(v) {
        super.lwcRecordSubmitButtonLabel = v;
    }

    @api get lwcRecordSubmitButtonVariant() {
        return super.lwcRecordSubmitButtonVariant;
    }
    set lwcRecordSubmitButtonVariant(v) {
        super.lwcRecordSubmitButtonVariant = v;
    }

    @api get lwcToastSuccessTitle() {
        return super.lwcToastSuccessTitle;
    }
    set lwcToastSuccessTitle(v) {
        super.lwcToastSuccessTitle = v;
    }

    @api get lwcToastSuccessMessage() {
        return super.lwcToastSuccessMessage;
    }
    set lwcToastSuccessMessage(v) {
        super.lwcToastSuccessMessage = v;
    }

    @api get loading() {
        return super.loading;
    }
    set loading(v) {
        super.loading = v;
    }

    @api get selectedFunctionalGroup() {
        return super.selectedFunctionalGroup;
    }
    set selectedFunctionalGroup(v) {
        super.selectedFunctionalGroup = v;
    }

    @api get selectedCategory() {
        return super.selectedCategory;
    }
    set selectedCategory(v) {
        super.selectedCategory = v;
    }

    @api get selectedSubCategory() {
        return super.selectedSubCategory;
    }
    set selectedSubCategory(v) {
        super.selectedSubCategory = v;
    }

    @api get categoryDisabled() {
        return super.categoryDisabled;
    }
    set categoryDisabled(v) {
        super.categoryDisabled = v;
    }

    @api get subCategoryDisabled() {
        return super.subCategoryDisabled;
    }
    set subCategoryDisabled(v) {
        super.subCategoryDisabled = v;
    }

    @api get categoryOptions() {
        return super.categoryOptions;
    }
    set categoryOptions(v) {
        super.categoryOptions = v;
    }

    @api get subCategoryOptions() {
        return super.subCategoryOptions;
    }
    set subCategoryOptions(v) {
        super.subCategoryOptions = v;
    }

    @api get errorMessage() {
        return super.errorMessage;
    }

    @api get hasValidationError() {
        return super.hasValidationError;
    }
    set hasValidationError(v) {
        super.hasValidationError = v;
    }
}
