public class UserService {
    public static void populateContactsUsingAsurite(List<User> userList) {
        Id communityProfileId = [SELECT Id FROM Profile WHERE Name = 'ASU Community'].Id;
        Id communityCapProfileId = [SELECT Id FROM Profile WHERE Name = 'ASU Community CAP'].Id;
        Map<String, Contact> asuritesToContact = new Map<String, Contact>();
        Map<String, User> asuritesToUser = new Map<String, User>();

        for (User u : userList) {
            if (u.FederationIdentifier != null && u.ProfileId == communityProfileId) {
                asuritesToUser.put(u.FederationIdentifier.split('@').get(0), u);
                System.debug(u.FederationIdentifier.split('@').get(0));
            }
        }

        if (!asuritesToUser.isEmpty()) {
            List<Contact> contactsForAsurites = [
                SELECT Id, ASURITE_Id__c, CAP__c
                FROM Contact
                WHERE ASURITE_Id__c IN :asuritesToUser.keySet()
            ];
            for (Contact c : contactsForAsurites) {
                asuritesToContact.put(c.ASURITE_Id__c, c);
            }

            for (String asurite : asuritesToUser.keySet()) {
                Contact c = asuritesToContact.get(asurite);
                User u = asuritesToUser.get(asurite);
                u.ContactId = c.Id;

                if (c.CAP__c != null) {
                    u.ProfileId = communityCapProfileId;
                }
            }
        }
    }

    public static void populateRoles(List<User> userList) {
        for (User u : userList) {
            if (u.UserPermissionsKnowledgeUser) {
                u.Role_Knowledge__c = true;
            } else {
                u.Role_Knowledge__c = false;
            }
        }
    }
}
