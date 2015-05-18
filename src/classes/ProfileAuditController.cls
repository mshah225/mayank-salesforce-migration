public without sharing class ProfileAuditController 
{    
    public Boolean drillDown { get;set; }
    public Id selectedProfileId { get;set; }
    public List<Profile> profileList;
    public List<ObjectPermissions> objectPerms { get;set; }
    public List<FieldPermissions> fieldPerms { get;set; }
    public List<String> finalList { get;set; }
    public List<String> fieldDrillList { get;set; }
    public Set<String> finalSet { get;set; }
    public String selectedProfileName { get;set; }
    public String selectedType { get;set; }
    public String selectedAccess { get;set; }
    public String selectedObject { get;set; }

    public ProfileAuditController() 
    {
        selectedProfileId = null;
        drillDown = false;
        profileList = [SELECT Name FROM Profile ORDER BY Name];
    }

    public List<SelectOption> getAccessOptions() 
    {
        List<SelectOption> accessOptions = new List<SelectOption>();
        accessOptions.add(new SelectOption('', '--Select--'));
        accessOptions.add(new SelectOption('Has Access', 'Has Access'));
        accessOptions.add(new SelectOption('No Access', 'No Access'));
        return accessOptions;
    }

    public List<SelectOption> getTypeOptions() 
    {
        List<SelectOption> typeOptions = new List<SelectOption>();
        typeOptions.add(new SelectOption('', '--Select--'));
        typeOptions.add(new SelectOption('Object Permissions', 'Object Permissions'));
        typeOptions.add(new SelectOption('Field Permissions', 'Field Permissions'));
        return typeOptions;
    }

    public List<SelectOption> getProfileOptions() 
    {
        List<SelectOption> profileOptions = new List<SelectOption>();
        profileOptions.add(new SelectOption('', '--Select--'));
        for (Profile p: profileList) 
        {
            String name = p.Name;
            if (p.Name.startsWith('ASU') && !p.Name.contains('TEMPLATE')) 
            {
                profileOptions.add(new SelectOption(p.Id, p.Name));
            }
        }
        return profileOptions;
    }

    public void profilePermissionSearch() 
    {
        drillDown = false;
        if (selectedType != null && selectedAccess == 'No Access') 
        {
            resetForm();
        }

        if (selectedAccess == 'Has Access')
        {
            if (selectedType == 'Object Permissions') 
            {
                if (selectedProfileId != null) 
                {
                    fieldPerms = null;
                    objectPerms = [SELECT ParentId, SObjectType, PermissionsCreate, PermissionsDelete, PermissionsEdit, PermissionsModifyAllRecords, PermissionsRead, PermissionsViewAllRecords 
                                   FROM ObjectPermissions 
                                   WHERE ParentId 
                                   IN (SELECT Id FROM PermissionSet 
                                       WHERE IsOwnedByProfile = true 
                                       AND PermissionSet.Profile.Id = :selectedProfileId)]; 
                    objectPerms.sort();
                    selectedProfileName = [SELECT Name FROM Profile WHERE Id = :selectedProfileId].Name;
                }
            } 
            else if (selectedType == 'Field Permissions') 
            {
                if (selectedProfileId != null) 
                {
                    objectPerms = null;
                    fieldPerms = [SELECT ParentId, SObjectType, Field, PermissionsEdit, PermissionsRead
                                  FROM FieldPermissions 
                                  WHERE ParentId IN (SELECT Id FROM PermissionSet 
                                                     WHERE IsOwnedByProfile = true 
                                                     AND PermissionSet.Profile.Id = :selectedProfileId) 
                                  ORDER BY SObjectType]; 
                    selectedProfileName = [SELECT Name FROM Profile WHERE Id = :selectedProfileId].Name;
                }
            } 
        }
        else if (selectedAccess == 'No Access')
        {  
            fieldPerms = null;
            List<ObjectPermissions> hasAccess = new List<ObjectPermissions>();
            hasAccess = [SELECT ParentId, SObjectType, PermissionsCreate, PermissionsDelete, PermissionsEdit, PermissionsModifyAllRecords, PermissionsRead, PermissionsViewAllRecords 
                         FROM ObjectPermissions 
                         WHERE ParentId 
                         IN (SELECT Id FROM PermissionSet 
                             WHERE IsOwnedByProfile = true 
                             AND PermissionSet.Profile.Id = :selectedProfileId)]; 
            
            Set<String> accessSet = new Set<String>();
            for (ObjectPermissions op: hasAccess)
            {
                accessSet.add(op.SObjectType);
            }

            finalSet = new Set<String>();
            for (Schema.SObjectType typ: Schema.getGlobalDescribe().values()) 
            {
                String sobjName = String.valueOf(typ);
                if(!accessSet.contains(sobjName))
                {
                    finalSet.add(sobjName);
                }
            }
            finalList = new List<String>();
            finalList.addAll(finalSet);
            finalList.sort();
            selectedProfileName = [SELECT Name FROM Profile WHERE Id = :selectedProfileId].Name;
        }
        else {}
    }

    public void drillDownSearch() 
    {
        drillDown = true;
        objectPerms = null;
        fieldPerms = null;
        fieldDrillList = new List<String>();
        SObjectType obType = Schema.getGlobalDescribe().get(selectedObject);
        Map<String,Schema.SObjectField> obFields = obType.getDescribe().fields.getMap();
        for (String obf: obFields.keySet()) 
        {         
            fieldDrillList.add(obFields.get(obf).getDescribe().getLabel());
        }
        fieldDrillList.sort();

        /*List<Schema.SObjectField> schemaFields = obFields.values();
        fieldDrillList = new List<String>();
        for (Schema.SObjectField sf: schemaFields)
        {
            fieldDrillList.add(sf.value());
        }*/
    }

    public void reStart() 
    {
        drillDown = false;
        objectPerms = null;
        fieldPerms = null; 
        selectedAccess = null;
        selectedType = null;   
    }

    public void resetForm() 
    {
        drillDown = false;
        objectPerms = null;
        fieldPerms = null; 
        selectedType = null;   
    }
}