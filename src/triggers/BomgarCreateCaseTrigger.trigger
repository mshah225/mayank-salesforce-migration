trigger BomgarCreateCaseTrigger on bomgar__BomgarWebEvent__c (after insert) {
	List<bomgar__BomgarWebEvent__c> eventList = Trigger.new;
    for(bomgar__BomgarWebEvent__c bgEvent : eventList){
        if('support_conference_member_added' == bgEvent.bomgar__EventType__c && bgEvent.bomgar__ConferenceMemberType__c == 'representative' && bgEvent.bomgar__ExternalKey__c != null && bgEvent.bomgar__ExternalKey__c.startsWith('SFDC')){
            //create case
            String caseId = BomgarCreateCaseUtil.createCase(bgEvent);
            //update external key
            try{
                BomgarCreateCaseUtil.assignCase(bgEvent.bomgar__BomgarSessionID__c, caseId);
            } catch(Exception e){
                Bomgar.BomgarAPIAccess.RecordError('BomgarCreateCaseTrigger assignCase Failure lsid=[' + bgEvent.bomgar__BomgarSessionID__c + ']', e);
            }
        }
    }
}