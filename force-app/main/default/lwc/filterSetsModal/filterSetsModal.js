import LightningModal from 'lightning/modal';
import {api, wire} from 'lwc';
import {gql, graphql} from 'lightning/uiGraphQLApi';
import {createRecord, updateRecord, deleteRecord} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import Id from '@salesforce/user/Id';
import {extractErrorMessages} from 'c/helperFunctions';
import FilterSetShareModal from 'c/filterSetShareModal';
import checkIfCanShare from '@salesforce/apex/FilterSetController.checkIfCanShare';

import FILTER_SET_ID_FIELD from '@salesforce/schema/Filter_Set__c.Id';
import FILTER_SET_NAME_FIELD from '@salesforce/schema/Filter_Set__c.Name';

import FSUA_OBJECT from '@salesforce/schema/Filter_Set_User_Association__c';
import FSUA_ID_FIELD from '@salesforce/schema/Filter_Set_User_Association__c.Id';
import FSUA_USER_FIELD from '@salesforce/schema/Filter_Set_User_Association__c.User__c';
import FSUA_FILTER_SET_FIELD from '@salesforce/schema/Filter_Set_User_Association__c.Filter_Set__c';
import FSUA_PINNED_FIELD from '@salesforce/schema/Filter_Set_User_Association__c.Pinned__c';

import UFSP_OBJECT from '@salesforce/schema/User_Filter_Set_Preference__c';
import UFSP_ID_FIELD from '@salesforce/schema/User_Filter_Set_Preference__c.Id';
import UFSP_SORT_ORDER_FIELD from '@salesforce/schema/User_Filter_Set_Preference__c.Sort_Order__c';

