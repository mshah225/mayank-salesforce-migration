/**
 * Take a list of contacts that were deleted as part of a merge operation and mark the winning records
 * as having been merged (and the current date).
 *
 * This must be done asynchronously because you cannot update a record currently involved in a merge.
 */
public with sharing class ContactMergeUpdaterQueueable implements Queueable {
    List<Contact> oldList;

    public ContactMergeUpdaterQueueable(List<Contact> oldList) {
        this.oldList = oldList;
    }

    public void execute(QueueableContext context) {
        try {
            Map<Id, Contact> winningRecordsMp = new Map<Id, Contact>();

            for (Contact deletedContact : oldList) {
                // Skip non merged contacts
                if (deletedContact.MasterRecordId == null)
                    continue;

                // Prevent duplicate ids if multiple records have merged into one winner
                if (winningRecordsMp.containsKey(deletedContact.MasterRecordId))
                    continue;

                // Mark that merge happened and when
                winningRecordsMp.put(
                    deletedContact.MasterRecordId,
                    new Contact(
                        Id = deletedContact.MasterRecordId,
                        Merged_Contact__c = true,
                        Last_Merge_Date__c = System.today()
                    )
                );
            }

            // Update records if needed
            if (!winningRecordsMp.isEmpty()) {
                update winningRecordsMp.values();
            }
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            List<String> winningLoserContacts = new List<String>();
            for (Contact c : oldList) {
                String loserId = c.Id;
                String winnerId = c.MasterRecordId != null ? c.MasterRecordId : 'NULL';
                winningLoserContacts.add('(Winner: ' + winnerId + ', Loser: ' + loserId + ')');
            }
            vars.add(ErrorLogger.convertListToJSON('winningLoserContacts', winningLoserContacts));
            ErrorLogger.log(ex, vars, false);
        }
    }
}