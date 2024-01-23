import {LightningElement, api} from 'lwc';
import {cloneObj} from 'c/helperFunctions';

export default class AdvisorPortalTableContactOutlookChangeDir extends LightningElement {
    @api set contactWrapper(val) {
        // make a deep copy so we can modify
        this._contactWrapper = cloneObj(val);
    }
    get contactWrapper() {
        return this._contactWrapper;
    }
    _contactWrapper = null;

    get contactWrapperNotNull() {
        return this.contactWrapper !== null;
    }

    getSelectedItems() {
        const selectedCases = [];

        for (let i = 0; i < this.contactWrapper.cases.length; i++) {
            const caseWrapper = this.contactWrapper.cases[i];
            if (caseWrapper.isSelected) {
                selectedCases.push(caseWrapper.portalCase.Id);
            }
        }

        return {
            contact: {
                Id: this.contactWrapper.portalContact.Id,
                selected: this.contactWrapper.isSelected,
            },
            cases: selectedCases,
        };
    }

    toggleContactSelect(e) {
        const checked = e.detail.checked;

        this.contactWrapper.isSelected = checked;

        for (let i = 0; i < this.contactWrapper.cases.length; i++) {
            const caseWrapper = this.contactWrapper.cases[i];
            caseWrapper.isSelected = checked;
        }

        this.sendSelectEvent();
    }

    toggleCaseSelect(e) {
        const caseId = e.currentTarget.name;
        const newSelectState = e.detail.checked;

        for (let i = 0; i < this.contactWrapper.cases.length; i++) {
            const caseWrapper = this.contactWrapper.cases[i];
            if (caseWrapper.portalCase.Id === caseId) {
                caseWrapper.isSelected = newSelectState;
                break;
            }
        }
        this.sendSelectEvent();
    }

    closeDropdown() {
        this.sendOpenToggleEvent(false);
    }

    openDropdown() {
        this.sendOpenToggleEvent(true);
    }

    openStudentProfile() {
        this.sendNavigateEvent('studentprofile', {
            contactId: this.contactWrapper.portalContact.Id,
            contactName: this.contactWrapper.portalContact.Name,
        });
    }

    openCase(e) {
        const caseId = e.currentTarget.dataset.caseId;
        const caseNumber = e.currentTarget.dataset.caseNumber;
        this.sendNavigateEvent('viewcase', {
            contactId: this.contactWrapper.portalContact.Id,
            contactName: this.contactWrapper.portalContact.Name,
            caseId: caseId,
            caseNumber: caseNumber,
        });
    }

    sendSelectEvent() {
        this.dispatchEvent(new CustomEvent('changeselected', {detail: this.getSelectedItems()}));
    }

    sendOpenToggleEvent(state) {
        this.dispatchEvent(
            new CustomEvent('changeopentoggle', {
                detail: {
                    contactId: this.contactWrapper.portalContact.Id,
                    open: state,
                },
            })
        );
    }

    sendNavigateEvent(location, params) {
        this.dispatchEvent(
            new CustomEvent('navigate', {
                detail: {
                    location: location,
                    params: params,
                },
            })
        );
    }
}
