@isTest
public class GovernorLimitPreemptExceptionTest {
    @isTest
    private static void testHeapUsage() {
        Exception ex1 = null, ex2 = null, ex3 = null, ex4 = null;

        try {
            GovernorLimitPreemptException.assertHasHeapSpaceRemaining(0.9, null);
        } catch (Exception ex) {
            ex1 = ex;
        }

        try {
            GovernorLimitPreemptException.assertHasHeapSpaceRemaining(0.0, null);
        } catch (Exception ex) {
            ex2 = ex;
        }

        try {
            GovernorLimitPreemptException.assertHasHeapSpaceRemaining(0.0, 'Custom Error Message');
        } catch (Exception ex) {
            ex3 = ex;
        }

        try {
            GovernorLimitForceHelper.wasteHeap(0.51);
            GovernorLimitPreemptException.assertHasHeapSpaceRemaining(0.5, null);
        } catch (Exception ex) {
            ex4 = ex;
            GovernorLimitForceHelper.clearHeap();
        }

        Assert.areEqual(null, ex1, 'Expected to NOT throw an exception, but it threw a ' + ex1?.getTypeName());

        Assert.isInstanceOfType(
            ex2,
            GovernorLimitPreemptException.class,
            'Expected to throw an exception of type GovernorLimitPreemptException, but actually threw ' +
            ex2?.getTypeName()
        );
        Assert.areEqual('Very near to the heap limit, exceeding 0.0% usage.', ex2.getMessage());

        Assert.isInstanceOfType(
            ex3,
            GovernorLimitPreemptException.class,
            'Expected to throw an exception of type GovernorLimitPreemptException, but actually threw ' +
            ex3?.getTypeName()
        );
        Assert.areEqual('Custom Error Message', ex3.getMessage());

        Assert.isInstanceOfType(
            ex4,
            GovernorLimitPreemptException.class,
            'Expected to throw an exception of type GovernorLimitPreemptException, but actually threw ' +
            ex4?.getTypeName()
        );
        Assert.areEqual('Very near to the heap limit, exceeding 50.0% usage.', ex4.getMessage());
    }
}
