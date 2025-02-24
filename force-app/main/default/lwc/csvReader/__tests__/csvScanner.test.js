/* eslint-disable no-undef */
import {CSVScanner} from 'c/csvReader';

describe('c-csv-scanner', () => {
    test('Read rows', () => {
        const str =
            'Id,Name,EMPLID,Enrolled\n1,Bob,2024031301,true\n2,Johnny Thunder,2022063001,false\n3,Hess LaCoil,2013060401,false\n';
        const scanner = new CSVScanner(str, {});

        const allJsonRows = [];
        while (scanner.hasNextRow()) allJsonRows.push(scanner.getNextRow());

        expect(allJsonRows).toHaveLength(3);
        expect(allJsonRows[0]).toMatchObject({Id: '1', Name: 'Bob', EMPLID: '2024031301', Enrolled: 'true'});
        expect(allJsonRows[1]).toMatchObject({
            Id: '2',
            Name: 'Johnny Thunder',
            EMPLID: '2022063001',
            Enrolled: 'false',
        });
        expect(allJsonRows[2]).toMatchObject({Id: '3', Name: 'Hess LaCoil', EMPLID: '2013060401', Enrolled: 'false'});
    });

    test('Read JSON rows, no header', () => {
        const str = '1,Bob,2024031301,true\n2,Johnny Thunder,2022063001,false\n3,Hess LaCoil,2013060401,false\n';
        const scanner = new CSVScanner(str, {
            hasHeader: false,
        });

        const allJsonRows = [];
        while (scanner.hasNextRow()) allJsonRows.push(scanner.getNextRow());

        expect(allJsonRows).toHaveLength(3);
        expect(allJsonRows[0]).toMatchObject({0: '1', 1: 'Bob', 2: '2024031301', 3: 'true'});
        expect(allJsonRows[1]).toMatchObject({
            0: '2',
            1: 'Johnny Thunder',
            2: '2022063001',
            3: 'false',
        });
        expect(allJsonRows[2]).toMatchObject({
            0: '3',
            1: 'Hess LaCoil',
            2: '2013060401',
            3: 'false',
        });
    });

    test('Read labels', () => {
        const str =
            'Id,Name,EMPLID,Enrolled\n1,Bob,2024031301,true\n2,Johnny Thunder,2022063001,false\n3,Hess LaCoil,2013060401,false\n';
        const scanner = new CSVScanner(str, {});

        const allJsonRows = [];
        while (scanner.hasNextRow()) allJsonRows.push(scanner.getNextRow());

        expect(scanner.getLabels()).toMatchObject(['Id', 'Name', 'EMPLID', 'Enrolled']);
    });
});
