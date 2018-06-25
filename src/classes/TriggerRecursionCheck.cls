public class TriggerRecursionCheck {

    private static boolean Firstrun = true;
	private static Integer LastTriggerFired;

    public static boolean FirstRunCheck(Integer FiredTrigger){

        if(Firstrun) {
            LastTriggerFired = FiredTrigger;
         	Firstrun=false;
         	return true;
        } else {
            if(LastTriggerFired != FiredTrigger) {
            	Firstrun = true;
                return FirstRunCheck(FiredTrigger);
            } else{
            	return Firstrun;
            }
        }
    }

}
