import {LightningElement} from 'lwc';

export default class AsuBrandAlert extends LightningElement {
    handleOnclick(event) {
        event.target.parentNode.parentNode.parentNode.style.display = 'none';
    }
}
