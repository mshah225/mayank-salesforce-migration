import {LightningElement, api} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

export default class CampusVisitNavigationPage extends NavigationMixin(LightningElement) {
    @api recordId;

    handleNavigate() {
        var compDefinition = {
            componentDef: 'c:campusVisitHomePage',
            attributes: {
                propertyValue: this.recordId,
            },
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef,
            },
        });
    }
}