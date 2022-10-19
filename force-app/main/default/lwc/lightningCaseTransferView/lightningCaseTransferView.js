import {LightningElement, api, wire} from 'lwc';
import {falseWireRun, parseBoolean} from 'c/helperFunctions';
import getTransferOptions from '@salesforce/apex/AdvisorCaseTransferService.getTransferOptions';
import transferMultipleCases from '@salesforce/apex/AdvisorCaseTransferService.transferMultipleCases';

export default class LightningCaseTransferView extends LightningElement {
    // Support both mass transfer mode, and (when false) single transfer mode
    @api set massTransfer(val) {
        this._massTransfer = parseBoolean(val);
    }
    get massTransfer() {
        return this._massTransfer;
    }
    _massTransfer = false;

    // List of cases that need to be transferred
    @api caseIds = [];

    // When in mass transfer mode, treat these as grad or ugrad cases?
    @api set grad(val) {
        this._grad = parseBoolean(val);
    }
    get grad() {
        return this._grad;
    }
    _grad = false;

    options = [];
    newOwner = '';

    @wire(getTransferOptions, {
        caseIds: '$caseIds',
        massTransfer: '$massTransfer',
        grad: '$grad',
    })
    gotTransferOptions(result) {
        if (falseWireRun(result)) return;
        if (this.options.length > 0) return; // only load once

        let {data, error} = result;

        if (data != null) {
            // Create a list of options
            const options = [];

            const parsedData = JSON.parse(data);
            let firstOption = null;

            for (let i = 0; i < parsedData.length; i++) {
                const opt = parsedData[i];
                let label = opt.label;
                let value = opt.value;

                const isLabel = label.indexOf('--') === 0 && label.lastIndexOf('--') + 2 === label.length; // -- indicates this is a header for a section of the dropdown
                if (isLabel) label = label.substring(2, label.length - 2); // strip off the -- markers

                // The first option is the user themself, it should be autoselected
                if (firstOption == null) firstOption = value;

                // Create an option in the dropdown for each option
                options.push({
                    label: label,
                    value: value,
                    isLabel: isLabel,
                    isSelected: false,
                });
            }

            this.options = options;
            this.newOwner = firstOption;
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
    }

    changeNewOwner(e) {
        this.newOwner = e.detail.value;
    }

    @api transferCases() {
        return transferMultipleCases({caseIds: this.caseIds, ownerId: this.newOwner});
    }
}
