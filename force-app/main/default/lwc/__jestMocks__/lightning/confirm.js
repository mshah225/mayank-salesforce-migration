import {LightningElement} from 'lwc';

export default class Confirm extends LightningElement {
    static open = jest.fn(() => Promise.resolve(true));
}
