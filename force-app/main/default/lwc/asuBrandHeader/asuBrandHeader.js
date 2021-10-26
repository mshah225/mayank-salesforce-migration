import {LightningElement, api} from 'lwc';
import {loadScript, loadStyle} from 'lightning/platformResourceLoader';
import bootstrap_4_asu from '@salesforce/resourceUrl/bootstrap_4_asu';
import jQuery from '@salesforce/resourceUrl/jQuery_3_1_1';
import getFirstName from '@salesforce/apex/ASUBrandUtilities.getFirstName';

export default class AsuBrandHeader extends LightningElement {
    @api title;
    @api baseUrl;
    @api navTreeStr;
    @api buttons = [];
    @api noAutoSpacer = false;
    @api stationary = false;
    oldStyle = false;
    oldStyleSelectedTab = null;

    @api viewingAs = false;
    @api viewAsFirstName;
    @api viewAsLastName;
    @api viewAsEmplId;
    @api viewAsViewAsUrl;
    @api viewAsStopViewAsUrl;

    connectedCallback() {
        loadStyle(this, bootstrap_4_asu + '/dist/css/bootstrap-asu.min.css');

        const params = new URLSearchParams(window.location.search);

        // Precedence: @api defined > URL param > default value

        // Title
        if (this.title === undefined) {
            this.title = params.get('title');

            if (this.title === null) {
                this.title = 'Arizona State University';
            }
        }

        // Base URL
        if (this.baseUrl === undefined) {
            this.baseUrl = params.get('baseUrl');

            if (this.baseUrl === null) {
                this.baseUrl = 'https://www.asu.edu/';
            }
        }
        // append / if needed
        if (this.baseUrl[this.baseUrl.length - 1] != '/') {
            this.baseUrl = this.baseUrl + '/';
        }

        // Nav Tree
        if (this.navTreeStr === undefined) {
            this.navTreeStr = params.get('navTree');

            if (this.navTreeStr === null) {
                this.navTreeStr = params.get('navbar');
                if (this.navTreeStr != null) {
                    this.oldStyle = true;
                    this.oldStyleSelectedTab = params.get('salesforceTabName');
                }
            }

            if (this.navTreeStr === null) {
                this.navTreeStr = '{ "navbarLinks" : [ { } ] }';
            }
        }
    }

    renderedCallback() {
        if (this.stationary) {
            this.template.querySelector('.top-level-wrapper').classList.add('force-relative-header');
        }
        if (this.viewingAs) {
            this.template.querySelector('.top-level-wrapper').classList.add('view-as-enabled');
        }

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
        const idSelector = this.template.querySelector('.header-container').id;
        const navTree = this.convertStrToNavTreeObj(this.navTreeStr);

        // Additional header params to investigate:
        // buttons
        // logoutLink (need to set custom for SF here)
        // loginLink (need to set custom for sites that don't have users already logged in, like Family Portal)

        // Always have these props
        let props = {
            navTree: navTree,
            title: this.title,
            baseUrl: this.baseUrl,
        };

        // Add section for view as
        if (this.viewingAs) {
            props.navTree.push({
                text: 'View As Student',
                href: this.viewAsViewAsUrl,
            });
            props.navTree.push({
                text: 'Stop Viewing As: ' + this.viewAsFirstName,
                href: this.viewAsStopViewAsUrl,
            });
        }

        getFirstName()
            .then((name) => {
                props.loggedIn = true;
                props.userName = name;
            })
            .catch(() => {})
            .finally(() => {
                componentsLibrary.initHeader(props, idSelector, false, this.template);
                this.setupSpacerResizing();
            });
    }
    convertStrToNavTreeObj(navTreeStr) {
        const json = JSON.parse(navTreeStr);
        const entries = json['navbarLinks'];
        let listOfLinks = [];

        if (entries) {
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
        this.template.querySelector('.header-spacer').style.height =
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
            this.template.querySelector('.header-container').addEventListener('click', () => {
                // only run near the top of the page
                window.setTimeout(() => {
                    this.resizeIt();
                }, 100);
            });
        }
    }
}
