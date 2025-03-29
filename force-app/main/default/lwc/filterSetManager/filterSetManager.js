import {createRecord, updateRecord, deleteRecord} from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';

import FILTER_SET_ID_FIELD from '@salesforce/schema/Filter_Set__c.Id';
import FILTER_SET_NAME_FIELD from '@salesforce/schema/Filter_Set__c.Name';

import FSUA_OBJECT from '@salesforce/schema/Filter_Set_User_Association__c';
import FSUA_ID_FIELD from '@salesforce/schema/Filter_Set_User_Association__c.Id';
import FSUA_USER_FIELD from '@salesforce/schema/Filter_Set_User_Association__c.User__c';
import FSUA_FILTER_SET_FIELD from '@salesforce/schema/Filter_Set_User_Association__c.Filter_Set__c';
import FSUA_PINNED_FIELD from '@salesforce/schema/Filter_Set_User_Association__c.Pinned__c';

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

export default class FilterSetManager {
    records;
    constructor(records) {
        this.records = records;

        // Mark each as Pinned__c or not
        for (let fs of records)
            fs.Pinned__c =
                fs.Filter_Set_User_Associations__r.filter((fsua) => fsua.User__c === Id)[0]?.Pinned__c ?? false;
    }

    /**
     * Get the list of filter sets used to construct this filter set manager
     * This will closely match the records passed in the constructor, but each
     * filter set will have a parameter `Pinned__c` to indicate if this filter
     * set is pinned by the current user
     *
     * @returns {FilterSet[]} Get a list of filter sets
     */
    getAll() {
        return this.records;
    }

    /**
     * Rename a filter set.
     *
     * @param {String} filterSetId Id of the filter set we need to change the name of
     * @param {String} name The new name
     * @returns Promise that resolves once it has been renamed
     */
    rename(filterSetId, name) {
        const fields = {};
        fields[FILTER_SET_ID_FIELD.fieldApiName] = filterSetId;
        fields[FILTER_SET_NAME_FIELD.fieldApiName] = name;

        const recordInput = {fields};

        return updateRecord(recordInput);
    }

    /**
     * Pin or unpin a filter set.
     *
     * @param {String} filterSetId Id of the filter set this user wants to pin or unpin
     * @param {Boolean} pinned TRUE to pin, FALSE to unpin
     * @returns Promise that resolves once it has been pinned/unpinned
     */
    pin(filterSetId, pinned) {
        let filterSet = this.records.filter((fs) => fs.Id === filterSetId)[0];
        let filterSetUserAssociation = filterSet.Filter_Set_User_Associations__r.filter(
            (fsua) => fsua.User__c === Id
        )[0];

        const fields = {};
        fields[FSUA_ID_FIELD.fieldApiName] = filterSetUserAssociation.Id;
        fields[FSUA_PINNED_FIELD.fieldApiName] = pinned;

        const recordInput = {fields};

        return updateRecord(recordInput);
    }

    /**
     * Change who a filter set is shared with, this will add and remove Filter Set
     * User Associations (FSUA) for this filter set. The only FSUA it will not modify
     * is the owner's FSUA.
     *
     * @param {String} filterSetId Id of the filter set to modify sharing for
     * @param {String[]} userIds List of users this filter set should be shared with
     * @returns Promise that resolves once sharing changes have applied
     */
    share(filterSetId, userIds) {
        let filterSet = this.records.filter((fs) => fs.Id === filterSetId)[0];

        let fsuas = filterSet.Filter_Set_User_Associations__r.filter((fsua) => fsua.User__c !== Id);
        let alreadyHaveFSUALs = fsuas.map((fsua) => fsua.User__c);

        // Any FSUA that exist but aren't in the new list
        // (excluding the owner since the owner cannot be unshared with)
        let fSUAsToRemove = fsuas.filter(
            (fsua) => fsua.User__c !== filterSet.Owner__c && !userIds.includes(fsua.User__c)
        );
        // Any users in the list that don't have a FSUA
        let usersThatNeedNewFSUA = userIds.filter((userId) => !alreadyHaveFSUALs.includes(userId));

        let promiseList = [];

        for (const removeMe of fSUAsToRemove) {
            promiseList.push(deleteRecord(removeMe.Id));
        }
        for (const userId of usersThatNeedNewFSUA) {
            const fields = {};
            fields[FSUA_USER_FIELD.fieldApiName] = userId;
            fields[FSUA_FILTER_SET_FIELD.fieldApiName] = filterSet.Id;

            const recordInput = {
                apiName: FSUA_OBJECT.objectApiName,
                fields,
            };

            promiseList.push(createRecord(recordInput));
        }

        return Promise.all(promiseList);
    }

    /**
     * Remove a filter set, either removing the filter set completely, or removing
     * FSUA to unshare it with specified users
     *
     * @typedef {Object} DeleteDetails
     * @property {Boolean} delete Do a complete delete of the filter set
     * @property {String[]} unshare List of FSUAs Ids to unshare with
     *
     * @param {String} filterSetId Id of the filter set to remove or unshare
     * @param {DeleteDetails} deleteDetails Object describing the remove details
     * @returns Promise that resolves once removal changes have applied
     */
    remove(filterSetId, deleteDetails) {
        let prm;

        if (deleteDetails.delete === true) {
            // Delete the filter set outright
            prm = deleteRecord(filterSetId);
        } else {
            // Unshare with some users
            let promiseList = [];
            for (const fsuaId of deleteDetails.unshare) promiseList.push(deleteRecord(fsuaId));
            prm = Promise.all(promiseList);
        }

        return prm;
    }
}
