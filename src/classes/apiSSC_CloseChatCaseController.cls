@RestResource(urlMapping='/CloseChatCase')
global with sharing class apiSSC_CloseChatCaseController {

  @HttpPost  
  global static boolean closeChatCase() {
     String caseId = RestContext.request.params.get('caseId');
     boolean retVal = false;
     
     List<Case> updateCase = [SELECT Id FROM Case WHERE Id =: caseId];
     if(updateCase.size()>0)
     {
         updateCase[0].Status = 'Closed: Resolved';
         update updateCase;
         retVal = true; 
     }
     
     return retVal;
  }
  
}