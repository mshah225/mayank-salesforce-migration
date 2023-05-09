/* eslint-disable compat/compat */
/* eslint-disable @salesforce/aura/ecma-intrinsics */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
/* eslint-disable no-sequences */
/* eslint-disable no-constant-condition */
/* eslint-disable no-undef */
import {createElement} from 'lwc';
import LightningCloneCaseModal from 'c/lightningCloneCaseModal';
import {getRecord} from 'lightning/uiRecordApi';
import getClassifications from '@salesforce/apex/CaseClassificationLWCService.getClassifications';

// Mock data for testing
const CASE_ID = '1234567890qwerty';
const CONTACT_ID = '123abc';
const CATEGORY = 'Category A';
const SUB_CATEGORY = 'Sub Category A';
const ORIGIN = 'Clone';
const STATUS = 'New';
const SUBJECT = 'Cloned: Test case subject';
const DESCRIPTION = 'Test case description';
const FUNCTIONAL_GROUP = 'Group A';

const mockGetRecord = require('./data/getRecordResponse.json');
const mockGetClassifications = require('./data/getClassificationResponse.json');

jest.mock(
    '@salesforce/apex/CaseClassificationLWCService.getClassifications',
    () => {
        return {
            default: jest.fn(),
        };
    },
    {virtual: true}
);

describe('c-lightning-clone-case-modal', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }

        jest.clearAllMocks();
    });

    beforeEach(async () => {
        getClassifications.mockResolvedValue(mockGetClassifications);
    })

    async function flushPromises() {
        return Promise.resolve();
    }

    it('renders the component', () => {
        // Arrange
        const element = createElement('c-lightning-clone-case-modal', {
            is: LightningCloneCaseModal,
        });
        element.recordId = CASE_ID;

        // Act
        document.body.appendChild(element);

        // Assert
        expect(element).not.toBeNull();
        expect(element.shadowRoot).not.toBeNull();
    });

    it('verify parameters passed and buttons', async () => {
        // Arrange
        const element = createElement('c-lightning-clone-case-modal', {
            is: LightningCloneCaseModal,
        });
        element.objectApiName = 'Case';

        // Act
        document.body.appendChild(element);

        getRecord.emit(mockGetRecord);

        await flushPromises();

        // Validate if parameters were passed correctly to the base element
        const formElement = element.shadowRoot.querySelector('lightning-record-edit-form');
        expect(formElement.objectApiName).toBe('Case');

        // Validate buttons
        const buttons = element.shadowRoot.querySelectorAll('lightning-button');
        expect(buttons.length).toBe(2);
        expect(buttons[0].label).toBe('Cancel');
        expect(buttons[1].type).toBe('submit');
        expect(buttons[1].label).toBe('Submit');
    });

    it('verify fields and values', async () => {
        const EXPECTED_FIELDS_NAMES = [
            'ContactId',
            'CC_Functional_Group__c',
            'CC_Category__c',
            'CC_Sub_Category__c',
            'Origin__c',
            'Status',
            'Subject',
            'Description',
        ];
        const EXPECTED_FIELD_VALUES = [
            CONTACT_ID,
            FUNCTIONAL_GROUP,
            CATEGORY,
            SUB_CATEGORY,
            ORIGIN,
            STATUS,
            SUBJECT,
            DESCRIPTION,
        ];

        // Arrange
        const element = createElement('c-lightning-clone-case-modal', {
            is: LightningCloneCaseModal,
        });

        // Act
        document.body.appendChild(element);

        getRecord.emit(mockGetRecord);

        await flushPromises();

        const fields = element.shadowRoot.querySelectorAll('lightning-input-field');
        const outputFieldNames = Array.from(fields).map((field) => field.fieldName);
        const outputFieldValues = Array.from(fields).map((field) => field.value);

        expect(outputFieldNames).toEqual(EXPECTED_FIELDS_NAMES);
        expect(outputFieldValues).toEqual(EXPECTED_FIELD_VALUES);
    });

    it('verify onchange events on category and sub category', async () => {
        const UPDATED_CATEGORY = 'Category X';
        const UPDATED_SUB_CATEGORY = 'Sub Category X';

        // Arrange
        const element = createElement('c-lightning-clone-case-modal', {
            is: LightningCloneCaseModal,
        });

        // Act
        document.body.appendChild(element);

        getRecord.emit(mockGetRecord);

        await flushPromises();

        // Before on change event (Checking default values for category and sub category)
        let fields = element.shadowRoot.querySelectorAll('lightning-input-field');
        fields.forEach((field) => {
            if (field.fieldName === 'CC_Category__c') {
                expect(field.value).toBe(CATEGORY);
            } else if (field.fieldName === 'CC_Sub_Category__c') {
                expect(field.value).toBe(SUB_CATEGORY);
            }
        });

        const comboboxElements = element.shadowRoot.querySelectorAll('lightning-combobox');
        const categoryCombobox = comboboxElements[0];
        const subCategoryCombobox = comboboxElements[1];

        categoryCombobox.value = UPDATED_CATEGORY;
        subCategoryCombobox.value = UPDATED_SUB_CATEGORY;

        categoryCombobox.dispatchEvent(new CustomEvent('change'));
        subCategoryCombobox.dispatchEvent(new CustomEvent('change'));

        await flushPromises();

        // After on change event
        fields = element.shadowRoot.querySelectorAll('lightning-input-field');
        fields.forEach((field) => {
            if (field.fieldName === 'CC_Category__c') {
                expect(field.value).toBe(UPDATED_CATEGORY);
            } else if (field.fieldName === 'CC_Sub_Category__c') {
                expect(field.value).toBe(UPDATED_SUB_CATEGORY);
            }
        });
    });

    it('verify category and sub category combobox options', async () => {
        const EXPECTED_CATEGORY_OPTIONS = [
            {
                label: '--',
                value: '',
            },
            {
                label: 'Test Case Category',
                value: '1234567890',
            },
        ];

        const EXPECTED_SUB_CATEGORY_OPTIONS = [
            {
                label: '--',
                value: '',
            },
            {
                label: 'Test Sub Category',
                value: 'asdfghjkl',
            }
        ];

        // Arrange
        const element = createElement('c-lightning-clone-case-modal', {
            is: LightningCloneCaseModal,
        });

        // Act
        document.body.appendChild(element);

        getRecord.emit(mockGetRecord);

        await flushPromises();

        let comboboxes = element.shadowRoot.querySelectorAll('lightning-combobox');
        expect(comboboxes.length).toBe(2);

        const categoryOptions = comboboxes[0].options;

        expect(categoryOptions).toEqual(EXPECTED_CATEGORY_OPTIONS);

        // try selecting a value
        comboboxes[0].value = '1234567890';
        comboboxes[0].dispatchEvent(new CustomEvent('change'));

        await flushPromises();

        comboboxes = element.shadowRoot.querySelectorAll('lightning-combobox');
        const subCategoryOptions = comboboxes[1].options;

        expect(subCategoryOptions).toEqual(EXPECTED_SUB_CATEGORY_OPTIONS);
    });
});
