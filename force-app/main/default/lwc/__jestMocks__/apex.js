// Mocking how getSObjectValue retrieves the field value.
export const getSObjectValue = (object, field) => {
    return object[field.fieldApiName];
};

// Mock refresh apex - this will allow you to do is check that refreshApex was called, and with what parameters
// but it won't retrigger wires
export const refreshApex = jest.fn(() => Promise.resolve());
