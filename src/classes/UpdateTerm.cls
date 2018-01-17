public class UpdateTerm implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        StudentTerm__c currentTermData = StudentTerm__c.getOrgDefaults();
        JBT_RET_TERMS_VW__x currentTermInfo = [
                    SELECT  CURR_TERM__c, NEXT_TERM__c, PREV_TERM__c
                    FROM    JBT_RET_TERMS_VW__x
                    LIMIT 1
        ];
        
        currentTermData.PrevTerm__c = currentTermInfo.PREV_TERM__c;
        currentTermData.CurrTerm__c = currentTermInfo.CURR_TERM__c;
        currentTermData.NextTerm__c = currentTermInfo.NEXT_TERM__c;

        update currentTermData;
    }
}