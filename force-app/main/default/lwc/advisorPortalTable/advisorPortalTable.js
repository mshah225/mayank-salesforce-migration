import {LightningElement, api, wire} from 'lwc';
import checkIfAllowedToUseMassTransfer from '@salesforce/apex/AdvisorPortalMassTransferController.checkIfAllowedToUse';
import persistenceChart from '@salesforce/resourceUrl/PersistenceChart';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {cloneObj, extractErrorMessages} from 'c/helperFunctions';

export default class AdvisorPortalTable extends LightningElement {
    @api currentFilter = null;
    @api set allResults(v) {
        this._allResults = cloneObj(v); // cloning here help on performance for toggling select all
    }
    get allResults() {
        return this._allResults;
    }
    _allResults = null;

    /**
     * Check if should show mass transfer or not
     */
    @wire(checkIfAllowedToUseMassTransfer, {})
    checkedIfAllowedToUseMassTransfer({data, error}) {
        if (data !== undefined) {
            this.allowedToUseMassTransfer = data;
        } else if (error !== undefined) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error checking if user can user mass transfer',
                    message: extractErrorMessages(error)[0],
                    variant: 'error',
                })
            );
        }
    }
    allowedToUseMassTransfer = false;

    currentPage = 0;
    pageSize = 20;

    expandedAll = true;
    selectedAll = false;

    get showPersistenceLegend() {
        if (this.currentFilter?.career === 'GRD') return false;
        return true;
    }

    get sizeOfResults() {
        return this.allResults?.length ?? 0;
    }

    get allResultsIsEmpty() {
        return this.sizeOfResults === 0;
    }

    get persistenceIconVeryLow() {
        return persistenceChart + '/icon-1.png';
    }
    get persistenceIconLow() {
        return persistenceChart + '/icon-2.png';
    }
    get persistenceChartModerate() {
        return persistenceChart + '/icon-3.png';
    }
    get persistenceIconHigh() {
        return persistenceChart + '/icon-4.png';
    }
    get persistenceIconVeryHigh() {
        return persistenceChart + '/icon-5.png';
    }

    changePage(e) {
        const newPage = e.detail;
        this.currentPage = newPage;
    }

    changePageSize(e) {
        const newSize = e.detail;
        this.pageSize = newSize;
    }

    updateExpandedAll(e) {
        this.expandOverrides = {};
        this.expandedAll = e.detail.checked;
    }

    updateSelectedAll(e) {
        this.selectOverrides = {};
        this.selectedAll = e.detail.checked;
    }

    /**
     * All the contact wrappers, with correct toggle/selected state
     */
    get contactWrappers() {
        const rows = [];

        const allResults = cloneObj(this.allResults ?? []); // cloning here ensures rendered detects change
        for (const c of allResults) {
            // Mark as selected
            c.isSelected = this.selectOverrides[c.portalContact.Id] ?? this.selectedAll;

            if (this.selectedAll)
                for (const caseWrapper of c.cases ?? [])
                    caseWrapper.isSelected = this.selectOverrides[caseWrapper.portalCase.Id] ?? true;
            else
                for (const caseWrapper of c.cases ?? [])
                    caseWrapper.isSelected = this.selectOverrides[caseWrapper.portalCase.Id] ?? false;

            // Mark as open or closed accordian
            c.isOpen = this.expandOverrides[c.portalContact.Id] ?? this.expandedAll;

            rows.push(c);
        }

        /**
         * This getter should rerun whenever its dependencies change - which means whenever the contact list changes,
         * stuff is toggled, or stuff is (un)selected.
         *
         * Whenever these change calculate the list of selected ids, and raise event if it has changed
         */
        // eslint-disable-next-line no-undef
        const newSelectedIds = new Set();
        for (const c of rows) {
            if (c.isSelected) newSelectedIds.add(c.portalContact.Id);
            for (const caseWrapper of c.cases ?? [])
                if (caseWrapper.isSelected) newSelectedIds.add(caseWrapper.portalCase.Id);
        }

        // Either a differing number of ids, or some ids in new list are not in old list
        if (
            newSelectedIds.size !== this.prevSelectedIds.size ||
            // eslint-disable-next-line @salesforce/aura/ecma-intrinsics
            Array.from(newSelectedIds).filter((id) => !this.prevSelectedIds.has(id)).length > 0
        ) {
            this.prevSelectedIds = newSelectedIds;
        }

        return rows;
    }
    // eslint-disable-next-line no-undef
    prevSelectedIds = new Set();

    /**
     * Only the contact wrappers on the current page
     */
    get shownContactWrappers() {
        const rows = [];

        const contactWrappers = this.contactWrappers;

        for (let i = 0; i < contactWrappers.length; i++) {
            const contactWrapper = contactWrappers[i];

            if (i < this.currentPage * this.pageSize) {
                continue; // these are on a previous page
            } else if (i >= (this.currentPage + 1) * this.pageSize) {
                continue; // these are on a next page
            } else {
                rows.push(contactWrapper);
            }
        }

        return rows;
    }

    selectOverrides = {};
    updateSelected(e) {
        const changedContact = e.detail.contact;
        const changedCases = e.detail.cases;
        // Add contact to override list
        this.selectOverrides[changedContact.Id] = changedContact.selected;
        // Add all cases to override list
        const contactWrapper = (this.allResults ?? []).filter((v) => v.portalContact.Id === changedContact.Id)[0];
        for (const caseWrapper of contactWrapper.cases)
            if (changedCases.includes(caseWrapper.portalCase.Id))
                this.selectOverrides[caseWrapper.portalCase.Id] = true;
            else this.selectOverrides[caseWrapper.portalCase.Id] = false;
        // trigger re-render
        this.selectOverrides = cloneObj(this.selectOverrides);
    }

    expandOverrides = {};
    updateToggleAccordian(e) {
        const changedContactId = e.detail.contactId;
        const newState = e.detail.open;
        // Add to override list
        this.expandOverrides[changedContactId] = newState;
        // trigger re-render
        this.expandOverrides = cloneObj(this.expandOverrides);
    }

    sendMassTransferEvent() {
        this.dispatchEvent(
            new CustomEvent('transfer', {
                detail: {
                    value: this.getSelectedWrappers(),
                },
            })
        );
    }
    sendMassEmailEvent() {
        this.dispatchEvent(
            new CustomEvent('email', {
                detail: {
                    value: this.getSelectedWrappers(),
                },
            })
        );
    }
    sentMassCloseEvent() {
        this.dispatchEvent(
            new CustomEvent('close', {
                detail: {
                    value: this.getSelectedWrappers(),
                },
            })
        );
    }
    sendRefreshEvent() {
        this.dispatchEvent(new CustomEvent('refresh', {}));
    }

    bubbleEvent(e) {
        this.dispatchEvent(
            new CustomEvent(e.type, {
                detail: e.detail,
            })
        );
    }

    getSelectedWrappers() {
        // Make a list of all contacts and cases that are selected
        const selectedContactCaseWrappers = [];
        for (const res of this.contactWrappers) {
            const wrapper = {contactId: res.portalContact.Id, selected: false, cases: []};
            let somethingSelected = false;
            if (res.isSelected) {
                wrapper.selected = true;
                somethingSelected = true;
            }
            for (const c of res.cases) {
                if (c.isSelected) {
                    wrapper.cases.push({caseId: c.portalCase.Id, selected: true});
                    somethingSelected = true;
                }
            }
            if (somethingSelected) selectedContactCaseWrappers.push(wrapper);
        }

        return selectedContactCaseWrappers;
    }
}