/**
 * @typedef {Object} PinEventDetail Each pin event detail contains the filterSetId of which filter set this is for
 *      and whether it should be pinned or not
 * @property {String} filterSetId Filter Set Id
 * @property {Boolean} pinned Should this be pinned, or unpinned?
 *
 * @typedef {Object} RenameEventDetail Each rename event detail contains the filterSetId of which filter set this is for and its new name
 * @property {String} filterSetId Filter Set Id
 * @property {String} value New name for filter set
 *
 * @typedef {Object} ShareEventDetail Each share event contains only the filter set id
 * @property {String} filterSetId Filter Set Id
 *
 * @typedef {Object} RemoveEventDetail Each remove event contains only the filter set id
 * @property {String} filterSetId Filter Set Id
 *
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

export default class FilterSetsModal extends LightningModal {
    /**
     * Get all the details for all filter sets the current user has access to
     */
    @wire(graphql, {
        query: gql`
            query FilterSetQuery($userId: ID!) {
                uiapi {
                    query {
                        Filter_Set__c(
                            where: {
                                and: [
                                    {
                                        Id: {
                                            inq: {
                                                Filter_Set_User_Association__c: {User__c: {eq: $userId}}
                                                ApiName: "Filter_Set__c"
                                            }
                                        }
                                    }
                                    {RecordType: {DeveloperName: {eq: "Advisor_Portal"}}}
                                ]
                            }
                        ) {
                            edges {
                                node {
                                    Id
                                    Name {
                                        value
                                    }
                                    Owner__c {
                                        value
                                    }
                                    Owner__r {
                                        Name {
                                            value
                                        }
                                        Alias {
                                            value
                                        }
                                    }
                                    Value__c {
                                        value
                                    }
                                    Is_Shared__c {
                                        value
                                    }
                                    CreatedDate {
                                        value
                                    }

                                    Filter_Set_User_Associations__r {
                                        edges {
                                            node {
                                                Id
                                                User__c {
                                                    value
                                                }
                                                User__r {
                                                    Name {
                                                        value
                                                    }
                                                    Alias {
                                                        value
                                                    }
                                                }
                                                Pinned__c {
                                                    value
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        User_Filter_Set_Preference__c(where: {OwnerId: {eq: $userId}}) {
                            edges {
                                node {
                                    Id
                                    Sort_Order__c {
                                        value
                                    }
                                }
                            }
                        }
                    }
                }
            }
        `,
        variables: '$gqlVariables',
    })
    gotData({data, errors}) {
        if (data !== undefined) {
            this.wireData = data;
            this.wireError = undefined;
        } else if (errors !== undefined) {
            this.wireError = errors;
            this.wireData = undefined;
        }
    }
    get gqlVariables() {
        return {
            userId: Id,
        };
    }

    wireData = undefined;
    wireError = undefined;

    @wire(checkIfCanShare, {})
    forCheckIfCanShare({data, errors}) {
        if (data !== undefined) {
            this.allowedToShare = data;
        } else if (errors !== undefined) {
            this.allowedToShare = false;
        }
    }
    allowedToShare = false;

    get filterSetPreferences() {
        return (this.wireData?.uiapi?.query?.User_Filter_Set_Preference__c?.edges ?? []).map((userPref) => {
            return {
                Id: userPref?.node?.Id,
                Sort_Order__c: userPref?.node?.Sort_Order__c?.value,
            };
        })[0];
    }
    /** @type {FilterSet[]} */
    get allFilterSets() {
        return (this.wireData?.uiapi?.query?.Filter_Set__c?.edges ?? []).map((filterSet) => {
            return {
                Id: filterSet?.node?.Id,
                Name: filterSet?.node?.Name?.value,
                Owner__c: filterSet?.node?.Owner__c?.value,
                Owner__r: {
                    Name: filterSet?.node?.Owner__r?.Name?.value,
                    Alias: filterSet?.node?.Owner__r?.Alias?.value,
                },
                Value__c: filterSet?.node?.Value__c?.value,
                Is_Shared__c: filterSet?.node?.Is_Shared__c?.value,
                CreatedDate: filterSet?.node?.CreatedDate?.value,
                Filter_Set_User_Associations__r: (filterSet?.node?.Filter_Set_User_Associations__r?.edges ?? []).map(
                    (fsua) => {
                        return {
                            Id: fsua?.node?.Id,
                            User__c: fsua?.node?.User__c?.value,
                            User__r: {
                                Name: fsua?.node?.User__r?.Name?.value,
                                Alias: fsua?.node?.User__r?.Alias?.value,
                            },
                        };
                    }
                ),
                Pinned__c:
                    (filterSet?.node?.Filter_Set_User_Associations__r?.edges ?? []).filter(
                        (fsua) => fsua?.node?.User__c?.value === Id
                    )[0]?.node?.Pinned__c?.value ?? false,
            };
        });
    }

    /**
     * Pinned filter sets
     */
    pinnedDropdownIsOpen = true;
    get pinnedDropdownText() {
        return this.pinnedDropdownIsOpen ? 'Hide pinned fitler sets' : 'Show pinned filter sets';
    }
    get pinnedDropdownIcon() {
        return this.pinnedDropdownIsOpen ? 'utility:down' : 'utility:right';
    }
    togglePinnedSection() {
        this.pinnedDropdownIsOpen = !this.pinnedDropdownIsOpen;
    }

    get pinnedFilterSets() {
        return this.allFilterSets.filter((filterSet) => filterSet.Pinned__c);
    }
    get numberPinned() {
        return this.pinnedFilterSets.length;
    }

    /**
     * Sorting filter sets
     */
    sortByOptions = [
        {
            label: 'Filter Name Asc',
            value: 'Filter Name Asc',
        },
        {
            label: 'Filter Name Desc',
            value: 'Filter Name Desc',
        },
        {
            label: 'Created Date Asc',
            value: 'Created Date Asc',
        },
        {
            label: 'Created Date Desc',
            value: 'Created Date Desc',
        },
        {
            label: 'Owner Name Asc',
            value: 'Owner Name Asc',
        },
        {
            label: 'Owner Name Desc',
            value: 'Owner Name Desc',
        },
        {
            label: 'Private First',
            value: 'Private First',
        },
        {
            label: 'Shared First',
            value: 'Shared First',
        },
    ];

    /**
     * Whenever search text is entered, we need to search the list to only include those that contain this text
     * @param {CustomEvent} evnt This is a change event
     */
    handleSearch(evnt) {
        this.searchText = evnt.detail.value;
    }
    searchText;
    get isSearching() {
        return !!this.searchText;
    }

    /**
     * Whenever the sort dropdown is changed we need to apply the sort and save it as the new default for this user
     * @param {CustomEvent} evnt This is a change event
     */
    handleSort(evnt) {
        this._sortOrder = evnt.detail.value;

        let savePromise = null;

        if (this.filterSetPreferences?.Id == null) {
            const fields = {};
            fields[UFSP_SORT_ORDER_FIELD.fieldApiName] = this.sortOrder;

            const recordInput = {
                apiName: UFSP_OBJECT.objectApiName,
                fields,
            };

            savePromise = createRecord(recordInput);
        } else {
            const fields = {};
            fields[UFSP_ID_FIELD.fieldApiName] = this.filterSetPreferences?.Id;
            fields[UFSP_SORT_ORDER_FIELD.fieldApiName] = this.sortOrder;

            const recordInput = {
                fields,
            };

            savePromise = updateRecord(recordInput);
        }

        // If saving throws an error, show that to user. Success is not noteworthy.
        savePromise.catch((error) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while saving filter order',
                    message: extractErrorMessages(error)[0],
                    variant: 'error',
                    mode: 'sticky',
                })
            );
        });
    }
    _sortOrder;
    get sortOrder() {
        return this._sortOrder || this.filterSetPreferences?.Sort_Order__c || null;
    }
    get isSorted() {
        return !!this.sortOrder;
    }

    /**
     * Nonpinned filter sets
     */
    get nonpinnedFilterSets() {
        return this.allFilterSets
            .filter((filterSet) => !filterSet.Pinned__c)
            .filter((filterSet) => {
                // Either not in search mode (in which don't do any additional filtering)
                // Or in search mode and need to filter using filter name and owner name
                return (
                    !this.isSearching ||
                    filterSet.Name.toLowerCase().includes(this.searchText.toLowerCase()) ||
                    filterSet.Owner__r.Name.toLowerCase().includes(this.searchText.toLowerCase())
                );
            })
            .sort((a, b) => {
                // If sort has been applied, sort options
                if (this.isSorted) {
                    if (this.sortOrder === 'Filter Name Asc') {
                        return a.Name.localeCompare(b.Name);
                    } else if (this.sortOrder === 'Filter Name Desc') {
                        return -1 * a.Name.localeCompare(b.Name);
                    } else if (this.sortOrder === 'Created Date Asc') {
                        return new Date(a.CreatedDate).getTime() - new Date(b.CreatedDate).getTime();
                    } else if (this.sortOrder === 'Created Date Desc') {
                        return -1 * (new Date(a.CreatedDate).getTime() - new Date(b.CreatedDate).getTime());
                    } else if (this.sortOrder === 'Owner Name Asc') {
                        return a.Owner__r.Name.localeCompare(b.Owner__r.Name);
                    } else if (this.sortOrder === 'Owner Name Desc') {
                        return -1 * a.Owner__r.Name.localeCompare(b.Owner__r.Name);
                    } else if (this.sortOrder === 'Private First') {
                        return a.Is_Shared__c === b.Is_Shared__c ? 0 : !a.Is_Shared__c ? -1 : 1;
                    } else if (this.sortOrder === 'Shared First') {
                        return a.Is_Shared__c === b.Is_Shared__c ? 0 : a.Is_Shared__c ? -1 : 1;
                    }
                }
                return 0;
            });
    }
    get numberNonpinned() {
        return this.nonpinnedFilterSets.length;
    }
    get hasNonpinnedFilterSets() {
        return this.nonpinnedFilterSets.length > 0;
    }

    /**
     * Either pin or unpin a filter set
     * @param {CustomEvent} evnt
     */
    handlePinEvent(evnt) {
        /** @type {PinEventDetail} */
        const eventDetail = evnt.detail;

        let filterSet = this.allFilterSets.filter((fs) => fs.Id === eventDetail.filterSetId)[0];
        let filterSetUserAssociation = filterSet.Filter_Set_User_Associations__r.filter(
            (fsua) => fsua.User__c === Id
        )[0];

        const fields = {};
        fields[FSUA_ID_FIELD.fieldApiName] = filterSetUserAssociation.Id;
        fields[FSUA_PINNED_FIELD.fieldApiName] = eventDetail.pinned;

        const recordInput = {fields};

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: eventDetail.pinned ? 'Filter set pinned' : 'Filter set unpinned',
                        variant: 'success',
                    })
                );
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: `Error when ${eventDetail.pinned ? 'pinning' : 'unpinning'} filter set`,
                        message: extractErrorMessages(error)[0],
                        variant: 'error',
                        mode: 'sticky',
                    })
                );
            });
    }

    handleApplyEvent(evnt) {}
    handleShareEvent(evnt) {
        if (!this.allowedToShare) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'You are not allowed to share filter sets',
                    message: ' ',
                    variant: 'error',
                })
            );
        }

        /** @type {ShareEventDetail} */
        const eventDetail = evnt.detail;
        let filterSet = this.allFilterSets.filter((fs) => fs.Id === eventDetail.filterSetId)[0];

        FilterSetShareModal.open({
            size: 'medium',
            filterSet: filterSet,
        })
            .then((resp) => {
                if (resp?.userIds != null) {
                    let shareWithUserIds = resp.userIds;
                    shareWithUserIds.push(Id);

                    let fsuas = filterSet.Filter_Set_User_Associations__r ?? [];
                    let alreadyHaveFSUALs = fsuas.map((fsua) => fsua.User__c);

                    // Any FSUA that exist but aren't in the new list
                    // (exlcuding for the current user since the own users sharing is not managed using this button)
                    let fSUAsToRemove = fsuas.filter((fsua) => !shareWithUserIds.includes(fsua.User__c));
                    // Any users in the list that don't have a FSUA
                    let usersThatNeedNewFSUA = shareWithUserIds.filter((userId) => !alreadyHaveFSUALs.includes(userId));

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

                    return Promise.all(promiseList).then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Filter set has been shared',
                                message: ' ',
                                variant: 'success',
                            })
                        );
                    });
                }
                // Cancelled out of modal and not applying changes
                return Promise.resolve();
            })
            .catch((e) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: extractErrorMessages(e)[0],
                        variant: 'error',
                    })
                );
            });
    }
    handleViewEvent(evnt) {}

    /**
     * Handle removing a filter set
     * @param {CustomEvent} evnt
     */
    handleRemoveEvent(evnt) {
        /** @type {RemoveEventDetail} */
        const eventDetail = evnt.detail;

        let filterSet = this.allFilterSets.filter((fs) => fs.Id === eventDetail.filterSetId)[0];
        if (filterSet.Is_Shared__c) {
            // Shared filter, deletion depends on if the user owns this filter set or not
            if (filterSet.Owner__c === Id) {
                // User owns this filter set, which means we need the complicated share/unshare screen
            } else {
                // User does not own this filter set, so we need to unshare it with the current user
                LightningConfirm.open({
                    label: 'Remove filter set',
                    message: `You are removing ${filterSet.Name} from your list`,
                })
                    .then((val) => {
                        if (val === true) {
                            const filterSetUserAssociation = filterSet.Filter_Set_User_Associations__r.filter(
                                (fsua) => fsua.User__c === Id
                            )[0];

                            // Confirmed deletion - actually delete record
                            return deleteRecord(filterSetUserAssociation.Id).then(() => {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success',
                                        message: 'Filter set has been removed',
                                        variant: 'success',
                                    })
                                );
                            });
                        }
                        // Cancelled deletion
                        return Promise.resolve();
                    })
                    .catch((error) => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error when removing filter set',
                                message: extractErrorMessages(error)[0],
                                variant: 'error',
                                mode: 'sticky',
                            })
                        );
                    });
            }
        } else {
            // Private filters are simple, we can just delete it
            LightningConfirm.open({
                label: 'Remove filter set',
                message: `You are removing ${filterSet.Name} from the System`,
            })
                .then((val) => {
                    if (val === true) {
                        // Confirmed deletion - actually delete record
                        return deleteRecord(filterSet.Id).then(() => {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Filter set has been removed',
                                    variant: 'success',
                                })
                            );
                        });
                    }
                    // Cancelled deletion
                    return Promise.resolve();
                })
                .catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error when removing filter set',
                            message: extractErrorMessages(error)[0],
                            variant: 'error',
                            mode: 'sticky',
                        })
                    );
                });
        }
    }

    /**
     * Rename a filter set
     * @param {CustomEvent} evnt
     */
    handleRenameEvent(evnt) {
        /** @type {RenameEventDetail} */
        const eventDetail = evnt.detail;

        const fields = {};
        fields[FILTER_SET_ID_FIELD.fieldApiName] = eventDetail.filterSetId;
        fields[FILTER_SET_NAME_FIELD.fieldApiName] = eventDetail.value;

        const recordInput = {fields};

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Filter set renamed',
                        variant: 'success',
                    })
                );
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while renaming filter set',
                        message: extractErrorMessages(error)[0],
                        variant: 'error',
                        mode: 'sticky',
                    })
                );
            });
    }

    /**
     * Loading and error state
     */
    get isLoading() {
        return this.wireData === undefined;
    }
    get hasError() {
        return this.wireError !== undefined;
    }
    get errorMessage() {
        if (this.wireError !== undefined) return extractErrorMessages(this.wireError)[0];
        return '';
    }
}

