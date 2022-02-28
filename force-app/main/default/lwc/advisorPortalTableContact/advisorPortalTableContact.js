import {LightningElement, api} from 'lwc';

export default class AdvisorPortalTableContact extends LightningElement {
    @api set contactWrapper(val) {
        // make a deep copy when this is initially set, then to keep parent and this synced up we should use events and
        // trust that the parent is keeping their copy up to date
        if (this._contactWrapper === null) {
            this._contactWrapper = JSON.parse(JSON.stringify(val));
        }
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

    toggleSelectRelatedCases(e) {
        const checked = e.originalTarget.checked;

        this.contactWrapper.isSelected = checked;

        for (let i = 0; i < this.contactWrapper.cases.length; i++) {
            const caseWrapper = this.contactWrapper.cases[i];
            caseWrapper.isSelected = checked;
        }

        this.triggerRenderChanges();
        this.sendSelectEvent();
    }

    toggleCaseSelect(e) {
        const caseId = e.originalTarget.dataset.caseId;
        const newSelectState = e.originalTarget.checked;

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
        this.contactWrapper.isOpen = false;
        this.triggerRenderChanges();
        this.sendOpenToggleEvent();
    }

    openDropdown() {
        this.contactWrapper.isOpen = true;
        this.triggerRenderChanges();
        this.sendOpenToggleEvent();
    }

    openStudentProfile() {
        this.sendNavigateEvent('studentprofile', {
            contactId: this.contactWrapper.portalContact.Id,
        });
    }

    openCase(e) {
        const caseId = e.originalTarget.dataset.caseId;
        this.sendNavigateEvent('viewcase', {
            contactId: this.contactWrapper.portalContact.Id,
            caseId: caseId,
        });
    }

    triggerRenderChanges() {
        this._contactWrapper = {...this._contactWrapper};
    }

    sendSelectEvent() {
        this.dispatchEvent(new CustomEvent('changeselected', {detail: this.getSelectedItems()}));
    }

    sendOpenToggleEvent() {
        this.dispatchEvent(
            new CustomEvent('changeopentoggle', {
                detail: {
                    contactId: this.contactWrapper.portalContact.Id,
                    open: this.contactWrapper.isOpen,
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
