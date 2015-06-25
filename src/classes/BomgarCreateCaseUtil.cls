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
        if (dynamicFieldMap.get('employeeNumber') != null && '' != dynamicFieldMap.get('employeeNumber'))
        {
             contact = lookupContactByEmployeeId(dynamicFieldMap.get('employeeNumber'));
        }
        if (contact == null) 
        {
            lookupContactByASURITE(dynamicFieldMap.get('asuriteId'));
        }
        if (dynamicFieldMap.get('asuriteId') != null && '' != dynamicFieldMap.get('asuriteId'))
        {
             contact = lookupContactByASURITE(dynamicFieldMap.get('asuriteId'));
        }
        Case c = new Case();
        String subject = dynamicFieldMap.get('description');
        if (subject != null && subject.length() > 255)
        {
            subject = subject.substring(0,254);
        }
        try
        {
            List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE Name = 'ASU Service'];
            for (RecordType rt : recordTypes)
            {
                c.RecordTypeId = rt.Id;
            }
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
        }
        c.Status = 'New';
        c.Subject = subject;
        c.Description = dynamicFieldMap.get('description');
        c.Priority = 'Normal';
        c.Origin__c = 'Chat';
        c.Functional_Group__c = 'Help Desk';
        if (dynamicFieldMap.get('externalKey') == 'Other')
        {
            c.Category__c = 'General Help Desk';
        }
        else
        {
            c.Category__c = 'Finances (Help Desk)';
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
        List<Contact> contacts = [SELECT Id
                                  FROM Contact
                                  WHERE EMPLID__c = :employeeId];
        for (Contact contact : contacts)
        {
            return contact;
        }
        return null;
    }

    global static Contact lookupContactByASURITE(String asurite)
    {
        List<Contact> contacts = [SELECT Id
                                  FROM Contact
                                  WHERE ASURITE_Id__c = :asurite];
        for (Contact contact : contacts)
        {
            return contact;
        }
        return null;
    }

    global static User lookupUserByBomgarUsername(String bomgarUsername)
    {
        List<User> users = [SELECT Id
                            FROM User
                            WHERE bomgar__Bomgar_Username__c = :bomgarUsername];
        if (users.size() > 1)
        {
            throw new BomgarCreateCaseException('Multiple Users Found for Bomgar Username[' + bomgarUsername + ']');
        }
        for (User user : users)
        {
            return user;
        }
        return null;
    }

    global static User lookupUserByFederationId(String bomgarUsername)
    {
        String federationId = bomgarUserName + '@admin.asu.edu';
        List<User> users = [SELECT Id
                            FROM User
                            WHERE ContactId = Null AND FederationIdentifier = :federationId];
        if (users.size() > 1)
        {
            throw new BomgarCreateCaseException('Multiple Users Found for Bomgar Username[' + bomgarUsername + ']');
        }
        for (User user : users)
        {
            return user;
        }
        return null;
    }

    global static Id getOwnerIdBySessionId(String sessionId)
    {
        List<bomgar__Participant__c> myList = [SELECT bomgar__Username__c
                                               FROM bomgar__Participant__c
                                               WHERE bomgar__IsPrimary__c = true
                                               AND bomgar__ParticipantType__c = 'Representative'
                                               AND bomgar__BomgarSession__r.Id = :sessionId];
        for (bomgar__Participant__c x : myList)
        {
            if (x != null && x.bomgar__Username__c != null)
            {
                User owner = lookupUserByFederationId(x.bomgar__Username__c);
                if (owner != null)
                {
                    return owner.Id;
                }
            }
        }
        return null;
    }

    @future (callout=true)
    global static void assignCase(String lsid, String caseId)
    {
        Map<String,String> parameters = new Map<String, String>();
        parameters.put('lsid', lsid);
        parameters.put('custom.external_key', caseId);
        try
        {
            Bomgar.BomgarAPIAccess.CallCommandAPI(Bomgar.BomgarAPIAccess.CommandType.SetSessionAttributes, parameters);
        }
        catch (Exception e)
        {
            Bomgar.BomgarAPIAccess.RecordError('BomgarCreateCaseUtil assignCase Failure', e);
        }
    }
}