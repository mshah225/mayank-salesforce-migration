/**
 * Helper utility for reading and parsing CSV files, you must know the structure of the CSV file in order to use this,
 * meaning you need to know the column delimiter (often comma) and the newline delimiter (\n or \r usually)
 * Keep in mind, CSVs are a string-based format - if fields need to be cast to non strings, you must do that manually
 *
 * There are two main ways to use this you can use the CSVReader class or the CSVScanner class
 * Both constructors take a string and am opts object
 *      The string is the contents of the CSV file
 *      opts is an object configuring how to read that file
 *          {
 *              "delim": ",",          // column delimiter
 *              "rowDelim": "\n",      // row delimiter
 *              "hasHeader": true,     // treat first row as a header row
 *          }
 *
 * The CSVReader class is designed to make it easy to jump around in the file and read arbitrary rows
 * getHeader() = returns a String[], each item in the array corresponds to each header in the original CSV file
 * getRowCount() = returns a number, the number of rows (excluding the header row)
 * getRow(rowIndx) = returns a String[], the values at row rowIndx
 * getJSONRow(rowIndx) = returns a JS Object, the keys being the header names and the values being the value in row rowIndx
 *
 * The CSVScanner class is meant for when you need to simply step through the file one row at a time
 * hasNextRow() = returns a Boolean, true if there are rows you have not retrieved yet
 * getNextRow() = returns a JS Object, the keys being the header names and the values being the value in row rowIndx and moves pointer to next row in file
 */

export class CSVReader {
    type = 'CSVReader';
    fullBody = null;
    rowDelim = null;
    delim = null;
    hasHeader = false;
    header = null;
    body = null;
    DQUOTE = '"';
    DOUBLE_DQUOTE = '""';
    indx = 0;

    constructor(csvStr, opts) {
        this.fullBody = csvStr;
        this.rowDelim = opts?.rowDelim ?? '\n';
        this.delim = opts?.delim ?? ',';
        this.hasHeader = opts?.hasHeader ?? true;

        this._init();
    }

    /**
     * Initialization function expects fullBody, rowDelim, and delim to all be set
     */
    _init() {
        if (!this.fullBody.endsWith(this.rowDelim)) this.fullBody = this.fullBody + this.rowDelim;

        let fileString = this.fullBody;
        let allRows = [];

        let endOfData = false;
        let rowValues = [];

        while (!endOfData) {
            // accumulate all values from this row
            let csvVal = this._popNextValue();
            rowValues.push(csvVal.value);

            // once we reach end of row, push into allRows list
            if (csvVal.delimiter === this.rowDelim) {
                // as long as the row has data and isn't just a empty value add it to the list
                if (rowValues.length > 1 || (rowValues.length === 1 && rowValues[0] !== '')) {
                    allRows.push(rowValues);

                    if (allRows.length > 0 && allRows[0].length !== rowValues.length)
                        throw new Error(
                            'Every subsequent row should have same number of columns. Expected ' +
                                allRows[0].length +
                                ' columns but row ' +
                                allRows.length +
                                ' had ' +
                                rowValues.length +
                                ' columns'
                        );
                }
                rowValues = [];
            }

            if (this.indx === fileString.length) endOfData = true;
        }

        if (this.hasHeader) {
            this.header = allRows[0];
            this.body = [];
            for (let i = 1; i < allRows.length; i++) this.body.push(allRows[i]);
        } else {
            this.body = allRows;
        }
    }

    _popNextValue() {
        let data = this.fullBody.substring(this.indx);

        // eslint-disable-next-line no-use-before-define
        const csvVal = new CsvValue(null, null, null, this.DQUOTE);

        if (data.startsWith(this.DQUOTE)) {
            csvVal.enclosed = true;

            let startingSearchIndex = 1;
            let dquoteIndex = -1;
            let doubleDquoteIndex = -1;

            let closerFound = false;

            while (!closerFound) {
                dquoteIndex = data.indexOf(this.DQUOTE, startingSearchIndex);
                doubleDquoteIndex = data.indexOf(this.DOUBLE_DQUOTE, startingSearchIndex);

                if (dquoteIndex === -1)
                    throw new Error('Unpaired double quote found at index ' + this.indx + ', cannot parse CSV');

                if (dquoteIndex === doubleDquoteIndex) {
                    // next dquote is actually a double dquote (escaped dquote)
                    startingSearchIndex = doubleDquoteIndex + this.DOUBLE_DQUOTE.length;
                } else {
                    // Found matching dquote
                    closerFound = true;
                }
            }

            // Get value and unescape dquotes
            csvVal.value = data.substring(this.DQUOTE.length, dquoteIndex).replaceAll(this.DOUBLE_DQUOTE, this.DQUOTE);

            let commaIndex = data.indexOf(this.delim, dquoteIndex + 1);
            let crlfIndex = data.indexOf(this.rowDelim, dquoteIndex + 1);

            if (commaIndex !== -1 && commaIndex < crlfIndex) {
                // next is a comma
                csvVal.delimiter = this.delim;
                // move to after comma
                this.indx += commaIndex + this.delim.length;
            } else {
                // next is a newline
                csvVal.delimiter = this.rowDelim;
                // move to after newline
                this.indx += crlfIndex + this.rowDelim.length;
            }
        } else {
            csvVal.enclosed = false;

            let commaIndex = data.indexOf(this.delim);
            let crlfIndex = data.indexOf(this.rowDelim);

            if (commaIndex !== -1 && commaIndex < crlfIndex) {
                // next is a comma
                csvVal.delimiter = this.delim;
                // read value
                csvVal.value = data.substring(0, commaIndex);
                // move to after comma
                this.indx += commaIndex + this.delim.length;
            } else {
                // next is a newline
                csvVal.delimiter = this.rowDelim;
                // read value
                csvVal.value = data.substring(0, crlfIndex);
                // move to after newline
                this.indx += crlfIndex + this.rowDelim.length;
            }
        }

        return csvVal;
    }

