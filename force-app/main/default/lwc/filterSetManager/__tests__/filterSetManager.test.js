/* eslint-disable no-undef */
import FilterSetManager from 'c/filterSetManager';
import {createRecord, updateRecord, deleteRecord} from 'lightning/uiRecordApi';

const recordsBasic = require('./data/basic.json');

describe('c-filter-set-manager', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Clear mocks
        jest.clearAllMocks();
    });

    test('Test pinning', () => {
        const filterSetManager = new FilterSetManager(recordsBasic);
        filterSetManager.pin(recordsBasic[0].Id, true);

        expect(updateRecord).toHaveBeenCalledWith({
            fields: {
                Id: recordsBasic[0].Filter_Set_User_Associations__r[0].Id,
                Pinned__c: true,
            },
        });
    });

    test('Test unpinning', () => {
        const filterSetManager = new FilterSetManager(recordsBasic);
        filterSetManager.pin(recordsBasic[0].Id, false);

        expect(updateRecord).toHaveBeenCalledWith({
            fields: {
                Id: recordsBasic[0].Filter_Set_User_Associations__r[0].Id,
                Pinned__c: false,
            },
        });
    });

    test('Test renaming', () => {
        const filterSetManager = new FilterSetManager(recordsBasic);
        filterSetManager.rename(recordsBasic[0].Id, 'New name');

        expect(updateRecord).toHaveBeenCalledWith({
            fields: {
                Id: recordsBasic[0].Id,
                Name: 'New name',
            },
        });
    });

    test('Removes unshared users', async () => {
        const filterSetManager = new FilterSetManager(recordsBasic);
        filterSetManager.share(recordsBasic[0].Id, []);

        expect(deleteRecord).toHaveBeenCalledWith(recordsBasic[0].Filter_Set_User_Associations__r[1].Id);
    });

    test('Adds newly shared users', async () => {
        const filterSetManager = new FilterSetManager(recordsBasic);
        filterSetManager.share(recordsBasic[0].Id, ['USER-1', 'USER-2', 'USER-3']);

        expect(createRecord).toHaveBeenCalledWith({
            apiName: 'Filter_Set_User_Association__c',
            fields: {
                User__c: 'USER-1',
                Filter_Set__c: recordsBasic[0].Id,
            },
        });
        expect(createRecord).toHaveBeenCalledWith({
            apiName: 'Filter_Set_User_Association__c',
            fields: {
                User__c: 'USER-2',
                Filter_Set__c: recordsBasic[0].Id,
            },
        });
        expect(createRecord).toHaveBeenCalledWith({
            apiName: 'Filter_Set_User_Association__c',
            fields: {
                User__c: 'USER-3',
                Filter_Set__c: recordsBasic[0].Id,
            },
        });
    });

    test('Remove filter set', async () => {
        const filterSetManager = new FilterSetManager(recordsBasic);
        filterSetManager.remove(recordsBasic[0].Id, {delete: true, unshare: []});
        expect(deleteRecord).toHaveBeenCalledWith(recordsBasic[0].Id);
    });

    test('Unshare filter set', async () => {
        const filterSetManager = new FilterSetManager(recordsBasic);
        filterSetManager.remove(recordsBasic[0].Id, {delete: false, unshare: ['FSUA-1', 'FSUA-2', 'FSUA-3']});

        // Check deleteRecord was called to delete FSUAs not the entire filter set
        expect(deleteRecord).not.toHaveBeenCalledWith(recordsBasic[0].Id);
        expect(deleteRecord).toHaveBeenCalledWith('FSUA-1');
        expect(deleteRecord).toHaveBeenCalledWith('FSUA-2');
        expect(deleteRecord).toHaveBeenCalledWith('FSUA-3');
    });
});
