/* eslint-disable no-undef */
import {createElement} from 'lwc';
import JiraProdDataImports from 'c/jiraProdDataImports';
import createDataImport from '@salesforce/apex/JiraReportIssueController.createDataImport';

const createDataImportMock = require('./data/mockCreateDataImport.json');
const createDataImportErrorMock = require('./data/mockCreateDataImportError.json');

// Mock all Apex functions (these allow us to mock the data)
jest.mock(
    '@salesforce/apex/JiraReportIssueController.createDataImport',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);

describe('c-jira-prod-data-imports', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Captures changes to questions', () => {
        // Arrange
        const element = createElement('c-jira-prod-data-imports', {
            is: JiraProdDataImports,
        });
        // Add attributes
        element.title = 'Request Data Import';
        element.questionListJSON =
            '[   {     "action": "title",     "question": "Summary (Title):",     "type": "textarea",     "subnote": "FIELD LIMIT:  This field must be less than 255 characters.",     "maxLength": 255,     "required": true   },   {     "question": "Description:",     "type": "textarea",     "subnote": "FIELD LIMIT:  This field must be less than 3000 characters.",     "maxLength": 3000,     "required": true   },   {     "action": "requestForm",     "question": "URL for import file(s):",     "type": "textarea",     "required": true   },   {     "action": "watcherList",     "question": "Watchers for the ticket:",     "type": "textarea",     "subnote": "Enter the ASURITES for each user you want to watch this ticket. Each ASURITE must be separated with a comma.",     "required": false   } ]';

        // Expected answers
        const expectedTitle = 'Import the numbers';
        const expectedDescription =
            'We have discovered four new numbers. We need these imported into SF so we can use them';
        const expectedUrl = 'https://research.asu.edu/researcher-discovers-new-numbers/sources/numberList.csv';
        const expectedWatchers = 'rnordman,jdsanch8';

        // Act
        document.body.appendChild(element);

        // Let's set some answers
        const qaSection = element.shadowRoot.querySelector('c-lightning-question-answer-section');
        qaSection.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    key: 'key-0',
                    answer: expectedTitle,
                },
            })
        );
        qaSection.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    key: 'key-1',
                    answer: expectedDescription,
                },
            })
        );
        qaSection.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    key: 'key-2',
                    answer: expectedUrl,
                },
            })
        );
        qaSection.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    key: 'key-3',
                    answer: expectedWatchers,
                },
            })
        );

        const questionList = element.test__getField('configurableQuestions');

        for (let i = 0; i < questionList.length; i++) {
            if (questionList[i].key === 'key-0') expect(questionList[i].answer).toBe(expectedTitle);
            else if (questionList[i].key === 'key-1') expect(questionList[i].answer).toBe(expectedDescription);
            else if (questionList[i].key === 'key-2') expect(questionList[i].answer).toBe(expectedUrl);
            else if (questionList[i].key === 'key-3') expect(questionList[i].answer).toBe(expectedWatchers);
            else expect(questionList[i].key).toBeFalsy(); // extra keys make no sense
        }
    });

    test("Can't submit if form is invalid", () => {
        // Arrange
        const element = createElement('c-jira-prod-data-imports', {
            is: JiraProdDataImports,
        });
        // Add attributes
        element.title = 'Request Data Import';
        element.questionListJSON =
            '[   {     "action": "title",     "question": "Summary (Title):",     "type": "textarea",     "subnote": "FIELD LIMIT:  This field must be less than 255 characters.",     "maxLength": 255,     "required": true   },   {     "question": "Description:",     "type": "textarea",     "subnote": "FIELD LIMIT:  This field must be less than 3000 characters.",     "maxLength": 3000,     "required": true   },   {     "action": "requestForm",     "question": "URL for import file(s):",     "type": "textarea",     "required": true   },   {     "action": "watcherList",     "question": "Watchers for the ticket:",     "type": "textarea",     "subnote": "Enter the ASURITES for each user you want to watch this ticket. Each ASURITE must be separated with a comma.",     "required": false   } ]';
        // Report the form as invalid
        const validityFunc = () => {
            return false;
        };

        // Act
        document.body.appendChild(element);
        // attach mock validity function
        element.shadowRoot.querySelector('c-lightning-question-answer-section').reportValidity = validityFunc;
        // Submit form
        element.test__runFunction('submit', []);

        // Assert error alert shown
        expect(element.test__getField('alert')).toBeTruthy();
        expect(element.test__getField('alert')).toBe('Please complete the required forms below!');
        expect(element.test__getField('alertHref')).toBeFalsy();
    });

    test('Show URL if successful submission', async () => {
        // Arrange
        const element = createElement('c-jira-prod-data-imports', {
            is: JiraProdDataImports,
        });
        // Add attributes
        element.title = 'Request Data Import';
        element.questionListJSON =
            '[   {     "action": "title",     "question": "Summary (Title):",     "type": "textarea",     "subnote": "FIELD LIMIT:  This field must be less than 255 characters.",     "maxLength": 255,     "required": true   },   {     "question": "Description:",     "type": "textarea",     "subnote": "FIELD LIMIT:  This field must be less than 3000 characters.",     "maxLength": 3000,     "required": true   },   {     "action": "requestForm",     "question": "URL for import file(s):",     "type": "textarea",     "required": true   },   {     "action": "watcherList",     "question": "Watchers for the ticket:",     "type": "textarea",     "subnote": "Enter the ASURITES for each user you want to watch this ticket. Each ASURITE must be separated with a comma.",     "required": false   } ]';
        // setup a mock response for submission
        createDataImport.mockResolvedValue(createDataImportMock);
        // Report the form as valid
        const validityFunc = () => {
            return true;
        };

        // Act
        document.body.appendChild(element);
        // attach mock validity function
        element.shadowRoot.querySelector('c-lightning-question-answer-section').reportValidity = validityFunc;
        // Submit form
        element.test__runFunction('submit', []);
        await flushPromises(); // await response

        // Assert success alert is shown
        expect(element.test__getField('alert')).toBeTruthy();
        expect(element.test__getField('alert')).toBe('Jira Issue Successfully Created');
        expect(element.test__getField('alertHref')).toBeTruthy();
        expect(element.test__getField('alertHref')).toBe('https://asudev.jira.com/browse/' + createDataImportMock);
    });

    test('Display error if failed submission', async () => {
        // Arrange
        const element = createElement('c-jira-prod-data-imports', {
            is: JiraProdDataImports,
        });
        // Add attributes
        element.title = 'Request Data Import';
        element.questionListJSON =
            '[   {     "action": "title",     "question": "Summary (Title):",     "type": "textarea",     "subnote": "FIELD LIMIT:  This field must be less than 255 characters.",     "maxLength": 255,     "required": true   },   {     "question": "Description:",     "type": "textarea",     "subnote": "FIELD LIMIT:  This field must be less than 3000 characters.",     "maxLength": 3000,     "required": true   },   {     "action": "requestForm",     "question": "URL for import file(s):",     "type": "textarea",     "required": true   },   {     "action": "watcherList",     "question": "Watchers for the ticket:",     "type": "textarea",     "subnote": "Enter the ASURITES for each user you want to watch this ticket. Each ASURITE must be separated with a comma.",     "required": false   } ]';
        // setup a mock response for submission
        createDataImport.mockRejectedValue(createDataImportErrorMock);
        // Report the form as valid
        const validityFunc = () => {
            return true;
        };
        // Verify error is logged to JS console
        global.console = {
            error: jest.fn(),
        };

        // Act
        document.body.appendChild(element);
        // attach mock validity function
        element.shadowRoot.querySelector('c-lightning-question-answer-section').reportValidity = validityFunc;
        // Submit form
        element.test__runFunction('submit', []);
        await flushPromises(); // await response

        // Assert error is shown
        expect(element.test__getField('alert')).toBeTruthy();
        expect(element.test__getField('alert')).toBe(
            'Cannot create JIRA ticket, please email your request to salesforce.development@asu.edu'
        );
        expect(element.test__getField('alertHref')).toBeFalsy();
        // assert the error was logged in the JS console
        expect(global.console.error).toBeCalled();
    });
});

// Helper function to wait until the microtask queue is empty. This is needed for promise
// timing when calling imperative Apex.
async function flushPromises() {
    return Promise.resolve();
}
