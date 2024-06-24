// Helper function to wait until the microtask queue is empty. This is needed for promise
// timing when calling imperative Apex.
export async function flushPromises() {
    return Promise.resolve();
}
