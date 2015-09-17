global class JITUserHandler implements Auth.SamlJitHandler
{
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes, String assertion)
    {
        String fedId = attributes.get('User.FederationIdentifier');
        String[] fedIdSplit = fedId.split('@');
        String asurite = fedIdSplit[0];
        String searchFedId = asurite + '@admin.asu.edu';

        List<User> dupeCheck = [
            SELECT Id, FirstName, LastName, Username, ProfileId, Alias, TimeZoneSidKey, Email,
                EmailEncodingKey, LocaleSidKey, LanguageLocaleKey, FederationIdentifier
            FROM User
            WHERE FederationIdentifier = :searchFedId
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
                u.FederationIdentifier = asurite + '@admin.asu.edu';

                if (attributes.containsKey('User.FirstName')
                        && attributes.containsKey('User.LastName'))
                {
                    u.FirstName = attributes.get('User.FirstName');
                    u.LastName = attributes.get('User.LastName');
                }
                else
                {
                    List<Contact> contactLookup = [
                        SELECT FirstName, LastName
                        FROM Contact
                        WHERE ASURite_ID__c = :asurite
                        LIMIT 1
                    ];

                    u.FirstName = contactLookup[0].FirstName;
                    u.LastName = contactLookup[0].LastName;
                }

                String fullURL = URL.getSalesforceBaseUrl().toExternalForm();
                System.debug(fullURL);

                String[] splitArray = fullURL.split('\\.');
                System.debug(splitArray[0]);

                if(splitArray[0].contains('--'))
                {
                    String[] finalArray = splitArray[0].split('--');
                    system.debug(finalArray[1]);

                    u.UserName = asurite + '@asu.edu.' + finalArray[1];
                }
                else {
                    u.UserName = asurite + '@asu.edu';
                }

                u.Email = asurite + '@asu.edu';
                u.Alias = asurite;
                Profile p = [SELECT Id FROM Profile WHERE Name = 'Chatter Free User'];
                u.ProfileId = p.Id;
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