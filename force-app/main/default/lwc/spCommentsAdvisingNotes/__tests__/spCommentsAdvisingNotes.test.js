import {createElement} from 'lwc';
import {SpCommentsAdvisingNotesTest} from 'c/spCommentsAdvisingNotes';
import getPSAdvisorNotes from '@salesforce/apex/StudentProfileController.getPSAdvisorNotesLWC';
import {flushPromises} from 'c/helperTestFunctions';
import {refreshApex} from '@salesforce/apex';
import {getNavigateCalledWith} from 'lightning/navigation';

jest.mock(
    '@salesforce/apex/StudentProfileController.getPSAdvisorNotesLWC',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);

const psAdvisorNotesMock = require('./data/psAdvisorNotes.json');
const psAdvisorNotesExtractProgramPlanNamesMock = require('./data/psAdvisorNotesExtractProgramPlanNames.json');
const psAdvisorNotesNoAdvUserIdMock = require('./data/psAdvisorNotesNoAdvUserId.json');
const psAdvisorNotesNoneMock = require('./data/psAdvisorNotesNone.json');
const psAdvisorNotesTable = require('./expected/psAdvisorNotes.json');

describe('c-sp-comments-advising-notes', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    test('Wire request made', async () => {
        const element = createElement('c-sp-comments-advising-notes', {
            is: SpCommentsAdvisingNotesTest,
        });
        element.contactId = '0035900000UBEIgAAP';
        document.body.appendChild(element);
        await flushPromises(); // wait for wire request to queue

        // Requested using proper contactId
        expect(getPSAdvisorNotes.getLastConfig()).toEqual({contactId: '0035900000UBEIgAAP'});
    });

    test('Display flag order', () => {
        const element = createElement('c-sp-comments-advising-notes', {
            is: SpCommentsAdvisingNotesTest,
        });
        element.contactId = '0035900000UBEIgAAP';
        document.body.appendChild(element);

        // Starts as loading
        expect(element.loading).toEqual(true);

        // After wire completes - with no data
        getPSAdvisorNotes.emit(psAdvisorNotesNoneMock);

        // Done loading but no data
        expect(element.loading).toEqual(false);
        expect(element.hasData).toEqual(false);

        // After wire completes - with data
        getPSAdvisorNotes.emit(psAdvisorNotesMock);

        // Done loading and has data
        expect(element.loading).toEqual(false);
        expect(element.hasData).toEqual(true);
    });

    test('Correct data', async () => {
        const element = createElement('c-sp-comments-advising-notes', {
            is: SpCommentsAdvisingNotesTest,
        });
        element.contactId = '0035900000UBEIgAAP';
        document.body.appendChild(element);
        getPSAdvisorNotes.emit(psAdvisorNotesMock);
        await flushPromises(); // wait for page to render

        // Get table
        const advisorNoteTableNode = element.shadowRoot.querySelector('.advising-notes-table');

        // 2 rows per item
        expect(advisorNoteTableNode.querySelectorAll('tr')).toHaveLength(2 * psAdvisorNotesTable.length);

        // Rows match mock table
        for (let i = 0; i < psAdvisorNotesTable.length; i++) {
            const expectedRowData = psAdvisorNotesTable[i];
            const actualRowPart1 = advisorNoteTableNode.querySelectorAll('tr')[2 * i];
            const actualRowPart2 = advisorNoteTableNode.querySelectorAll('tr')[2 * i + 1];

            // Has all values
            expect(actualRowPart1.querySelectorAll('td')[0].textContent?.trim()).toEqual(expectedRowData.c__UserName);
            expect(actualRowPart1.querySelectorAll('td')[0].querySelector('a').dataset.userid?.trim()).toEqual(
                expectedRowData.c__UserId
            );
            expect(actualRowPart1.querySelectorAll('td')[1].textContent?.trim()).toEqual(expectedRowData.c__Date);
            expect(actualRowPart1.querySelectorAll('td')[2].textContent?.trim()).toEqual(expectedRowData.c__PlanName);
            expect(actualRowPart1.querySelectorAll('td')[3].textContent?.trim()).toEqual(
                expectedRowData.c__ProgramName
            );
            expect(actualRowPart2.textContent?.trim()).toEqual(expectedRowData.c__Comment);
        }
    });

    test('Extracting program/plan names', async () => {
        const element = createElement('c-sp-comments-advising-notes', {
            is: SpCommentsAdvisingNotesTest,
        });
        element.contactId = '0035900000UBEIgAAP';
        document.body.appendChild(element);
        getPSAdvisorNotes.emit(psAdvisorNotesExtractProgramPlanNamesMock);
        await flushPromises(); // wait for page to render

        // Get table
        const advisorNoteTableNode = element.shadowRoot.querySelector('.advising-notes-table');

        // Assert all are shown
        expect(advisorNoteTableNode.querySelectorAll('tr')).toHaveLength(6); // 3 items, 2 rows per item

        // First has names for both
        expect(advisorNoteTableNode.querySelectorAll('tr')[0].querySelectorAll('td')[2].textContent).toEqual(
            'Comp Sci (Cybersecurity)'
        );
        expect(advisorNoteTableNode.querySelectorAll('tr')[0].querySelectorAll('td')[3].textContent).toEqual(
            'Ira A Fulton Engineering'
        );

        // Second has codes for both
        expect(advisorNoteTableNode.querySelectorAll('tr')[2].querySelectorAll('td')[2].textContent).toEqual(
            'ESCSEIBS'
        );
        expect(advisorNoteTableNode.querySelectorAll('tr')[2].querySelectorAll('td')[3].textContent).toEqual('UGES');

        // Third has -- for both
        expect(advisorNoteTableNode.querySelectorAll('tr')[4].querySelectorAll('td')[2].textContent).toEqual('--');
        expect(advisorNoteTableNode.querySelectorAll('tr')[4].querySelectorAll('td')[3].textContent).toEqual('--');
    });

    test('Only link for users with an ID', async () => {
        const element = createElement('c-sp-comments-advising-notes', {
            is: SpCommentsAdvisingNotesTest,
        });
        element.contactId = '0035900000UBEIgAAP';
        document.body.appendChild(element);
        getPSAdvisorNotes.emit(psAdvisorNotesNoAdvUserIdMock);
        await flushPromises(); // wait for page to render

        // Get table
        const advisorNoteTableNode = element.shadowRoot.querySelector('.advising-notes-table');

        // Assert all are shown
        expect(advisorNoteTableNode.querySelectorAll('tr')).toHaveLength(4); // 2 items, 2 rows per item

        // First has a <a> link
        expect(advisorNoteTableNode.querySelectorAll('tr')[0].querySelectorAll('td')[0]).toHaveChildElement('a');
        expect(advisorNoteTableNode.querySelectorAll('tr')[0].querySelectorAll('td')[0].textContent?.trim()).toEqual(
            'Wendy Gibson-Wright'
        );

        // Second has no <a> link
        expect(advisorNoteTableNode.querySelectorAll('tr')[2].querySelectorAll('td')[0]).not.toHaveChildElement('a');
        expect(advisorNoteTableNode.querySelectorAll('tr')[2].querySelectorAll('td')[0].textContent?.trim()).toEqual(
            'Leah Miller'
        );
    });

    test('Navigate when click on users', async () => {
        const element = createElement('c-sp-comments-advising-notes', {
            is: SpCommentsAdvisingNotesTest,
        });
        element.contactId = '0035900000UBEIgAAP';
        document.body.appendChild(element);
        getPSAdvisorNotes.emit(psAdvisorNotesMock);
        await flushPromises(); // wait for page to render

        // Get table
        const advisorNoteTableNode = element.shadowRoot.querySelector('.advising-notes-table');

        // First item
        advisorNoteTableNode.querySelectorAll('tr')[0].querySelectorAll('td')[0].querySelector('a').click();
        expect(getNavigateCalledWith()).toEqual({
            pageReference: {
                type: 'standard__recordPage',
                attributes: {
                    objectApiName: 'User',
                    actionName: 'view',
                    recordId: psAdvisorNotesMock[0].authorUserId,
                },
            },
        });

        // Second item
        advisorNoteTableNode.querySelectorAll('tr')[2].querySelectorAll('td')[0].querySelector('a').click();
        expect(getNavigateCalledWith()).toEqual({
            pageReference: {
                type: 'standard__recordPage',
                attributes: {
                    objectApiName: 'User',
                    actionName: 'view',
                    recordId: psAdvisorNotesMock[1].authorUserId,
                },
            },
        });
    });

    test('Reload function triggers refreshApex', async () => {
        const element = createElement('c-sp-comments-advising-notes', {
            is: SpCommentsAdvisingNotesTest,
        });
        element.contactId = '0035900000UBEIgAAP';
        document.body.appendChild(element);
        getPSAdvisorNotes.emit(psAdvisorNotesMock);
        await flushPromises(); // wait for page to render

        element.reload();
        expect(refreshApex).toHaveBeenCalledTimes(1);

        element.reload();
        expect(refreshApex).toHaveBeenCalledTimes(2);

        element.reload();
        expect(refreshApex).toHaveBeenCalledTimes(3);
    });
});
