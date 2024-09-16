/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {CaseClassificationTest} from 'c/caseClassification';
import {getRecord} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {graphql} from 'lightning/uiGraphQLApi';

import FUNCTIONAL_GROUP_ID_FIELD from '@salesforce/schema/Case.CC_Functional_Group__c';
import CATEGORY_ID_FIELD from '@salesforce/schema/Case.CC_Category__c';
import SUB_CATEGORY_ID_FIELD from '@salesforce/schema/Case.CC_Sub_Category__c';

const caseClassificationsMock = require('./data/caseClassifications.json');
const caseClassificationsNoneMock = require('./data/caseClassificationsNone.json');
const caseMock = require('./data/caseRecord.json');
const caseNoFuncGrpMock = require('./data/caseRecordNoFuncGrp.json');
const caseNoCatMock = require('./data/caseRecordNoCat.json');
const caseNoSubCatMock = require('./data/caseRecordNoSubcat.json');

describe('c-case-classification', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Clear mocks
        jest.clearAllMocks();
    });

    test('Initial wire requests made', async () => {
        // Arrange
        const element = createElement('c-case-classification', {
            is: CaseClassificationTest,
        });
        element.recordId = '5005900000BNasPAAT';
        document.body.appendChild(element);
        await flushPromises(); // wires queue

        // Made wire request for case functional group. case category, and case sub category
        expect(getRecord.getLastConfig()).toMatchObject({
            recordId: '5005900000BNasPAAT',
            fields: [FUNCTIONAL_GROUP_ID_FIELD, CATEGORY_ID_FIELD, SUB_CATEGORY_ID_FIELD],
        });

        // GraphQL has undefined variables thus preventing it from running
        expect(graphql.getLastConfig()).toMatchObject({variables: undefined});
    });

    test('Dependent wire requests', async () => {
        // Setup
        const element = createElement('c-case-classification', {
            is: CaseClassificationTest,
        });
        element.recordId = '5005900000BNasPAAT';
        document.body.appendChild(element);
        await flushPromises(); // wires queue
        getRecord.emit(caseMock);
        await flushPromises(); // wires requeue

        // Made wire request for case classification information now that current selections are known
        expect(graphql.getLastConfig()).toMatchObject({
            variables: {
                funcGrpId: caseMock.fields.CC_Functional_Group__c.value,
                selectedIds: [
                    caseMock.fields.CC_Functional_Group__c.value,
                    caseMock.fields.CC_Category__c.value,
                    caseMock.fields.CC_Sub_Category__c.value,
                ],
            },
        });
    });

    test('Filter by active/visible or selectedIds AND which are under proper functional group', async () => {
        // Setup
        const element = createElement('c-case-classification', {
            is: CaseClassificationTest,
        });
        element.recordId = '5005900000BNasPAAT';
        document.body.appendChild(element);
        await flushPromises(); // wires queue
        getRecord.emit(caseMock);
        await flushPromises(); // wires requeue

        // Made wire request for case classification information now that current selections are known
        expect(graphql.getLastConfig()).toMatchObject({
            query: {
                CaseClassifications: {
                    uiapi: {
                        query: {
                            Case_Classification__c: {
                                __attribs: {
                                    // correct filter
                                    where: {
                                        and: [
                                            {
                                                or: [
                                                    {Parent__c: {eq: '$funcGrpId'}},
                                                    {Parent__r: {Parent__c: {eq: '$funcGrpId'}}},
                                                ],
                                            },
                                            {
                                                or: [
                                                    {Id: {in: '$selectedIds'}},
                                                    {and: [{Active__c: {eq: 'true'}}, {Visible__c: {eq: 'true'}}]},
                                                ],
                                            },
                                        ],
                                    },
                                },
                            },
                        },
                    },
                },
            },
        });
    });

    test('Correct fields queried', async () => {
        // Setup
        const element = createElement('c-case-classification', {
            is: CaseClassificationTest,
        });
        element.recordId = '5005900000BNasPAAT';
        document.body.appendChild(element);
        await flushPromises(); // wires queue
        getRecord.emit(caseMock);
        await flushPromises(); // wires requeue

        // Made wire request for case classification information now that current selections are known
        expect(graphql.getLastConfig()).toMatchObject({
            query: {
                CaseClassifications: {
                    uiapi: {
                        query: {
                            Case_Classification__c: {
                                edges: {
                                    // has all needed fields
                                    node: {
                                        Id: null,
                                        Name: {value: null},
                                        Parent__c: {value: null},
                                    },
                                },
                            },
                        },
                    },
                },
            },
        });
    });

    test('No functional group', async () => {
        // Setup
        const element = createElement('c-case-classification', {
            is: CaseClassificationTest,
        });
        element.recordId = '5005900000BNasPAAT';
        document.body.appendChild(element);
        await flushPromises(); // wires queue
        getRecord.emit(caseNoFuncGrpMock);
        await flushPromises(); // wires requeue
        graphql.emit(caseClassificationsMock);
        await flushPromises(); // wires complete

        // no values selected
        expect(element.selectedFunctionalGroup).toEqual(null);
        expect(element.selectedCategory).toEqual(null);
        expect(element.selectedSubCategory).toEqual(null);
        // no options shown (only the empty option is shown)
        expect(element.categoryOptions).toHaveLength(1);
        expect(element.subCategoryOptions).toHaveLength(1);
        // dropdowns disabled
        expect(element.categoryDisabled).toEqual(true);
        expect(element.subCategoryDisabled).toEqual(true);
    });

    test('No category', async () => {
        // Setup
        const element = createElement('c-case-classification', {
            is: CaseClassificationTest,
        });
        element.recordId = '5005900000BNasPAAT';
        document.body.appendChild(element);
        await flushPromises(); // wires queue
        getRecord.emit(caseNoCatMock);
        await flushPromises(); // wires requeue
        graphql.emit(caseClassificationsMock);
        await flushPromises(); // wires complete

        // no values selected
        expect(element.selectedFunctionalGroup).toEqual(caseNoCatMock.fields.CC_Functional_Group__c.value);
        expect(element.selectedCategory).toEqual(null);
        expect(element.selectedSubCategory).toEqual(null);
        // options shown
        expect(element.categoryOptions).toHaveLength(3); // the 3 options for this functional group (2 categories and --)
        expect(element.subCategoryOptions).toHaveLength(1); //no options shown (only the empty option is shown)
        // dropdowns disabled
        expect(element.categoryDisabled).toEqual(false);
        expect(element.subCategoryDisabled).toEqual(true);
    });

    test('No sub category', async () => {
        // Setup
        const element = createElement('c-case-classification', {
            is: CaseClassificationTest,
        });
        element.recordId = '5005900000BNasPAAT';
        document.body.appendChild(element);
        await flushPromises(); // wires queue
        getRecord.emit(caseNoSubCatMock);
        await flushPromises(); // wires requeue
        graphql.emit(caseClassificationsMock);
        await flushPromises(); // wires complete

        // no values selected
        expect(element.selectedFunctionalGroup).toEqual(caseNoSubCatMock.fields.CC_Functional_Group__c.value);
        expect(element.selectedCategory).toEqual(caseNoSubCatMock.fields.CC_Category__c.value);
        expect(element.selectedSubCategory).toEqual(null);
        // options shown
        expect(element.categoryOptions).toHaveLength(3); // the 3 options for this functional group (2 categories and --)
        expect(element.subCategoryOptions).toHaveLength(6); // 5 subcategories for this category, and --
        // dropdowns disabled
        expect(element.categoryDisabled).toEqual(false);
        expect(element.subCategoryDisabled).toEqual(false);
    });

    test('No case classification records', async () => {
        // Setup
        const element = createElement('c-case-classification', {
            is: CaseClassificationTest,
        });
        element.recordId = '5005900000BNasPAAT';
        document.body.appendChild(element);
        await flushPromises(); // wires queue
        getRecord.emit(caseMock);
        await flushPromises(); // wires requeue
        graphql.emit(caseClassificationsNoneMock);
        await flushPromises(); // wires complete

        // no values selected
        expect(element.selectedFunctionalGroup).toEqual(caseMock.fields.CC_Functional_Group__c.value);
        expect(element.selectedCategory).toEqual(caseMock.fields.CC_Category__c.value);
        expect(element.selectedSubCategory).toEqual(caseMock.fields.CC_Sub_Category__c.value);
        // no options shown (only the empty option is shown)
        expect(element.categoryOptions).toHaveLength(1);
        expect(element.subCategoryOptions).toHaveLength(1);
        // dropdowns disabled
        expect(element.categoryDisabled).toEqual(false);
        expect(element.subCategoryDisabled).toEqual(false);
    });

    test('Missing data', async () => {
        // Setup
        const element = createElement('c-case-classification', {
            is: CaseClassificationTest,
        });
        element.recordId = '5005900000BNasPAAT';
        document.body.appendChild(element);
        await flushPromises(); // wires queue
        getRecord.emit(caseNoFuncGrpMock);
        await flushPromises(); // wires requeue
        graphql.emit(caseClassificationsNoneMock);
        await flushPromises(); // wires complete

        // no values selected
        expect(element.selectedFunctionalGroup).toEqual(null);
        expect(element.selectedCategory).toEqual(null);
        expect(element.selectedSubCategory).toEqual(null);
        // no options shown (only the empty option is shown)
        expect(element.categoryOptions).toHaveLength(1);
        expect(element.subCategoryOptions).toHaveLength(1);
        // dropdowns disabled
        expect(element.categoryDisabled).toEqual(true);
        expect(element.subCategoryDisabled).toEqual(true);
        // not loading anymore - just empty data
        expect(element.loading).toEqual(false);
    });
});

function flushPromises() {
    return Promise.resolve();
}
