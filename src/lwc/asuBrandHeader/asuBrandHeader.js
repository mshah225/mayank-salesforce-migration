import {LightningElement, api} from 'lwc';
import {loadScript} from 'lightning/platformResourceLoader';
import jquery from '@salesforce/resourceUrl/jQuery_3_1_1';

export default class AsuBrandHeader extends LightningElement {
    @api title;
    @api baseUrl;
    @api navTreeStr;
    connectedCallback() {
        let params = this.getQueryParameters();

        // Precedence: @api defined > URL param > default value

        // Title
        if (this.title === undefined) {
            this.title = params['title'];

            if (this.title === undefined) {
                this.title = 'Arizona State University';
            }
        }

        // Base URL
        if (this.baseUrl === undefined) {
            this.baseUrl = params['baseUrl'];

            if (this.baseUrl === undefined) {
                this.baseUrl = 'https://www.asu.edu/';
            }
        }
        // append / if needed
        if (this.baseUrl[this.baseUrl.length - 1] != '/') {
            this.baseUrl = this.baseUrl + '/';
        }

        // Nav Tree
        if (this.navTreeStr === undefined) {
            this.navTreeStr = params['navTree'];
            if (this.navTreeStr == undefined) {
                this.navTreeStr = params['navbar'];
            }

            if (this.navTreeStr === undefined) {
                this.navTreeStr =
                    '{ "navbarLinks" : [ { "href": "' +
                    this.baseUrl +
                    '", "text": "Home", "type": "icon", "class": "home" }, { "text": "News/Events", "href": "' +
                    this.baseUrl +
                    '?feature=newsevents" }, { "text": "Academics", "href": "' +
                    this.baseUrl +
                    '?feature=academics" }, { "text": "Admission", "href": "https://admission.asu.edu/" }, { "text": "Research", "href": "' +
                    this.baseUrl +
                    '?feature=research" }, { "text": "Athletics", "href": "' +
                    this.baseUrl +
                    '?feature=athletics" }, { "text": "Alumni", "href": "' +
                    this.baseUrl +
                    '?feature=alumni" }, { "text": "Giving", "href": "' +
                    this.baseUrl +
                    '?feature=giving" }, { "text": "President", "href": "' +
                    this.baseUrl +
                    '?feature=president" }, { "text": "About ASU", "href": "' +
                    this.baseUrl +
                    'about" } ] }';
            }
        }
    }
    renderedCallback() {
        loadScript(this, jquery).then(() => {
            $.getScript('https://cdn.jsdelivr.net/gh/rnordmanASU/scripts/vendor.js', () => {
                $.getScript('https://cdn.jsdelivr.net/gh/rnordmanASU/scripts/components-library.js', () => {
                    this.generateHeader();
                });
            });
        });
    }
    generateHeader() {
        const navTree = this.convertStrToNavTreeObj(this.navTreeStr);
        let props = {
            navTree: navTree,
            title: this.title,
            baseUrl: this.baseUrl,
        };

        var idSelector = this.template.querySelector('.headerContainer').id;

        componentsLibrary.initHeader(props, idSelector, false, this.template);
    }
    getQueryParameters() {
        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === '' ? value : decodeURIComponent(value);
            });
        }

        return params;
    }
    convertStrToNavTreeObj(navTreeStr) {
        const json = JSON.parse(navTreeStr);
        const entries = json['navbarLinks'];
        let newStyle = true;
        let listOfLinks = [];

        if (entries) {
            // Determine if using old link format
            for (let i = 0; i < entries.length; i++) {
                let entry = entries[i];
                if (entry['text'] === undefined) {
                    newStyle = false;
                    break;
                }
            }

            if (newStyle) {
                listOfLinks = entries;
            } else {
                for (let i = 0; i < entries.length; i++) {
                    let entry = entries[i];
                    for (let j in entry) {
                        let name = j;
                        let url = entry[j];

                        name = name.replace('+', ' ');
                        if (name === 'Student Home') {
                            listOfLinks.push({href: url, text: name, type: 'icon', class: 'home'});
                        } else {
                            listOfLinks.push({href: url, text: name});
                        }
                    }
                }
            }
        }
        return listOfLinks;
    }
}
