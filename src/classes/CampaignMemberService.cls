public with sharing class CampaignMemberService {
    /**
     * Returns all the fields on CampaignMember in a String
     * @return A string containing all the CampaignMember fields
     */
    public static String campaignMemberFieldsToString() {
        String campaignMemberFields = null;

        Map<String, SObjectField> campaignMemberFieldMap = ObjectService.getObjectFieldMap('CampaignMember');

        campaignMemberFields = ObjectService.objectFieldsToString(campaignMemberFieldMap);

        return campaignMemberFields;
    }

    /**
     * Get a list of CampaignMembers for the provided Contact Id
     * @param The Id of the Contact to search on
     * @return A list of CampaignMembers for the provided Contact Id
     */
    public static List<CampaignMember> getCampaignMembers(Id contactId) {
        String camFields = campaignMemberFieldsToString();

        List<CampaignMember> camMems = new List<CampaignMember>();

        String soql =
            '' +
            'SELECT ' +
            camFields +
            ', Campaign.RecordType.Name, Campaign.Name, ' +
            'Campaign.ParentId, Campaign.Type, Campaign.Requested__c, Campaign.Parent.Name, ' +
            'Campaign.Event_Start_Date__c, Campaign.Event_End_Date__c, ' +
            'Campaign.Interest_PeopleSoft_Major__c, Campaign.StartDate, Campaign.EndDate ' +
            'FROM CampaignMember ' +
            'WHERE ContactId = :contactId ';

        camMems = Database.query(soql);

        return camMems;
    }

    /**
     * Create a test list of CampaignMembers for the provided Contact Id
     * @param The Id of the Contact to create CampaignMembers for
     * @param A list of Campaigns to add the Contact to
     * @return A list of CampaignMembers for the provided Contact Id to insert
     */
    public static List<CampaignMember> createTestCampaignMembers(Id contactId, List<Campaign> camList) {
        List<CampaignMember> camMems = new List<CampaignMember>();

        for (Campaign cam : camList) {
            CampaignMember tempCamMem = new CampaignMember(CampaignId = cam.Id, ContactId = contactId, Status = 'Sent');

            if (cam.RecordType.Name == 'Corporate Relations') {
                tempCamMem.Status = 'Active';
            }

            camMems.add(tempCamMem);
        }

        return camMems;
    }
}
