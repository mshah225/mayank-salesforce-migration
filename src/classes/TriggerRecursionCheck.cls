public class TriggerRecursionChecker {

    private static Boolean beforeTriggerFirstRun = true;
	private static Boolean afterTriggerFirstRun = true;


    public static Boolean BeforeTriggerFirstRunCheck() {

        if (beforeTriggerFirstRun) {
         	beforeTriggerFirstRun = false;
         	return true;
        }
        else {
            return false;
        }
    }

    public static Boolean AfterTriggerFirstRunCheck() {

        if (afterTriggerFirstRun) {
         	afterTriggerFirstRun = false;
         	return true;
        }
        else {
            return false;
        }
    }
}
