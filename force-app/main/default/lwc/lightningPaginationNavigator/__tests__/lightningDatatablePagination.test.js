import {createElement} from 'lwc';
import LightningPaginationNavigator from 'c/lightningPaginationNavigator';
import {cloneObj} from 'c/helperFunctions';

describe('c-lightning-datatable-pagination', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('No page size dropdown rendered when not extended', () => {
        // Arrange
        const element = createElement('c-lightning-pagination-navigator', {
            is: LightningPaginationNavigator,
        });
        element.resultsCount = 100;
        element.pageSize = 20;
        element.itemType = 'Students';
        element.extended = false;

        // Act
        document.body.appendChild(element);

        // Assert that the page size dropdown is not rendered (since extended=false)
        expect(element.shadowRoot.querySelector('[data-testid="page-size-selector"]')).toBeFalsy();
    });

    test('Render page size dropdown when extended is true', () => {
        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningPaginationNavigator,
        });
        element.resultsCount = 100;
        element.pageSize = 20;
        element.itemType = 'Students';
        element.extended = true;

        // Act
        document.body.appendChild(element);

        // Assert that the page size dropdown is not rendered (since extended=true)
        expect(element.shadowRoot.querySelector('[data-testid="page-size-selector"]')).toBeTruthy();
    });

    test('Raise event when changing page', async () => {
        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningPaginationNavigator,
        });
        element.resultsCount = 100;
        element.pageSize = 20;
        element.itemType = 'Students';
        element.extended = false;
        const mockPageChange = jest.fn();
        element.addEventListener('changepage', mockPageChange); // detect page change events

        // Act
        document.body.appendChild(element);

        // Start pressing page change buttons
        const firstPageButton = element.shadowRoot.querySelector('[data-testid="first-page-button"]');
        const prevPageButton = element.shadowRoot.querySelector('[data-testid="prev-page-button"]');
        const nextPageButton = element.shadowRoot.querySelector('[data-testid="next-page-button"]');
        const lastPageButton = element.shadowRoot.querySelector('[data-testid="last-page-button"]');

        // Start at first page
        expect(mockPageChange).toBeCalledTimes(0); // start at 0 calls

        // Move onto next page
        nextPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        expect(mockPageChange).toBeCalledTimes(1); // Should have triggered a page change event

        // Move onto last page
        lastPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        expect(mockPageChange).toBeCalledTimes(2); // Should have triggered a page change event

        // Try to move onto next page (fails because no more next pages)
        nextPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        expect(mockPageChange).toBeCalledTimes(2); // Should NOT have triggered a page change event

        // Try to move onto last page (fails because already on last page)
        lastPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        expect(mockPageChange).toBeCalledTimes(2); // Should NOT have triggered a page change event

        // Try to move onto previous page
        prevPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        expect(mockPageChange).toBeCalledTimes(3); // Should have triggered a page change event

        // Move onto the first page
        firstPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        expect(mockPageChange).toBeCalledTimes(4); // Should have triggered a page change event

        // Try to move onto previous page (fails because no more previous pages)
        prevPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        expect(mockPageChange).toBeCalledTimes(4); // Should NOT have triggered a page change event

        // Try to move onto first page (fails because already on first page)
        firstPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        expect(mockPageChange).toBeCalledTimes(4); // Should NOT have triggered a page change event
    });

    test('Raise events and go to page 1 when changing page size', async () => {
        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningPaginationNavigator,
        });
        element.resultsCount = 100;
        element.pageSize = 20;
        element.itemType = 'Students';
        element.currentPage = 3;
        element.extended = true;
        const mockPageChange = jest.fn();
        const mockPageSizeChange = jest.fn();
        element.addEventListener('changepage', mockPageChange); // detect page change events
        element.addEventListener('changepagesize', mockPageSizeChange); // detect page size change events

        // Act
        document.body.appendChild(element);

        // Change page size
        const pageSizeSelector = element.shadowRoot.querySelector('[data-testid="page-size-selector"]');

        // Start at no calls
        expect(mockPageChange).toBeCalledTimes(0); // start at 0 calls

        // Change page size, should trigger both events and go to first page
        pageSizeSelector.dispatchEvent(new CustomEvent('change', {detail: {value: 50}}));
        expect(mockPageSizeChange).toBeCalledTimes(1); // Should have triggered a page change event
        expect(mockPageChange).toBeCalledTimes(1); // Should have triggered a page change event
        expect(element.currentPage).toBe(0); // force back to first page when resize
    });

    test('Calculate displayed offsets when changing page', async () => {
        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningPaginationNavigator,
        });
        element.resultsCount = 100;
        element.pageSize = 20;
        element.itemType = 'Students';
        element.extended = true;

        // Act
        document.body.appendChild(element);

        // Start pressing page change buttons
        const firstPageButton = element.shadowRoot.querySelector('[data-testid="first-page-button"]');
        const prevPageButton = element.shadowRoot.querySelector('[data-testid="prev-page-button"]');
        const nextPageButton = element.shadowRoot.querySelector('[data-testid="next-page-button"]');
        const lastPageButton = element.shadowRoot.querySelector('[data-testid="last-page-button"]');
        const shownItemsLabel = element.shadowRoot.querySelector('[data-testid="shown-items-label"]');
        const shownPageLabel = element.shadowRoot.querySelector('[data-testid="shown-page-label"]');

        // Start at first page
        expect(shownPageLabel.innerHTML).toBe('Page 1 of 5'); // first page
        expect(shownItemsLabel.innerHTML).toBe('Showing 1 - 20 of 100 Students'); // first 20 students

        // Move onto next page
        nextPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        await flushPromises(); // await async render cycle
        expect(shownPageLabel.innerHTML).toBe('Page 2 of 5'); // second page
        expect(shownItemsLabel.innerHTML).toBe('Showing 21 - 40 of 100 Students'); // second 20 students

        // Move onto last page
        lastPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        await flushPromises(); // await async render cycle
        expect(shownPageLabel.innerHTML).toBe('Page 5 of 5'); // final page
        expect(shownItemsLabel.innerHTML).toBe('Showing 81 - 100 of 100 Students'); // final 20 students

        // Try to move onto next page (fails because no more next pages)
        nextPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        await flushPromises(); // await async render cycle
        expect(shownPageLabel.innerHTML).toBe('Page 5 of 5'); // final page
        expect(shownItemsLabel.innerHTML).toBe('Showing 81 - 100 of 100 Students'); // final 20 students

        // Try to move onto last page (fails because already on last page)
        lastPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        await flushPromises(); // await async render cycle
        expect(shownPageLabel.innerHTML).toBe('Page 5 of 5'); // final page
        expect(shownItemsLabel.innerHTML).toBe('Showing 81 - 100 of 100 Students'); // final 20 students

        // Try to move onto previous page
        prevPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        await flushPromises(); // await async render cycle
        expect(shownPageLabel.innerHTML).toBe('Page 4 of 5'); // fourth page
        expect(shownItemsLabel.innerHTML).toBe('Showing 61 - 80 of 100 Students'); // fourth set of 20 students

        // Move onto the first page
        firstPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        await flushPromises(); // await async render cycle
        expect(shownPageLabel.innerHTML).toBe('Page 1 of 5'); // first page
        expect(shownItemsLabel.innerHTML).toBe('Showing 1 - 20 of 100 Students'); // first 20 students

        // Try to move onto previous page (fails because no more previous pages)
        prevPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        await flushPromises(); // await async render cycle
        expect(shownPageLabel.innerHTML).toBe('Page 1 of 5'); // first page
        expect(shownItemsLabel.innerHTML).toBe('Showing 1 - 20 of 100 Students'); // first 20 students

        // Try to move onto first page (fails because already on first page)
        firstPageButton.dispatchEvent(new Event('click', {bubbles: true}));
        await flushPromises(); // await async render cycle
        expect(shownPageLabel.innerHTML).toBe('Page 1 of 5'); // first page
        expect(shownItemsLabel.innerHTML).toBe('Showing 1 - 20 of 100 Students'); // first 20 students
    });

    test('Calculate displayed offsets when changing page size', async () => {
        // Arrange
        const element = createElement('c-lightning-combo-box', {
            is: LightningPaginationNavigator,
        });
        element.resultsCount = 100;
        element.pageSize = 20;
        element.itemType = 'Students';
        element.currentPage = 2; // 2 is page 3 bc 0-indexed vs 1-indexed
        element.extended = true;

        // Act
        document.body.appendChild(element);

        // Change page size
        const pageSizeSelector = element.shadowRoot.querySelector('[data-testid="page-size-selector"]');
        const shownItemsLabel = element.shadowRoot.querySelector('[data-testid="shown-items-label"]');
        const shownPageLabel = element.shadowRoot.querySelector('[data-testid="shown-page-label"]');

        // Start at third page
        expect(shownPageLabel.innerHTML).toBe('Page 3 of 5'); // third page
        expect(shownItemsLabel.innerHTML).toBe('Showing 41 - 60 of 100 Students'); // third set of 20 students

        // Change page size, should trigger both events and go to first page
        pageSizeSelector.dispatchEvent(new CustomEvent('change', {detail: {value: 50}}));
        await flushPromises(); // await async render cycle
        expect(shownPageLabel.innerHTML).toBe('Page 1 of 2'); // first page
        expect(shownItemsLabel.innerHTML).toBe('Showing 1 - 50 of 100 Students'); // first 50 students
    });
});

// Helper function to wait until the microtask queue is empty. This is needed for promise
// timing when calling imperative Apex or when awaiting a render cycle.
async function flushPromises() {
    return Promise.resolve();
}
