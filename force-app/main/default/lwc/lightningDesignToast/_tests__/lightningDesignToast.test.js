/* eslint-disable no-undef */
import {createElement} from 'lwc';
import LightningDesignToast from 'c/lightningDesignToast';

describe('c-lightning-datatable-pagination', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Default values', () => {
        // Arrange
        const element = createElement('c-lightning-design-toast', {
            is: LightningDesignToast,
        });

        // Act
        document.body.appendChild(element);

        // Default values check
        expect(element.shadowRoot.querySelector('[data-testid="variant-assistive-label"]').innerHTML).toBe('info');
        expect(element.shadowRoot.querySelector('[data-testid="variant-icon"]').iconName).toBe('utility:info');
        expect(element.shadowRoot.querySelector('[data-testid="title-text"]').innerHTML).toBe('Example Title');
        expect(element.shadowRoot.querySelector('[data-testid="body-text"]').innerHTML).toBe('Example body');
    });

    test('Sucess toast', () => {
        // Arrange
        const element = createElement('c-lightning-design-toast', {
            is: LightningDesignToast,
        });
        element.variant = 'success';

        // Act
        document.body.appendChild(element);

        // Check that success icon is setup
        expect(element.shadowRoot.querySelector('[data-testid="variant-assistive-label"]').innerHTML).toBe('success');
        expect(element.shadowRoot.querySelector('[data-testid="variant-icon"]').iconName).toBe('utility:success');
    });

    test('Info toast', () => {
        // Arrange
        const element = createElement('c-lightning-design-toast', {
            is: LightningDesignToast,
        });
        element.variant = 'info';

        // Act
        document.body.appendChild(element);

        // Check that info icon is setup
        expect(element.shadowRoot.querySelector('[data-testid="variant-assistive-label"]').innerHTML).toBe('info');
        expect(element.shadowRoot.querySelector('[data-testid="variant-icon"]').iconName).toBe('utility:info');
    });

    test('Warning toast', () => {
        // Arrange
        const element = createElement('c-lightning-design-toast', {
            is: LightningDesignToast,
        });
        element.variant = 'warning';

        // Act
        document.body.appendChild(element);

        // Check that warning icon is setup
        expect(element.shadowRoot.querySelector('[data-testid="variant-assistive-label"]').innerHTML).toBe('warning');
        expect(element.shadowRoot.querySelector('[data-testid="variant-icon"]').iconName).toBe('utility:warning');
    });

    test('Error toast', () => {
        // Arrange
        const element = createElement('c-lightning-design-toast', {
            is: LightningDesignToast,
        });
        element.variant = 'error';

        // Act
        document.body.appendChild(element);

        // Check that error icon is setup
        expect(element.shadowRoot.querySelector('[data-testid="variant-assistive-label"]').innerHTML).toBe('error');
        expect(element.shadowRoot.querySelector('[data-testid="variant-icon"]').iconName).toBe('utility:error');
    });

    test('Loading toast', () => {
        // Arrange
        const element = createElement('c-lightning-design-toast', {
            is: LightningDesignToast,
        });
        element.variant = 'loading';

        // Act
        document.body.appendChild(element);

        // Check that loading icon is setup
        expect(element.shadowRoot.querySelector('[data-testid="variant-assistive-label"]').innerHTML).toBe('loading');
        expect(element.shadowRoot.querySelector('[data-testid="variant-icon"]').nodeName.toLowerCase()).toBe(
            'lightning-spinner'
        );
    });

    test('Setting values', () => {
        // Arrange
        const element = createElement('c-lightning-design-toast', {
            is: LightningDesignToast,
        });
        element.variant = 'success';
        element.title = 'Contact Updated';
        element.body = 'Address changed.';

        // Act
        document.body.appendChild(element);

        // Check that values are being set
        expect(element.shadowRoot.querySelector('[data-testid="variant-assistive-label"]').innerHTML).toBe('success');
        expect(element.shadowRoot.querySelector('[data-testid="variant-icon"]').iconName).toBe('utility:success');
        expect(element.shadowRoot.querySelector('[data-testid="title-text"]').innerHTML).toBe('Contact Updated');
        expect(element.shadowRoot.querySelector('[data-testid="body-text"]').innerHTML).toBe('Address changed.');
    });

    test('Opening toast', async () => {
        // Arrange
        const element = createElement('c-lightning-design-toast', {
            is: LightningDesignToast,
        });
        element.variant = 'success';
        element.title = 'Contact Updated';
        element.body = 'Address changed.';

        // Act
        document.body.appendChild(element);

        // Starts as closed
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).toContain('slds-hide');
        // trigger open
        element.fire();
        // wait for render cycle
        await flushPromises();
        // verify that it is now open
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).not.toContain('slds-hide');
    });

    test('Opening toast with params', async () => {
        // Arrange
        const element = createElement('c-lightning-design-toast', {
            is: LightningDesignToast,
        });
        element.variant = 'success';
        element.title = 'Contact Updated';
        element.body = 'Address changed.';

        // Act
        document.body.appendChild(element);

        // Starts as closed
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).toContain('slds-hide');
        // trigger open
        element.fireParams('Invalid Email', "Contact's email does not appear to be valid.", 'warning', 2000);
        // wait for render cycle
        await flushPromises();
        // verify that it is now open and has correct text
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).not.toContain('slds-hide');
        expect(element.shadowRoot.querySelector('[data-testid="variant-assistive-label"]').innerHTML).toBe('warning');
        expect(element.shadowRoot.querySelector('[data-testid="variant-icon"]').iconName).toBe('utility:warning');
        expect(element.shadowRoot.querySelector('[data-testid="title-text"]').innerHTML).toBe('Invalid Email');
        expect(element.shadowRoot.querySelector('[data-testid="body-text"]').innerHTML).toBe(
            "Contact's email does not appear to be valid."
        );
    });

    test('Autoclosing toast', async () => {
        // Arrange
        const element = createElement('c-lightning-design-toast', {
            is: LightningDesignToast,
        });
        element.variant = 'success';
        element.title = 'Contact Updated';
        element.body = 'Address changed.';
        element.duration = 2000;

        // Act
        document.body.appendChild(element);

        // Use fake timers
        jest.useFakeTimers();

        // Starts as closed
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).toContain('slds-hide');
        // trigger open
        element.fire();
        // it is now open
        await flushPromises();
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).not.toContain('slds-hide');
        // it is still open after 1 seconds
        jest.advanceTimersByTime(1000);
        await flushPromises();
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).not.toContain('slds-hide');
        // it is still open after 2 seconds
        jest.advanceTimersByTime(1000);
        await flushPromises();
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).not.toContain('slds-hide');
        // it is still open after 3 seconds
        jest.advanceTimersByTime(1000);
        await flushPromises();
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).not.toContain('slds-hide');
        // after ~4 seconds (2000ms timeout + 2000ms fadeout) it is hidden
        jest.advanceTimersByTime(1200);
        await flushPromises();
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).toContain('slds-hide');
    });

    test('Fades out', async () => {
        // Arrange
        const element = createElement('c-lightning-design-toast', {
            is: LightningDesignToast,
        });
        element.variant = 'success';
        element.title = 'Contact Updated';
        element.body = 'Address changed.';
        element.duration = 2000;

        // Act
        document.body.appendChild(element);

        // Use fake timers
        jest.useFakeTimers();

        // Starts as closed
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).toContain('slds-hide');
        // trigger open
        element.fire();
        // it is now open
        await flushPromises();
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).not.toContain('slds-hide');
        // it is still open after 1 seconds
        jest.advanceTimersByTime(1000);
        await flushPromises();
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).not.toContain('slds-hide');
        // it is still open after ~2 seconds
        jest.advanceTimersByTime(1000);
        await flushPromises();
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).not.toContain('slds-hide');
        // After approximately 2 seconds - it begins to fade out
        jest.advanceTimersByTime(100);
        await flushPromises();
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).toContain(
            'fadeOutTransition'
        );
        // still fading at 3 seconds
        jest.advanceTimersByTime(900);
        await flushPromises();
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).toContain(
            'fadeOutTransition'
        );
        // still fading at 4 seconds
        jest.advanceTimersByTime(1000);
        await flushPromises();
        expect(element.shadowRoot.querySelector('[data-testid="wrapper-div"]').classList).toContain(
            'fadeOutTransition'
        );
    });
});

// Helper function to wait until the microtask queue is empty. This is needed for promise
// timing when calling imperative Apex or when awaiting a render cycle.
async function flushPromises() {
    return Promise.resolve();
}
