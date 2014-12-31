trigger TerritoryAssignmentRuleTrigger on Territory_Assignment_Rule__c (before update) {

    TerritoryAssignmentHelper tah = new TerritoryAssignmentHelper();
    tah.TerritoryAssignmentRuleTA();

    /*    
    if(Trigger.isAfter && Trigger.isUpdate){     
        Set<Id> RuleUserIdSet = new Set<Id>();
        for (Territory_Assignment_Rule__c ATAR : Trigger.New) {
             if(ATAR.Defer_Territory_Assignment__c == false && ATAR.User__c != null && Trigger.oldmap.get(ATAR.Id).User__c != ATAR.User__c){
                 RuleUserIdSet.add(Trigger.oldmap.get(ATAR.Id).User__c);
             }    
        }
        if(RuleUserIdSet.Size() > 0){
            LIST<Opportunity> OpportunityList = [SELECT Id,Territory_Assignment_Required__c  FROM Opportunity WHERE Territory_Assignment_Last_Rule_Type__c != null AND OwnerId IN :RuleUserIdSet LIMIT 5000];
            for(Opportunity Opp : OpportunityList){Opp.Territory_Assignment_Required__c = true;}
            if(OpportunityList != null){update OpportunityList;}
            
            List<Lead> leadList = [SELECT Id, Territory_Assignment_Required__c FROM Lead WHERE Territory_Assignment_Last_Rule_Type__c != null AND OwnerId IN :RuleUserIdSet LIMIT 5000];
    	    for(Lead l:leadList){l.Territory_Assignment_Required__c = true;}
    	    if(!LeadList.isEmpty()){update leadList;}
        }    
    }
    */
}