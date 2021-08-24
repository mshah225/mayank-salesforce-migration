import {LightningElement, api} from 'lwc';
import {loadScript} from 'lightning/platformResourceLoader';
import jQuery from '@salesforce/resourceUrl/jQuery_3_1_1';
import getFirstName from '@salesforce/apex/ASUBrandUtilities.getFirstName';

export default class AsuBrandHeader extends LightningElement {
    @api title;
    @api baseUrl;
    @api navTreeStr;
    @api buttons = [];
    @api noAutoSpacer = false;
    oldStyle = false;
    oldStyleSelectedTab = null;

    @api viewingAs = false;
    @api viewAsFirstName;
    @api viewAsLastName;
    @api viewAsEmplId;
    @api viewAsViewAsUrl;
    @api viewAsStopViewAsUrl;

    connectedCallback() {
        this.viewingAs = true;
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
    viewAsToggle() {
        let obj = this.template.querySelector('.viewAsWrapper');
        if (obj.classList.contains('d-none')) {
            obj.classList.add('d-block');
            obj.classList.remove('d-none');
        } else {
            obj.classList.add('d-none');
            obj.classList.remove('d-block');
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

        // Always have these props
        let props = {
            navTree: navTree,
            title: this.title,
            baseUrl: this.baseUrl,
        };

        // Add button for view as toggle
        if (this.viewingAs) {
            this.buttons = [
                {
                    text:
                        'Viewing as ' +
                        this.viewAsFirstName +
                        ' ' +
                        this.viewAsLastName +
                        ' (' +
                        this.viewAsEmplId +
                        ')',
                    color: 'maroon',
                    href:
                        "javascript:document.querySelector('c-asu-brand-header').shadowRoot.querySelector('#" +
                        this.template.querySelector('.jsBinding').id +
                        "').querySelector('.viewAsToggle').click()",
                },
            ];

            props.buttons = this.buttons;
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
                this.attachViewAsSection();
            });
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
    attachViewAsSection() {
        this.template.querySelector('header').appendChild(this.template.querySelector('.viewAsWrapper'));
    }
}
