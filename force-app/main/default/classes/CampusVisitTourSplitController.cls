public class CampusVisitTourSplitController {
    
    
    private static final List<String> VALID_MEMBER_STATUSES = new List<String> {'Registered - Attended', 'Registered - Late', 'Not Registered - Attended'};    
	private static final Integer OVERFLOW_MEMBER_LIMIT = 999;    
    public static List<CampaignMember> tourGroupParticipants {get; set;}
    public static List<TourPod> tourPods {get; set;}
    public static TourPod overflowPod {get; set;}
    
    private static Integer tourGroupSizes;
    private static Integer amountOfPods = 0;
    

    @AuraEnabled
    public static void updateCampaignMembers(List<CampaignMember> cmsToUpdate){
        update cmsToUpdate;
    }

    @AuraEnabled
    public static List<TourPod> refreshCampaignMemberTable(List<CampaignMember> cmsToUpdate) {
        Map<String, TourPod> recreatedPods = new Map<String, TourPod>();

        for (CampaignMember cm : cmsToUpdate) {
            String tourGroupId = '' + cm.Tour_Group_Id__c;
            TourPod pod = recreatedPods.get(tourGroupId);
            if (pod == null) {
                pod = new TourPod(999, (Integer)cm.Tour_Group_Id__c);
                recreatedPods.put(tourGroupId, pod);
            }

            pod.addMember(cm);
        }
        
        return recreatedPods.values();
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getCampaignMemberAcademicSessions(String campaignId) {

        List<CampaignMember> memberInfo = [
        	SELECT Name, Number_of_Attendees__c, Academic_Session__c, Academic_Session_Name__c, Tour_Group_Id__c, Id,
            Comments__c, Barrett_Session__c, Housing_Tour__c, Additional_Tour_Information__c
            FROM CampaignMember
            WHERE Status IN: VALID_MEMBER_STATUSES AND CampaignId =: campaignId
            ORDER By Academic_Session__c, Number_of_Attendees__c DESC
        ];

        Map<String, Integer> academicSessionsWithMemberCount = new Map<String, Integer>();

        for (CampaignMember eventParticipant : memberInfo) {
            Integer currCount = academicSessionsWithMemberCount.get(eventParticipant.Academic_Session_Name__c);

            if (currCount == null) {
                academicSessionsWithMemberCount.put(eventParticipant.Academic_Session_Name__c, 0);
                currCount = 0;
            }

            currCount = currCount + (Integer)eventParticipant.Number_of_Attendees__c;
            academicSessionsWithMemberCount.put(eventParticipant.Academic_Session_Name__c, currCount);
        }

        return academicSessionsWithMemberCount;
    }

    @AuraEnabled(cacheable=true)
    public static List<TourPod> splitGroupsByAcademicSession(String academicSessionGuideNumbers, String campaignId) {

        Map<String, Integer> academicSessionGuideNumberMap = (Map<String, Integer>)JSON.deserialize(academicSessionGuideNumbers, Map<String, Integer>.class);

        Map<String, List<CampaignMember>> academicGroupCampignMembers = new Map<String, List<CampaignMember>>();

        List<CampaignMember> membersInfo = [
        	SELECT Name, Number_of_Attendees__c, Academic_Session__c, Academic_Session_Name__c, Tour_Group_Id__c, Id,
            Comments__c, Barrett_Session__c, Housing_Tour__c, Additional_Tour_Information__c
            FROM CampaignMember
            WHERE Status IN: VALID_MEMBER_STATUSES AND CampaignId =: campaignId
            ORDER By Academic_Session__c, Number_of_Attendees__c DESC
        ];
        
        for (CampaignMember memberForEvent : membersInfo) {

            if (memberForEvent.Academic_Session_Name__c == null) {
                if (academicGroupCampignMembers.get('null') == null) {
                    academicGroupCampignMembers.put('null', new List<CampaignMember>());
                }

                List<CampaignMember> academicGroupMembers = academicGroupCampignMembers.get('null');

                academicGroupMembers.add(memberForEvent);

                academicGroupCampignMembers.put('null', academicGroupMembers);

            } else {

                if (academicGroupCampignMembers.get(memberForEvent.Academic_Session_Name__c) == null) {
                    academicGroupCampignMembers.put(memberForEvent.Academic_Session_Name__c, new List<CampaignMember>());
                }

                List<CampaignMember> academicGroupMembers = academicGroupCampignMembers.get(memberForEvent.Academic_Session_Name__c);
                academicGroupMembers.add(memberForEvent);
                academicGroupCampignMembers.put(memberForEvent.Academic_Session_Name__c, academicGroupMembers);
            }
        }

        tourPods = new List<TourPod>();

        for (String key : academicGroupCampignMembers.keyset()) {
            createPodsForAcademicGroup(academicGroupCampignMembers.get(key), academicSessionGuideNumberMap.get(key));
        }

        return tourPods;
    }

    private static void createPodsForAcademicGroup (List<CampaignMember> eventParticipants, Integer amountOfTourGuides) {

        Integer tourGroupSize = calculateTourGroupSizes(eventParticipants, amountOfTourGuides);

        List<TourPod> podsForAcademicSession = new List<TourPod>();

        for (Integer i = 0; i < amountOfTourGuides; i++) {

            TourPod pod = new TourPod(tourGroupSize, ++amountOfPods);

            podsForAcademicSession.add(pod);
        }

        for (CampaignMember eventMember : eventParticipants) {

            for (Integer i = 0; i < amountOfTourGuides; i++) {
                if (podsForAcademicSession[i].addMember(eventMember)) {
                    break;
                }
            }
        }

        tourPods.addAll(podsForAcademicSession);
    }


    
    private static void getCampaignMembersForTour(String campaignId) {
        tourGroupParticipants = [
        	SELECT Name, Number_of_Attendees__c, Academic_Session__c, Academic_Session_Name__c, Tour_Group_Id__c, Id
            FROM CampaignMember
            WHERE Status IN: VALID_MEMBER_STATUSES AND CampaignId =: campaignId
            ORDER By Academic_Session__c, Number_of_Attendees__c DESC
        ];

        Map<String, Integer> academicSessionsWithMemberCount = new Map<String, Integer>();

        for (CampaignMember eventParticipant : tourGroupParticipants) {
            Integer currCount = academicSessionsWithMemberCount.get(eventParticipant.Academic_Session_Name__c);

            if (currCount == null) {
                academicSessionsWithMemberCount.put(eventParticipant.Academic_Session_Name__c, 0);
            }

            academicSessionsWithMemberCount.put(eventParticipant.Academic_Session_Name__c, ++currCount);
        }
    }
    
    private static Integer calculateTourGroupSizes(List<CampaignMember> campaignMembers, Integer amountOfTourGuides) {
        Integer totalAttendees = 0;
        Integer tourGroupSize;
        for (CampaignMember tourGroupMember : campaignMembers) {
            totalAttendees += (Integer)tourGroupMember.Number_of_Attendees__c;
        }
        
        if ( totalAttendees > 0 && amountOfTourGuides > 0) {
            tourGroupSize = (Integer)Math.ceil(Decimal.valueOf(totalAttendees).divide(amountOfTourGuides, 1));
            tourGroupSize += 1; //Slight increase the max pod size to prevent overflow
        }

        return tourGroupSize;
    }
    
    public class TourPod {
        @AuraEnabled public Integer maxSize {get; set;}
        @AuraEnabled public Integer currentSize {get; set;}
        @AuraEnabled public Integer tourGroupId {get; set;}
        @AuraEnabled public List<CampaignMember> membersForTour {get; set;}
        
        public TourPod (Integer sizeLimit, Integer groupId) {
            maxSize = sizeLimit;
            tourGroupId = groupId;
            currentSize = 0;
            membersForTour = new List<CampaignMember>();
        }
        
        public Boolean addMember(CampaignMember memIn) {
            if (memIn.Number_of_Attendees__c >= maxSize && currentSize == 0) {
                currentSize += (Integer)memIn.Number_of_Attendees__c;
                memIn.Tour_Group_Id__c = tourGroupId;
            	membersForTour.add(memIn);
            
            	return true;
            }
            
            if (memIn.Number_of_Attendees__c + currentSize > maxSize) {
                return false;
            }
            
            currentSize += (Integer)memIn.Number_of_Attendees__c;
            memIn.Tour_Group_Id__c = tourGroupId;
            membersForTour.add(memIn);
            
            return true;
        }
        
        public Boolean isMaxSized() {
            return (currentSize >= maxSize);
        }
    }

}