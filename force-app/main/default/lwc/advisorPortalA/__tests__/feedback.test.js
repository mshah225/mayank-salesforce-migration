/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {AdvisorPortalTest} from 'c/advisorPortalA';
import LightningPrompt from 'lightning/prompt';
import {flushPromises} from 'c/helperTestFunctions';
import submitFeedback from '@salesforce/apex/FeedbackButtonService.submitFeedback';
import createTicket from '@salesforce/apex/JiraCallout.createTicket';

jest.mock(
    '@salesforce/apex/FeedbackButtonService.submitFeedback',
    () => {
        return {
            default: jest.fn(),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/JiraCallout.createTicket',
    () => {
        return {
            default: jest.fn(),
        };
    },
    {virtual: true}
);

describe('c-advisor-portal feedback', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    test('UGRAD Feedback opens prompt', () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.currentFilter = {career: 'UGRD'};
        document.body.appendChild(element);

        // Fake a response
        LightningPrompt.open = jest.fn().mockResolvedValueOnce();

        // Click the save as button
        element.shadowRoot.querySelector('.feedbackWrapper button').click();

        // Did open prompt
        expect(LightningPrompt.open).toHaveBeenCalled();
    });

    test('UGRAD Feedback submits case', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.currentFilter = {career: 'UGRD'};
        document.body.appendChild(element);

        // Fake a response
        LightningPrompt.open = jest.fn().mockResolvedValueOnce('I keep getting errors when loading');

        // Click the save as button
        element.shadowRoot.querySelector('.feedbackWrapper button').click();

        // Wait for successful mock response from prompt
        await flushPromises();

        // Did open prompt
        expect(submitFeedback).toHaveBeenCalledWith({
            carName: 'Advisor Portal',
            feedbackText: 'I keep getting errors when loading',
        });
    });

    test('UGRAD Feedback success toast', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.currentFilter = {career: 'UGRD'};
        document.body.appendChild(element);

        const toastHandler = jest.fn((evnt) => {
            expect(evnt.detail).toMatchObject({
                variant: 'success',
            });
        });
        element.addEventListener('lightning__showtoast', toastHandler);

        // Fake a response
        LightningPrompt.open = jest.fn().mockResolvedValueOnce('I keep getting errors when loading');
        submitFeedback.mockResolvedValueOnce(true);

        // Click the save as button
        element.shadowRoot.querySelector('.feedbackWrapper button').click();

        await flushPromises(); // Wait for promise from opening prompt
        await flushPromises(); // Wait for Apex to complete

        // Did show success toast
        expect(toastHandler).toHaveBeenCalled();
    });

    test('UGRAD Feedback error toast', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.currentFilter = {career: 'UGRD'};
        document.body.appendChild(element);

        const toastHandler = jest.fn((evnt) => {
            expect(evnt.detail).toMatchObject({
                variant: 'error',
            });
        });
        element.addEventListener('lightning__showtoast', toastHandler);

        // Fake a response
        LightningPrompt.open = jest.fn().mockResolvedValueOnce('I keep getting errors when loading');
        submitFeedback.mockRejectedValueOnce('ERROR');

        // Click the save as button
        element.shadowRoot.querySelector('.feedbackWrapper button').click();

        await flushPromises(); // Wait for promise from opening prompt
        await flushPromises(); // Wait for Apex to complete

        // Did show success toast
        expect(toastHandler).toHaveBeenCalled();
    });

    test('GRAD Feedback opens prompt', () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.currentFilter = {career: 'GRD'};
        document.body.appendChild(element);

        // Fake a response
        LightningPrompt.open = jest.fn().mockResolvedValueOnce();

        // Click the save as button
        element.shadowRoot.querySelector('.feedbackWrapper button').click();

        // Did open prompt
        expect(LightningPrompt.open).toHaveBeenCalled();
    });

    test('GRAD Feedback submits JIRA ticket', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.currentFilter = {career: 'GRD'};
        document.body.appendChild(element);

        // Fake a response
        LightningPrompt.open = jest.fn().mockResolvedValueOnce('I keep getting errors when loading');

        // Click the save as button
        element.shadowRoot.querySelector('.feedbackWrapper button').click();

        // Wait for successful mock response from prompt
        await flushPromises();

        // Did open prompt
        expect(createTicket).toHaveBeenCalledWith({
            jiraProjectMetadataRecordName: 'Graduate College',
            summary: 'Graduate Advisor Portal Feedback Inquiry',
            description: 'I keep getting errors when loading',
            type: 'Improvement',
            componentNames: 'Salesforce',
        });
    });

    test('GRAD Feedback success toast', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.currentFilter = {career: 'GRD'};
        document.body.appendChild(element);

        const toastHandler = jest.fn((evnt) => {
            expect(evnt.detail).toMatchObject({
                variant: 'success',
            });
        });
        element.addEventListener('lightning__showtoast', toastHandler);

        // Fake a response
        LightningPrompt.open = jest.fn().mockResolvedValueOnce('I keep getting errors when loading');
        createTicket.mockResolvedValueOnce(true);

        // Click the save as button
        element.shadowRoot.querySelector('.feedbackWrapper button').click();

        await flushPromises(); // Wait for promise from opening prompt
        await flushPromises(); // Wait for Apex to complete

        // Did show success toast
        expect(toastHandler).toHaveBeenCalled();
    });

    test('GRAD Feedback error toast', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.currentFilter = {career: 'GRD'};
        document.body.appendChild(element);

        const toastHandler = jest.fn((evnt) => {
            expect(evnt.detail).toMatchObject({
                variant: 'error',
            });
        });
        element.addEventListener('lightning__showtoast', toastHandler);

        // Fake a response
        LightningPrompt.open = jest.fn().mockResolvedValueOnce('I keep getting errors when loading');
        createTicket.mockRejectedValueOnce('ERROR');

        // Click the save as button
        element.shadowRoot.querySelector('.feedbackWrapper button').click();

        await flushPromises(); // Wait for promise from opening prompt
        await flushPromises(); // Wait for Apex to complete

        // Did show success toast
        expect(toastHandler).toHaveBeenCalled();
    });
});
