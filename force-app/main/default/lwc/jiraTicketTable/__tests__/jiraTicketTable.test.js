/* eslint-disable no-undef */
import {createElement} from 'lwc';
import JiraTicketTable from 'c/jiraTicketTable';
import {TicketItem} from 'c/jiraTicketTable';

// Tests
describe('c-jira-ticket-table', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('No tickets populated', () => {
        // Arrange
        const element = createElement('c-jira-ticket-table', {
            is: JiraTicketTable,
        });
        // Add attributes
        element.tickets = [];
        element.testFormQuestions = [];
        element.techReviewFormQuestions = [];

        // Act
        document.body.appendChild(element);
        const headerElem = element.shadowRoot.querySelector('[data-testid="header"]');
        const allTicketElems = element.shadowRoot.querySelectorAll('[data-testid="ticket"]');

        // Assert headers but no items
        expect(headerElem).toBeTruthy();
        expect(allTicketElems.length).toBe(0);
    });

    test('3 tickets populated', () => {
        // Arrange
        const element = createElement('c-jira-ticket-table', {
            is: JiraTicketTable,
        });
        // Add attributes
        element.tickets = [
            createTicket('10023', 'SFE-52145', 'Task', 'New Pipeline for crm-academic-terms', 'In Progress'),
            createTicket('10399', 'SFE-52142', 'Epic', 'Move Mulesoft APIs to New Pipeline', 'In Progress'),
            createTicket('10419', 'SDSE-74', 'Task', 'Timestamp for changes in PostgresDB', 'Open'),
        ];
        element.testFormQuestions = [];
        element.techReviewFormQuestions = [];

        // Act
        document.body.appendChild(element);
        const headerElem = element.shadowRoot.querySelector('[data-testid="header"]');
        const allTicketElems = element.shadowRoot.querySelectorAll('[data-testid="ticket"]');

        // Assert headers and 3 items
        expect(headerElem).toBeTruthy();
        expect(allTicketElems.length).toBe(3);
    });
});

// Helper function that creates a TicketItem for the JIRA ticket table
function createTicket(issueId, key, issuetype, summary, status) {
    const ticket = new TicketItem({
        id: issueId,
        key: key,
        fields: {
            issuetype: {
                name: issuetype,
            },
            summary: summary,
            status: {
                name: status,
            },
        },
    });

    return ticket;
}

// Helper function to wait until the microtask queue is empty. This is needed for promise
// timing when calling imperative Apex.
async function flushPromises() {
    return Promise.resolve();
}
