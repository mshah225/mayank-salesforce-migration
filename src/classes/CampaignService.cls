public with sharing class CampaignService
{
    /* Creates a list of Campaigns for each RecordType for tests
    * @return returns the list of Campaigns for insert
    */
    public static List<Campaign> createTestCampaigns()
    {
        List<Campaign> cams = new List<Campaign>();

        List<RecordType> camRecordTypes = [
            SELECT Id, Name
            FROM RecordType
            WHERE SObjectType = 'Campaign'
			AND Name != 'Subscription Center'
        ];

        for (RecordType rt : camRecordTypes)
        {
            Campaign tempCam = new Campaign(
                Name = rt.Name + ' Test',
                RecordTypeId = rt.Id,
                Status = 'Active'
            );

            cams.add(tempCam);
        }

        return cams;
    }

    /* Create a List of Campaigns from the provided type
    * @param the number of Campaigns to create
    * @param the RecordType Name for the Campaign
    * @return the List of Campaigns for insert
    */
    public static List<Campaign> createTestCampaignOfType(Integer howMany, String recTypeName)
    {
        List<Campaign> camList = new List<Campaign>();

        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE Name = :recTypeName
            AND SobjectType = 'Campaign'
        ];

        for (Integer i = 0; i < howMany; i++)
        {
            Campaign tempCampaign = new Campaign(
                Name = recTypeName + ' Test Campaign ' + i,
                RecordTypeId = rt.Id,
                Status = 'Active',
                IsActive = true
            );

            camList.add(tempCampaign);
        }

        return camList;
    }
}