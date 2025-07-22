public with sharing class CampaignService {
    /* Creates a list of Campaigns for each RecordType for tests
     * @return returns the list of Campaigns for insert
     */
    public static List<Campaign> createTestCampaigns() {
        List<Campaign> cams = new List<Campaign>();

        for (RecordType rt : [
            SELECT Id, Name
            FROM RecordType
            WHERE SObjectType = 'Campaign' AND Name != 'Subscription Center'
        ]) {
            cams.add(new Campaign(Name = rt.Name + ' Test', RecordTypeId = rt.Id, Status = 'Active'));
        }

        return cams;
    }

    /* Create a List of Campaigns from the provided type
     * @param the number of Campaigns to create
     * @param the RecordType Name for the Campaign
     * @return the List of Campaigns for insert
     */
    public static List<Campaign> createTestCampaignOfType(Integer howMany, String recTypeName) {
        List<Campaign> camList = new List<Campaign>();

        RecordType rt = [SELECT Id FROM RecordType WHERE Name = :recTypeName AND SobjectType = 'Campaign'];

        for (Integer i = 0; i < howMany; i++) {
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

    @future
    public static void setHashId(List<Id> CampaignIdList) {
        List<Campaign> CampaignList = new List<Campaign>();
        for (Id i : campaignIdList) {
            Campaign c = new Campaign(Id = i, HashCampaignID__c = Hasher.hashId(i));
            CampaignList.add(c);
        }
        update CampaignList;
    }

    /**
     * On each record, whenever Normalized_Event_Start_Time__c changes, update the Event_Start_Time__c to the corresponding
     * time following the ASU Communication Guidelines format.
     */
    public static void setPrintableStartTime(List<Campaign> newList, Map<Id, Campaign> oldMap) {
        for (Campaign newCampaign : newList) {
            Campaign oldCampaign = oldMap == null ? null : oldMap.get(newCampaign.Id);
            if (oldCampaign?.Normalized_Event_Start_Time__c != newCampaign?.Normalized_Event_Start_Time__c) {
                newCampaign.Event_Start_Time__c = convertTimeToASUCommunciationGuidelines(
                    newCampaign.Normalized_Event_Start_Time__c
                );
            }
        }
    }

    /**
     * On each record, whenever Normalized_Event_End_Time__c changes, update the Event_End_Time__c to the corresponding
     * time following the ASU Communication Guidelines format.
     */
    public static void setPrintableEndTime(List<Campaign> newList, Map<Id, Campaign> oldMap) {
        for (Campaign newCampaign : newList) {
            Campaign oldCampaign = oldMap == null ? null : oldMap.get(newCampaign.Id);
            if (oldCampaign?.Normalized_Event_End_Time__c != newCampaign?.Normalized_Event_End_Time__c) {
                newCampaign.Event_End_Time__c = convertTimeToASUCommunciationGuidelines(
                    newCampaign.Normalized_Event_End_Time__c
                );
            }
        }
    }

    /**
     * On each record, whenever Normalized_Registration_Time__c changes, update the Registration_Time__c to the corresponding
     * time following the ASU Communication Guidelines format.
     */
    public static void setPrintableRegistrationTime(List<Campaign> newList, Map<Id, Campaign> oldMap) {
        for (Campaign newCampaign : newList) {
            Campaign oldCampaign = oldMap == null ? null : oldMap.get(newCampaign.Id);
            if (oldCampaign?.Normalized_Registration_Time__c != newCampaign?.Normalized_Registration_Time__c) {
                newCampaign.Registration_Time__c = convertTimeToASUCommunciationGuidelines(
                    newCampaign.Normalized_Registration_Time__c
                );
            }
        }
    }

    /**
     * Converts a Time object to a string following the ASU communication guidelines
     * https://brandguide.asu.edu/brand-elements/writing-content/time-days-months-years
     *
     * This means:
     *      "noon"            if the time is at noon
     *      "%h a.m./p.m."    for times that are on the hour
     *      "%h:%m a.m./p.m." for times that include a minute
     *
     * Notes:
     *      Returns empty string if time is null
     *
     * @param tm Time object to convert
     *
     * @return A string representing the time
     */
    public static String convertTimeToASUCommunciationGuidelines(Time tm) {
        if (tm == null) {
            // if time is changed to null, clear the printable timestring
            return '';
        } else if (tm.hour() == 12 && tm.minute() == 0) {
            // Special case "noon"
            return 'noon';
        } else {
            Integer hour = tm.hour();
            Integer minute = tm.minute();
            String ampm = 'a.m.';

            // Edge cases for converting from 24-hour time to 12-hour times
            if (hour == 0) {
                hour = 12;
                ampm = 'a.m.';
            } else if (hour == 12) {
                hour = 12;
                ampm = 'p.m.';
            } else if (hour > 12) {
                hour -= 12;
                ampm = 'p.m.';
            }

            if (minute == 0) {
                // On the hour - don't include minute
                return hour + ' ' + ampm;
            } else {
                // Has a minute component - include it
                return hour + ':' + minute + ' ' + ampm;
            }
        }
    }
}