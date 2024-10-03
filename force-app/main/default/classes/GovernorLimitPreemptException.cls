public class GovernorLimitPreemptException extends Exception {
    /**
     * Throws an exception if using over P% of heap usage governor limit
     */
    public static void assertHasHeapSpaceRemaining(Decimal p, String msg) {
        if (msg == null)
            msg = 'Very near to the heap limit, exceeding ' + (100 * p) + '% usage.';

        // In practice, it seems like tests max out at 6MB, even when testing async code
        // So when running in tests and if is async, cut it in half to use 6MB limit to
        // compare against
        Decimal x = 1;
        if (
            Test.isRunningTest() &&
            (System.isBatch() ||
            System.isFuture() ||
            System.isQueueable() ||
            System.isScheduled())
        )
            x = 0.5;

        if (Limits.getHeapSize() > Limits.getLimitHeapSize() * p * x)
            throw new GovernorLimitPreemptException(msg);
    }
}
