/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {AdvisorPortalTest} from 'c/advisorPortalA';
import getUsersAndPods from '@salesforce/apex/AdvisorPortalFilterSectionController.getUsersAndPods';
import {flushPromises} from 'c/helperTestFunctions';
import FilterSetsModal from 'c/filterSetsModal';

jest.mock('c/filterSetsModal');

jest.mock(
    '@salesforce/apex/AdvisorPortalFilterSectionController.getUsersAndPods',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);

describe('c-advisor-portal View filter set', () => {
    // Function to emit values that are consistent across all tests
    // you cannot do this in beforeEach since the emit must happen after the element has
    // been created and added to the document
    const emitCommon = () => {
        getUsersAndPods.emit([
            {label: 'Tommy Nordman', value: 'USER-1'},
            {label: '--My PODs--', value: 'HEADER-XX1'},
            {label: 'Cat Owners', value: 'POD-1'},
            {label: 'Employee', value: 'POD-2'},
        ]);
    };

    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    test('Opens filter set modal', () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        // Fake a response
        FilterSetsModal.open = jest.fn().mockResolvedValueOnce({});

        // Click on view saved filters button
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((v) => v.label === 'View Saved Filters')[0]
            .click();

        // Did open prompt
        expect(FilterSetsModal.open).toHaveBeenCalled();
    });

    test('Views filter values', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);
        emitCommon();

        // Fake a response
        FilterSetsModal.open = jest.fn().mockResolvedValueOnce({
            action: {
                filterSetId: 'FS-1',
                filterSet: {
                    Value__c: '{"career":"GRD", "ownerIds":"USER-1;POD-2"}',
                },
                apply: false,
            },
        });

        // Click on view saved filters button
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((v) => v.label === 'View Saved Filters')[0]
            .click();

        await flushPromises();

        // Applied new filter set
        expect(element.appliedFilterSetId).toEqual('FS-1');

        expect(element.currentFilter).toMatchObject({
            career: 'GRD',
            ownerIds: 'USER-1;POD-2',
        });
    });

    test('DOES NOT apply filter set values', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);
        emitCommon();

        // Fake a response
        FilterSetsModal.open = jest.fn().mockResolvedValueOnce({
            action: {
                filterSetId: 'FS-1',
                filterSet: {
                    Value__c: '{"career":"GRD", "ownerIds":"USER-1;POD-2"}',
                },
                apply: false,
            },
        });

        // Click on view saved filters button
        [...element.shadowRoot.querySelectorAll('lightning-button')]
            .filter((v) => v.label === 'View Saved Filters')[0]
            .click();

        await flushPromises();

        // Did open prompt
        expect(element.appliedFilterSetId).toEqual('FS-1');

        expect(element.appliedFilter ?? {}).not.toMatchObject({
            career: 'GRD',
            ownerIds: 'USER-1;POD-2',
        });
    });
});
