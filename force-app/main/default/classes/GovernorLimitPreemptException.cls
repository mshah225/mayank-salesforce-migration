public class GovernorLimitPreemptException extends Exception {
    /**
     * Throws an exception if within N of the SOQL query governor limit
     */
    public static void assertCanQueryN(Integer n, String msg) {
        if (msg == null)
            msg = 'Already at SOQL query limit, cannot run ' + n + ' queries.';

        if (Limits.getQueries() + n > Limits.getLimitQueries())
            throw new GovernorLimitPreemptException(msg);
    }

    /**
     * Throws an exception if within N of the SOQL row governor limit
     */
    public static void assertCanQueryRowsN(Integer n, String msg) {
        if (msg == null)
            msg = 'Already at SOQL query row limit, cannot run query that will return ' + n + ' rows.';

        if (Limits.getQueryRows() + n > Limits.getLimitQueryRows())
            throw new GovernorLimitPreemptException(msg);
    }

    /**
     * Throws an exception if within N of the DML governor limit
     */
    public static void assertCanDML(Integer n, String msg) {
        if (msg == null)
            msg = 'Already at DML query limit, cannot execture ' + n + ' DML statement(s).';

        if (Limits.getDMLStatements() + n > Limits.getLimitDMLStatements())
            throw new GovernorLimitPreemptException(msg);
    }
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
