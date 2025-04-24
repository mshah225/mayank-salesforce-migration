/* eslint-disable no-undef */
import {createElement} from 'lwc';
import LightningComplexToast from 'c/lightningComplexToast';
import {flushPromises} from 'c/helperTestFunctions';

describe('c-lightning-complex-toast', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('variant=info styles', async () => {
        const element = createElement('c-lightning-complex-toast', {
            is: LightningComplexToast,
        });
        element.variant = 'info';
        document.body.appendChild(element);

        element.show();
        await flushPromises(); //await rerender

        // Check theme and icon
        expect(element.shadowRoot.querySelector('.slds-notify').classList).toContain('slds-theme_info');
        expect(element.shadowRoot.querySelector('lightning-icon').iconName).toContain('utility:info');
    });

    test('variant=success styles', async () => {
        const element = createElement('c-lightning-complex-toast', {
            is: LightningComplexToast,
        });
        element.variant = 'success';
        document.body.appendChild(element);

        element.show();
        await flushPromises(); //await rerender

        // Check theme and icon
        expect(element.shadowRoot.querySelector('.slds-notify').classList).toContain('slds-theme_success');
        expect(element.shadowRoot.querySelector('lightning-icon').iconName).toContain('utility:success');
    });

    test('variant=warning styles', async () => {
        const element = createElement('c-lightning-complex-toast', {
            is: LightningComplexToast,
        });
        element.variant = 'warning';
        document.body.appendChild(element);

        element.show();
        await flushPromises(); //await rerender

        // Check theme and icon
        expect(element.shadowRoot.querySelector('.slds-notify').classList).toContain('slds-theme_warning');
        expect(element.shadowRoot.querySelector('lightning-icon').iconName).toContain('utility:warning');
    });

    test('variant=error styles', async () => {
        const element = createElement('c-lightning-complex-toast', {
            is: LightningComplexToast,
        });
        element.variant = 'error';
        document.body.appendChild(element);

        element.show();
        await flushPromises(); //await rerender

        // Check theme and icon
        expect(element.shadowRoot.querySelector('.slds-notify').classList).toContain('slds-theme_error');
        expect(element.shadowRoot.querySelector('lightning-icon').iconName).toContain('utility:error');
    });

    test('mode=pester, no close button', async () => {
        const element = createElement('c-lightning-complex-toast', {
            is: LightningComplexToast,
        });
        element.mode = 'pester';
        document.body.appendChild(element);

        element.show();
        await flushPromises(); //await rerender

        // No close button
        expect(element.shadowRoot.querySelector('lightning-button-icon')).toBeFalsy();
    });

    test('mode=sticky, yes close button', async () => {
        const element = createElement('c-lightning-complex-toast', {
            is: LightningComplexToast,
        });
        element.mode = 'sticky';
        document.body.appendChild(element);

        element.show();
        await flushPromises(); //await rerender

        // No close button
        expect(element.shadowRoot.querySelector('lightning-button-icon')).toBeTruthy();
    });

    test('mode=dismissable, yes close button', async () => {
        const element = createElement('c-lightning-complex-toast', {
            is: LightningComplexToast,
        });
        element.mode = 'dismissable';
        document.body.appendChild(element);

        element.show();
        await flushPromises(); //await rerender

        // No close button
        expect(element.shadowRoot.querySelector('lightning-button-icon')).toBeTruthy();
    });

    test('mode=pester, yes auto close', async () => {
        const element = createElement('c-lightning-complex-toast', {
            is: LightningComplexToast,
        });
        element.mode = 'pester';
        document.body.appendChild(element);

        jest.useFakeTimers();

        element.show();
        await flushPromises(); //await rerender

        jest.runAllTimers(); // wait for setTimeout to pass
        await flushPromises(); //await rerender

        // No close button
        expect(element.shadowRoot.querySelector('.slds-notify_container')).toBeFalsy();
    });

    test('mode=sticky, no auto close', async () => {
        const element = createElement('c-lightning-complex-toast', {
            is: LightningComplexToast,
        });
        element.mode = 'sticky';
        document.body.appendChild(element);

        jest.useFakeTimers();

        element.show();
        await flushPromises(); //await rerender

        jest.runAllTimers(); // wait for setTimeout to pass
        await flushPromises(); //await rerender

        // No close button
        expect(element.shadowRoot.querySelector('.slds-notify_container')).toBeTruthy();
    });

    test('mode=dismissable, yes auto close', async () => {
        const element = createElement('c-lightning-complex-toast', {
            is: LightningComplexToast,
        });
        element.mode = 'dismissable';
        document.body.appendChild(element);

        jest.useFakeTimers();

        element.show();
        await flushPromises(); //await rerender

        jest.runAllTimers(); // wait for setTimeout to pass
        await flushPromises(); //await rerender

        // No close button
        expect(element.shadowRoot.querySelector('.slds-notify_container')).toBeFalsy();
    });
});
