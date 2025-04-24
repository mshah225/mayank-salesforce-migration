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

let element = null;

describe('c-advisor-portal Change filters', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    beforeEach(async () => {
        element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.showAdditionalFilters = true;
        document.body.appendChild(element);
        getAccessModes.emit(['UGRD', 'GRD']);

        await flushPromises();
    });

    test('Change career', () => {
        element.shadowRoot
            .querySelector('c-lightning-input-radio-group-row')
            .dispatchEvent(new CustomEvent('change', {detail: {name: 'career', value: 'GRD'}}));

        expect(element.currentFilter).toMatchObject({career: 'GRD'});
    });

    test('Change ownerIds', () => {
        element.shadowRoot
            .querySelector('c-advisor-portal-user-select')
            .dispatchEvent(new CustomEvent('changeusers', {detail: {value: 'USER-1;USER-2;POD-4'}}));

        expect(element.currentFilter).toMatchObject({ownerIds: 'USER-1;USER-2;POD-4'});
    });

    test('Change case type state', () => {
        element.shadowRoot
            .querySelector('lightning-radio-group')
            .dispatchEvent(new CustomEvent('change', {detail: {value: 'AllCasesState'}}));

        expect(element.currentFilter).toMatchObject({caseTypeState: 'AllCasesState'});
    });

    test('Change studentString', () => {
        [...element.shadowRoot.querySelectorAll('lightning-input')]
            .filter((elem) => elem.name === 'studentString')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {value: 'Tommy'}}));

        expect(element.currentFilter).toMatchObject({studentString: 'Tommy'});
    });

    test('Change campus', () => {
        [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')]
            .filter((elem) => elem.name === 'campus')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {name: 'campus', value: 'TEMPE;DWTWN'}}));

        expect(element.currentFilter).toMatchObject({campus: 'TEMPE;DWTWN'});
    });

    test('Change academic level', () => {
        [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')]
            .filter((elem) => elem.name === 'academicLevel')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {name: 'academicLevel', value: 'freshman'}}));

        expect(element.currentFilter).toMatchObject({academicLevel: 'freshman'});
    });

    test('Change student group', () => {
        [...element.shadowRoot.querySelectorAll('lightning-input')]
            .filter((elem) => elem.name === 'studentGroupCode')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {value: 'PSPS'}}));

        expect(element.currentFilter).toMatchObject({studentGroupCode: 'PSPS'});
    });

    test('Change major', () => {
        [...element.shadowRoot.querySelectorAll('lightning-input')]
            .filter((elem) => elem.name === 'major')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {value: 'Computer Science'}}));

        expect(element.currentFilter).toMatchObject({major: 'Computer Science'});
    });

    test('Change degree level', async () => {
        element.currentFilter = {career: 'GRD'};
        await flushPromises();

        [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')]
            .filter((elem) => elem.name === 'degreeLevel')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {name: 'degreeLevel', value: 'masters'}}));

        expect(element.currentFilter).toMatchObject({degreeLevel: 'masters'});
    });

    test('Change academic program', async () => {
        element.currentFilter = {career: 'GRD'};
        await flushPromises();

        [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')]
            .filter((elem) => elem.name === 'academicProgram')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {name: 'academicProgram', value: 'COMPSCI'}}));

        expect(element.currentFilter).toMatchObject({academicProgram: 'COMPSCI'});
    });

    test('Change school/department', async () => {
        element.currentFilter = {career: 'GRD'};
        await flushPromises();

        [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')]
            .filter((elem) => elem.name === 'schoolDepartment')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {name: 'schoolDepartment', value: 'FULTON'}}));

        expect(element.currentFilter).toMatchObject({schoolDepartment: 'FULTON'});
    });

    test('Change academic plan', async () => {
        element.currentFilter = {career: 'GRD'};
        await flushPromises();

        [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')]
            .filter((elem) => elem.name === 'academicPlan')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {name: 'academicPlan', value: 'LITANLYSIS'}}));

        expect(element.currentFilter).toMatchObject({academicPlan: 'LITANLYSIS'});
    });

    test('Change residency', () => {
        [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')]
            .filter((elem) => elem.name === 'residency')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {name: 'residency', value: 'INT;NONRES'}}));

        expect(element.currentFilter).toMatchObject({residency: 'INT;NONRES'});
    });

    test('Change case status', () => {
        [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')]
            .filter((elem) => elem.name === 'caseStatus')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {name: 'caseStatus', value: 'INPROG'}}));

        expect(element.currentFilter).toMatchObject({caseStatus: 'INPROG'});
    });

    test('Change case category', () => {
        [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')]
            .filter((elem) => elem.name === 'caseCategory')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {name: 'caseCategory', value: 'FRESHREC'}}));

        expect(element.currentFilter).toMatchObject({caseCategory: 'FRESHREC'});
    });

    test('Change case subcategory', async () => {
        element.currentFilter = {career: 'GRD'};
        await flushPromises();

        [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')]
            .filter((elem) => elem.name === 'caseSubCategory')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {name: 'caseSubCategory', value: 'LIBSTUDY'}}));

        expect(element.currentFilter).toMatchObject({caseSubCategory: 'LIBSTUDY'});
    });

    test('Change special population', async () => {
        element.currentFilter = {career: 'GRD'};
        await flushPromises();

        [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')]
            .filter((elem) => elem.name === 'specialPopulation')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {name: 'specialPopulation', value: 'cintana students'}}));

        expect(element.currentFilter).toMatchObject({specialPopulation: 'cintana students'});
    });

    test('Change case subject', () => {
        [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')]
            .filter((elem) => elem.name === 'caseSubject')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {name: 'caseSubject', value: 'APPLSCI'}}));

        expect(element.currentFilter).toMatchObject({caseSubject: 'APPLSCI'});
    });

    test('Change outlook score', () => {
        [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')]
            .filter((elem) => elem.name === 'outlookScore')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {name: 'outlookScore', value: 'low;very low'}}));

        expect(element.currentFilter).toMatchObject({outlookScore: 'low;very low'});
    });

    test('Change outlook change', () => {
        [...element.shadowRoot.querySelectorAll('c-lightning-combo-box')]
            .filter((elem) => elem.name === 'outlookChange')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {name: 'outlookChange', value: 'up;down'}}));

        expect(element.currentFilter).toMatchObject({outlookChange: 'up;down'});
    });

    test('Change caseCount', () => {
        [...element.shadowRoot.querySelectorAll('lightning-input')]
            .filter((elem) => elem.name === 'caseCount')[0]
            .dispatchEvent(new CustomEvent('commit', {detail: {value: '5'}}));

        expect(element.currentFilter).toMatchObject({caseCount: '5'});
    });

    test('Change created date', () => {
        [...element.shadowRoot.querySelectorAll('c-lightning-input-date-range')]
            .filter((elem) => elem.name === 'createdDateRange')[0]
            .dispatchEvent(
                new CustomEvent('change', {
                    detail: {
                        name: 'createdDateRange',
                        value: {
                            from: '2020-04-04',
                            to: '2020-06-04',
                        },
                    },
                })
            );

        expect(element.currentFilter).toMatchObject({createdFromDate: '2020-04-04', createdToDate: '2020-06-04'});
    });

    test('Change follow up date range', () => {
        [...element.shadowRoot.querySelectorAll('c-lightning-input-date-range')]
            .filter((elem) => elem.name === 'followUpDateRange')[0]
            .dispatchEvent(
                new CustomEvent('change', {
                    detail: {
                        name: 'followUpDateRange',
                        value: {
                            from: '2020-04-04',
                            to: '2020-06-04',
                        },
                    },
                })
            );

        expect(element.currentFilter).toMatchObject({followUpFromDate: '2020-04-04', followUpToDate: '2020-06-04'});
    });

    test('Change persistence change date', () => {
        [...element.shadowRoot.querySelectorAll('c-lightning-input-date-range')]
            .filter((elem) => elem.name === 'persistenceChangeDateRange')[0]
            .dispatchEvent(
                new CustomEvent('change', {
                    detail: {
                        name: 'persistenceChangeDateRange',
                        value: {
                            from: '2020-04-04',
                            to: '2020-06-04',
                        },
                    },
                })
            );

        expect(element.currentFilter).toMatchObject({
            persistenceFromDate: '2020-04-04',
            persistenceToDate: '2020-06-04',
        });
    });
});
