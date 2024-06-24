import {createElement} from 'lwc';
import LightningAwaitLoadBlock from 'c/lightningAwaitLoadBlock';
import {flushPromises} from 'c/helperTestFunctions';

describe('c-lightning-await-load-block', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Which state to show?', async () => {
        // Setup
        const element = createElement('c-lightning-await-load-block', {
            is: LightningAwaitLoadBlock,
        });
        element.loading = true;
        element.notFoundMessage = 'Not found...';
        element.hasContent = false;
        document.body.appendChild(element);

        // Only spinner is shown
        expect(element.shadowRoot).toHaveChildElement('lightning-spinner');
        expect(element.shadowRoot).not.toHaveChildElement('slot');
        expect(element.shadowRoot).not.toHaveChildElement('.not-found-message');

        // Even if content is ready, is loading=true keep showing loading icon
        element.hasContent = true;
        await flushPromises(); // await re-render

        // Only spinner is shown
        expect(element.shadowRoot).toHaveChildElement('lightning-spinner');
        expect(element.shadowRoot).not.toHaveChildElement('slot');
        expect(element.shadowRoot).not.toHaveChildElement('.not-found-message');

        // Done loading
        element.loading = false;
        await flushPromises(); // await re-render

        // Content is shown
        expect(element.shadowRoot).not.toHaveChildElement('lightning-spinner');
        expect(element.shadowRoot).toHaveChildElement('slot');
        expect(element.shadowRoot).not.toHaveChildElement('.not-found-message');

        // Show special message if empty content
        element.hasContent = false;
        await flushPromises(); // await re-render

        // Content is shown
        expect(element.shadowRoot).not.toHaveChildElement('lightning-spinner');
        expect(element.shadowRoot).not.toHaveChildElement('slot');
        expect(element.shadowRoot).toHaveChildElement('.not-found-message');
    });

    test('Empty content message', async () => {
        // Setup
        const element = createElement('c-lightning-await-load-block', {
            is: LightningAwaitLoadBlock,
        });
        element.loading = false;
        element.notFoundMessage = 'This student does not have any charge history.';
        element.hasContent = false;
        document.body.appendChild(element);

        expect(element.shadowRoot).toHaveChildElement('.not-found-message');

        expect(element.shadowRoot.textContent?.trim()).toEqual('This student does not have any charge history.');
    });
});
