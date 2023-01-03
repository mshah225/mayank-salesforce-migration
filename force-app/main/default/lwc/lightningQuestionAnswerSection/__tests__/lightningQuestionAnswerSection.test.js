/* eslint-disable no-undef */
import {createElement} from 'lwc';
import LightningQuestionAnswerSection from 'c/lightningQuestionAnswerSection';
import {cloneObj} from 'c/helperFunctions';

describe('c-lightning-question-answer-section', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Simple labels', async () => {
        // Arrange
        const element = createElement('c-lightning-question-answer-section', {
            is: LightningQuestionAnswerSection,
        });

        element.questions = [
            {key: 'BOLD', question: 'Hearts', type: 'label', subtype: 'bold'},
            {key: 'PLAIN', question: 'Spades', type: 'label', subtype: 'plain'},
            {key: 'LINK', question: 'Clubs', type: 'label', subtype: 'link', href: 'https://asu.edu/'},
            {key: 'CENTER', question: 'Diamonds', type: 'label', subtype: 'center'},
            {key: 'DEFAULT', question: 'Jokers', type: 'label'},
        ];

        // Act
        document.body.appendChild(element);

        // Default values check
        const allQuestionElems = element.shadowRoot.querySelectorAll('[data-testid="question"]');

        // bold label
        expect(allQuestionElems[0].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe('b');
        // plain label
        expect(allQuestionElems[1].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe('span');
        // link label
        expect(allQuestionElems[2].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe('a');
        expect(allQuestionElems[2].querySelector('[data-testid="body"]').href).toBe('https://asu.edu/');
        // centered label
        expect(allQuestionElems[3].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe('div');
        expect(allQuestionElems[3].querySelector('[data-testid="body"]').classList).toContain('slds-text-align_center');
        // plain label
        expect(allQuestionElems[4].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe('span');
    });

    test('Text questions', async () => {
        // Arrange
        const element = createElement('c-lightning-question-answer-section', {
            is: LightningQuestionAnswerSection,
        });

        element.questions = [
            {key: 'NONREQUIRED', question: 'Nonrequired text question', type: 'text', required: false},
            {key: 'REQUIRED', question: 'Required text question', type: 'text', required: true},
            {key: 'DEFAULT', question: 'Default text question', type: 'text'},
        ];

        // Act
        document.body.appendChild(element);
        const allQuestionElems = element.shadowRoot.querySelectorAll('[data-testid="question"]');

        // non-required question
        expect(allQuestionElems[0].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe(
            'lightning-input'
        );
        expect(allQuestionElems[0].querySelector('[data-testid="body"]').type).toBe('text');
        expect(allQuestionElems[0].querySelector('[data-testid="body"]').required).toBeFalsy();

        // required question
        expect(allQuestionElems[1].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe(
            'lightning-input'
        );
        expect(allQuestionElems[1].querySelector('[data-testid="body"]').type).toBe('text');
        expect(allQuestionElems[1].querySelector('[data-testid="body"]').required).toBeTruthy();

        // default question
        expect(allQuestionElems[2].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe(
            'lightning-input'
        );
        expect(allQuestionElems[2].querySelector('[data-testid="body"]').type).toBe('text');
        expect(allQuestionElems[2].querySelector('[data-testid="body"]').required).toBeFalsy();
    });

    test('Textarea questions', async () => {
        // Arrange
        const element = createElement('c-lightning-question-answer-section', {
            is: LightningQuestionAnswerSection,
        });

        element.questions = [
            {key: 'NONREQUIRED', question: 'Nonrequired textarea question', type: 'textarea', required: false},
            {key: 'REQUIRED', question: 'Required textarea question', type: 'textarea', required: true},
            {key: 'DEFAULT', question: 'Default textarea question', type: 'textarea'},
        ];

        // Act
        document.body.appendChild(element);
        const allQuestionElems = element.shadowRoot.querySelectorAll('[data-testid="question"]');

        // non-required question
        expect(allQuestionElems[0].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe(
            'lightning-textarea'
        );
        expect(allQuestionElems[0].querySelector('[data-testid="body"]').required).toBeFalsy();

        // required question
        expect(allQuestionElems[1].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe(
            'lightning-textarea'
        );
        expect(allQuestionElems[1].querySelector('[data-testid="body"]').required).toBeTruthy();

        // default question
        expect(allQuestionElems[2].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe(
            'lightning-textarea'
        );
        expect(allQuestionElems[2].querySelector('[data-testid="body"]').required).toBeFalsy();
    });

    test('Combobox questions', async () => {
        // Arrange
        const element = createElement('c-lightning-question-answer-section', {
            is: LightningQuestionAnswerSection,
        });

        element.questions = [
            {
                key: 'MULTI',
                question: 'Citizenship',
                type: 'combobox',
                subtype: 'multi',
                options: [
                    {label: 'United States', value: 'US'},
                    {label: 'Canada', value: 'CA'},
                ],
            },
            {
                key: 'NONREQUIRED',
                question: 'State',
                type: 'combobox',
                required: false,
                options: [
                    {label: 'Ohio', value: 'OH'},
                    {label: 'Michigan', value: 'MI'},
                    {label: 'Arizona', value: 'AZ'},
                ],
            },
            {
                key: 'REQUIRED',
                question: 'Country',
                type: 'combobox',
                required: true,
                options: [
                    {label: 'United States', value: 'US'},
                    {label: 'Canada', value: 'CA'},
                ],
            },
            {
                key: 'DEFAULT',
                question: 'State',
                type: 'combobox',
                options: [
                    {label: 'Ohio', value: 'OH'},
                    {label: 'Michigan', value: 'MI'},
                    {label: 'Arizona', value: 'AZ'},
                ],
            },
        ];

        // Act
        document.body.appendChild(element);
        const allQuestionElems = element.shadowRoot.querySelectorAll('[data-testid="question"]');

        // Multiselect combobox
        expect(allQuestionElems[0].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe(
            'c-lightning-combo-box'
        );
        expect(allQuestionElems[0].querySelector('[data-testid="body"]').required).toBeFalsy();
        expect(allQuestionElems[0].querySelector('[data-testid="body"]').multiSelect).toBeTruthy();

        // non-required question
        expect(allQuestionElems[1].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe(
            'c-lightning-combo-box'
        );
        expect(allQuestionElems[1].querySelector('[data-testid="body"]').required).toBeFalsy();
        expect(allQuestionElems[1].querySelector('[data-testid="body"]').multiSelect).toBeFalsy();

        // required question
        expect(allQuestionElems[2].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe(
            'c-lightning-combo-box'
        );
        expect(allQuestionElems[2].querySelector('[data-testid="body"]').required).toBeTruthy();
        expect(allQuestionElems[2].querySelector('[data-testid="body"]').multiSelect).toBeFalsy();

        // default question
        expect(allQuestionElems[3].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe(
            'c-lightning-combo-box'
        );
        expect(allQuestionElems[3].querySelector('[data-testid="body"]').required).toBeFalsy();
        expect(allQuestionElems[3].querySelector('[data-testid="body"]').multiSelect).toBeFalsy();
    });

    test('Dual Listbox questions', async () => {
        // Arrange
        const element = createElement('c-lightning-question-answer-section', {
            is: LightningQuestionAnswerSection,
        });

        element.questions = [
            {
                key: 'DEFAULT',
                question: 'State',
                type: 'dual-listbox',
                sourceLabel: 'No',
                selectedLabel: 'Yes',
                options: [
                    {label: 'Ohio', value: 'OH'},
                    {label: 'Michigan', value: 'MI'},
                    {label: 'Arizona', value: 'AZ'},
                ],
            },
            {
                key: 'NONREQUIRED',
                question: 'State',
                type: 'dual-listbox',
                sourceLabel: 'No',
                selectedLabel: 'Yes',
                required: false,
                options: [
                    {label: 'Ohio', value: 'OH'},
                    {label: 'Michigan', value: 'MI'},
                    {label: 'Arizona', value: 'AZ'},
                ],
            },
            {
                key: 'REQUIRED',
                question: 'Country',
                type: 'dual-listbox',
                sourceLabel: 'No',
                selectedLabel: 'Yes',
                required: true,
                options: [
                    {label: 'United States', value: 'US'},
                    {label: 'Canada', value: 'CA'},
                ],
            },
        ];

        // Act
        document.body.appendChild(element);
        const allQuestionElems = element.shadowRoot.querySelectorAll('[data-testid="question"]');

        // default dual listbox
        expect(allQuestionElems[0].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe(
            'lightning-dual-listbox'
        );
        expect(allQuestionElems[0].querySelector('[data-testid="body"]').required).toBeFalsy();

        // non-required dual listbox
        expect(allQuestionElems[1].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe(
            'lightning-dual-listbox'
        );
        expect(allQuestionElems[1].querySelector('[data-testid="body"]').required).toBeFalsy();

        // required dual listbox
        expect(allQuestionElems[2].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe(
            'lightning-dual-listbox'
        );
        expect(allQuestionElems[2].querySelector('[data-testid="body"]').required).toBeTruthy();
    });

    test('Add subnote', async () => {
        // Arrange
        const element = createElement('c-lightning-question-answer-section', {
            is: LightningQuestionAnswerSection,
        });

        element.questions = [
            {
                key: 'MULTI',
                question: 'Citizenship',
                type: 'dual-listbox',
                subtype: 'multi',
                sourceLabel: 'No',
                selectedLabel: 'Yes',
                options: [
                    {label: 'United States', value: 'US'},
                    {label: 'Canada', value: 'CA'},
                ],
                subnote: 'Only select one!',
            },
        ];

        // Act
        document.body.appendChild(element);

        // Default values check
        const allQuestionElems = element.shadowRoot.querySelectorAll('[data-testid="question"]');

        // Multiselect combobox
        expect(allQuestionElems[0].querySelector('[data-testid="body"]').nodeName.toLowerCase()).toBe(
            'lightning-dual-listbox'
        );
        expect(allQuestionElems[0].querySelector('[data-testid="body"]').required).toBeFalsy();
        expect(allQuestionElems[0].querySelector('[data-testid="subnote"]').innerHTML).toBe('Only select one!');
    });

    test('Report validity', async () => {
        // Arrange
        const element = createElement('c-lightning-question-answer-section', {
            is: LightningQuestionAnswerSection,
        });

        element.questions = [
            {
                key: 'NONREQUIRED',
                question: 'Nonrequired text question',
                type: 'combobox',
                options: [
                    {label: 'United States', value: 'US'},
                    {label: 'Canada', value: 'CA'},
                ],
                required: false,
            },
            {
                key: 'REQUIRED-1',
                question: 'Required text question',
                type: 'combobox',
                options: [
                    {label: 'United States', value: 'US'},
                    {label: 'Canada', value: 'CA'},
                ],
                required: true,
            },
            {
                key: 'REQUIRED-2',
                question: 'Required text question',
                type: 'combobox',
                options: [
                    {label: 'United States', value: 'US'},
                    {label: 'Canada', value: 'CA'},
                ],
                required: true,
            },
            {
                key: 'DEFAULT',
                question: 'Default text question',
                type: 'combobox',
                options: [
                    {label: 'United States', value: 'US'},
                    {label: 'Canada', value: 'CA'},
                ],
            },
        ];

        // Act
        document.body.appendChild(element);

        // Should be invalid - since required field is not completed
        expect(element.reportValidity()).toBeFalsy();

        // Fill in an answer - should still be invalid
        element.questions[1].answer = 'CA';
        element.questions = cloneObj(element.questions);
        await flushPromises(); // await promises
        expect(element.reportValidity()).toBeFalsy();

        // Fill in answer - now should be valid
        element.questions[2].answer = 'CA';
        element.questions = cloneObj(element.questions);
        await flushPromises(); // await promises
        expect(element.reportValidity()).toBeTruthy();
    });

    test('Clear all', async () => {
        // Arrange
        const element = createElement('c-lightning-question-answer-section', {
            is: LightningQuestionAnswerSection,
        });

        element.questions = [
            {
                key: 'NONREQUIRED',
                question: 'Nonrequired text question',
                type: 'combobox',
                answer: 'CA',
                options: [
                    {label: 'United States', value: 'US'},
                    {label: 'Canada', value: 'CA'},
                ],
                required: false,
            },
            {
                key: 'REQUIRED-1',
                question: 'Required text question',
                type: 'combobox',
                answer: 'US',
                options: [
                    {label: 'United States', value: 'US'},
                    {label: 'Canada', value: 'CA'},
                ],
                required: true,
            },
            {
                key: 'REQUIRED-2',
                question: 'Required text question',
                type: 'combobox',
                answer: 'CA',
                options: [
                    {label: 'United States', value: 'US'},
                    {label: 'Canada', value: 'CA'},
                ],
                required: true,
            },
        ];

        // Act
        document.body.appendChild(element);

        // All questions have an answer
        expect(element.questions[0].answer).toBeTruthy();
        expect(element.questions[1].answer).toBeTruthy();
        expect(element.questions[2].answer).toBeTruthy();

        // Clear all answers
        element.clearAll();

        // All questions have no answer now
        expect(element.questions[0].answer).toBeFalsy();
        expect(element.questions[1].answer).toBeFalsy();
        expect(element.questions[2].answer).toBeFalsy();
    });
});

// Helper function to wait until the microtask queue is empty. This is needed for promise
// timing when calling imperative Apex or when awaiting a render cycle.
async function flushPromises() {
    return Promise.resolve();
}
