global class BomgarCreateCaseUtil
{
    global static String createCase(bomgar__BomgarWebEvent__c bgEvent)
    {
        Map<String, String> dynamicFieldMap = new Map<String, String>();
        JSONParser parser = JSON.createParser(bgEvent.bomgar__ExternalKey__c.substring(5));

        while (parser.nextToken() != null)
        {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME)
            {
                String key = parser.getText();
                parser.nextToken();
                String value = parser.getText();
                dynamicFieldMap.put(key, value);
            }
        }

        Contact contact = null;
        Case c = new Case();

        String emplId = dynamicFieldMap.get('employeeNumber');
        String externalKey = dynamicFieldMap.get('externalKey');
        String asurite = dynamicFieldMap.get('asuriteId');
        String description = dynamicFieldMap.get('description');
        String firstname = '';
        String lastname = '';
        Boolean error = false;
        String errorStr = '';

        // Handle ASURITE for BB chat if asurite is null.
        // (bb_asurite__ca or asurite_@ce.asu.edu)
        if (externalKey == 'BB' && asurite == '')
        {
            if (description.contains('ASURITE ID:'))
            {
                asurite = description.substring(
                    description.indexOf('ASURITE ID:') + 12,
                    description.indexOf('Full Name:')
                );

                if (asurite.contains('_'))
                {
                    String[] strs = asurite.split('_');

                    for (String s : strs)
                    {
                        if (s.length() > 5 && !s.contains('@') && !s.contains('.'))
                        {
                            asurite = s;
                        }
                    }
                }
            }
        }

        if (externalKey == 'BB' && asurite != '')
        {
            if (asurite.contains('_'))
            {
                String[] strs = asurite.split('_');

                for (String s : strs)
                {
                    if (s.length() > 5 && !s.contains('@') && !s.contains('.'))
                    {
                        asurite = s;
                    }
                }
            }
        }

        List<RecordType> recordTypes = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'ASU Service'
        ];

        for (RecordType rt : recordTypes)
        {
            c.RecordTypeId = rt.Id;
        }

        // Set case values
        if (description.length() > 255)
        {
            c.Subject = description.substring(0, 254);
        }
        else
        {
            c.Subject = description;
        }

        c.Status = 'New';
        c.Description = description;
        c.Priority = 'Normal';
        c.Origin__c = 'Chat';
        c.Functional_Group__c = 'Help Desk';

        // Check if finance chat and route, if not default to gen
        if (externalKey == 'Finances')
        {
            c.Category__c = 'Finances (Help Desk)';
        }
        else
        {
            c.Category__c = 'General Help Desk';
        }

        // If contact is still null, try and find contact by asuriteId
        if (contact == null && asurite != '')
        {
            contact = lookupContactByASURITE(asurite);
        }

        // Lookup contact by employeeNumber
        if (contact == null && emplId != '')
        {
            contact = lookupContactByEmployeeId(emplId);
        }

        // Final check to see if Contact was found. If not, create one.
        if (contact != null)
        {
            c.ContactId = contact.Id;
        }
        else
        {
            // Handle parsing out name from description if creating a new Contact
            if (externalKey == 'BB' && description != '')
            {
                if (description.contains('Full Name:') && description.contains('Course Role:'))
                {
                    String name = description.substring(
                        description.indexOf('Full Name:') + 10,
                        description.indexOf('Course Role:')
                    );

                    name = name.trim();
                    String[] strs;

                    if (name.contains(' '))
                    {
                        strs = name.split(' ');

                        if (strs.size() == 2)
                        {
                            firstname = strs[0];
                            lastname = strs[1];
                        }
                    }
                    else
                    {
                        firstname = name;
                    }
                }
            }

            if (asurite != '')
            {
                // Try to create a new Contact
                Contact newContact = new Contact();

                newContact.Email = asurite + '@asu.edu';
                newContact.ASURite_ID__c = asurite;
                newContact.EMPLID__c = emplId;
                newContact.MailingPostalCode = '11111';

                if (lastname != '')
                {
                    newContact.LastName = lastname;
                }
                else
                {
                    lastname = asurite;
                    newContact.LastName = lastname;
                }

                if (firstname != '')
                {
                    newContact.FirstName = firstname;
                }
                else
                {
                    firstname = 'BomgarError';
                    newContact.FirstName = firstname;
                }

                insert newContact;

                // Attach new contact to case.
                c.ContactId = newContact.Id;
            }
            else
            {
                c.Reason = 'Bomgar Error';
                error = true;
            }
        }

        // On error, log all the contact info we have.
        if (error)
        {
            c.Description = c.Description + 'UNABLE TO FIND/CREATE A ' +
                'CONTACT WITH THESE VALUES: ' +
                ' - Name: ' + firstname + ' ' + lastname +
                ' - ASURITE: ' + asurite +
                ' - EmplId: ' + emplId +
                ' - ' + errorStr;
        }

        insert c;

        return c.Id;
    }

    global static Contact lookupContactByEmployeeId(String employeeId)
    {
        List<Contact> contacts = [
            SELECT Id, ASURite_ID__c, EMPLID__c
            FROM Contact
            WHERE EMPLID__c = :employeeId
        ];

        for (Contact contact : contacts)
        {
            return contact;
        }

        return null;
    }

    global static Contact lookupContactByASURITE(String asurite)
    {
        List<Contact> contacts = [
            SELECT Id, ASURite_ID__c, EMPLID__c
            FROM Contact
            WHERE ASURITE_Id__c = :asurite
        ];

        for (Contact contact : contacts)
        {
            return contact;
        }

        return null;
    }

    global static User lookupUserByBomgarUsername(String bomgarUsername)
    {
        List<User> users = [
            SELECT Id
            FROM User
            WHERE bomgar__Bomgar_Username__c = :bomgarUsername
        ];

        if (users == null)
        {
            throw new BomgarCreateCaseException(
                'No Users Found for Bomgar Username[' + bomgarUsername + ']'
            );
        }

        return users[0];
    }

    global static User lookupUserByFederationId(String bomgarUsername)
    {
        String federationId = bomgarUserName + '@admin.asu.edu';

        List<User> users = [
            SELECT Id
            FROM User
            WHERE ContactId = Null AND FederationIdentifier = :federationId
        ];

        if (users == null)
        {
            throw new BomgarCreateCaseException(
                'No Users Found for Bomgar Username[' + bomgarUsername + ']'
            );
        }

        return users[0];
    }

    global static Id getOwnerIdBySessionId(String sessionId)
    {
        List<bomgar__Participant__c> myList = [
            SELECT bomgar__Username__c
            FROM bomgar__Participant__c
            WHERE bomgar__IsPrimary__c = true
            AND bomgar__ParticipantType__c = 'Representative'
            AND bomgar__BomgarSession__r.Id = :sessionId
        ];

        for (bomgar__Participant__c bomgarParticipant : myList)
        {
            if (bomgarParticipant != null && bomgarParticipant.bomgar__Username__c != null)
            {
                User owner = lookupUserByFederationId(bomgarParticipant.bomgar__Username__c);

                if (owner != null)
                {
                    return owner.Id;
                }
            }
        }

        return null;
    }

    @future (callout = true)
    global static void assignCase(String lsid, String caseId)
    {
        Map<String,String> parameters = new Map<String, String>();
        parameters.put('lsid', lsid);
        parameters.put('custom.external_key', caseId);

        try
        {
            Bomgar.BomgarAPIAccess.CallCommandAPI(
                Bomgar.BomgarAPIAccess.CommandType.SetSessionAttributes,
                parameters
            );
        }
        catch (Exception e)
        {
            Bomgar.BomgarAPIAccess.RecordError('BomgarCreateCaseUtil assignCase Failure', e);
        }
    }
}