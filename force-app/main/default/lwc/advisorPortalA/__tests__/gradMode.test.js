/* eslint-disable no-undef */
import {createElement} from 'lwc';
import getAccessModes from '@salesforce/apex/AdvisorPortalFilterSectionController.getAccessModes';
import {AdvisorPortalTest} from 'c/advisorPortalA';
import {flushPromises} from 'c/helperTestFunctions';

jest.mock(
    '@salesforce/apex/AdvisorPortalFilterSectionController.getAccessModes',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);

describe('c-advisor-portal grad mode', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    test('Properly sets mode and career', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(element.gradMode).toEqual(true);
        expect(element.currentFilter.career).toEqual('GRD');
    });

    test('Student text box', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('lightning-input')].filter((elem) => elem.label === 'Student †')[0]
        ).toBeTruthy();
    });

    test('Campus dropdown', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')].filter(
                (elem) => elem.label === 'Campus'
            )[0]
        ).toBeTruthy();
    });

    test('Degree Level dropdown', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')].filter(
                (elem) => elem.label === 'Degree Level'
            )[0]
        ).toBeTruthy();
    });

    test('College dropdown', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')].filter(
                (elem) => elem.label === 'College'
            )[0]
        ).toBeTruthy();
    });

    test('School/Department dropdown', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')].filter(
                (elem) => elem.label === 'School/Department'
            )[0]
        ).toBeTruthy();
    });

    test('Academic Plan dropdown', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')].filter(
                (elem) => elem.label === 'Academic Plan'
            )[0]
        ).toBeTruthy();
    });

    test('Admit Term Range', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('.slds-form-element__label')].filter(
                (elem) => elem.textContent === 'Admit Term'
            )[0]
        ).toBeTruthy();
    });

    test('Academic Level dropdown', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')].filter(
                (elem) => elem.label === 'Academic Level'
            )[0]
        ).toBeFalsy();
    });

    test('Student Group text box', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('lightning-input')].filter(
                (elem) => elem.label === 'Student Group'
            )[0]
        ).toBeFalsy();
    });

    test('Major text box', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('lightning-input')].filter((elem) => elem.label === 'Major')[0]
        ).toBeFalsy();
    });

    test('Residency dropdown', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')].filter(
                (elem) => elem.label === 'Residency'
            )[0]
        ).toBeTruthy();
    });

    test('Case Status dropdown', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')].filter(
                (elem) => elem.label === 'Case Status'
            )[0]
        ).toBeTruthy();
    });

    test('Case Category dropdown', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')].filter(
                (elem) => elem.label === 'Case Category'
            )[0]
        ).toBeTruthy();
    });

    test('Case Sub-Category dropdown', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')].filter(
                (elem) => elem.label === 'Case Sub-Category'
            )[0]
        ).toBeTruthy();
    });

    test('Special Population dropdown', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')].filter(
                (elem) => elem.label === 'Special Population'
            )[0]
        ).toBeTruthy();
    });

    test('Case Subject dropdown', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')].filter(
                (elem) => elem.label === 'Case Subject'
            )[0]
        ).toBeFalsy();
    });

    test('Outlook Score dropdown', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')].filter(
                (elem) => elem.label === 'Outlook Score'
            )[0]
        ).toBeFalsy();
    });

    test('Outlook Change dropdown', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')].filter(
                (elem) => elem.label === 'Outlook Change'
            )[0]
        ).toBeFalsy();
    });

    test('Case Count text box', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('lightning-input')].filter((elem) => elem.label === 'Case Count')[0]
        ).toBeTruthy();
    });

    test('Created Date date range', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-input-date-range')].filter(
                (elem) => elem.label === 'Created Date'
            )[0]
        ).toBeTruthy();
    });

    test('Follow Up Date date range', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-input-date-range')].filter(
                (elem) => elem.label === 'Follow Up Date'
            )[0]
        ).toBeTruthy();
    });

    test('Persistence Change Date date range', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['GRD']);
        await flushPromises();

        expect(
            [...element.shadowRoot.querySelectorAll('c-lightning-input-date-range')].filter(
                (elem) => elem.label === 'Persistence Change Date'
            )[0]
        ).toBeFalsy();
    });
});
