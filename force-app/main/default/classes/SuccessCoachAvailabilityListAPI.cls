@RestResource(urlMapping='/AvailableCoachesList2')
global with sharing class SuccessCoachAvailabilityListAPI {
    @HttpGet
    global static List<Success_Resource__c> getCoachList() {
        String isTest = RestContext.request.params.get('isTest');
        String lim = RestContext.request.params.get('limit');
        Integer limitReturn = Integer.valueOf(lim);
        String retVal = '';
        if (lim != null) {
            try {
                HTTPResponse res;
                string jsonContent;
                if (isTest != null && isTest == 'true') {
                    Test.setMock(HttpCalloutMock.class, new HTTPRestService_InContact_MockImpl());
                    jsonContent = '{"agentStates": [{"agentId": "2547405","agentStateId": "1","agentStateName": "LoggedOut","businessUnitId": "4595606","contactId": "","isActive": "True"}]}';
                } else {
                    res = HTTPRestService_InContact.GETRestCallout('services/v7.0/agents/states');
                    jsonContent = res.getBody();
                }
                Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(jsonContent);
                List<Object> agents = (List<Object>) root.get('agentStates');
                List<String> availableAgentsList = new List<String>();
                // Integer availableAgentsCount = 0;
                for (Object agent : agents) {
                    Map<String, Object> agentMap = (Map<String, Object>) agent;
                    if (agentMap.get('agentStateId') == '1') {
                        //   availableAgentsCount++;
                        availableAgentsList.add((String) agentMap.get('agentId')); //just save agentIds
                    }
                    //  if (availableAgentsCount>=limitReturn){
                    //      break;
                    //  }
                }
                String coachRecordTypeId = '';
                List<RecordType> rectype = [
                    SELECT Id
                    FROM RecordType
                    WHERE DeveloperName = 'Coach' AND SobjectType = 'Success_Resource__c'
                ];
                if (rectype.size() > 0) {
                    coachRecordTypeId = rectype[0].Id;
                    //get the ASURITE's
                    List<Success_Resource__c> coachASURites = new List<Success_Resource__c>();
                    coachASURites = [
                        SELECT ASURiteID__c
                        FROM Success_Resource__c
                        WHERE
                            agentId__c IN :availableAgentsList
                            AND IsActive__c = TRUE
                            AND RecordTypeId = :coachRecordTypeId
                        ORDER BY ASURiteID__c ASC
                        LIMIT :limitReturn
                    ];
                    return coachASURites;
                }
            } catch (Exception ex) {
                System.debug(ex);
                retVal = ex.getMessage();
            }
        }
        // List<String> retList = new List<String>();
        // retList.add(retVal);
        //return retList;
        return null;
    }
}
