/* eslint-disable no-undef */
import {createElement} from 'lwc';
import JiraAlert from 'c/jiraAlert';

describe('c-jira-alert', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Not visible by default', () => {
        // Arrange
        const element = createElement('c-jira-alert', {
            is: JiraAlert,
        });

        // Act
        document.body.appendChild(element);

        // Assert that div is not rendered (since message is unset)
        expect(element.shadowRoot.querySelector('div')).toBeFalsy();
    });

    test('Not visible is empty', () => {
        // Arrange
        const element = createElement('c-jira-alert', {
            is: JiraAlert,
        });
        element.message = '';

        // Act
        document.body.appendChild(element);

        // Assert that the div is not rendered (since message is empty)
        expect(element.shadowRoot.querySelector('div')).toBeFalsy();
    });

    test('Message visibile if set', () => {
        // Arrange
        const element = createElement('c-jira-alert', {
            is: JiraAlert,
        });
        element.message = 'Hello World!';

        // Act
        document.body.appendChild(element);

        // Assert that the div is rendered (since message is set)
        expect(element.shadowRoot.querySelector('div')).toBeTruthy();
        expect(element.shadowRoot.querySelector('div').innerHTML.includes('Hello World!')).toBe(true);
    });

    test('href not visible by default', () => {
        // Arrange
        const element = createElement('c-jira-alert', {
            is: JiraAlert,
        });
        element.message = 'Hello World!';

        // Act
        document.body.appendChild(element);

        // Assert that the div is rendered (since message is set)
        expect(element.shadowRoot.querySelector('div')).toBeTruthy();
        expect(element.shadowRoot.querySelector('div').innerHTML.includes('Hello World!')).toBeTruthy();
        // Assert that the href is not rendered (since url is unset)
        expect(element.shadowRoot.querySelector('a')).toBeFalsy();
    });

    test('href not visible if empty', () => {
        // Arrange
        const element = createElement('c-jira-alert', {
            is: JiraAlert,
        });
        element.message = 'Hello World!';
        element.url = '';

        // Act
        document.body.appendChild(element);

        // Assert that the div is rendered (since message is set)
        expect(element.shadowRoot.querySelector('div')).toBeTruthy();
        expect(element.shadowRoot.querySelector('div').innerHTML.includes('Hello World!')).toBeTruthy();
        // Assert that the href is not rendered (since url is unset)
        expect(element.shadowRoot.querySelector('a')).toBeFalsy();
    });

    test('href visible if set', () => {
        // Arrange
        const element = createElement('c-jira-alert', {
            is: JiraAlert,
        });
        element.message = 'Hello World!';
        element.url = 'https://asu.edu';

        // Act
        document.body.appendChild(element);

        // Assert that the div is rendered (since message is set)
        expect(element.shadowRoot.querySelector('div')).toBeTruthy();
        expect(element.shadowRoot.querySelector('div').innerHTML.includes('Hello World!')).toBeTruthy();
        // Assert that the href is not rendered (since url is unset)
        expect(element.shadowRoot.querySelector('a')).toBeTruthy();
        expect(element.shadowRoot.querySelector('a').getAttribute('href')).toBe('https://asu.edu');
        expect(element.shadowRoot.querySelector('a').innerHTML.includes('https://asu.edu')).toBeTruthy();
    });
});