    /**
     * Get the header labels as a string[]
     * @returns String[] the header labels for this CSV file
     * @throws Error if there is no header
     */
    getHeader() {
        if (!this.hasHeader || this.header == null) throw new Error('CSV has no header');
        return this.header;
    }

    /**
     * Get the String[] for a specific row in the CSV file. 0 indexed, skips header row
     * @param {Integer} rowIndx
     * @returns String[] the values of a specific row
     * @throws Error if there are no rows
     * @throws Error if rowIndx is out of range
     */
    getRow(rowIndx) {
        if (this.body == null) throw new Error('CSV has no body');
        if (rowIndx >= this.body.length) throw new Error('row ' + rowIndx + ' is out of range');
        return this.body[rowIndx];
    }

    /**
     * Get an object where the keys are the header labels, and the values are the corresponding values
     * @param {Integer} rowIndx
     * @returns Object for this row, mapping each header label to the corresponding value
     * @throws Error if there is no header
     * @throws Error if there are no rows
     * @throws Error if rowIndx is out of range
     */
    getJSONRow(rowIndx) {
        let rowJSON = {};

        let headerArr = this.hasHeader ? this.getHeader() : null;
        let rowArr = this.getRow(rowIndx);

        for (let i = 0; i < rowArr.length; i++) {
            let label = headerArr?.at(i) ?? `${i}`;
            let value = rowArr[i];
            rowJSON[label] = value;
        }

        return rowJSON;
    }

    /**
     * Gets the number of rows (excluding the header row)
     * @returns Integer, how many rows are in this file
     */
    getRowCount() {
        return this.body.length;
    }
}

export class CSVScanner {
    type = 'CSVScanner';
    csvReader = null;
    pntr = 0;
    rowCount = 0;

    constructor(csvStr, opts) {
        this.csvReader = new CSVReader(csvStr, opts);
        this._init();
    }

    /**
     * Initialization function expects csvReader to be set
     */
    _init() {
        this.rowCount = this.csvReader.getRowCount();
    }

    /**
     * Get all the labels of the CSV file
     * @returns String[] for header of CSV
     */
    getLabels() {
        return this.csvReader.getHeader();
    }

    /**
     * Check if there is a next row to scan for this CSV file
     * @returns Boolean if there are more rows to scan
     */
    hasNextRow() {
        if (this.pntr >= this.rowCount) return false;
        return true;
    }

    /**
     * Should be used in conjunction with hasNextRow(), this retrieves the next row as an object
     * @returns Object, get the next row, mapping each header label to the corresponding value
     * @throws Error if there are no more rows
     */
    getNextRow() {
        if (!this.hasNextRow()) throw new Error('No more rows');
        const jsonRow = this.csvReader.getJSONRow(this.pntr);
        this.pntr++;
        return jsonRow;
    }
}

export class CsvValue {
    type = 'CsvValue';
    value = null;
    enclosed = null;
    delimiter = null;
    dquote = null;
    double_dquote = null;

    constructor(value, enclosed, delimiter, dquote) {
        this.value = value;
        this.enclosed = enclosed;
        this.delimiter = delimiter;
        this.dquote = dquote;
        this.double_dquote = dquote + dquote;
    }

    biteSize() {
        let biteSize = this.value.replaceAll(this.dquote, this.double_dquote).length + this.delimiter.length;

        if (this.enclosed) {
            biteSize += this.dquote.length * 2;
        }

        return biteSize;
    }
}
