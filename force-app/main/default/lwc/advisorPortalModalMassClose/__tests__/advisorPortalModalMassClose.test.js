/* eslint-disable no-undef */
import {createElement} from 'lwc';
import AdvisorPortalModalMassClose from 'c/advisorPortalModalMassClose';
import {graphql} from 'lightning/uiGraphQLApi';
import {flushPromises} from 'c/helperFunctions';

// Mock realistic data
const recordTypeInfoMock = require('./data/recordTypeInfo.json');

describe('c-advisor-portal-modal-mass-close', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    test('Extracts case ids', async () => {
        // Arrange
        const element = createElement('c-advisor-portal-modal-mass-close', {
            is: AdvisorPortalModalMassClose,
        });
        element.selectedContactWrappers = [
            {cases: [{caseId: '5006t000006mwnuAAA'}, {caseId: '5006t000007ISX6AAO'}]},
            {cases: [{caseId: '5006t000007IoSJAA0'}, {caseId: '5006t000007IzGJAA0'}]},
            {cases: [{caseId: '5006t000007J0cTAAS'}]},
        ];

        // Act
        document.body.appendChild(element);

        // Form is loaded at start
        expect(element.caseIds).toHaveLength(5);
        expect(element.caseIds).toContain('5006t000006mwnuAAA');
        expect(element.caseIds).toContain('5006t000007ISX6AAO');
        expect(element.caseIds).toContain('5006t000007IoSJAA0');
        expect(element.caseIds).toContain('5006t000007IzGJAA0');
        expect(element.caseIds).toContain('5006t000007J0cTAAS');
    });

    test('Record Type, GRAD Mode = TRUE', async () => {
        // Arrange
        const element = createElement('c-advisor-portal-modal-mass-close', {
            is: AdvisorPortalModalMassClose,
        });
        element.gradMode = true;

        // Act
        document.body.appendChild(element);

        // Wires complete
        graphql.emit(recordTypeInfoMock);

        const gradRecordTypeId = recordTypeInfoMock.uiapi.query.RecordType.edges
            .filter((v) => v.node.DeveloperName.value === 'ASU_Graduate_Advisor_Portal')
            .map((v) => v.node.Id)[0];

        // Form is loaded at start
        expect(element.advisorCaseRecordTypeId).toEqual(gradRecordTypeId);
    });

    test('Record Type, GRAD Mode = FALSE', async () => {
        // Arrange
        const element = createElement('c-advisor-portal-modal-mass-close', {
            is: AdvisorPortalModalMassClose,
        });
        element.gradMode = false;

        // Act
        document.body.appendChild(element);

        // Wires complete
        graphql.emit(recordTypeInfoMock);

        const ugradRecordTypeId = recordTypeInfoMock.uiapi.query.RecordType.edges
            .filter((v) => v.node.DeveloperName.value === 'ASU_Advisor_Outreach')
            .map((v) => v.node.Id)[0];

        // Form is loaded at start
        expect(element.advisorCaseRecordTypeId).toEqual(ugradRecordTypeId);
    });

    test('Submnit button triggers form commit', async () => {
        // Arrange
        const element = createElement('c-advisor-portal-modal-mass-close', {
            is: AdvisorPortalModalMassClose,
        });
        const commitFn = jest.fn();
        document.body.appendChild(element);

        element.modalBody$('c-lightning-case-close-view').commit = commitFn;

        // Press the submit button
        element.modalFooter$$('lightning-button')[1].click();

        // Commit function has been called
        expect(commitFn).toHaveBeenCalled();
    });

    test('Success closes modal', async () => {
        // Arrange
        const element = createElement('c-advisor-portal-modal-mass-close', {
            is: AdvisorPortalModalMassClose,
        });
        document.body.appendChild(element);

        // Form is submitted successfully
        element.modalBody$('c-lightning-case-close-view').dispatchEvent(
            new CustomEvent('status', {
                detail: {
                    type: 'success',
                },
            })
        );

        // Modal was closed
        expect(element.closeValue).toEqual(true);
    });

    test('Cancel closes modal', async () => {
        // Arrange
        const element = createElement('c-advisor-portal-modal-mass-close', {
            is: AdvisorPortalModalMassClose,
        });
        document.body.appendChild(element);

        // Press the case close button
        element.modalFooter$('lightning-button').click();

        // Modal was closed
        expect(element.closeValue).toEqual(true);
    });

    test('Errors are propagated', async () => {
        // Arrange
        const element = createElement('c-advisor-portal-modal-mass-close', {
            is: AdvisorPortalModalMassClose,
        });
        document.body.appendChild(element);

        // Form component raises a list of errors
        element.modalBody$('c-lightning-case-close-view').dispatchEvent(
            new CustomEvent('error', {
                detail: {
                    errors: [
                        'Could not find FieldSetHelper.getFieldsFromFieldSet - you do not have permission to class FieldSetHelper',
                        'Another error message',
                    ],
                },
            })
        );
        await flushPromises();

        // Hides form
        expect(element.shadowRoot.querySelector('c-lightning-case-close-view')).toBeFalsy();
        // And ahow error message
        expect(element.shadowRoot.querySelector('div[role="alert"]').textContent).toContain(
            'Could not find FieldSetHelper.getFieldsFromFieldSet - you do not have permission to class FieldSetHelper'
        );
    });
});
