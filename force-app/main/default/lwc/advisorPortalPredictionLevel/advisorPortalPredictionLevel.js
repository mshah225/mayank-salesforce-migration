import {LightningElement, api} from 'lwc';
import persistenceChart from '@salesforce/resourceUrl/PersistenceChart';

export default class AdvisorPortalPredictionLevel extends LightningElement {
    @api set predictionLevel(val) {
        let newVal = val;
        if (typeof newVal === 'string') newVal = parseInt(newVal, 10);
        this._predictionLevel = newVal;
    }
    get predictionLevel() {
        return this._predictionLevel;
    }
    _predictionLevel = null;

    alt;
    title;

    get whichIcon() {
        let iconUrl = '';

        if (this.predictionLevel >= 0 && this.predictionLevel <= 3) {
            iconUrl = this.persistenceIconVeryLow;
            this.alt = 'very low';
            this.title = 'Very Low';
        } else if (this.predictionLevel >= 4 && this.predictionLevel <= 5) {
            iconUrl = this.persistenceIconLow;
            this.alt = 'low';
            this.title = 'Low';
        } else if (this.predictionLevel === 6) {
            iconUrl = this.persistenceChartModerate;
            this.alt = 'moderate';
            this.title = 'Moderate';
        } else if (this.predictionLevel === 7) {
            iconUrl = this.persistenceIconHigh;
            this.alt = 'high';
            this.title = 'High';
        } else if (this.predictionLevel >= 8 && this.predictionLevel <= 10) {
            iconUrl = this.persistenceIconVeryHigh;
            this.alt = 'very high';
            this.title = 'Very High';
        }

        return iconUrl;
    }

    get notEmptyPredictionLevel() {
        return this.predictionLevel !== null;
    }

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
