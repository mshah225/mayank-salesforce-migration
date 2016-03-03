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

        // Lookup contact by employeeNumber
        if (dynamicFieldMap.get('employeeNumber') != null
            && '' != dynamicFieldMap.get('employeeNumber'))
        {
            contact = lookupContactByEmployeeId(dynamicFieldMap.get('employeeNumber'));
        }

        // If contact is still null, try and find contact by asuriteId
        if (contact == null
            && dynamicFieldMap.get('asuriteId') != null
            && '' != dynamicFieldMap.get('asuriteId'))
        {
            contact = lookupContactByASURITE(dynamicFieldMap.get('asuriteId'));
        }

        String subject = dynamicFieldMap.get('description');

        if (subject != null && subject.length() > 255)
        {
            subject = subject.substring(0, 254);
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

        c.Status = 'New';
        c.Subject = subject;
        c.Description = dynamicFieldMap.get('description');
        c.Priority = 'Normal';
        c.Origin__c = 'Chat';
        c.Functional_Group__c = 'Help Desk';

        // Check if finance chat and route, if not default to gen
        if (dynamicFieldMap.get('externalKey') == 'Finances')
        {
            c.Category__c = 'Finances (Help Desk)';
        }
        else
        {
            c.Category__c = 'General Help Desk';
        }

        if (contact != null)
        {
            c.ContactId = contact.Id;
        }

        insert c;
        return c.Id;
    }

    global static Contact lookupContactByEmployeeId(String employeeId)
    {
        List<Contact> contacts = [
            SELECT Id
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
            SELECT Id
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