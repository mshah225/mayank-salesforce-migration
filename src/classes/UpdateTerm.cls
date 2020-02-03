public class UpdateTerm implements Schedulable {

    public void execute(SchedulableContext sc) {
        StudentTerm__c currentTermData = StudentTerm__c.getOrgDefaults();
        Term__c currentTermInfo = [
                    SELECT  PeopleSoft_Code__c
                    FROM    Term__c
                    WHERE   Session_A_C_Close_Date__c   >= TODAY
                    AND     (PeopleSoft_Code__c         LIKE '%1' 
                    OR      PeopleSoft_Code__c          LIKE '%7')
                    ORDER BY PeopleSoft_Code__c ASC 
                    LIMIT 1
        ];
        currentTermData.CurrTerm__c = currentTermInfo.PeopleSoft_Code__c;
        if (currentTermInfo.PeopleSoft_Code__c.right(1) == '1') {
            currentTermData.PrevTerm__c = String.valueOf(Integer.valueOf(currentTermInfo.PeopleSoft_Code__c) - 4);
        } else {
            currentTermData.PrevTerm__c = String.valueOf(Integer.valueOf(currentTermInfo.PeopleSoft_Code__c) - 6);
        }
        if (currentTermInfo.PeopleSoft_Code__c.right(1) == '1') {
            currentTermData.NextTerm__c = String.valueOf(Integer.valueOf(currentTermInfo.PeopleSoft_Code__c) + 6);
        } else {
            currentTermData.NextTerm__c = String.valueOf(Integer.valueOf(currentTermInfo.PeopleSoft_Code__c) + 4);
        }

        update currentTermData;
    }
}