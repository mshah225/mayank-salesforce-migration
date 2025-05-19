/**
 * Default implementation for Nextables to use (unfortunately you cannot provide default implementations for an interface
 * in Apex, so we need to write code for all classes implementing `Nextable`).
 *
 * My suggestion is, for each class implementing `Nextable` to add the following:
 *
 * ```
 * private NextableDefaultImplementation nextImpl = new NextableDefaultImplementation();
 * public void launchNext() { nextImpl.launchNext(); }
 * public void enqueueNext(Nextable next) { nextImpl.enqueueNext(next); }
 * ```
 *
 * This basically just hooks it up to use this implementation for you
 *
 */
public class NextableDefaultImplementation {
    Nextable next;

    public NextableDefaultImplementation() {
    }

    public void launchNext() {
        if (next == null) {
            return;
        } else if (next instanceof Queueable) {
            GovernorLimitPreemptException.assertCanEnqueueJobs(
                1,
                'Could not enqueue next Nextable - reached Queueable job limit'
            );
            GovernorLimitPreemptException.assertCanEnqueueJobsDepth(
                1,
                'Could not enqueue next Nextable - reached Queueable stack depth limit'
            );
            System.enqueueJob((Queueable) next);
        } else if (next instanceof Database.Batchable<SObject>) {
            Database.executeBatch((Database.Batchable<SObject>) next, 200);
        } else if (next instanceof Database.Batchable<String>) {
            Database.executeBatch((Database.Batchable<String>) next, 200);
        }
    }

    public void enqueueNext(Nextable next) {
        if (this.next != null) {
            this.next.enqueueNext(next);
        } else {
            this.next = next;
        }
    }
}