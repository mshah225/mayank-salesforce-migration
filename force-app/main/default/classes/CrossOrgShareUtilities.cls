/**
 * File Name: CrossOrgShareUtilities
 * Description: Handles API calls for CrossOrg Data Sharing
 * Author: Carl Hussey
 * Created: 04/22/2020
 */
public class CrossOrgShareUtilities {
    /**
     * Given an MDM GUID, find crosswalk records
     * for the contact
     */
    public static List<CrosswalkGetWrapper> getCrosswalkRecords(String mdmGuid) {
        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();
        HttpResponse crosswalkResponse = crosswalkService.makeGetCallout('guid=' + mdmGuid);
        List<CrosswalkGetWrapper> crosswalk = new List<CrosswalkGetWrapper>();

        if (crosswalkResponse.getStatusCode() == 200) {
            crosswalk = deserializeCrosswalkResponse(crosswalkResponse.getBody());
        }

        return crosswalk;
    }

    /**
     * Given a ContactId, find crosswalk record
     * for the contact
     */
    public static List<CrosswalkGetWrapper> getCrosswalkRecordById(String contactId) {
        CrossOrgShareCallout crosswalkService = new CrossOrgShareCallout();
        HttpResponse crosswalkResponse = crosswalkService.makeGetCalloutById(contactId);
        List<CrosswalkGetWrapper> crosswalk = new List<CrosswalkGetWrapper>();

        if (crosswalkResponse.getStatusCode() == 200) {
            crosswalk = deserializeCrosswalkResponse(crosswalkResponse.getBody());
        }

        return crosswalk;
    }

    /**
     * Deserialize JSON crosswalk records
     */
    public static List<CrosswalkGetWrapper> deserializeCrosswalkResponse(String jsonResponse) {
        List<CrosswalkGetWrapper> crosswalkWrapperList = (List<CrosswalkGetWrapper>) JSON.deserialize(
            jsonResponse,
            List<CrosswalkGetWrapper>.class
        );

        return crosswalkWrapperList;
    }

    /**
     * Deserialize JSON crosswalk status
     */
    public static CrosswalkResponseWrapper deserializeCrosswalkReturnResponse(String jsonResponse) {
        CrosswalkResponseWrapper crosswalkResponseWrapper = (CrosswalkResponseWrapper) JSON.deserialize(
            jsonResponse,
            CrosswalkResponseWrapper.class
        );

        return crosswalkResponseWrapper;
    }

    /**
     * Convert crosswalk response
     * to a list of ContactIds
     */
    public static List<Id> crosswalkToIDList(List<CrosswalkGetWrapper> crosswalk) {
        List<Id> contactIds = new List<Id>();

        for (CrosswalkGetWrapper c : crosswalk) {
            contactIds.add((Id) c.contactId);
        }

        return contactIds;
    }

    /**
     * Wrapper class for the crosswalk GET response
     */
    public class CrosswalkGetWrapper {
        public String contactId { get; set; }
        public String guid { get; set; }
        public String sourceOrgId { get; set; }
        public String lastModifiedDate { get; set; }
    }

    /**
     * Wrapper class for the crosswalk response
     */
    public class CrosswalkResponseWrapper {
        public Integer status { get; set; }
        public String message { get; set; }
    }
}
