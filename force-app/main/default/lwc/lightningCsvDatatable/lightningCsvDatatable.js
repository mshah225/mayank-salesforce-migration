import {LightningElement, api} from 'lwc';
import {CSVScanner} from 'c/csvReader';

export default class LightningCsvDatatable extends LightningElement {
    @api set contents(v) {
        if (this._contents !== v) {
            this._contents = v;
            this.sortDirection = 'asc';
            this.sortedBy = 'rowNumber';
            this.regenerateTable();
        }
    }
    get contents() {
        return this._contents;
    }
    _contents;

    @api
    set displayAmount(value) {
        this._displayAmount = Number(value);
    }
    get displayAmount() {
        return this._displayAmount;
    }
    _displayAmount = 25;

    regenerateTable() {
        if (this.contents == null) return;
        let scanner = new CSVScanner(this.contents, {delim: /,/, rowDelim: /[\r\n]+/});

        const dataRows = [];
        let rowNumber = 0;
        while (scanner.hasNextRow()) {
            rowNumber += 1;
            dataRows.push({
                rowNumber,
                ...scanner.getNextRow(),
            });
        }

        this.csvColumns = scanner.getLabels().map((v) => {
            return {label: v, fieldName: v, type: 'text', wrapText: true, sortable: true};
        });

        this.csvRows = dataRows;
    }
    csvColumns;
    csvRows;

    sortDirection = 'asc';
    sortedBy = 'rowNumber';

    /**
     * Since we pass handleSort as a callback to a different LWC, we must use arrow notation to define it,
     * otherwise it will have the wrong context
     */
    handleSort = (event) => {
        this.sortedBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
    };

    get tableRows() {
        // We use spread operator here because it's important that we return a reference to a NEW
        // array each time this resorts - otherwise it won't detect the change and won't re-render
        return [
            ...(this.csvRows ?? []).sort((a, b) =>
                a[this.sortedBy] < b[this.sortedBy]
                    ? this.sortDirection === 'asc'
                        ? -1
                        : 1
                    : this.sortDirection === 'asc'
                    ? 1
                    : -1
            ),
        ];
    }
    get tableColumns() {
        return this.csvColumns ?? [];
    }
}

export class LightningCsvDatatableTest extends LightningCsvDatatable {
    @api
    get tableRows() {
        return super.tableRows;
    }

    @api
    get tableColumns() {
        return super.tableColumns;
    }
}
