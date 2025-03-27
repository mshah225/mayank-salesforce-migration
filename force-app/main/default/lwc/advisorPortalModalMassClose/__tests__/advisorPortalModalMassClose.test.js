/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {AdvisorPortalModalMassCloseTest} from 'c/advisorPortalModalMassClose';
import {flushPromises} from 'c/helperTestFunctions';

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
            is: AdvisorPortalModalMassCloseTest,
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

    test('Submnit button triggers form commit', async () => {
        // Arrange
        const element = createElement('c-advisor-portal-modal-mass-close', {
            is: AdvisorPortalModalMassCloseTest,
        });
        const commitFn = jest.fn();
        document.body.appendChild(element);

        element.modalBody$('c-lightning-case-close-view').commit = commitFn;

        // Press the submit button
        element.modalFooter$$('lightning-button')[1].click();

        // Commit function has been called
        expect(commitFn).toHaveBeenCalled();
    });

    test('Success toasts', async () => {
        // Arrange
        const element = createElement('c-advisor-portal-modal-mass-close', {
            is: AdvisorPortalModalMassCloseTest,
        });
        const toastHandler = jest.fn();
        element.addEventListener('lightning__showtoast', toastHandler);
        document.body.appendChild(element);

        // Form is submitted successfully
        element.modalBody$('c-lightning-case-close-view').dispatchEvent(
            new CustomEvent('status', {
                detail: {
                    type: 'success',
                },
            })
        );
        await flushPromises();

        // Modal was closed
        expect(toastHandler).toHaveBeenCalledTimes(1);
    });

    test('Success closes modal', async () => {
        // Arrange
        const element = createElement('c-advisor-portal-modal-mass-close', {
            is: AdvisorPortalModalMassCloseTest,
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
            is: AdvisorPortalModalMassCloseTest,
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
            is: AdvisorPortalModalMassCloseTest,
        });
        document.body.appendChild(element);

        // Form component raises a list of errors
        element.modalBody$('c-lightning-case-close-view').dispatchEvent(
            new CustomEvent('error', {
                detail: {
                    errors: [
                        'Could not find ObjectHelper.getFieldsFromFieldSet - you do not have permission to class ObjectHelper',
                        'Another error message',
                    ],
                },
            })
        );
        await flushPromises();

        // Shows error message
        expect(element.hasError).toEqual(true);
        expect(element.errorMessage).toContain(
            'Could not find ObjectHelper.getFieldsFromFieldSet - you do not have permission to class ObjectHelper'
        );
    });
});
