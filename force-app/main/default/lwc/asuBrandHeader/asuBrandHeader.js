/* eslint-disable no-undef */
import {LightningElement, api, wire} from 'lwc';
import {loadScript, loadStyle} from 'lightning/platformResourceLoader';
import getFirstName from '@salesforce/apex/ASUBrandUtilities.getFirstName';
import BOOTSTRAP4ASU from '@salesforce/resourceUrl/bootstrap_4_asu';
import REACT from '@salesforce/resourceUrl/react18';
import HEADER_FOOTER from '@salesforce/resourceUrl/asuHeaderFooterJS';

export default class AsuBrandHeader extends LightningElement {
    /**
     * Properties for configuring header
     * Default preference is:
     *  1. @api defined
     *  2. URL defined
     *  3. Default value
     */
    @api set title(v) {
        this._title = v;
    }
    get title() {
        return this._title || this.getUrlParam('title') || 'Arizona State University';
    }

    _baseUrl;
    @api set baseUrl(v) {
        this._baseUrl = v;
    }
    get baseUrl() {
        return this._baseUrl || this.getUrlParam('baseUrl') || 'https://www.asu.edu/';
    }

    _navTreeStr;
    @api set navTreeStr(v) {
        this._navTreeStr = v;
    }
    get navTreeStr() {
        return this._navTreeStr || this.getUrlParam('navbar') || '{ "navbarLinks" : [ { } ] }';
    }
    /**
     * Get navTree object from navTreeStr - while navTreeStr can be either the new navTree-style or the old navbar-style,
     * this object is always the new style, ready to be used by the ASU Header component
     */
    get navTree() {
        let navTree = [];
        const navObj = JSON.parse(this.navTreeStr);

        // Carefully unwrap object
        if (
            navObj != null &&
            typeof navObj === 'object' &&
            navObj.navbarLinks != null &&
            Array.isArray(navObj.navbarLinks)
        ) {
            /* Two formats are possbile
             *  1. navbar-style
             *  2. navTree-style
             *
             * navbar-style objects have the shape
             *  { "Tab Name": "Tab URL" }
             * navTree-style objects have the shape (see ASU header docs for other optional params)
             *  { "text": "Tab Name", "href": "Tab URL" }
             */

            for (const navbarLink of navObj.navbarLinks) {
                const objKeys = Object.keys(navbarLink);

                if (objKeys.length === 0) {
                    // no value (misconfiguration)
                } else if (objKeys.length > 1 || objKeys.includes('text') || objKeys.includes('href')) {
                    // navTree-style (no changes)
                    navTree.push(navbarLink);
                } else {
                    // navbar-style (create navTree element)

                    const name = objKeys[0].replace('+', ' ');
                    const url = navbarLink[name];

                    let navTreeElem = {text: name, href: url};

                    // Special rule for student home - convert text to home-icon
                    if (name === 'Student Home') {
                        navTreeElem.type = 'icon';
                        navTreeElem.class = 'home';
                    }

                    // Special rule for showing which tab is selected
                    if (this.getUrlParam('salesforceTabName') === name) navTreeElem.selected = true;

                    navTree.push(navTreeElem);
                }
            }
        } else {
            navTree = [];
        }

        return navTree;
    }

    _buttons = [];
    @api set buttons(v) {
        this._buttons = v;
    }
    get buttons() {
        return this._buttons;
    }

    /**
     * Configurations to change behavior of header
     */
    @api stationary = false; // Use relative positioning rather than fixed positioning
    @api dontLoadStyles = false; // Don't load ASU brand style
    @api noAutoSpacer = false; // Don't automatically update top-of-page spacing

    /**
     * Enable the view as
     */
    @api viewingAs = false;
    @api viewAsFirstName;
    @api viewAsLastName;
    @api viewAsEmplId;
    @api viewAsViewAsUrl;
    @api viewAsStopViewAsUrl;

