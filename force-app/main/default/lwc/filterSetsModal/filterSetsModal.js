import LightningModal from 'lightning/modal';
import {api, wire} from 'lwc';
import {gql, graphql} from 'lightning/uiGraphQLApi';
import {updateRecord} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import {extractErrorMessages} from 'c/helperFunctions';

import FSUA_ID_FIELD from '@salesforce/schema/Filter_Set_User_Association__c.Id';
import FSUA_PINNED_FIELD from '@salesforce/schema/Filter_Set_User_Association__c.Pinned__c';

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
                        User_Filter_Set_Preference__c(where: {User__c: {eq: $userId}}) {
                            edges {
                                node {
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

    get filterSetPreferences() {
        return (this.wireData?.uiapi?.query?.User_Filter_Set_Preference__c?.edges ?? []).map((userPref) => {
            return {
                Sort_Order__c: userPref?.node?.Sort_Order__c?.value,
            };
        })[0];
    }
    get allFilterSets() {
        return (this.wireData?.uiapi?.query?.Filter_Set__c?.edges ?? []).map((filterSet) => {
            return {
                Id: filterSet?.node?.Id,
                Name: filterSet?.node?.Name?.value,
                Owner__c: filterSet?.node?.Owner__c?.value,
                Owner__r: {
                    Name: filterSet?.node?.Owner__r?.Name?.value,
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
     * Nonpinned filter sets
     */
    get nonpinnedFilterSets() {
        return this.allFilterSets.filter((filterSet) => !filterSet.Pinned__c);
    }
    get numberNonpinned() {
        return this.nonpinnedFilterSets.length;
    }
    get hasNonpinnedFilterSets() {
        return this.nonpinnedFilterSets.length > 0;
    }

    /**
     * Each pin event detail contains the filterSetId of which filter set this is for
     * And whether it should be pinned or not
     *
     * @typedef {Object} PinEventDetail
     * @property {String} filterSetId Filter Set Id
     * @property {Boolean} pinned Should this be pinned, or unpinned?
     */

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
                        title: eventDetail.pinned ? 'Filter set pinned' : 'Filter set unpinned',
                        message: 'Success',
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
                    })
                );
            });
    }

    handleApplyEvent(evnt) {}
    handleShareEvent(evnt) {}
    handleViewEvent(evnt) {}
    handleRemoveEvent(evnt) {}
    handleRenameEvent(evnt) {}

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
