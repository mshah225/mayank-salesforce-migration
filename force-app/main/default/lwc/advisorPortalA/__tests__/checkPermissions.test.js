/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {AdvisorPortalTest} from 'c/advisorPortalA';
import getAccessModes from '@salesforce/apex/AdvisorPortalFilterSectionController.getAccessModes';
import checkIfCanShareFilterSets from '@salesforce/apex/FilterSetController.checkIfCanShare';
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
jest.mock(
    '@salesforce/apex/FilterSetController.checkIfCanShare',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);

describe('c-advisor-portal Check user permissions', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    test('User has both grad and ugrad access', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        getAccessModes.emit(['UGRD', 'GRD']);

        expect(element.userIsBothGradAndUgrad).toEqual(true);
        expect(element.currentFilter.career).toEqual('UGRD');
        expect(element.ugradMode).toEqual(true);
        expect(element.gradMode).toEqual(false);
        expect(element.hasError).toEqual(false);
    });

    test('User has only ugrd access', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        getAccessModes.emit(['UGRD']);

        expect(element.userIsBothGradAndUgrad).toEqual(false);
        expect(element.currentFilter.career).toEqual('UGRD');
        expect(element.ugradMode).toEqual(true);
        expect(element.gradMode).toEqual(false);
        expect(element.hasError).toEqual(false);
    });

    test('User has only grad access', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        getAccessModes.emit(['GRD']);

        expect(element.userIsBothGradAndUgrad).toEqual(false);
        expect(element.currentFilter.career).toEqual('GRD');
        expect(element.ugradMode).toEqual(false);
        expect(element.gradMode).toEqual(true);
        expect(element.hasError).toEqual(false);
    });

    test('User has no grd or ugrd access', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        getAccessModes.emit([]);

        expect(element.userIsBothGradAndUgrad).toEqual(false);
        expect(element.currentFilter.career).toEqual(undefined);
        expect(element.ugradMode).toEqual(false);
        expect(element.gradMode).toEqual(false);
        expect(element.hasError).toEqual(true);
        expect(element.errorMessage).toContain('does not have access');
    });

    test('User can share filter sets', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        checkIfCanShareFilterSets.emit(true);

        expect(element.allowedToShareFilterSets).toEqual(true);
    });

    test('User cannot share filter sets', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        checkIfCanShareFilterSets.emit(false);

        expect(element.allowedToShareFilterSets).toEqual(false);
    });
});
