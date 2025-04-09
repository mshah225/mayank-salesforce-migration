/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {AdvisorPortalTest} from 'c/advisorPortalA';
import getUsersAndPods from '@salesforce/apex/AdvisorPortalFilterSectionController.getUsersAndPods';
import getPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getPicklistValues';
import getCampusValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCampusValues';
import getAcademicProgramPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getAcademicProgramPicklistValues';
import getSchoolDepartmentPicklistVaues from '@salesforce/apex/AdvisorPortalFilterSectionController.getSchoolDepartmentPicklistVaues';
import getAcademicPlanPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getAcademicPlanPicklistValues';
import getCaseStatusSettings from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseStatusSettings';
import getCaseClassificationPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseClassificationPicklistValues';
import getCaseSubClassificationPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseSubClassificationPicklistValues';
import getCaseSubjectPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseSubjectPicklistValues';
import {flushPromises} from 'c/helperTestFunctions';

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
jest.mock(
    '@salesforce/apex/AdvisorPortalFilterSectionController.getPicklistValues',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/AdvisorPortalFilterSectionController.getCampusValues',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/AdvisorPortalFilterSectionController.getAcademicProgramPicklistValues',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/AdvisorPortalFilterSectionController.getSchoolDepartmentPicklistVaues',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/AdvisorPortalFilterSectionController.getAcademicPlanPicklistValues',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseStatusSettings',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseClassificationPicklistValues',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseSubClassificationPicklistValues',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseSubjectPicklistValues',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);

