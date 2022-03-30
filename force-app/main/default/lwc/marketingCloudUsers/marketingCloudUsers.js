import {LightningElement, wire, track} from 'lwc';
import getUsers from '@salesforce/apex/MarketingCloudUserWebService.getUsers';

export default class MarketingCloudUsers extends LightningElement {
    _allData = [];
    @track data = [];
    pagesize = 100;
    loading = true;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    columns = [
        {
            label: 'Created Date',
            fieldName: 'CreatedDate',
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
            fieldName: 'Id',
            type: 'string',
            sortable: true,
        },
        {
            label: 'Customer Key',
            fieldName: 'CustomerKey',
            type: 'string',
            sortable: false,
        },
        {
            label: 'Account User Id',
            fieldName: 'AccountUserId',
            type: 'string',
            sortable: true,
        },
        {
            label: 'User Id',
            fieldName: 'UserId',
            type: 'string',
            sortable: true,
        },
        {
            label: 'Name',
            fieldName: 'Name',
            type: 'string',
            sortable: true,
        },
        {
            label: 'Email',
            fieldName: 'Email',
            type: 'email',
            sortable: true,
        },
        {
            label: 'Must Change Password',
            fieldName: 'MustChangePassword',
            type: 'boolean',
            sortable: true,
        },
        {
            label: 'Is Active',
            fieldName: 'ActiveFlag',
            type: 'boolean',
            sortable: true,
        },
        {
            label: 'Is Deleted',
            fieldName: 'Deleted',
            type: 'boolean',
            sortable: true,
        },
        {
            label: 'Last Successful Login',
            fieldName: 'LastSuccessfulLogin',
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
            fieldName: 'IsAPIUser',
            type: 'boolean',
            sortable: true,
        },
        {
            label: 'Notification Email Address',
            fieldName: 'NotificationEmailAddress',
            type: 'email',
            sortable: true,
        },
        {
            label: 'Is Locked',
            fieldName: 'IsLocked',
            type: 'boolean',
            sortable: true,
        },
        {
            label: 'Default Business Unit',
            fieldName: 'DefaultBusinessUnit',
            type: 'string',
            sortable: true,
        },
    ];

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

    // On requested change of page size
    handlePageSizeChange(event) {
        var newPageSize = event.detail.value;

        if (newPageSize) {
            this.pagesize = newPageSize;
        }
    }

    handleKeyChange(event) {
        this.data = this.filterByValue(this._allData, event.target.value);
    }

    filterByValue(array, string) {
        return array.filter(function (o) {
            return Object.keys(o).some(function (k) {
                return o[k].toString().toLowerCase().indexOf(string) !== -1;
            });
        });
    }

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

    onHandleSort(event) {
        console.log(JSON.stringify(event.detail));
        const {fieldName: sortedBy, sortDirection} = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}
