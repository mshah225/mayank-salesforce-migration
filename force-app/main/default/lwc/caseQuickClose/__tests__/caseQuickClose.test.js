/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {CaseQuickCloseTest} from 'c/caseQuickClose';
import {getRecord, updateRecord} from 'lightning/uiRecordApi';
import {flushPromises} from 'c/helperTestFunctions';

// Mock realistic data
const caseRecorCanCloseSpamdMock = require('./data/caseRecordCanCloseSpam.json');
const caseRecordCannotCloseSpamMock = require('./data/caseRecordCannotCloseSpam.json');
const caseRecordMock = require('./data/caseRecord.json');
const caseRecordAlreadyClosedAsSpamMock = require('./data/caseRecordAlreadyClosedAsSpam.json');

describe('c-case-quick-close', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    test('Starts as just one button to close case', async () => {
        const element = createElement('c-case-quick-close', {
            is: CaseQuickCloseTest,
        });
        element.recordId = '5005900000BNavNAAT';
        document.body.appendChild(element);

        // Just the one close button is shown
        expect(element.buttonVisible).toEqual(true);
    });

    test('Show spam button depending on record type', async () => {
        const element = createElement('c-case-quick-close', {
            is: CaseQuickCloseTest,
        });
        element.recordId = '5005900000BNavNAAT';
        document.body.appendChild(element);
        getRecord.emit(caseRecorCanCloseSpamdMock); // Wire completes
        await flushPromises();
        // Done loading component

        // Both buttons
        expect(element.buttonVisible).toEqual(true);
        expect(element.spamButtonVisible).toEqual(true);
    });

    test('Hides spam button depending on record type', async () => {
        const element = createElement('c-case-quick-close', {
            is: CaseQuickCloseTest,
        });
        element.recordId = '5005900000BNavNAAT';
        document.body.appendChild(element);
        getRecord.emit(caseRecordCannotCloseSpamMock); // Wire completes
        await flushPromises();
        // Done loading component

        // Just one button shown
        expect(element.buttonVisible).toEqual(true);
        expect(element.spamButtonVisible).toEqual(false);
    });

    test('Close as spam', async () => {
        const element = createElement('c-case-quick-close', {
            is: CaseQuickCloseTest,
        });
        element.recordId = '5005900000BNavNAAT';
        document.body.appendChild(element);
        getRecord.emit(caseRecordMock); // Wire completes
        await flushPromises();
        // Done loading component

        // Press the spam close button
        element.shadowRoot.querySelectorAll('lightning-button')[1].dispatchEvent(new Event('click'), {bubbles: true});

        // Closed the case
        expect(updateRecord.mock.lastCall[0]).toMatchObject({
            fields: {
                Id: caseRecordMock.id,
                Status: 'Closed: SPAM',
            },
        });
    });

    test('Prepend SPAM to subject and description', async () => {
        const element = createElement('c-case-quick-close', {
            is: CaseQuickCloseTest,
        });
        element.recordId = '5005900000BNavNAAT';
        document.body.appendChild(element);
        getRecord.emit(caseRecordMock); // Wire completes
        await flushPromises();
        // Done loading component

        // Press the spam close button
        element.shadowRoot.querySelectorAll('lightning-button')[1].dispatchEvent(new Event('click'), {bubbles: true});

        // Prepended SPAM to subject and description

        expect(updateRecord.mock.lastCall[0]).toMatchObject({
            fields: {
                Description: `SPAM: ${caseRecordMock.fields.Description.value}`,
                Subject: `SPAM: ${caseRecordMock.fields.Subject.value}`,
            },
        });
    });

    test('Only prepend SPAM if not already prepended to subj/descr', async () => {
        const element = createElement('c-case-quick-close', {
            is: CaseQuickCloseTest,
        });
        element.recordId = '5005900000BNavNAAT';
        document.body.appendChild(element);
        getRecord.emit(caseRecordAlreadyClosedAsSpamMock); // Wire completes
        await flushPromises();
        // Done loading component

        // Press the spam close button
        element.shadowRoot.querySelectorAll('lightning-button')[1].dispatchEvent(new Event('click'), {bubbles: true});
        await flushPromises();

        // Does not include subject or description (since they already have SPAM prepended)
        expect(updateRecord.mock.lastCall[0].fields.Description).toEqual(undefined);
        expect(updateRecord.mock.lastCall[0].fields.Subject).toEqual(undefined);
    });

    test('Starts with form hidden', async () => {
        const element = createElement('c-case-quick-close', {
            is: CaseQuickCloseTest,
        });
        element.recordId = '5005900000BNavNAAT';
        document.body.appendChild(element);
        getRecord.emit(caseRecordMock); // Wire completes
        await flushPromises();
        // Done loading component

        // Form is hidden at start
        expect(element.formVisible).toEqual(false);
    });

    test('Open close case form', async () => {
        const element = createElement('c-case-quick-close', {
            is: CaseQuickCloseTest,
        });
        element.recordId = '5005900000BNavNAAT';
        document.body.appendChild(element);
        getRecord.emit(caseRecordMock); // Wire completes
        await flushPromises();
        // Done loading component

        // Press the case close button
        element.shadowRoot.querySelectorAll('lightning-button')[0].dispatchEvent(new Event('click'), {bubbles: true});
        await flushPromises();

        // Loads the case close view
        expect(element.formVisible).toEqual(true);
    });

    test('Only show submit/cancel button after close case form is ready', async () => {
        const element = createElement('c-case-quick-close', {
            is: CaseQuickCloseTest,
        });
        element.recordId = '5005900000BNavNAAT';
        document.body.appendChild(element);
        getRecord.emit(caseRecordMock); // Wire completes
        await flushPromises();
        // Done loading component

        // Press the case close button
        element.shadowRoot.querySelectorAll('lightning-button')[0].dispatchEvent(new Event('click'), {bubbles: true});
        await flushPromises();

        // No cancel/submit buttons
        expect(element.formReady).toEqual(false);

        // Form finished loading
        element.shadowRoot
            .querySelector('c-lightning-case-close-view')
            .dispatchEvent(new CustomEvent('ready'), {bubbles: true});
        await flushPromises();

        // Cancel/submit buttons are shown
        expect(element.formReady).toEqual(true);
    });

    test('Cancel button reverts back to original 2 buttons', async () => {
        const element = createElement('c-case-quick-close', {
            is: CaseQuickCloseTest,
        });
        element.recordId = '5005900000BNavNAAT';
        document.body.appendChild(element);
        getRecord.emit(caseRecordMock); // Wire completes
        await flushPromises();
        // Done loading component

        // Press the case close button
        element.shadowRoot.querySelectorAll('lightning-button')[0].dispatchEvent(new Event('click'), {bubbles: true});
        await flushPromises();

        // Form finished loading
        element.shadowRoot
            .querySelector('c-lightning-case-close-view')
            .dispatchEvent(new CustomEvent('ready'), {bubbles: true});
        await flushPromises();

        // Press the cancel button
        element.shadowRoot.querySelectorAll('lightning-button')[0].dispatchEvent(new Event('click'), {bubbles: true});
        await flushPromises();

        // Hides form
        expect(element.formVisible).toEqual(false);
        // And close/spam buttons are shown
        expect(element.buttonVisible).toEqual(true);
        expect(element.spamButtonVisible).toEqual(true);
    });

    test('Submit button triggers commit on form', async () => {
        const element = createElement('c-case-quick-close', {
            is: CaseQuickCloseTest,
        });
        element.recordId = '5005900000BNavNAAT';
        document.body.appendChild(element);
        getRecord.emit(caseRecordMock); // Wire completes
        await flushPromises();
        // Done loading component

        const commitFn = jest.fn();

        // Press the case close button
        element.shadowRoot.querySelectorAll('lightning-button')[0].dispatchEvent(new Event('click'), {bubbles: true});
        await flushPromises();

        // Form finished loading
        element.shadowRoot
            .querySelector('c-lightning-case-close-view')
            .dispatchEvent(new CustomEvent('ready'), {bubbles: true});
        await flushPromises();
        element.shadowRoot.querySelector('c-lightning-case-close-view').commit = commitFn;

        // Press the submit button
        element.shadowRoot.querySelectorAll('lightning-button')[1].dispatchEvent(new Event('click'), {bubbles: true});
        await flushPromises();

        // Commit function has been called
        expect(commitFn).toHaveBeenCalled();
    });

    test('Close form on success', async () => {
        const element = createElement('c-case-quick-close', {
            is: CaseQuickCloseTest,
        });
        element.recordId = '5005900000BNavNAAT';
        document.body.appendChild(element);
        getRecord.emit(caseRecordMock); // Wire completes
        await flushPromises();
        // Done loading component

        const commitFn = jest.fn();

        // Press the case close button
        element.shadowRoot.querySelectorAll('lightning-button')[0].dispatchEvent(new Event('click'), {bubbles: true});
        await flushPromises();

        // Form finished loading
        element.shadowRoot
            .querySelector('c-lightning-case-close-view')
            .dispatchEvent(new CustomEvent('ready'), {bubbles: true});
        await flushPromises();
        element.shadowRoot.querySelector('c-lightning-case-close-view').commit = commitFn;

        // Press the submit button
        element.shadowRoot.querySelectorAll('lightning-button')[1].dispatchEvent(new Event('click'), {bubbles: true});
        await flushPromises();

        // Form is submitted successfully
        element.shadowRoot.querySelector('c-lightning-case-close-view').dispatchEvent(
            new CustomEvent('status', {
                detail: {
                    type: 'success',
                },
            })
        );
        await flushPromises();

        // Hides form
        expect(element.formVisible).toEqual(false);
        // And close/spam buttons are shown
        expect(element.buttonVisible).toEqual(true);
        expect(element.spamButtonVisible).toEqual(true);
    });

    test('Errors are shown', async () => {
        const element = createElement('c-case-quick-close', {
            is: CaseQuickCloseTest,
        });
        element.recordId = '5005900000BNavNAAT';
        document.body.appendChild(element);
        getRecord.error({
            message: 'Record ID is malformed: 5005900000CNXHcAAL',
        }); // Wire completes
        await flushPromises();
        // Done loading component

        // In error state
        expect(element.hasError).toEqual(true);
        expect(element.errorMessage).toContain('Record ID is malformed: 5005900000CNXHcAAL');
    });

    test('Errors are propagated', async () => {
        const element = createElement('c-case-quick-close', {
            is: CaseQuickCloseTest,
        });
        element.recordId = '5005900000BNavNAAT';
        document.body.appendChild(element);
        getRecord.emit(caseRecordMock); // Wire completes
        await flushPromises();
        // Done loading component

        // Press the case close button
        element.shadowRoot.querySelectorAll('lightning-button')[0].dispatchEvent(new Event('click'), {bubbles: true});
        await flushPromises();

        // Form finished loading
        element.shadowRoot
            .querySelector('c-lightning-case-close-view')
            .dispatchEvent(new CustomEvent('ready'), {bubbles: true});
        await flushPromises();

        // Form component raises a list of errors
        element.shadowRoot.querySelector('c-lightning-case-close-view').dispatchEvent(
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

        // In error state
        expect(element.hasError).toEqual(true);
        expect(element.errorMessage).toContain(
            'Could not find ObjectHelper.getFieldsFromFieldSet - you do not have permission to class ObjectHelper'
        );
    });
});
