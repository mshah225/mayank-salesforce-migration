global class JITStudentHandler implements Auth.SamlJitHandler
{
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes, String assertion)
    {
        String fedId = attributes.get('User.FederationIdentifier');

        List<User> dupeCheck = new List<User>();
        dupeCheck = [
            SELECT Id, FirstName, LastName, Username, ProfileId, Alias, TimeZoneSidKey, Email,
                EmailEncodingKey, LocaleSidKey, LanguageLocaleKey, FederationIdentifier,
                CommunityNickname
            FROM User
            WHERE FederationIdentifier = :fedId
        ];

        if (dupeCheck.size() < 1)
        {
            User u = new User();
            handleJit(true, u, samlSsoProviderId, communityId, portalId,
                    federationIdentifier, attributes, assertion);
            return u;
        }
        else
        {
            return dupeCheck[0];
        }
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes, String assertion) { }

    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes, String assertion)
    {
        if (communityId != null || portalId != null)
        {
            handleUser(create, u, attributes, federationIdentifier, false);
        }
        else
        {
            handleUser(create, u, attributes, federationIdentifier, true);
        }
    }

    private void handleUser(boolean create, User u, Map<String, String> attributes,
            String federationIdentifier, boolean isStandard)
    {
        if (create)
        {
            if (attributes.containsKey('User.FederationIdentifier'))
            {
                String fedId = attributes.get('User.FederationIdentifier');
                String[] fedIdSplit = fedId.split('@');
                String asurite = fedIdSplit[0];
                u.FederationIdentifier = asurite + '@asu.edu';

                List<Contact> contactLookup = [
                        SELECT Id, FirstName, LastName, CAP__c
                        FROM Contact
                        WHERE ASURite_ID__c = :asurite
                ];

                if (attributes.containsKey('User.FirstName')
                        && attributes.containsKey('User.LastName'))
                {
                    u.FirstName = attributes.get('User.FirstName');
                    u.LastName = attributes.get('User.LastName');
                }
                else
                {
                    u.FirstName = contactLookup[0].FirstName;
                    u.LastName = contactLookup[0].LastName;
                }

                if (contactLookup[0].CAP__c != null)
                {
                    Profile p = [SELECT Id FROM Profile WHERE Name = 'ASU Community CAP'];
                    u.ProfileId = p.Id;
                }
                else
                {
                    Profile p = [SELECT Id FROM Profile WHERE Name = 'ASU Community'];
                    u.ProfileId = p.Id;
                }

                u.Username = 'community_' + asurite + '@asu.edu';
                u.Email = attributes.get('User.FederationIdentifier');
                u.CommunityNickname = asurite + '_comm';
                u.Alias = asurite;
                u.TimeZoneSidKey = 'America/Phoenix';
                u.LocaleSidKey = 'en_US';
                u.EmailEncodingKey = 'ISO-8859-1';
                u.LanguageLocaleKey = 'en_US';
            }
            else
            {
                System.debug('!!!! NO FEDERATION IDENTIFIER PRESENT');
            }
        }
    }

    private class JitException extends Exception { }
}