    /**
     * Get the user's name (if they are logged in)
     */
    @wire(getFirstName, {})
    gotFirstName({data, error}) {
        if (data !== undefined) {
            // logged in, update name
            this.userName = data;
            this.renderHeader();
        } else if (error !== undefined) {
            // not logged in - no error
        }
    }
    userName;

    /**
     * Load all dependencies
     */
    connectedCallback() {
        if (!this.dontLoadStyles) loadStyle(this, BOOTSTRAP4ASU + '/dist/css/bootstrap-asu.min.css');

        // Load React (dependency for header)
        loadScript(this, REACT + '/react.production.min.js')
            .then(() => {
                // Load ReactDOM (dependency for header)
                return loadScript(this, REACT + '/react-dom.production.min.js');
            })
            .then(() => {
                // Load header module
                return loadScript(this, HEADER_FOOTER);
            })
            .then(() => {
                this.renderHeader();
            })
            .catch((e) => {
                console.error('Error Loading Header Dependencies', e);
            });
    }

    /**
     * Wrapper classes that override some styles
     */
    get wrapperClasses() {
        let classLs = [];

        if (this.stationary) classLs.push('force-relative-header');
        if (this.viewingAs) classLs.push('view-as-enabled');

        return classLs.join(' ');
    }

    /**
     * Rendered the component
     */
    renderedCallback() {
        this.renderHeader();
    }

    /**
     * Render the header
     */
    renderHeader() {
        if (this.refs?.attachRoot == null) return; // not rendered yet
        if (typeof AsuHeaderFooter !== 'object') return; // dependencies still loading

        const props = {
            title: this.title,
            baseUrl: this.baseUrl,
            navTree: this.navTree,
        };

        // Add section for view as (CSS is used to only shown this when in dropdown mode)
        if (this.viewingAs) {
            props.buttons = [
                {
                    text: 'View As Student',
                    href: this.viewAsViewAsUrl,
                    color: 'light',
                    classes: 'view-as-button',
                },
                {
                    text: 'Stop Viewing As: ' + this.viewAsFirstName,
                    href: this.viewAsStopViewAsUrl,
                    color: 'light',
                    classes: 'view-as-button',
                },
            ];
        }

        if (this.userName != null) {
            props.loggedIn = true;
            props.userName = this.userName;
        }

        try {
            // Flush sync forces rendering to complete before continuing - which is needed to allow setupSpacerResizing to work properly
            ReactDOM.flushSync(() => {
                this.reactRoot.render(React.createElement(AsuHeaderFooter.ASUHeader, props));
            });
            this.setupSpacerResizing();
        } catch (e) {
            console.error('Error rendering header ', e);
        }
    }

    /**
     * React DOM root component
     */
    get reactRoot() {
        // Try to use existing react root - but if it has been removed from page (because
        // of weird stuff with Lightning Runtime), then create a new one
        if (this._reactRoot == null || this._reactRoot?._internalRoot?.containerInfo?.isConnected === false) {
            this._reactRoot = ReactDOM.createRoot(this.refs?.attachRoot);
        }

        return this._reactRoot;
    }
    _reactRoot;

    resizeIt() {
        this.template.firstChild.style.setProperty(
            '--header-height',
            this.template.querySelector('header').clientHeight + 'px'
        );
    }
    setupSpacerResizing() {
        try {
            // Resize to header height
            this.resizeIt();

            // Bind to element resize via ResizeObserver if ResizeObserver is defined
            if (typeof ResizeObserver === 'function') {
                new ResizeObserver(() => {
                    this.resizeIt();
                }).observe(this.template.querySelector('header'));
            }
        } catch (ex) {
            // failure is not an issue - it just messes a little with the styling
            console.error('Unable to calculate header height: ', ex.message);
            console.error(ex);
        }
    }

    /**
     * Get the value of a URL parameter
     * @param {String} key URL parameter name
     * @returns {String} Value of URL parameter
     */
    getUrlParam(key) {
        // eslint-disable-next-line compat/compat
        const params = new URLSearchParams(window.location.search);
        return params.get(key);
    }
}
