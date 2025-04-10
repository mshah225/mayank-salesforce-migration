import LightningModal from 'lightning/modal';
import Id from '@salesforce/user/Id';
import {api, track} from 'lwc';

/**
 * @typedef {Object} FilterSet Each filter set object
 * @property {String} Id If of the filter set
 * @property {String} Name Name of the filter set
 * @property {String} OwnerId Id of the user who owns this filter set
 * @property {UserRecord} Owner User who owns this filter set
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
 * @property {String} Alias ASURITE of the user
 */

export default class FilterSetRemoveModal extends LightningModal {
    @api set filterSet(v) {
        this._filterSet = v;
        // Start shared with list based on passed object
        this.sharedWith = (v?.Filter_Set_User_Associations__r ?? []).map((fsua) => fsua.User__c);
    }
    get filterSet() {
        return this._filterSet;
    }
    _filterSet;

    get filterSetName() {
        return this.filterSet?.Name;
    }

    get isPrivateFilter() {
        return this.filterSet?.Is_Shared__c === false;
    }
    get sharedWithMe() {
        return this.filterSet?.Is_Shared__c && this.filterSet?.OwnerId !== Id;
    }
    get sharedByMe() {
        return this.filterSet?.Is_Shared__c && this.filterSet?.OwnerId === Id;
    }

    // List of ids for users this is shared with
    @track
    sharedWith = [];
    get sharedWithStr() {
        return this.sharedWith.join(';');
    }

    /**
     * Swap between unshare with individual users mode
     * and delete the entire filter set mode
     */
    modeOptions = [
        {
            label: 'Remove entire filter set',
            value: 'delete',
        },
        {
            label: 'Remove shared users individually',
            value: 'unshare',
        },
    ];
    modeValue = 'unshare';
    modeSelect(evnt) {
        this.modeValue = evnt.detail.value;
    }
    get isUnshareMode() {
        return this.modeValue === 'unshare';
    }

    /**
     * Users you can share or unshare with
     */
    get userOptions() {
        return this.filterSet.Filter_Set_User_Associations__r.map((fsua) => {
            let label = fsua?.User__r?.Name ?? '???';
            if (fsua?.User__r?.Alias != null) label += ' - ' + fsua?.User__r?.Alias;

            return {
                label,
                value: fsua.User__c,
            };
        }).filter((v) => v.value !== Id);
    }

    /**
     * Options that are selected in pill form
     */
    get pillList() {
        let sharedWithIdToLabel = {};

        // Mapping based on users I can share with
        for (const userOption of this.userOptions) {
            sharedWithIdToLabel[userOption.value] = userOption.label;
        }

        return this.sharedWith
            .filter((v) => v.value !== Id)
            .map((v) => {
                return {
                    Name: sharedWithIdToLabel[v],
                    Id: v,
                };
            });
    }

    /**
     * Handle a change event whenever options are modified in combobox
     */
    handleChange(evnt) {
        if (evnt.detail.value.length > 0) this.sharedWith = evnt.detail.value.split(';');
        else this.sharedWith = [];
    }
    /**
     * Handle a remove event when pills are removed
     */
    handleRemove(evnt) {
        this.sharedWith.splice(this.sharedWith.indexOf(evnt.currentTarget?.dataset?.userid), 1);
    }

    /**
     * Clear selection button
     */
    removeAll() {
        this.sharedWith = [];
    }

    /**
     * Exit without deleting anything
     */
    closeModal() {
        this.close();
    }
    /**
     * Close with details to delete
     */
    saveChanges() {
        if (this.isPrivateFilter) {
            this.close({delete: true});
        } else if (this.sharedWithMe) {
            let unshareList = [];
            for (const fsua of this.filterSet?.Filter_Set_User_Associations__r ?? [])
                if (fsua.User__c === Id) unshareList.push(fsua.Id);
            this.close({delete: false, unshare: unshareList});
        } else if (this.sharedByMe) {
            let unshareList = [];
            for (const fsua of this.filterSet?.Filter_Set_User_Associations__r ?? [])
                if (fsua.User__c === Id) continue;
                else if (!this.sharedWith.includes(fsua.User__c)) unshareList.push(fsua.Id);
            this.close({delete: this.modeValue === 'delete', unshare: unshareList});
        }
    }
}
