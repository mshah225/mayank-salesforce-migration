import {LightningElement, api} from 'lwc';
import Id from '@salesforce/user/Id';

/**
 * @typedef {Object} FilterSet Each filter set object
 * @property {String} Id If of the filter set
 * @property {String} Name Name of the filter set
 * @property {String} Owner__c Id of the user who owns this filter set
 * @property {UserRecord} Owner__r User who owns this filter set
 * @property {String} Value__c The serialized JSON string for this filter set
 * @property {Boolean} Is_Shared__c Is this filter set shared with anyone?
 * @property {String} CreatedDate Datetime string
 * @property {FilterSetUserAssociation[]} Filter_Set_User_Associations__r All filter set associations for this filter set
 * @property {Boolean} Pinned__c Has the current user pinned this filter set
 *
 * @typedef FilterSetUserAssociation Each filter set association mapping filter set to each user who can use it
 * @property {String} Id Id of the filter set association
 * @property {String} User__c Id of the user this association is for
 * @property {UserRecord} User__r User this association is for
 *
 * @typedef UserRecord
 * @property {String} Name Name of the user
 */
export default class FilterSetElement extends LightningElement {
    @api filterSet;
    @api canShare = false;

    get filterName() {
        return this.newName || this.filterSet?.Name || '';
    }

    get filterId() {
        return this.filterSet?.Id || null;
    }

    get shareType() {
        return this.filterSet?.Is_Shared__c ? (this.userOwnsFilterSet ? 'Shared by me' : 'Shared with me') : 'Private';
    }
    get ownerName() {
        return this.filterSet?.Owner__r.Name || '';
    }

    get createdDate() {
        return this.filterSet?.CreatedDate || 0;
    }

    get isPinned() {
        return this.filterSet?.Pinned__c ?? false;
    }

    get pinLabel() {
        return this.isPinned ? 'Unpin' : 'Pin';
    }

    get userOwnsFilterSet() {
        return this.filterSet?.Owner__c === Id;
    }

    applyFilterSet(evnt) {
        evnt.stopPropagation();
        evnt.stopImmediatePropagation();
        evnt.preventDefault();

        this.dispatchEvent(
            new CustomEvent('apply', {
                detail: {
                    filterSetId: this.filterId,
                    filterSet: this.filterSet,
                },
            })
        );
    }

    handleSelect(evnt) {
        evnt.stopPropagation();
        evnt.stopImmediatePropagation();
        evnt.preventDefault();

        if (evnt.detail.name === 'pin') {
            this.dispatchEvent(
                new CustomEvent('pin', {
                    detail: {
                        filterSetId: this.filterId,
                        pinned: !this.isPinned,
                    },
                })
            );
        } else if (evnt.detail.name === 'share') {
            this.dispatchEvent(
                new CustomEvent('share', {
                    detail: {
                        filterSetId: this.filterId,
                    },
                })
            );
        } else if (evnt.detail.name === 'view') {
            this.dispatchEvent(
                new CustomEvent('view', {
                    detail: {
                        filterSetId: this.filterId,
                        filterSet: this.filterSet,
                    },
                })
            );
        } else if (evnt.detail.name === 'remove') {
            this.dispatchEvent(
                new CustomEvent('remove', {
                    detail: {
                        filterSetId: this.filterId,
                    },
                })
            );
        }
    }

    renameMode = false;
    newName = '';
    handleRename() {
        if (!this.renameMode) {
            this.renameMode = true;
            this.newName = this.filterName;
        }
    }

    renderedCallback() {
        if (this.renameMode) {
            this.refs.editNameInput.focus();
        }
    }

    changeFilterName(evnt) {
        this.newName = evnt.detail.value;
    }
    changeFilterNameKeydown(evnt) {
        if (evnt.key === 'Enter') {
            this.renameMode = false;

            evnt.stopPropagation();
            evnt.stopImmediatePropagation();
            evnt.preventDefault();

            this.dispatchEvent(
                new CustomEvent('rename', {
                    detail: {
                        filterSetId: this.filterId,
                        value: this.newName,
                    },
                })
            );
            return false;
        } else if (evnt.key === 'Escape') {
            this.renameMode = false;
            this.newName = '';

            evnt.stopPropagation();
            evnt.stopImmediatePropagation();
            evnt.preventDefault();
            return false;
        }

        return true;
    }
}

export class FilterSetElementTest extends FilterSetElement {
    @api set filterSet(v) {
        super.filterSet = v;
    }
    get filterSet() {
        return super.filterSet;
    }

    @api set renameMode(v) {
        super.renameMode = v;
    }
    get renameMode() {
        return super.renameMode;
    }

    @api get filterName() {
        return super.filterName;
    }

    @api get shareType() {
        return super.shareType;
    }

    @api get ownerName() {
        return super.ownerName;
    }

    @api get createdDate() {
        return super.createdDate;
    }

    @api get pinLabel() {
        return super.pinLabel;
    }
}
