import {createElement} from 'lwc';
import LightningErrorOrRetry from 'c/lightningErrorOrRetry';

describe('c-lightning-error-or-retry', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('Shows errors message and button when hasError=true', () => {
        // Arrange
        const element = createElement('c-lightning-error-or-retry', {
            is: LightningErrorOrRetry,
        });
        element.message = 'Failed to load. Retry?';
        element.hasError = true;
        document.body.appendChild(element);

        // Assert
        expect(element.shadowRoot).toHaveChildElement('lightning-button-icon');
        expect(element.shadowRoot).toHaveChildElement('h2');
        expect(element.shadowRoot.querySelector('h2').textContent).toEqual('Failed to load. Retry?');
    });

    it('Hides errors message and button when hasError=false', () => {
        // Arrange
        const element = createElement('c-lightning-error-or-retry', {
            is: LightningErrorOrRetry,
        });
        element.message = 'Failed to load. Retry?';
        element.hasError = false;
        document.body.appendChild(element);

        // Assert
        expect(element.shadowRoot).not.toHaveChildElement('lightning-button-icon');
        expect(element.shadowRoot).not.toHaveChildElement('h2');
    });

    it('Button is on newline if error message is multiline', () => {
        // Arrange
        const element = createElement('c-lightning-error-or-retry', {
            is: LightningErrorOrRetry,
        });
        element.message = 'Failed to load. Retry?\nError Details: {}';
        element.hasError = true;
        document.body.appendChild(element);

        // Assert
        expect(element.shadowRoot).toHaveChildElement('br');
    });

    it('Raises retry event on button press', () => {
        // Arrange
        const element = createElement('c-lightning-error-or-retry', {
            is: LightningErrorOrRetry,
        });
        element.message = 'Failed to load. Retry?';
        element.hasError = true;

        const retryHandler = jest.fn();
        element.addEventListener('retry', retryHandler);
        document.body.appendChild(element);

        // Not called yet
        expect(retryHandler).toHaveBeenCalledTimes(0);
        // Press button
        element.shadowRoot.querySelector('lightning-button-icon').click();
        // Triggered event
        expect(retryHandler).toHaveBeenCalledTimes(1);
    });
});
