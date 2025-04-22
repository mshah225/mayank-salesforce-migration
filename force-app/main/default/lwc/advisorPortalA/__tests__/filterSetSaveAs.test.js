/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {AdvisorPortalTest} from 'c/advisorPortalA';
import {getRecord, createRecord} from 'lightning/uiRecordApi';
import LightningPrompt from 'lightning/prompt';
import ToastContainer from 'lightning/toastContainer';
import {flushPromises} from 'c/helperTestFunctions';

describe('c-advisor-portal Save filter set', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    test('Save filteres button opens input prompt', () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        // Fake a response
        LightningPrompt.open = jest.fn().mockResolvedValueOnce();

        // Click the save filters button
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((v) => v.label === 'Save Filters')[0]
            .click();

        // Did open prompt
        expect(LightningPrompt.open).toHaveBeenCalled();
    });

    test('Default name if users name is unknown', () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        // Fake a response
        LightningPrompt.open = jest.fn().mockResolvedValueOnce();

        // Click the save filters button
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((v) => v.label === 'Save Filters')[0]
            .click();

        // Did open prompt
        expect(LightningPrompt.open).toHaveBeenCalledWith({
            label: 'New Filter Set',
            message: 'Give filter set a name',
            defaultValue: 'My filter set',
        });
    });

    test('Default name if users name is known', () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        // Emit user details
        getRecord.emit({fields: {Name: {value: 'Kitara'}}});

        // Fake a response
        LightningPrompt.open = jest.fn().mockResolvedValueOnce();

        // Click the save filters button
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((v) => v.label === 'Save Filters')[0]
            .click();

        // Did open prompt
        expect(LightningPrompt.open).toHaveBeenCalledWith({
            label: 'New Filter Set',
            message: 'Give filter set a name',
            defaultValue: "Kitara's filter set",
        });
    });

    test('Prompt complete creates new filter set', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });

        document.body.appendChild(element);

        // Mock responding with
        LightningPrompt.open = jest.fn().mockResolvedValue('Ba Sing Se');

        // Click the save filters button
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((v) => v.label === 'Save Filters')[0]
            .click();

        // await prompt to close with success and createRecord to enqueue
        await flushPromises();

        // Called to create new filter set
        expect(createRecord).toHaveBeenCalledWith({
            apiName: 'Filter_Set__c',
            fields: expect.objectContaining({
                Name: 'Ba Sing Se',
            }),
        });
    });

    test('Save applied filter', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        let filterSet = {
            career: 'UGRD',
            caseTypeState: 'AllCasesState',
            degreeLevel: 'masters;certificate',
        };
        element.currentFilter = filterSet;
        element.showAdditionalFilters = true;

        document.body.appendChild(element);

        // Apply filters
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((v) => v.label === 'Apply Selected Filters')[0]
            .click();

        // Mock responding with
        LightningPrompt.open = jest.fn().mockResolvedValue('Ba Sing Se');

        // Click the save filters button
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((v) => v.label === 'Save Filters')[0]
            .click();

        // await prompt to close with success and createRecord to enqueue
        await flushPromises();

        // Called to create new filter set
        expect(createRecord.mock.calls[0][0].fields.Value__c).toBeTruthy();
        expect(JSON.parse(createRecord.mock.calls[0][0].fields.Value__c)).toMatchObject(filterSet);
    });

    test('Shows success modal', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        let filterSet = {
            career: 'UGRD',
            caseTypeState: 'AllCasesState',
            degreeLevel: 'masters;certificate',
        };
        element.currentFilter = filterSet;
        element.showAdditionalFilters = true;

        document.body.appendChild(element);

        // Add mock to detect opening success toast
        element.shadowRoot.querySelector('c-lightning-complex-toast').show = jest.fn();

        // Apply filters
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((v) => v.label === 'Apply Selected Filters')[0]
            .click();

        // Mock responding with
        LightningPrompt.open = jest.fn().mockResolvedValue('Ba Sing Se');

        // Click the save filters button
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((v) => v.label === 'Save Filters')[0]
            .click();

        // await prompt to close with success and createRecord to enqueue
        await flushPromises();

        // Showed custom success toast
        expect(element.shadowRoot.querySelector('c-lightning-complex-toast').show).toHaveBeenCalled();
    });

    test('Error while saving filter', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        let filterSet = {
            career: 'UGRD',
            caseTypeState: 'AllCasesState',
            degreeLevel: 'masters;certificate',
        };
        element.currentFilter = filterSet;
        element.showAdditionalFilters = true;

        document.body.appendChild(element);

        const toastHandler = jest.fn((evnt) => {
            expect(evnt.detail).toMatchObject({
                title: 'Unable to save filter set',
                message: 'Duplicate name',
                variant: 'error',
                mode: 'sticky',
            });
        });
        element.addEventListener('lightning__showtoast', toastHandler);

        // Apply filters
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((v) => v.label === 'Apply Selected Filters')[0]
            .click();

        // Mock responding with
        LightningPrompt.open = jest.fn().mockResolvedValue('Ba Sing Se');

        // Click the save filters button
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((v) => v.label === 'Save Filters')[0]
            .click();

        // Mock createRecord failing
        createRecord.mockRejectedValueOnce('Duplicate name');

        // await createRecordFailure
        await flushPromises();

        // Show error
        expect(toastHandler).toHaveBeenCalled();
        // Reopened prompt
        expect(LightningPrompt.open).toHaveBeenCalledWith({
            label: 'New Filter Set',
            message: 'Give filter set a name',
            defaultValue: 'Ba Sing Se',
        });
    });

    test('Hides errors after success', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        let filterSet = {
            career: 'UGRD',
            caseTypeState: 'AllCasesState',
            degreeLevel: 'masters;certificate',
        };
        element.currentFilter = filterSet;
        element.showAdditionalFilters = true;

        document.body.appendChild(element);

        const toastHandler = jest.fn();
        element.addEventListener('lightning__showtoast', toastHandler);

        // Apply filters
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((v) => v.label === 'Apply Selected Filters')[0]
            .click();

        // Mock responding with
        LightningPrompt.open = jest.fn().mockResolvedValue('Ba Sing Se');

        // Click the save filters button
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((v) => v.label === 'Save Filters')[0]
            .click();

        // Mock createRecord failing
        let mockAttempt = 0;
        createRecord.mockImplementation(() => {
            if (mockAttempt++ < 3) return Promise.reject('ERROR');
            return Promise.resolve('Success');
        });

        // await createRecordFailure
        await flushPromises();
        await flushPromises();
        await flushPromises();
        await flushPromises();
        await flushPromises();

        // Show error 3 times, then success
        expect(toastHandler).toHaveBeenCalledTimes(3);
        // Closed all error toasts
        expect(ToastContainer.instance().close).toHaveBeenCalled();
    });
});
