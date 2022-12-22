import {LightningElement} from 'lwc';
import persistenceChart from '@salesforce/resourceUrl/PersistenceChart';

export default class AdvisorPortalFauxView extends LightningElement {
    gradToggleOptions = [
        {label: 'Undergraduate', value: 'UGRD'},
        {label: 'Graduate', value: 'GRD'},
    ];
    gradToggleValue = 'UGRD';

    viewStateOptions = [
        {label: 'All Students', value: 'AllCasesState'},
        {label: 'Proactive Cases', value: 'ProactiveCasesState'},
        {label: 'Watchlist Cases', value: 'WatchlistCasesState'},
    ];
    viewStateValue = 'ProactiveCasesState';

    get persistenceIconVeryLow() {
        return persistenceChart + '/icon-1.png';
    }
    get persistenceIconLow() {
        return persistenceChart + '/icon-2.png';
    }
    get persistenceChartModerate() {
        return persistenceChart + '/icon-3.png';
    }
    get persistenceIconHigh() {
        return persistenceChart + '/icon-4.png';
    }
    get persistenceIconVeryHigh() {
        return persistenceChart + '/icon-5.png';
    }
}
