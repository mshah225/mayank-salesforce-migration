/**
 * Queueable job to update the Profile_Ids__c custom setting cache.
 * This is usually queued by the ProfileHelper class
 *
 * System.enqueueJob(new ProfileHelperQueueable());
 */
public without sharing class ProfileHelperQueueable implements Queueable {
    public ProfileHelperQueueable() {
    }

    public void execute(QueueableContext context) {
        try {
            // Existing records
            List<Profile_Ids__c> oldProfileIds = Profile_Ids__c.getAll().values();

            // Create new records
            List<Profile_Ids__c> newProfileIds = new List<Profile_Ids__c>();
            for (Profile p : [SELECT Id, Name FROM Profile]) {
                Profile_Ids__c profileId = new Profile_Ids__c(Name = p.Id, Name__c = p.Name, Id__c = p.Id);
                newProfileIds.add(profileId);
            }

            // Check if actually changed or not (we won't recreate if no changes)
            Boolean hasChanged = false;
            Map<String, Id> oldMapping = new Map<String, Id>();
            Map<String, Id> newMapping = new Map<String, Id>();
            for (Profile_Ids__c pi : oldProfileIds)
                oldMapping.put(pi.Name__c, pi.Id__c);
            for (Profile_Ids__c pi : newProfileIds)
                newMapping.put(pi.Name__c, pi.Id__c);

            if (oldMapping.size() != newMapping.size()) {
                hasChanged = true;
            } else {
                for (String pName : newMapping.keySet()) {
                    if (!oldMapping.containsKey(pName)) {
                        hasChanged = true;
                        break;
                    } else if (oldMapping.get(pName) != newMapping.get(pName)) {
                        hasChanged = true;
                        break;
                    }
                }
            }

            if (hasChanged) {
                // delete old records
                if (oldProfileIds.size() > 0)
                    delete oldProfileIds;

                // insert new records
                if (newProfileIds.size() > 0)
                    insert newProfileIds;
            }
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('Action', 'Could not update Profile_Ids__c '));
            ErrorLogger.log(ex, vars, false);
        }
    }
}
