/**
 * Waste resources to make it easier to reach governor limits and so we can test can
 * code that preempty governor limits.
 *
 * Production references MUST wrap call to this code in a Test.isRunningTest() check
 */
public class GovernorLimitForceHelper {
    public static List<String> hungryHeapHamsters = new List<String>();

    /**
     * Free any wasted heap memory
     */
    public static void clearHeap() {
        if (!Test.isRunningTest())
            throw new GovernorLimitForceHelperException(
                'You need to wrap calls to clearHeap in a Test.isRunningTest() check! Because you didn\'t now the heap hamsters will escape'
            );

        hungryHeapHamsters.clear();
    }

    /**
     * Eat heap memory until over p percent is used (in chunks of 100kb at a time)
     */
    public static void wasteHeap(Decimal p) {
        if (!Test.isRunningTest())
            throw new GovernorLimitForceHelperException(
                'You need to wrap calls to wasteHeap in a Test.isRunningTest() check! Because you didn\'t now the heap hamsters will escape'
            );

        List<String> hungryHeapHamsterHamburgerHelper = new List<String>();
        for (Integer i = 0; i < 32; i++)
            hungryHeapHamsterHamburgerHelper.add('HUNGRY_HEAP_HAMSTER_EATS_NOM_NOM');
        String hungryHeapHamsterHamburger = String.join(hungryHeapHamsterHamburgerHelper, ''); // 1024 bites each

        List<String> hungryHeapHamsterHelper = new List<String>();
        for (Integer i = 0; i < 128; i++)
            hungryHeapHamsterHelper.add(hungryHeapHamsterHamburger);

        // In practice, it seems like tests max out at 6MB, even when testing async code
        // So when running in tests and if is async, cut it in half to use 6MB limit to
        // compare against
        Decimal x = 1;
        if (System.isBatch() || System.isFuture() || System.isQueueable() || System.isScheduled())
            x = 0.5;

        while (Limits.getHeapSize() < Limits.getLimitHeapSize() * p * x) {
            String hungryHeapHamster = String.join(hungryHeapHamsterHelper, ''); // 100 kb each
            hungryHeapHamsters.add(hungryHeapHamster);
        }
    }

    public class GovernorLimitForceHelperException extends Exception {
    }
}