export class FilterSetsModalTest extends FilterSetsModal {
    @api get filterSetPreferences() {
        return super.filterSetPreferences;
    }

    @api set pinnedDropdownIsOpen(v) {
        super.pinnedDropdownIsOpen = v;
    }
    get pinnedDropdownIsOpen() {
        return super.pinnedDropdownIsOpen;
    }

    @api get pinnedDropdownText() {
        return super.pinnedDropdownText;
    }
    @api get pinnedDropdownIcon() {
        return super.pinnedDropdownIcon;
    }

    @api get pinnedFilterSets() {
        return super.pinnedFilterSets;
    }
    @api get numberPinned() {
        return super.numberPinned;
    }

    @api set sortByOptions(v) {
        super.sortByOptions = v;
    }
    get sortByOptions() {
        return super.sortByOptions;
    }

    @api get sortOrder() {
        return super.sortOrder;
    }

    @api get nonpinnedFilterSets() {
        return super.nonpinnedFilterSets;
    }
    @api get numberNonpinned() {
        return super.numberNonpinned;
    }
    @api get hasNonpinnedFilterSets() {
        return super.hasNonpinnedFilterSets;
    }

    /**
     * Loading and error state
     */
    @api get isLoading() {
        return super.isLoading;
    }
    @api get hasError() {
        return super.hasError;
    }
    @api get errorMessage() {
        return super.errorMessage;
    }
}
