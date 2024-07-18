/* eslint-disable no-undef */
import {createElement} from 'lwc';
import CaseQuickClose from 'c/caseQuickClose';
import {getRecord, updateRecord} from 'lightning/uiRecordApi';
import {flushPromises} from 'c/helperFunctions';

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
        // Arrange
        const element = createElement('c-case-quick-close', {
            is: CaseQuickClose,
        });
        element.recordId = '5005900000BNavNAAT';

        // Act
        document.body.appendChild(element);

        // Just the one close button is shown
        expect(element.shadowRoot.querySelectorAll('lightning-button')).toHaveLength(1);
        expect(element.shadowRoot.querySelector('lightning-button').label).toEqual(element.closeButtonLabel);
    });

    test('Show spam button depending on record type', async () => {
        // Arrange
        const element = createElement('c-case-quick-close', {
            is: CaseQuickClose,
        });
        element.recordId = '5005900000BNavNAAT';

        // Act
        document.body.appendChild(element);

        // Wire completes
        getRecord.emit(caseRecorCanCloseSpamdMock);
        await flushPromises();

        // Both buttons
        expect(element.shadowRoot.querySelectorAll('lightning-button')).toHaveLength(2);
        expect(element.shadowRoot.querySelectorAll('lightning-button')[0].label).toEqual(element.closeButtonLabel);
        expect(element.shadowRoot.querySelectorAll('lightning-button')[1].label).toEqual(element.closeSpamButtonLabel);
    });

    test('Hides spam button depending on record type', async () => {
        // Arrange
        const element = createElement('c-case-quick-close', {
            is: CaseQuickClose,
        });
        element.recordId = '5005900000BNavNAAT';

        // Act
        document.body.appendChild(element);

        // Wire completes
        getRecord.emit(caseRecordCannotCloseSpamMock);
        await flushPromises();

        // Just one button shown
        expect(element.shadowRoot.querySelectorAll('lightning-button')).toHaveLength(1);
        expect(element.shadowRoot.querySelector('lightning-button').label).toEqual(element.closeButtonLabel);
    });

    test('Close as spam', async () => {
        // Arrange
        const element = createElement('c-case-quick-close', {
            is: CaseQuickClose,
        });
        element.recordId = '5005900000BNavNAAT';

        // Act
        document.body.appendChild(element);

        // Wire completes
        getRecord.emit(caseRecordMock);
        await flushPromises();

        // Press the spam close button
        element.shadowRoot.querySelectorAll('lightning-button')[1].dispatchEvent(new Event('click'), {bubbles: true});

        // Closed the case
        expect(updateRecord.mock.lastCall[0].fields.Id).toEqual(caseRecordMock.id);
        expect(updateRecord.mock.lastCall[0].fields.Status).toEqual('Closed: SPAM');
    });

    test('Prepend SPAM to subject and description', async () => {
        // Arrange
        const element = createElement('c-case-quick-close', {
            is: CaseQuickClose,
        });
        element.recordId = '5005900000BNavNAAT';

        // Act
        document.body.appendChild(element);

        // Wire completes
        getRecord.emit(caseRecordMock);
        await flushPromises();

        // Press the spam close button
        element.shadowRoot.querySelectorAll('lightning-button')[1].dispatchEvent(new Event('click'), {bubbles: true});

        // Prepended SPAM to subject and description
        expect(updateRecord.mock.lastCall[0].fields.Description).toEqual(
            `SPAM: ${caseRecordMock.fields.Description.value}`
        );
        expect(updateRecord.mock.lastCall[0].fields.Subject).toEqual(`SPAM: ${caseRecordMock.fields.Subject.value}`);
    });

    test('Only prepend SPAM if not already prepended to subj/descr', async () => {
        // Arrange
        const element = createElement('c-case-quick-close', {
            is: CaseQuickClose,
        });
        element.recordId = '5005900000BNavNAAT';

        // Act
        document.body.appendChild(element);

        // Wire completes
        getRecord.emit(caseRecordAlreadyClosedAsSpamMock);
        await flushPromises();

        // Press the spam close button
        element.shadowRoot.querySelectorAll('lightning-button')[1].dispatchEvent(new Event('click'), {bubbles: true});
        await flushPromises();

        // Does not include subject or description (since they already have SPAM prepended)
        expect(updateRecord.mock.lastCall[0].fields.Description).toEqual(undefined);
        expect(updateRecord.mock.lastCall[0].fields.Subject).toEqual(undefined);
    });

    test('Open close case form', async () => {
        // Arrange
        const element = createElement('c-case-quick-close', {
            is: CaseQuickClose,
        });
        element.recordId = '5005900000BNavNAAT';

        // Act
        document.body.appendChild(element);

        // Wire completes
        getRecord.emit(caseRecordMock);
        await flushPromises();

        // Press the case close button
        element.shadowRoot.querySelectorAll('lightning-button')[0].dispatchEvent(new Event('click'), {bubbles: true});
        await flushPromises();

        // Loads the case close view
        expect(element.shadowRoot.querySelector('c-lightning-case-close-view')).toBeTruthy();
    });

    test('Only show submit/cancel button after close case form is ready', async () => {
        // Arrange
        const element = createElement('c-case-quick-close', {
            is: CaseQuickClose,
        });
        element.recordId = '5005900000BNavNAAT';

        // Act
        document.body.appendChild(element);

        // Wire completes
        getRecord.emit(caseRecordMock);
        await flushPromises();

        // Press the case close button
        element.shadowRoot.querySelectorAll('lightning-button')[0].dispatchEvent(new Event('click'), {bubbles: true});
        await flushPromises();

        // No cancel/submit buttons
        expect(element.shadowRoot.querySelectorAll('lightning-button')).toHaveLength(0);

        // Form finished loading
        element.shadowRoot
            .querySelector('c-lightning-case-close-view')
            .dispatchEvent(new CustomEvent('ready'), {bubbles: true});
        await flushPromises();

        // Cancel/submit buttons are shown
        expect(element.shadowRoot.querySelectorAll('lightning-button')).toHaveLength(2);
    });

    test('Cancel button reverts back to original 2 buttons', async () => {
        // Arrange
        const element = createElement('c-case-quick-close', {
            is: CaseQuickClose,
        });
        element.recordId = '5005900000BNavNAAT';

        // Act
        document.body.appendChild(element);

        // Wire completes
        getRecord.emit(caseRecordMock);
        await flushPromises();

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
        expect(element.shadowRoot.querySelector('c-lightning-case-close-view')).toBeFalsy();
        // And close/spam buttons are shown
        expect(element.shadowRoot.querySelectorAll('lightning-button')).toHaveLength(2);
    });

    test('Submit button triggers commit on form', async () => {
        // Arrange
        const element = createElement('c-case-quick-close', {
            is: CaseQuickClose,
        });
        element.recordId = '5005900000BNavNAAT';

        // Act
        document.body.appendChild(element);

        const commitFn = jest.fn();

        // Wire completes
        getRecord.emit(caseRecordMock);
        await flushPromises();

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
        // Arrange
        const element = createElement('c-case-quick-close', {
            is: CaseQuickClose,
        });
        element.recordId = '5005900000BNavNAAT';

        // Act
        document.body.appendChild(element);

        const commitFn = jest.fn();

        // Wire completes
        getRecord.emit(caseRecordMock);
        await flushPromises();

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
        expect(element.shadowRoot.querySelector('c-lightning-case-close-view')).toBeFalsy();
        // And close/spam buttons are shown
        expect(element.shadowRoot.querySelectorAll('lightning-button')).toHaveLength(2);
    });

    test('Errors are shown', async () => {
        // Arrange
        const element = createElement('c-case-quick-close', {
            is: CaseQuickClose,
        });
        element.recordId = '5005900000BNavNAAT';

        // Act
        document.body.appendChild(element);

        // Wire completes
        getRecord.error({message: 'Apex methods that are to be cached must be marked as @AuraEnabled(cacheable=true)'});
        await flushPromises();

        // Hides form
        expect(element.shadowRoot.querySelector('c-lightning-case-close-view')).toBeFalsy();
        // And ahow error message
        expect(element.shadowRoot.querySelector('div[role="alert"]').textContent).toContain(
            'Apex methods that are to be cached must be marked as @AuraEnabled(cacheable=true)'
        );
    });

    test('Errors are propagated', async () => {
        // Arrange
        const element = createElement('c-case-quick-close', {
            is: CaseQuickClose,
        });
        element.recordId = '5005900000BNavNAAT';

        // Act
        document.body.appendChild(element);

        // Wire completes
        getRecord.emit(caseRecordMock);
        await flushPromises();

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

        // Hides form
        expect(element.shadowRoot.querySelector('c-lightning-case-close-view')).toBeFalsy();
        // And ahow error message
        expect(element.shadowRoot.querySelector('div[role="alert"]').textContent).toContain(
            'Could not find ObjectHelper.getFieldsFromFieldSet - you do not have permission to class ObjectHelper'
        );
    });
});
