public class TriggerRecursionCheck {

	private static boolean BeforeTriggerFirstRun = true;
	private static boolean AfterTriggerFirstRun = true;


    public static boolean FirstRunCheck(Integer FiredTrigger){

        if(FiredTrigger == 1 && BeforeTriggerFirstRun) {
         	BeforeTriggerFirstRun=false;
         	return true;
        } else if (FiredTrigger == 2 && AfterTriggerFirstRun){
            AfterTriggerFirstRun = false;
            return true;
        }
        else{
            return false;
        }
    }
}
