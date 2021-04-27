public without sharing class UserHandler implements ITrigger {
    public void bulkBefore() {
        if (Trigger.isInsert) {
            List<User> newUsers = Trigger.new;
            Id communityProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community'].Id;
            Id communityCapProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community CAP'].Id;
            List<String> asurites = new List<String>();
            Map<String, Contact> asuritesToContact = new Map<String, Contact>();
            Map<String, User> asuritesToUser = new Map<String, User>();

            for (User newUser : newUsers) {
                if (newUser.UserPermissionsKnowledgeUser) {
                    newUser.Role_Knowledge__c = true;
                }

                if (newUser.FederationIdentifier != null && newUser.ProfileId == communityProfile) {
                    asurites.add(newUser.FederationIdentifier.split('@').get(0));
                    asuritesToUser.put(newUser.FederationIdentifier.split('@').get(0), newUser);
                    System.debug(newUser.FederationIdentifier.split('@').get(0));
                }
            }

            if (asurites.size() > 0) {
                List<Contact> newUserContactsByASURITE = [
                    SELECT Id, ASURITE_Id__c, CAP__c
                    FROM Contact
                    WHERE ASURITE_Id__c IN :asurites
                ];
                for (Integer x = 0; x < newUserContactsByASURITE.size(); x++) {
                    Contact c = newUserContactsByASURITE.get(x);
                    asuritesToContact.put(c.ASURITE_Id__c, c);
                }

                List<String> asuritesKeys = new List<String>(asuritesToContact.keySet());

                for (Integer x = 0; x < asuritesKeys.size(); x++) {
                    String asurite = asuritesKeys.get(x);
                    Contact c = asuritesToContact.get(asurite);
                    User u = asuritesToUser.get(asurite);
                    u.ContactId = c.Id;

                    if (c.CAP__c != null) {
                        u.ProfileId = communityCapProfile;
                    }
                }
            }

            //throw new ContactServiceException('This is the Contact: ' + );
        }
    }

    public void bulkAfter() {
        // Add to chatter groups
        UserChatterGroupHandler.handleChatterGroups((List<User>) Trigger.new);

        // Deprovision User
        if (Trigger.isUpdate) {
            UserDeprovisionOrganizer userDeprovisionOrganizer = new UserDeprovisionOrganizer(
                (Map<Id, User>) Trigger.oldMap,
                (List<User>) Trigger.new
            );
            userDeprovisionOrganizer.deprovisionUsersAfterUpdate();
        }
    }

    public void beforeInsert(SObject so) {
    }

    public void beforeUpdate(SObject oldSo, SObject so) {
        User updatedUser = (User) so;
        User oldUser = (User) so;

        if (updatedUser.UserPermissionsKnowledgeUser) {
            updatedUser.Role_Knowledge__c = true;
        } else {
            updatedUser.Role_Knowledge__c = false;
        }
    }

    public void beforeDelete(SObject so) {
    }

    public void beforeFinally() {
    }

    public void afterInsert(SObject so) {
    }

    public void afterUpdate(SObject oldSo, SObject so) {
    }

    public void afterDelete(SObject so) {
    }

    public void andFinally() {
    }
}