describe('c-advisor-portal Load dropdown options', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    test('Load user options', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        getUsersAndPods.emit([
            {label: 'Tommy Nordman', value: '001'},
            {label: '--My PODs--', value: '00x'},
            {label: 'Cat Owners', value: '002'},
            {label: 'Employee', value: '003'},
        ]);

        // Called with career
        expect(element.allUsersAndPods).toMatchObject([
            {label: 'Tommy Nordman', value: '001'},
            {label: 'My PODs', value: '00x', isLabel: true},
            {label: 'Cat Owners', value: '002'},
            {label: 'Employee', value: '003'},
        ]);
    });

    test('Reload user options based on career', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        expect(element.loadingUsersAndPodOptions).toEqual(true); // Start loading
        getUsersAndPods.emit([]);
        await flushPromises();
        expect(element.loadingUsersAndPodOptions).toEqual(false); // Done loading

        // Change career to GRD
        element.currentFilter = {career: 'GRD'};
        expect(element.loadingUsersAndPodOptions).toEqual(true); // Now loading
        getUsersAndPods.emit([]);
        await flushPromises();
        expect(JSON.parse(getUsersAndPods.getLastConfig().filterJSON ?? '{}')).toMatchObject({career: 'GRD'}); // Called with config
        expect(element.loadingUsersAndPodOptions).toEqual(false); // Done loading

        // Change career to UGRD
        element.currentFilter = {career: 'UGRD'};
        expect(element.loadingUsersAndPodOptions).toEqual(true); // Now loading
        getUsersAndPods.emit([]);
        await flushPromises();
        expect(JSON.parse(getUsersAndPods.getLastConfig().filterJSON ?? '{}')).toMatchObject({career: 'UGRD'}); // Called with config
        expect(element.loadingUsersAndPodOptions).toEqual(false); // Done loading
    });

    test('Load campuses', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        getCampusValues.emit([
            {label: 'Tempe', value: 'TMPE'},
            {label: 'Downtown Phoenix', value: 'DWTN'},
            {label: 'Online', value: 'ONLNE'},
        ]);

        // Called with career
        expect(element.campusOptions).toMatchObject([
            {label: 'Tempe', value: 'TMPE'},
            {label: 'Downtown Phoenix', value: 'DWTN'},
            {label: 'Online', value: 'ONLNE'},
        ]);
    });

    test('Reload campuses based on career', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        expect(element.loadingCampusOptions).toEqual(true); // Start loading
        getCampusValues.emit([]);
        await flushPromises();
        expect(element.loadingCampusOptions).toEqual(false); // Done loading

        // Change career to GRD
        element.currentFilter = {career: 'GRD'};
        expect(element.loadingCampusOptions).toEqual(true); // Now loading
        getCampusValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getCampusValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({career: 'GRD'});
        expect(element.loadingCampusOptions).toEqual(false); // Done loading

        // Change career to UGRD
        element.currentFilter = {career: 'UGRD'};
        expect(element.loadingCampusOptions).toEqual(true); // Now loading
        getCampusValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getCampusValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({career: 'UGRD'});
        expect(element.loadingCampusOptions).toEqual(false); // Done loading
    });

    test('Load academic programs', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        // Start loading
        expect(element.loadingAcadProgramOptions).toEqual(true);

        // Emit response
        getAcademicProgramPicklistValues.emit([
            {label: 'Computer Science', value: 'COMPSCI'},
            {label: 'World History', value: 'WHIST'},
            {label: 'Literary Analysis', value: 'LITANY'},
        ]);

        // Done loading
        expect(element.loadingAcadProgramOptions).toEqual(false);

        // Called with career
        expect(element.academicProgramOptions).toMatchObject([
            {label: 'Computer Science', value: 'COMPSCI'},
            {label: 'World History', value: 'WHIST'},
            {label: 'Literary Analysis', value: 'LITANY'},
        ]);
    });

    test('Load school/department', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        getSchoolDepartmentPicklistVaues.emit([
            {label: 'Fulton', value: 'FULTON'},
            {label: 'WP Carey', value: 'WPC'},
            {label: 'Walter Cronkite', value: 'CRONKITE'},
        ]);

        // Called with career
        expect(element.schoolDepartmentOptions).toMatchObject([
            {label: 'Fulton', value: 'FULTON'},
            {label: 'WP Carey', value: 'WPC'},
            {label: 'Walter Cronkite', value: 'CRONKITE'},
        ]);
    });

    test('Reload school/department based on program', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        // Fill in options for controlling picklists
        getAcademicProgramPicklistValues.emit([
            {label: 'Computer Science', value: 'COMPSCI'},
            {label: 'World History', value: 'WHIST'},
            {label: 'Literary Analysis', value: 'LITANY'},
        ]);

        expect(element.loadingSchoolDepartmentOptions).toEqual(true); // Start loading
        getSchoolDepartmentPicklistVaues.emit([]);
        await flushPromises();
        expect(element.loadingSchoolDepartmentOptions).toEqual(false); // Done loading

        // Called with program COMPSCI
        element.currentFilter = {academicProgram: 'COMPSCI'};
        expect(element.loadingSchoolDepartmentOptions).toEqual(true); // Now loading
        getSchoolDepartmentPicklistVaues.emit([]);
        await flushPromises();
        expect(JSON.parse(getSchoolDepartmentPicklistVaues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            academicProgram: 'COMPSCI',
        });
        expect(element.loadingSchoolDepartmentOptions).toEqual(false); // Done loading

        // Called with program LITANY
        element.currentFilter = {academicProgram: 'LITANY'};
        expect(element.loadingSchoolDepartmentOptions).toEqual(true); // Now loading
        getSchoolDepartmentPicklistVaues.emit([]);
        await flushPromises();
        expect(JSON.parse(getSchoolDepartmentPicklistVaues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            academicProgram: 'LITANY',
        });
        expect(element.loadingSchoolDepartmentOptions).toEqual(false); // Done loading
    });

    test('Load academic plans', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        getAcademicPlanPicklistValues.emit([
            {label: 'Todays Internet Age', value: 'TIA'},
            {label: 'Small Business Admin', value: 'SMALLBUS'},
            {label: 'Politics of Europe', value: 'POLEUR'},
        ]);

        // Called with career
        expect(element.academicPlanOptions).toMatchObject([
            {label: 'Todays Internet Age', value: 'TIA'},
            {label: 'Small Business Admin', value: 'SMALLBUS'},
            {label: 'Politics of Europe', value: 'POLEUR'},
        ]);
    });

    test('Reload academic plans based on degree level, academic program, and school/department', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        // Fill in options for controlling picklists
        getAcademicProgramPicklistValues.emit([
            {label: 'Computer Science', value: 'COMPSCI'},
            {label: 'World History', value: 'WHIST'},
            {label: 'Literary Analysis', value: 'LITANY'},
        ]);
        getSchoolDepartmentPicklistVaues.emit([
            {label: 'Fulton', value: 'FULTON'},
            {label: 'WP Carey', value: 'WPC'},
            {label: 'Walter Cronkite', value: 'CRONKITE'},
        ]);

        expect(element.loadingAcadPlanOptions).toEqual(true); // Start loading
        getAcademicPlanPicklistValues.emit([]);
        await flushPromises();
        expect(element.loadingAcadPlanOptions).toEqual(false); // Done loading

        // Called with program COMPSCI
        element.currentFilter = {academicProgram: 'COMPSCI'};
        expect(element.loadingAcadPlanOptions).toEqual(true); // Now loading
        getAcademicPlanPicklistValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getAcademicPlanPicklistValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            academicProgram: 'COMPSCI',
        });
        expect(element.loadingAcadPlanOptions).toEqual(false); // Done loading

        // Called with degree level masters
        element.currentFilter = {degreeLevel: 'masters'};
        expect(element.loadingAcadPlanOptions).toEqual(true); // Now loading
        getAcademicPlanPicklistValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getAcademicPlanPicklistValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            degreeLevel: 'masters',
        });
        expect(element.loadingAcadPlanOptions).toEqual(false); // Done loading

        // Called with school/department CRONKITE
        element.currentFilter = {schoolDepartment: 'CRONKITE'};
        expect(element.loadingAcadPlanOptions).toEqual(true); // Now loading
        getAcademicPlanPicklistValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getAcademicPlanPicklistValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            schoolDepartment: 'CRONKITE',
        });
        expect(element.loadingAcadPlanOptions).toEqual(false); // Done loading

        // Called with degree level masters, program COMPSCI, and school/department CRONKITE
        element.currentFilter = {degreeLevel: 'masters', academicProgram: 'COMPSCI', schoolDepartment: 'CRONKITE'};
        expect(element.loadingAcadPlanOptions).toEqual(true); // Now loading
        getAcademicPlanPicklistValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getAcademicPlanPicklistValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            degreeLevel: 'masters',
            academicProgram: 'COMPSCI',
            schoolDepartment: 'CRONKITE',
        });
        expect(element.loadingAcadPlanOptions).toEqual(false); // Done loading
    });

    test('Load residency options', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        // Start loading
        expect(element.loadingResidencyOptions).toEqual(true);

        // Emit response
        getPicklistValues.emit([
            {label: 'International', value: 'INT'},
            {label: 'Resident', value: 'AZ'},
            {label: 'Non-Resident', value: 'US'},
        ]);

        // Done loading
        expect(element.loadingResidencyOptions).toEqual(false);

        // Called with career
        expect(element.residencyOptions).toMatchObject([
            {label: 'International', value: 'INT'},
            {label: 'Resident', value: 'AZ'},
            {label: 'Non-Resident', value: 'US'},
        ]);
    });

    test('Load case status options', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        // Start loading
        expect(element.loadingCaseStatusOptions).toEqual(true);

        // Emit response
        getCaseStatusSettings.emit([
            {label: 'Email Sent', value: 'RW1haWwgU2VudA=='},
            {label: 'In Progress', value: 'SW4gUHJvZ3Jlc3M='},
            {label: 'Customer Replied', value: 'Q3VzdG9tZXIgUmVwbGllZA=='},
        ]);

        // Done loading
        expect(element.loadingCaseStatusOptions).toEqual(false);

        // Called with career
        expect(element.caseStatusOptions).toMatchObject([
            {label: 'Email Sent', value: 'RW1haWwgU2VudA=='},
            {label: 'In Progress', value: 'SW4gUHJvZ3Jlc3M='},
            {label: 'Customer Replied', value: 'Q3VzdG9tZXIgUmVwbGllZA=='},
        ]);
    });

    test('Load case classifications', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        getCaseClassificationPicklistValues.emit([
            {label: 'Freshman Recruitment', value: 'FRESHREC'},
            {label: 'Recruitment Operations', value: 'RECOP'},
            {label: 'Web Forms', value: 'WEBFORM'},
        ]);

        // Called with career
        expect(element.caseCategoryOptions).toMatchObject([
            {label: 'Freshman Recruitment', value: 'FRESHREC'},
            {label: 'Recruitment Operations', value: 'RECOP'},
            {label: 'Web Forms', value: 'WEBFORM'},
        ]);
    });

    test('Reload case classifications based on career and ownerIds', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        // Fill in options for controlling picklists
        getUsersAndPods.emit([
            {label: 'Tommy Nordman', value: '001'},
            {label: '--My PODs--', value: '00x'},
            {label: 'Cat Owners', value: '002'},
            {label: 'Employee', value: '003'},
        ]);

        expect(element.loadingCaseCategoryOptions).toEqual(true); // Start loading
        getCaseClassificationPicklistValues.emit([]);
        await flushPromises();
        expect(element.loadingCaseCategoryOptions).toEqual(false); // Done loading

        // Called with career UGRD
        element.currentFilter = {career: 'UGRD'};
        expect(element.loadingCaseCategoryOptions).toEqual(true); // Now loading
        getCaseClassificationPicklistValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getCaseClassificationPicklistValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            career: 'UGRD',
        });
        expect(element.loadingCaseCategoryOptions).toEqual(false); // Done loading

        // Called with ownerIds
        element.currentFilter = {ownerIds: '001;003'};
        expect(element.loadingCaseCategoryOptions).toEqual(true); // Now loading
        getCaseClassificationPicklistValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getCaseClassificationPicklistValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            ownerIds: '001;003',
        });
        expect(element.loadingCaseCategoryOptions).toEqual(false); // Done loading

        // Called with career and ownerIds
        element.currentFilter = {career: 'GRD', ownerIds: '001;002'};
        expect(element.loadingCaseCategoryOptions).toEqual(true); // Now loading
        getCaseClassificationPicklistValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getCaseClassificationPicklistValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            career: 'GRD',
            ownerIds: '001;002',
        });
        expect(element.loadingCaseCategoryOptions).toEqual(false); // Done loading
    });

    test('Load case subclassifications', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        getCaseSubClassificationPicklistValues.emit([
            {label: 'Applied Science', value: 'APPLSCI'},
            {label: 'Liberal Studies', value: 'LIBSTUDY'},
            {label: 'Health Sciences (BS)', value: 'HEALTHSCI'},
        ]);

        // Called with career
        expect(element.caseSubCategoryOptions).toMatchObject([
            {label: 'Applied Science', value: 'APPLSCI'},
            {label: 'Liberal Studies', value: 'LIBSTUDY'},
            {label: 'Health Sciences (BS)', value: 'HEALTHSCI'},
        ]);
    });

    test('Reload case subclassifications based on career, ownerIds, and case classifications', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        // Fill in options for controlling picklists
        getUsersAndPods.emit([
            {label: 'Tommy Nordman', value: '001'},
            {label: '--My PODs--', value: '00x'},
            {label: 'Cat Owners', value: '002'},
            {label: 'Employee', value: '003'},
        ]);
        getCaseClassificationPicklistValues.emit([
            {label: 'Freshman Recruitment', value: 'FRESHREC'},
            {label: 'Recruitment Operations', value: 'RECOP'},
            {label: 'Web Forms', value: 'WEBFORM'},
        ]);

        expect(element.loadingCaseSubCategoryOptions).toEqual(true); // Start loading
        getCaseSubClassificationPicklistValues.emit([]);
        await flushPromises();
        expect(element.loadingCaseSubCategoryOptions).toEqual(false); // Done loading

        // Called with career UGRD
        element.currentFilter = {career: 'UGRD'};
        expect(element.loadingCaseSubCategoryOptions).toEqual(true); // Now loading
        getCaseSubClassificationPicklistValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getCaseSubClassificationPicklistValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            career: 'UGRD',
        });
        expect(element.loadingCaseSubCategoryOptions).toEqual(false); // Done loading

        // Called with ownerIds
        element.currentFilter = {ownerIds: '001;003'};
        expect(element.loadingCaseSubCategoryOptions).toEqual(true); // Now loading
        getCaseSubClassificationPicklistValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getCaseSubClassificationPicklistValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            ownerIds: '001;003',
        });
        expect(element.loadingCaseSubCategoryOptions).toEqual(false); // Done loading

        // Called with case category
        element.currentFilter = {caseCategory: 'WEBFORM'};
        expect(element.loadingCaseSubCategoryOptions).toEqual(true); // Now loading
        getCaseSubClassificationPicklistValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getCaseSubClassificationPicklistValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            caseCategory: 'WEBFORM',
        });
        expect(element.loadingCaseSubCategoryOptions).toEqual(false); // Done loading

        // Called with career, ownerIds, and case category
        element.currentFilter = {career: 'GRD', ownerIds: '001;002', caseCategory: 'WEBFORM'};
        expect(element.loadingCaseSubCategoryOptions).toEqual(true); // Now loading
        getCaseSubClassificationPicklistValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getCaseSubClassificationPicklistValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            career: 'GRD',
            ownerIds: '001;002',
            caseCategory: 'WEBFORM',
        });
        expect(element.loadingCaseSubCategoryOptions).toEqual(false); // Done loading
    });

    test('Load case subjects', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        getCaseSubjectPicklistValues.emit([
            {label: 'Award Status', value: 'APPLSCI'},
            {label: 'Schedule Change', value: 'LIBSTUDY'},
            {label: 'Advising Follow Up', value: 'HEALTHSCI'},
        ]);

        // Called with career
        expect(element.caseSubjectOptions).toMatchObject([
            {label: 'Award Status', value: 'APPLSCI'},
            {label: 'Schedule Change', value: 'LIBSTUDY'},
            {label: 'Advising Follow Up', value: 'HEALTHSCI'},
        ]);
    });

    test('Reload case subjects based on career and ownerIds', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        document.body.appendChild(element);

        // Fill in options for controlling picklists
        getUsersAndPods.emit([
            {label: 'Tommy Nordman', value: '001'},
            {label: '--My PODs--', value: '00x'},
            {label: 'Cat Owners', value: '002'},
            {label: 'Employee', value: '003'},
        ]);
        getCaseClassificationPicklistValues.emit([
            {label: 'Freshman Recruitment', value: 'FRESHREC'},
            {label: 'Recruitment Operations', value: 'RECOP'},
            {label: 'Web Forms', value: 'WEBFORM'},
        ]);

        expect(element.loadingCaseSubjectOptions).toEqual(true); // Start loading
        getCaseSubjectPicklistValues.emit([]);
        await flushPromises();
        expect(element.loadingCaseSubjectOptions).toEqual(false); // Done loading

        // Called with career UGRD
        element.currentFilter = {career: 'UGRD'};
        expect(element.loadingCaseSubjectOptions).toEqual(true); // Now loading
        getCaseSubjectPicklistValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getCaseSubjectPicklistValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            career: 'UGRD',
        });
        expect(element.loadingCaseSubjectOptions).toEqual(false); // Done loading

        // Called with ownerIds
        element.currentFilter = {ownerIds: '001;003'};
        expect(element.loadingCaseSubjectOptions).toEqual(true); // Now loading
        getCaseSubjectPicklistValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getCaseSubjectPicklistValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            ownerIds: '001;003',
        });
        expect(element.loadingCaseSubjectOptions).toEqual(false); // Done loading

        // Called with career and ownerIds
        element.currentFilter = {career: 'GRD', ownerIds: '001;002'};
        expect(element.loadingCaseSubjectOptions).toEqual(true); // Now loading
        getCaseSubjectPicklistValues.emit([]);
        await flushPromises();
        expect(JSON.parse(getCaseSubjectPicklistValues.getLastConfig().filterJSON ?? '{}')).toMatchObject({
            career: 'GRD',
            ownerIds: '001;002',
        });
        expect(element.loadingCaseSubjectOptions).toEqual(false); // Done loading
    });
});
