export default class ToastContainer {
    // eslint-disable-next-line no-empty-function
    constructor() {}
    static instance() {
        if (ToastContainer.singleton == null) ToastContainer.singleton = new ToastContainer();
        return ToastContainer.singleton;
    }
    static singleton;

    containerPosition;
    maxToasts;
    toastPosition;

    // eslint-disable-next-line no-undef
    close = jest.fn();
}
