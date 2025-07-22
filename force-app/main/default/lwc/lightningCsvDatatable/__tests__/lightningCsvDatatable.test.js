/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {LightningCsvDatatableTest} from 'c/lightningCsvDatatable';

describe('c-lightning-csv-datatable', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Create header from CSV file', () => {
        const element = createElement('c-lightning-csv-datatable', {
            is: LightningCsvDatatableTest,
        });
        element.contents =
            'Id,Name,EMPLID,Enrolled\n1,Bob,2024031301,true\n2,Johnny Thunder,2022063001,false\n3,Hess LaCoil,2013060401,false';
        document.body.appendChild(element);

        // Assert
        expect(element.tableColumns).toMatchObject([
            {label: 'Id'},
            {label: 'Name'},
            {label: 'EMPLID'},
            {label: 'Enrolled'},
        ]);
    });

    test('Create rows from CSV file', () => {
        const element = createElement('c-lightning-csv-datatable', {
            is: LightningCsvDatatableTest,
        });
        element.contents =
            'Id,Name,EMPLID,Enrolled\n1,Bob,2024031301,true\n2,Johnny Thunder,2022063001,false\n3,Hess LaCoil,2013060401,false';
        document.body.appendChild(element);

        // Assert
        expect(element.tableRows).toMatchObject([
            {Id: '1', Name: 'Bob', EMPLID: '2024031301', Enrolled: 'true'},
            {Id: '2', Name: 'Johnny Thunder', EMPLID: '2022063001', Enrolled: 'false'},
            {Id: '3', Name: 'Hess LaCoil', EMPLID: '2013060401', Enrolled: 'false'},
        ]);
    });

    test('Create rows from Windows CSV file', () => {
        const element = createElement('c-lightning-csv-datatable', {
            is: LightningCsvDatatableTest,
        });
        element.contents =
            'Id,Name,EMPLID,Enrolled\r\n1,Bob,2024031301,true\r\n2,Johnny Thunder,2022063001,false\r\n3,Hess LaCoil,2013060401,false';
        document.body.appendChild(element);

        // Assert
        expect(element.tableRows).toMatchObject([
            {Id: '1', Name: 'Bob', EMPLID: '2024031301', Enrolled: 'true'},
            {Id: '2', Name: 'Johnny Thunder', EMPLID: '2022063001', Enrolled: 'false'},
            {Id: '3', Name: 'Hess LaCoil', EMPLID: '2013060401', Enrolled: 'false'},
        ]);
    });
});
