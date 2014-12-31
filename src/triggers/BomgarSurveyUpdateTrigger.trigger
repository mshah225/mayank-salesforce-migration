trigger BomgarSurveyUpdateTrigger on bomgar__SurveyData__c (after insert) {
    List<bomgar__SurveyData__c> surveyList = Trigger.new;
    for(bomgar__SurveyData__c surveyData : surveyList){
        String lsid = '';
        if('close_state' == surveyData.Name){
            try{
                List<bomgar__SurveyData__c> x = [SELECT Id, bomgar__Survey__r.bomgar__BomgarSession__c, bomgar__Survey__r.bomgar__BomgarSession__r.bomgar__RelatedCase__c from bomgar__SurveyData__c WHERE bomgar__SurveyData__c.Id =:surveyData.Id];
                for(bomgar__SurveyData__c surveyCaseData : x){
                    if(surveyCaseData.bomgar__Survey__r.bomgar__BomgarSession__r.bomgar__RelatedCase__c != null){
                        if('Resolved' == surveyData.bomgar__Value__c){
                            Case c = new Case();
                            c.Id = surveyCaseData.bomgar__Survey__r.bomgar__BomgarSession__r.bomgar__RelatedCase__c;
                            c.Status = 'Closed: Resolved'; 
                            Id ownerId = BomgarCreateCaseUtil.getOwnerIdBySessionId(surveyCaseData.bomgar__Survey__r.bomgar__BomgarSession__c); 
                            if(ownerId!= null){
                                c.OwnerId = ownerId;
                            } 
                            update c;             
                        }
                        else if('Escalate' == surveyData.bomgar__Value__c){
                            Case c = new Case();
                            c.Id = surveyCaseData.bomgar__Survey__r.bomgar__BomgarSession__r.bomgar__RelatedCase__c;
                            c.Status = 'In Progress'; 
                            Id ownerId = BomgarCreateCaseUtil.getOwnerIdBySessionId(surveyCaseData.bomgar__Survey__r.bomgar__BomgarSession__c); 
                            if(ownerId!= null){
                                c.OwnerId = ownerId;
                            }
                            update c;             
                        }
                    }
                }
            } catch(Exception e){
                Bomgar.BomgarAPIAccess.RecordError('BomgarSurveyUpdateTrigger Update Case Failure lsid=[' + lsid + ']', e);
            }
        }
    }
}