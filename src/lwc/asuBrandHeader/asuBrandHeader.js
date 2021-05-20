import {LightningElement, api} from 'lwc';
import {loadScript} from 'lightning/platformResourceLoader';
import jQuery from '@salesforce/resourceUrl/jQuery_3_1_1';
import getFirstName from '@salesforce/apex/ASUBrandUtilities.getFirstName';

export default class AsuBrandHeader extends LightningElement {
    @api title;
    @api baseUrl;
    @api navTreeStr;
    @api noAutoSpacer = false;
    oldStyle = false;
    oldStyleSelectedTab = null;

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
                if (this.navTreeStr != undefined) {
                    this.oldStyle = true;
                    this.oldStyleSelectedTab = params['salesforceTabName'];
                }
            }

            if (this.navTreeStr === undefined) {
                this.navTreeStr = '{ "navbarLinks" : [ { } ] }';
            }
        }
    }
    renderedCallback() {
        loadScript(this, jQuery).then(() => {
            $.getScript(
                'https://cdn.jsdelivr.net/gh/mgilardi/asu-design-system/components-library/dist/vendor.js',
                () => {
                    $.getScript(
                        'https://cdn.jsdelivr.net/gh/mgilardi/asu-design-system/components-library/dist/components-library.js',
                        () => {
                            this.generateHeader();
                        }
                    );
                }
            );
        });
    }
    generateHeader() {
        const idSelector = this.template.querySelector('.headerContainer').id;
        const navTree = this.convertStrToNavTreeObj(this.navTreeStr);

        // Additional header params to investigate:
        // buttons
        // logoutLink (need to set custom for SF here)
        // loginLink (need to set custom for sites that don't have users already logged in, like Family Portal)

        getFirstName()
            .then((name) => {
                const props = {
                    loggedIn: true,
                    userName: name,
                    navTree: navTree,
                    title: this.title,
                    baseUrl: this.baseUrl,
                };

                componentsLibrary.initHeader(props, idSelector, false, this.template);
                this.setupSpacerResizing();
            })
            .catch(() => {
                const props = {
                    navTree: navTree,
                    title: this.title,
                    baseUrl: this.baseUrl,
                };

                componentsLibrary.initHeader(props, idSelector, false, this.template);
                this.setupSpacerResizing();
            });
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

            if (!this.oldStyle) {
                listOfLinks = entries;
            } else {
                // Backward compatibility with existing URL structure
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

                        // Mark whichever tab is selected
                        if (name === this.oldStyleSelectedTab) {
                            listOfLinks[listOfLinks.length - 1]['selected'] = true;
                        }
                    }
                }
            }
        }
        return listOfLinks;
    }

    resizeIt() {
        this.template.querySelector('.headerSpacer').style.height =
            this.template.querySelector('header').clientHeight + 10 + 'px';
    }
    setupSpacerResizing() {
        // Don't do this if auto resizing is off
        if (this.noAutoSpacer) {
            return;
        }
        this.resizeIt();

        // Bind to element resize via ResizeObserver
        try {
            new ResizeObserver(() => {
                this.resizeIt();
            }).observe(this.template.querySelector('header'));
        } catch (e) {
            // Bind to window resize and scroll
            window.addEventListener('resize', () => {
                window.setTimeout(() => {
                    this.resizeIt();
                }, 100);
            });
            window.addEventListener('scroll', () => {
                if (window.scrollY < 30) {
                    // only run near the top of the page
                    window.setTimeout(() => {
                        this.resizeIt();
                    }, 100);
                }
            });
            this.template.querySelector('.headerContainer').addEventListener('click', () => {
                // only run near the top of the page
                window.setTimeout(() => {
                    this.resizeIt();
                }, 100);
            });
        }
    }
}
