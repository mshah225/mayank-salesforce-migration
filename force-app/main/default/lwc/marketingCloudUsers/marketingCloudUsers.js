import {LightningElement, wire, track} from 'lwc';
import getUsers from '@salesforce/apex/MarketingCloudUsersController.getUsersFromMarketingCloud';
export default class MarketingCloudUsers extends LightningElement {
    _allData = [];
    @track data = [];
    pagesize = 100;
    loading = true;

    // Sorting
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    // Datatable
    columns = [
        {
            label: 'Created Date',
            fieldName: 'createdDate',
            type: 'date',
            sortable: true,
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: true,
            },
        },
        {
            label: 'Id',
            fieldName: 'id',
            type: 'string',
            sortable: true,
        },
        {
            label: 'Customer Key',
            fieldName: 'customerKey',
            type: 'string',
            sortable: false,
        },
        {
            label: 'Account User Id',
            fieldName: 'accountUserId',
            type: 'string',
            sortable: true,
        },
        {
            label: 'User Id',
            fieldName: 'userId',
            type: 'string',
            sortable: true,
        },
        {
            label: 'Name',
            fieldName: 'name',
            type: 'string',
            sortable: true,
        },
        {
            label: 'Email',
            fieldName: 'email',
            type: 'email',
            sortable: true,
        },
        {
            label: 'Must Change Password',
            fieldName: 'mustChangePassword',
            type: 'boolean',
            sortable: true,
        },
        {
            label: 'Is Active',
            fieldName: 'activeFlag',
            type: 'boolean',
            sortable: true,
        },
        {
            label: 'Is Deleted',
            fieldName: 'deleted',
            type: 'boolean',
            sortable: true,
        },
        {
            label: 'Last Successful Login',
            fieldName: 'lastSuccessfulLogin',
            type: 'date',
            sortable: true,
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: true,
            },
        },
        {
            label: 'Is API User',
            fieldName: 'isAPIUser',
            type: 'boolean',
            sortable: true,
        },
        {
            label: 'Notification Email Address',
            fieldName: 'notificationEmailAddress',
            type: 'email',
            sortable: true,
        },
        {
            label: 'Is Locked',
            fieldName: 'isLocked',
            type: 'boolean',
            sortable: true,
        },
        {
            label: 'Default Business Unit',
            fieldName: 'defaultBusinessUnit',
            type: 'string',
            sortable: true,
        },
    ];

    /**
     * Check for data
     */
    get hasData() {
        return this._allData.length > 0 ? true : false;
    }

    /**
     * Get users
     */
    @wire(getUsers)
    wiredUsers({error, data}) {
        if (data) {
            this.data = data;
            this._allData = data;
            this.loading = false;
        } else if (error) {
            this.error = error;
            this.data = undefined;
            this.loading = false;
        }
    }

    /**
     * On key event for search box
     * @param {*} event
     */
    handleKeyChange(event) {
        this.data = this.filterByValue(this._allData, event.target.value);
    }

    /**
     * Filter array of objects by value
     * @param {*} array
     * @param {*} string
     * @returns
     */
    filterByValue(array, string) {
        return array.filter(function (o) {
            return Object.keys(o).some(function (k) {
                return o[k].toString().toLowerCase().indexOf(string) !== -1;
            });
        });
    }

    /**
     * Export data to csv download
     */
    exportCSV() {
        let csv = '';
        let header = Object.keys(this._allData[0]).join(',');
        let values = this._allData.map((o) => Object.values(o).join(',')).join('\n');

        csv += header + '\n' + values;

        let element = 'data:application/vnd.ms-excel,' + encodeURIComponent(csv);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'MCUsers.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    /**
     * Sort contents of table column
     * @param {*} field
     * @param {*} reverse
     * @param {*} primer
     * @returns
     */
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    /**
     * Callback function for sorting columns
     */
    onHandleSort = (event) => {
        const {fieldName: sortedBy, sortDirection} = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    };
}
