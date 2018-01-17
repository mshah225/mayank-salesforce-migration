global class UpdateTerm implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        StudentTerm__c studentTerm = StudentTerm__c.getOrgDefaults();
        JBT_RET_TERMS_VW__x currentTermInfo = [
                    SELECT  CURR_TERM__c, NEXT_TERM__c, PREV_TERM__c
                    FROM    JBT_RET_TERMS_VW__x
                    LIMIT 1
        ];
        String currentTerm = currentTermInfo.CURR_TERM__c;
        String nextTerm = currentTermInfo.NEXT_TERM__c;
        String prevTerm = currentTermInfo.PREV_TERM__c;
        studentTerm.PrevTerm__c = prevTerm;
        studentTerm.CurrTerm__c = currentTerm;
        studentTerm.NextTerm__c = nextTerm;

        update studentTerm;
    }
}