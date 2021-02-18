import {LightningElement} from 'lwc';
import {loadScript} from 'lightning/platformResourceLoader';
import jquery from '@salesforce/resourceUrl/jQuery_3_1_1';

export default class AsuBrandHeader extends LightningElement {
    connectedCallback() {}
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
        const BasicNavTree = [
            {
                href: '/',
                text: 'Home',
                type: 'icon',
                class: 'home',
            },
            {
                text: 'Degree programs',
                href: '#',
                items: [
                    [
                        {
                            href: 'https://www.asu.edu/?feature=newsevents',
                            text: 'Mauris viverra, sem nec',
                        },
                        {
                            href: 'https://www.asu.edu/?feature=academics',
                            text: 'Academics',
                        },
                        {
                            href: 'https://www.asu.edu/?feature=research',
                            text: 'Research',
                        },
                        {
                            href: 'https://www.asu.edu/?feature=athletics',
                            text: 'Athletics',
                        },
                        {
                            href: 'https://www.asu.edu/?feature=alumni',
                            text: 'Alumni',
                        },
                        {
                            href: 'https://www.asu.edu/?feature=giving',
                            text: 'Giving',
                        },
                        {
                            href: 'https://www.asu.edu/?feature=president',
                            text: 'President',
                        },
                        {
                            href: 'https://www.asu.edu/about',
                            text: 'About ASU',
                        },
                    ],
                ],
            },

            {
                text: 'People',
                href: '#',
                items: [
                    [
                        {
                            classes: 'border first',
                            href: 'https://www.asu.edu/map/',
                            text: 'Map',
                        },
                        {
                            href: 'https://campus.asu.edu/tempe/',
                            text: 'Tempe',
                        },
                        {
                            href: 'https://campus.asu.edu/west/',
                            text: 'West',
                        },
                        {
                            href: 'https://campus.asu.edu/polytechnic/',
                            text: 'Polytechnic',
                        },
                        {
                            href: 'https://asuonline.asu.edu/',
                            text: 'Online and Extended',
                        },
                        {
                            href: 'https://havasu.asu.edu/',
                            text: 'Mauris viverra, sem nec',
                        },
                    ],
                ],
            },
            {
                text: 'My ASU',
                href: '#',
            },
            {
                text: 'Research',
                href: '#',
            },
            {
                text: 'About us',
                href: '#',
            },
            {
                text: 'Contact us',
                href: '#',
            },
        ];
        let props = {
            navTree: BasicNavTree,
            title: 'Example title',
            baseUrl: 'asu.edu',
        };

        var idSelector = this.template.querySelector('.headerContainer').id;

        //var idSelector = 'headerContainer-1';
        componentsLibrary.initHeader(props, idSelector, false, this.template);
    }
}
