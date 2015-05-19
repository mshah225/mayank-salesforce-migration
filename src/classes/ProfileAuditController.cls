public without sharing class ProfileAuditController 
{    
    public Boolean drillDown { get;set; }
    public Boolean back { get;set; }
    public Id selectedProfileId { get;set; }
    public List<Profile> profileList;
    public List<ObjectPermissions> objectPerms { get;set; }
    public List<FieldPermissions> fieldPerms { get;set; }
    public List<String> finalList { get;set; }
    public List<String> fieldDrillList { get;set; }
    public String selectedProfileName { get;set; }
    public String selectedAccess { get;set; }
    public String selectedObject { get;set; }

    public ProfileAuditController()
    {
        drillDown = false;
        back = false;
        profileList = [SELECT Name FROM Profile ORDER BY Name];
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

    public List<SelectOption> getAccessOptions() 
    {
        List<SelectOption> accessOptions = new List<SelectOption>();
        accessOptions.add(new SelectOption('', '--Select--'));
        accessOptions.add(new SelectOption('Has Access', 'Has Access'));
        accessOptions.add(new SelectOption('No Access', 'No Access'));
        return accessOptions;
    }

    public void profilePermissionSearch() 
    {
        drillDown = false;
        back = false;
        if (selectedAccess == 'Has Access')
        {
            if (selectedProfileId != null) 
            {
                fieldPerms = null;
                objectPerms = ProfileService.getAccessibleObjectsByProfile(selectedProfileId);
                selectedProfileName = [SELECT Name FROM Profile WHERE Id = :selectedProfileId].Name;
            }
        }
        else if (selectedAccess == 'No Access')
        {  
            fieldPerms = null;
            finalList = ProfileService.getInaccessibleObjectsByProfile(selectedProfileId);
            selectedProfileName = [SELECT Name FROM Profile WHERE Id = :selectedProfileId].Name;
        }
    }

    public void drillDownSearch() 
    {
        drillDown = true;
        back = true;
        objectPerms = null;
        fieldPerms = null;
        fieldDrillList = ObjectService.getFieldLabelsToList(selectedObject);
    }

    public void drillDownFieldSearch() 
    {
        drillDown = true;
        back = true;
        objectPerms = null;
        fieldPerms = ProfileService.getAccessibleObjectFieldsByProfile(selectedProfileId, selectedObject);
        selectedProfileName = [SELECT Name FROM Profile WHERE Id = :selectedProfileId].Name;
    }

    public void reStart() 
    {
        drillDown = false;
        back = false;
        objectPerms = null;
        fieldPerms = null; 
        selectedAccess = null;
    }
}