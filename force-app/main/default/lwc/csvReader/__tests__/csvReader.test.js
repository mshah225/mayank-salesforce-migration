/* eslint-disable no-undef */
import {CSVReader} from 'c/csvReader';

describe('c-csv-reader', () => {
    test('Read column headers', () => {
        const str =
            'Id,Name,EMPLID,Enrolled\n1,Bob,2024031301,true\n2,Johnny Thunder,2022063001,false\n3,Hess LaCoil,2013060401,false\n';
        const reader = new CSVReader(str, {});

        expect(reader.getHeader()).toMatchObject(['Id', 'Name', 'EMPLID', 'Enrolled']);
    });

    test('Read rows', () => {
        const str =
            'Id,Name,EMPLID,Enrolled\n1,Bob,2024031301,true\n2,Johnny Thunder,2022063001,false\n3,Hess LaCoil,2013060401,false\n';
        const reader = new CSVReader(str, {});

        expect(reader.getRowCount()).toEqual(3);
        expect(reader.getRow(0)).toMatchObject(['1', 'Bob', '2024031301', 'true']);
        expect(reader.getRow(1)).toMatchObject(['2', 'Johnny Thunder', '2022063001', 'false']);
        expect(reader.getRow(2)).toMatchObject(['3', 'Hess LaCoil', '2013060401', 'false']);
    });

    test('Read rows with enclosed values', () => {
        const str =
            'Id,Name,Address\n1,Bob,"Front End, Venture Explorer"\n2,Johnny Thunder,"Venture\nNimbus Station"\n3,Hess LaCoil,"""Starbase 3001"""';
        const reader = new CSVReader(str, {});

        expect(reader.getRowCount()).toEqual(3);
        expect(reader.getRow(0)).toMatchObject(['1', 'Bob', 'Front End, Venture Explorer']);
        expect(reader.getRow(1)).toMatchObject(['2', 'Johnny Thunder', 'Venture\nNimbus Station']);
        expect(reader.getRow(2)).toMatchObject(['3', 'Hess LaCoil', '"Starbase 3001"']);
    });

    test('Read rows, nonstandard delims', () => {
        const str =
            'Id|Name|EMPLID|Enrolled\r\t1|Bob|2024031301|true\r\t2|Johnny Thunder|2022063001|false\r\t3|Hess LaCoil|2013060401|false';
        const reader = new CSVReader(str, {
            delim: '|',
            rowDelim: '\r\t',
        });

        expect(reader.getRowCount()).toEqual(3);
        expect(reader.getRow(0)).toMatchObject(['1', 'Bob', '2024031301', 'true']);
        expect(reader.getRow(1)).toMatchObject(['2', 'Johnny Thunder', '2022063001', 'false']);
        expect(reader.getRow(2)).toMatchObject(['3', 'Hess LaCoil', '2013060401', 'false']);
    });

    test('Read rows, no header', () => {
        const str = '1,Bob,2024031301,true\n2,Johnny Thunder,2022063001,false\n3,Hess LaCoil,2013060401,false\n';
        const reader = new CSVReader(str, {
            hasHeader: false,
        });

        expect(reader.getRowCount()).toEqual(3);
        expect(reader.getRow(0)).toMatchObject(['1', 'Bob', '2024031301', 'true']);
        expect(reader.getRow(1)).toMatchObject(['2', 'Johnny Thunder', '2022063001', 'false']);
        expect(reader.getRow(2)).toMatchObject(['3', 'Hess LaCoil', '2013060401', 'false']);
    });

    test('Read JSON rows', () => {
        const str =
            'Id,Name,EMPLID,Enrolled\n1,Bob,2024031301,true\n2,Johnny Thunder,2022063001,false\n3,Hess LaCoil,2013060401,false\n';
        const reader = new CSVReader(str, {});

        expect(reader.getRowCount()).toEqual(3);
        expect(reader.getJSONRow(0)).toMatchObject({Id: '1', Name: 'Bob', EMPLID: '2024031301', Enrolled: 'true'});
        expect(reader.getJSONRow(1)).toMatchObject({
            Id: '2',
            Name: 'Johnny Thunder',
            EMPLID: '2022063001',
            Enrolled: 'false',
        });
        expect(reader.getJSONRow(2)).toMatchObject({
            Id: '3',
            Name: 'Hess LaCoil',
            EMPLID: '2013060401',
            Enrolled: 'false',
        });
    });

    test('Read JSON rows, no header', () => {
        const str = '1,Bob,2024031301,true\n2,Johnny Thunder,2022063001,false\n3,Hess LaCoil,2013060401,false\n';
        const reader = new CSVReader(str, {
            hasHeader: false,
        });

        expect(reader.getRowCount()).toEqual(3);
        expect(reader.getJSONRow(0)).toMatchObject({0: '1', 1: 'Bob', 2: '2024031301', 3: 'true'});
        expect(reader.getJSONRow(1)).toMatchObject({
            0: '2',
            1: 'Johnny Thunder',
            2: '2022063001',
            3: 'false',
        });
        expect(reader.getJSONRow(2)).toMatchObject({
            0: '3',
            1: 'Hess LaCoil',
            2: '2013060401',
            3: 'false',
        });
    });

    test('Error state, wrong size row', () => {
        const str =
            'Id,Name,EMPLID,Enrolled\n1,Bob,2024031301,true\n2,Johnny Thunder,2022063001,false\n3,Hess LaCoil,2013060401\n';
        let err = null;

        try {
            const reader = new CSVReader(str, {});
        } catch (e) {
            err = e;
        }

        expect(err.message).toContain(
            'Every subsequent row should have same number of columns. Expected 4 columns but row 4 had 3 columns'
        );
    });

    test('Error state, unpaired dquotes', () => {
        const str =
            'Id,Name,EMPLID,Enrolled\n1,Bob,2024031301,true\n2,"Johnny Thunder,2022063001,false\n3,Hess LaCoil,2013060401\n';
        let err = null;

        try {
            const reader = new CSVReader(str, {});
        } catch (e) {
            err = e;
        }

        expect(err.message).toContain('Unpaired double quote found at index 48, cannot parse CSV');
    });

    test('Error state, read out of bounds row', () => {
        const str =
            'Id,Name,EMPLID,Enrolled\n1,Bob,2024031301,true\n2,Johnny Thunder,2022063001,false\n3,Hess LaCoil,2013060401,false\n';
        const reader = new CSVReader(str, {});
        let err = null;

        try {
            let row3 = reader.getRow(3);
        } catch (e) {
            err = e;
        }

        expect(err.message).toEqual('row 3 is out of range');
    });
});
