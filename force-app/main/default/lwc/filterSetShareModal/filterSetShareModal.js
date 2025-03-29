import LightningModal from 'lightning/modal';
import {api, wire, track} from 'lwc';
import Id from '@salesforce/user/Id';
import getShareOptions from '@salesforce/apex/FilterSetController.getShareOptions';
import {extractErrorMessages} from 'c/helperFunctions';

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
 * @property {String} Alias ASURITE of the user
 */
export default class FilterSetShareModal extends LightningModal {
    /** @type {FilterSet} */
    @api set filterSet(v) {
        this._filterSet = v;
        // Start shared with list based on passed object
        this.sharedWith = (v?.Filter_Set_User_Associations__r ?? [])
            .map((fsua) => fsua.User__c)
            .filter((fsua) => fsua.User__c !== Id);
    }
    get filterSet() {
        return this._filterSet;
    }
    _filterSet;

    get filterName() {
        return this.filterSet?.Name ?? '';
    }

    // List of ids for users this is shared with
    @track
    sharedWith = [];
    get sharedWithStr() {
        return this.sharedWith.join(';');
    }

    /**
     * Get a list of all users the current user can transfer to
     */
    @wire(getShareOptions, {})
    gotShareOptions(result) {
        const {data, error} = result;

        if (data !== undefined) {
            this.shareOptionsData = data;
            this.shareOptionsError = undefined;
        } else if (error !== undefined) {
            this.shareOptionsError = error;
            this.shareOptionsData = undefined;
        }
    }
    shareOptionsData;
    shareOptionsError;

    /**
     * Get the list of all possible users we can share with - this will be those we are already
     * sharing with in addition to any we can add
     */
    get shareOptionList() {
        let allShareOptions = [];

        // Add any that we are already sharing with
        for (const fsua of this.filterSet?.Filter_Set_User_Associations__r ?? []) {
            allShareOptions.push({
                label: [fsua.User__r.Name, fsua.User__r.Alias].filter((v) => !!v).join(' - '),
                value: fsua.User__c,
            });
        }

        // Add any user we are allowed to share with
        for (const userOpt of this.shareOptionsData ?? []) {
            allShareOptions.push(userOpt);
        }

        // Remove duplicates and the current user, then
        // sort with shared first, and then alphabetically
        let seen = [];
        return allShareOptions
            .filter((v) => {
                if (v.value === Id) return false;
                if (seen.includes(v.value)) return false;
                seen.push(v.value);
                return true;
            })
            .sort((a, b) => {
                if (this.sharedWith.includes(a.value) && this.sharedWith.includes(b.value)) {
                    return a.label.localeCompare(b.label);
                } else if (this.sharedWith.includes(a.value)) {
                    return -1;
                } else if (this.sharedWith.includes(b.value)) {
                    return 1;
                }
                return a.label.localeCompare(b.label);
            });
    }

    /**
     * Options that are selected in pill form
     */
    get pillList() {
        let sharedWithIdToLabel = {};

        // Mapping based on users I can share with
        for (const userOption of this.shareOptionList) {
            sharedWithIdToLabel[userOption.value] = userOption.label;
        }

        return this.sharedWith.map((v) => {
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

    selectAll() {
        this.sharedWith = this.shareOptionList.map((v) => v.value);
    }
    removeAll() {
        this.sharedWith = [];
    }

    closeModal() {
        this.close();
    }
    saveChanges() {
        let shareWithIds = [...this.sharedWith];
        this.close({userIds: shareWithIds});
    }

    /**
     * Loading or error
     */
    get isLoading() {
        return this.shareOptionsData === undefined;
    }
    get hasError() {
        return this.shareOptionsError !== undefined;
    }
    get errorMessage() {
        return extractErrorMessages(this.shareOptionsError)[0];
    }
}
