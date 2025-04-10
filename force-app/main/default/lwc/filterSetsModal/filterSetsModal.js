import LightningModal from 'lightning/modal';
import {api, wire} from 'lwc';
import {gql, graphql, refreshGraphQL} from 'lightning/uiGraphQLApi';
import {createRecord, updateRecord, deleteRecord} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import {parseBoolean, extractErrorMessages} from 'c/helperFunctions';
import FilterSetShareModal from 'c/filterSetShareModal';
import FilterSetRemoveModal from 'c/filterSetRemoveModal';
import checkIfCanShare from '@salesforce/apex/FilterSetController.checkIfCanShare';
import GraphqlManager from 'c/graphqlManager';
import FilterSetManager from 'c/filterSetManager';

import UFSP_OBJECT from '@salesforce/schema/User_Filter_Set_Preference__c';
import UFSP_ID_FIELD from '@salesforce/schema/User_Filter_Set_Preference__c.Id';
import UFSP_SORT_ORDER_FIELD from '@salesforce/schema/User_Filter_Set_Preference__c.Sort_Order__c';

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

export default class FilterSetsModal extends LightningModal {
    @api set forceRefresh(v) {
        this._forceRefresh = parseBoolean(v);
    }
    get forceRefresh() {
        return this._forceRefresh;
    }
    _forceRefresh = false;

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
                                    OwnerId {
                                        value
                                    }
                                    Owner {
                                        ... on User {
                                            Name {
                                                value
                                            }
                                            Alias {
                                                value
                                            }
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
    gotData(resp) {
        const {data, errors} = resp;

        if (data !== undefined) {
            /** If this field is set, then we will invalidate the cache and force the modal to get more recent data */
            if (this.forceRefresh) {
                this.forceRefresh = false;
                refreshGraphQL(resp);
                return;
            }

            let graphqlManager = new GraphqlManager(data);
            this.filterSetManager = new FilterSetManager(graphqlManager.unwrap().Filter_Set__c);
            this.filterSetPreferences = graphqlManager.unwrap().User_Filter_Set_Preference__c[0];
            this.wireError = undefined;
        } else if (errors !== undefined) {
            this.wireError = errors;
            this.filterSetManager = undefined;
            this.filterSetPreferences = undefined;
        }
    }
    get gqlVariables() {
        return {
            userId: Id,
        };
    }

    filterSetManager = undefined;
    filterSetPreferences = undefined;
    wireError = undefined;

    @wire(checkIfCanShare, {})
    forCheckIfCanShare({data, error}) {
        if (data !== undefined) {
            this.allowedToShare = data;
        } else if (error !== undefined) {
            this.allowedToShare = false;
        }
    }
    allowedToShare = false;

    /** @type {FilterSet[]} */
    get allFilterSets() {
        return this.filterSetManager?.getAll() ?? [];
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
                    filterSet.Owner.Name.toLowerCase().includes(this.searchText.toLowerCase())
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
                        return a.Owner.Name.localeCompare(b.Owner.Name);
                    } else if (this.sortOrder === 'Owner Name Desc') {
                        return -1 * a.Owner.Name.localeCompare(b.Owner.Name);
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
        this.filterSetManager
            .pin(evnt.detail.filterSetId, evnt.detail.pinned)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: evnt.detail.pinned ? 'Filter set pinned' : 'Filter set unpinned',
                        variant: 'success',
                    })
                );
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: `Error when ${evnt.detail.pinned ? 'pinning' : 'unpinning'} filter set`,
                        message: extractErrorMessages(error)[0],
                        variant: 'error',
                        mode: 'sticky',
                    })
                );
            });
    }

    /**
     * Handle applying a filter set
     */
    handleApplyEvent(evnt) {
        this.close({
            action: {
                apply: true,
                filterSetId: evnt.detail?.filterSetId,
                filterSet: evnt.detail?.filterSet,
            },
        });
    }

    /**
     * Handle sharing a filter set
     */
    handleShareEvent(evnt) {
        const eventDetail = evnt.detail;
        let filterSet = this.allFilterSets.filter((fs) => fs.Id === eventDetail.filterSetId)[0];

        FilterSetShareModal.open({
            size: 'medium',
            filterSet: filterSet,
        })
            .then((resp) => {
                if (resp?.userIds != null) {
                    return this.filterSetManager.share(eventDetail.filterSetId, resp.userIds).then(() => {
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

    /**
     * Handle viewing a filter set
     */
    handleViewEvent(evnt) {
        this.close({
            action: {
                apply: false,
                filterSetId: evnt.detail?.filterSetId,
                filterSet: evnt.detail?.filterSet,
            },
        });
    }

    /**
     * Handle removing a filter set
     * @param {CustomEvent} evnt
     */
    handleRemoveEvent(evnt) {
        const eventDetail = evnt.detail;

        let filterSet = this.allFilterSets.filter((fs) => fs.Id === eventDetail.filterSetId)[0];

        FilterSetRemoveModal.open({
            size: 'small',
            filterSet: filterSet,
        })
            .then((val) => {
                if (val?.delete != null) {
                    return this.filterSetManager.remove(filterSet.Id, val).then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: val.delete
                                    ? 'Filter set has been removed'
                                    : 'Filter set has been unshared with selected users',
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

    /**
     * Rename a filter set
     */
    handleRenameEvent(evnt) {
        this.filterSetManager
            .rename(evnt.detail.filterSetId, evnt.detail.value)
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
        return this.filterSetManager === undefined;
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
    @api set filterSetPreferences(v) {
        super.filterSetPreferences = v;
    }
    get filterSetPreferences() {
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
