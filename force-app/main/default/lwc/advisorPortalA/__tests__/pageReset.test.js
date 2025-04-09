/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {AdvisorPortalTest} from 'c/advisorPortalA';
import LightningConfirm from 'lightning/confirm';
import {graphql} from 'lightning/uiGraphQLApi';
import {flushPromises} from 'c/helperTestFunctions';

const filterSetPrivateMock = require('./data/appliedFilterSetPrivate.json');

describe('c-advisor-portal reset button', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Confirmation modal', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.currentFilter = {career: 'UGRD', studentString: 'wow', caseCount: '4'};
        document.body.appendChild(element);

        await flushPromises(); // await render

        // Press reset button
        [...element.shadowRoot.querySelectorAll('lightning-button-icon')]
            .filter((elem) => elem.title === 'Reset page')[0]
            .click();

        // Confirmation opened
        expect(LightningConfirm.open).toHaveBeenCalled();
    });

    test('Clears current filter', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.currentFilter = {career: 'UGRD', studentString: 'wow', caseCount: '4'};
        document.body.appendChild(element);

        await flushPromises(); // await render

        // Mock confirmation approved
        LightningConfirm.open.mockResolvedValueOnce(true);

        // Press reset button
        [...element.shadowRoot.querySelectorAll('lightning-button-icon')]
            .filter((elem) => elem.title === 'Reset page')[0]
            .click();

        await flushPromises(); // await confirmation to complete

        // Reset values
        expect(element.currentFilter).toEqual({
            career: 'UGRD',
            caseTypeState: 'ProactiveCasesState',
        });
    });

    test('Clears applied filter set', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.appliedFilterSetId = 'FS-1';
        document.body.appendChild(element);
        graphql.emit(filterSetPrivateMock);

        await flushPromises(); // await render

        // Current has applied filter set
        expect(element.appliedFilterSetId).not.toEqual(undefined);
        expect(element.appliedFilterSet).not.toEqual(undefined);

        // Mock confirmation approved
        LightningConfirm.open.mockResolvedValueOnce(true);

        // Press reset button
        [...element.shadowRoot.querySelectorAll('lightning-button-icon')]
            .filter((elem) => elem.title === 'Reset page')[0]
            .click();

        await flushPromises(); // await confirmation to complete

        // Cleared filter set
        expect(element.appliedFilterSetId).toEqual(undefined);
        expect(element.appliedFilterSet).toEqual(undefined);
    });

    test('Rejects confirmation modal', async () => {
        const element = createElement('c-advisor-portal', {
            is: AdvisorPortalTest,
        });
        element.currentFilter = {career: 'UGRD', studentString: 'wow', caseCount: '4'};
        document.body.appendChild(element);

        await flushPromises(); // await render

        // Mock confirmation approved
        LightningConfirm.open.mockResolvedValueOnce(false);

        // Press reset button
        [...element.shadowRoot.querySelectorAll('lightning-button-icon')]
            .filter((elem) => elem.title === 'Reset page')[0]
            .click();

        await flushPromises(); // await confirmation to be rejected

        // Not modified current filter
        expect(element.currentFilter).toEqual({
            career: 'UGRD',
            studentString: 'wow',
            caseCount: '4',
        });
    });
});
