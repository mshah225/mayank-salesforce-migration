/**
 * Nextable is an interface that allows Queueables and Batchables to easily be configured to run one
 * after one another
 *
 * The primary use case of this is to setup multiple ErrorLogger Queueables prior to running continuing
 * with normal processing
 *
 * ```
 * this.enqueueNext(new ErrorLoggerQueue(ex, vars, false));
 * this.enqueueNext(new ErrorLoggerQueue(ex2, vars2, false));
 * this.enqueueNext(new UserDeprovisionerQueueSetupRecords());
 * this.launchNext();
 * ```
 *
 * Suggested default implementations:
 * ```
 * private NextableDefaultImplementation nextImpl = new NextableDefaultImplementation();
 * public void launchNext() { nextImpl.launchNext(); }
 * public void enqueueNext(Nextable next) { nextImpl.enqueueNext(next); }
 * ```
 *
 */
public interface Nextable {
    void launchNext();
    void enqueueNext(Nextable next);
}