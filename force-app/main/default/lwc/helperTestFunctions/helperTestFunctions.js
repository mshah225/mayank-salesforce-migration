// Helper function to wait until the microtask queue is empty. This is needed for promise
// timing when calling imperative Apex. Or when awaiting other async work like re-rendering.
export async function flushPromises() {
    return Promise.resolve();
}
