public without sharing class CampaignMemberHandler
  implements ITrigger {
    
    //Set<Id> interestCmIds = new Set<Id>();
    //Set<Id> interestContactIds = new Set<Id>();
    
    //Map<Id, Opportunity> relatedOpportunityMap;
    //Map<Id, Campaign> relatedCampaignMap;
    //Map<Id, List<CampaignMember>> interestRecordsByContactMap;
    Map<Id, List<Opportunity>> OpportunitiesByContactMap = new Map<Id, List<Opportunity>>();
    Set<Id> cmIds = new Set<Id>();
  
  /**
   * bulkBefore
   *
   * This method is called prior to execution of a BEFORE trigger. Use this to cache
   * any data required into maps prior execution of the trigger.
   */
  public void bulkBefore() {

    // TODO: Some way to limit this to recruitment CM records?
    //
    if (Trigger.isInsert || Trigger.isUpdate) {
      Set<Id> contactIds = new Set<Id>();
      for (CampaignMember cm: (List<CampaignMember>)Trigger.new) {
        if (cm.ContactId != null)
          contactIds.add(cm.ContactId);
      }
      List<Opportunity> OpportunityList = new List<Opportunity>([SELECT Id, Contact__c FROM Opportunity WHERE Contact__c IN :contactIds AND IsClosed = false ORDER BY CreatedDate DESC]);
      if (opportunityList.size() > 0) {
        for (Opportunity o: opportunityList) {
          if (OpportunitiesByContactMap.containsKey(o.Contact__c)) {
            // This may not be necessary; we only want the first Opportunity found
            OpportunitiesByContactMap.get(o.Contact__c).add(o);
          }
          else {
            List<Opportunity> newList = new List<Opportunity>();
            newList.add(o);
            OpportunitiesByContactMap.put(o.Contact__c, newList);
          }
        }
      }
    } 
  }
  
  /** 
   * bulkAfter
   *
   * This method is called prior to execution of an AFTER trigger. Use this to cache
   * any data required into maps prior execution of the trigger.
   */
  public void bulkAfter() {
    if (Trigger.IsDelete) {
      cmIds = Trigger.oldMap.keySet();
    }
    else {
      cmIds = Trigger.newMap.keySet();
    }
  }
  
  /**
   * beforeInsert
   *
   * This method is called iteratively for each record to be inserted during a BEFORE
   * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
   */
  public void beforeInsert(SObject so) {
    CampaignMember cm = (CampaignMember)so;
    cm.Last_Member_Status_Change__c = Datetime.now();

    if (cm.Opportunity__c == null && OpportunitiesByContactMap.containsKey(cm.ContactId)) {
      cm.Opportunity__c = OpportunitiesByContactMap.get(cm.ContactId)[0].Id;
    }
  }
  
  /**
   * beforeUpdate
   *
   * This method is called iteratively for each record to be updated during a BEFORE
   * trigger.
   */
  public void beforeUpdate(SObject oldSo, SObject so) {
    CampaignMember cm = (CampaignMember)so;
    CampaignMember oldCm = (CampaignMember)oldSo;
    if (cm.ContactId != oldCm.ContactId && OpportunitiesByContactMap.containsKey(cm.ContactId))
        cm.Opportunity__c = OpportunitiesByContactMap.get(cm.ContactId)[0].Id;
  }

  /**
   * beforeDelete
   *
   * This method is called iteratively for each record to be deleted during a BEFORE
   * trigger.
   */
  public void beforeDelete(SObject so){}
  
  /**
   * beforeFinally
   *
   * This method is called at the end of the execution of a BEFORE trigger. Use this to finalize
   * any bulk operations for a BEFORE trigger.
   */
  public void beforeFinally(){}

  /**
   * afterInsert
   *
   * This method is called iteratively for each record inserted during an AFTER
   * trigger. Always put field validation in the 'After' methods in case another trigger
   * has modified any values. The record is 'read only' by this point.
   */
  public void afterInsert(SObject so) {
  }

  /**
   * afterUpdate
   *
   * This method is called iteratively for each record updated during an AFTER
   * trigger.
   */
  public void afterUpdate(SObject oldSo, SObject so) {
  }

  /**
   * afterDelete
   *
   * This method is called iteratively for each record deleted during an AFTER
   * trigger.
   */
  public void afterDelete(SObject so){}

  /**
   * andFinally
   *
   * This method is called once all records have been processed by the trigger. Use this 
   * method to accomplish any final operations such as creation or updates of other records.
   */
  public void andFinally() {
    Set<Id> interestOpportunityIds = new Set<Id>();
    Set<Id> interestContactIds = new Set<Id>();
    Set<Id> interestLeadIds = new Set<Id>();
    Set<Id> nationalMeritContactIds = new Set<Id>();

    Map<Id, List<CampaignMember>> interestRecordsByContactOrLeadMap = new Map<Id, List<CampaignMember>>(); 
    List<Opportunity> interestOpportunities = new List<Opportunity>();
    List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
    
    List<Lead> interestLeads = new List<Lead>();
    List<Lead> leadsToUpdate = new List<Lead>();

    List<CampaignMember> cmList = new List<CampaignMember>([SELECT Id, CampaignId, Opportunity__c, ContactId, LeadId, Campaign.RecordType.DeveloperName FROM CampaignMember WHERE Id IN :cmIds AND Campaign.RecordType.DeveloperName IN ('Interest', 'Scholarship')]);
    for (CampaignMember cm: cmList) {
//      if (cm.Opportunity__c != null && cm.Campaign.RecordType.DeveloperName == 'Interest')
      if (cm.Opportunity__c != null)
        interestOpportunityIds.add(cm.Opportunity__c);
      if (cm.ContactId != null)
        interestContactIds.add(cm.ContactId);
      if (cm.LeadId != null)
        interestLeadIds.add(cm.LeadId);
    }
    system.debug('GRF interestContactIds: ' + interestContactIds);

    // Build a Set of all Contact IDs who have a Scholarship that should indicate that they are 
    // a National Merit Scholar
    Set<String> NationalMeritCampaignNames = new Set<String>{'National Achievement Finalist', 
                                                                'National Achievement Semifinalist', 
                                                                'National Hispanic Scholar Finalist',
                                                                'National Merit Finalist', 
                                                                'National Merit Semifinalist', 
                                                                'Gammage Scholar',
                                                                'Flinn Designate', 
                                                                'Flinn Semifinalist', 
                                                                'Flinn Finalist'};

    List<CampaignMember> nmsList = new List<CampaignMember>([SELECT Id, ContactId FROM CampaignMember WHERE ContactId IN :interestContactIds AND Campaign.RecordType.DeveloperName = 'Scholarship' AND Campaign.Name IN :NationalMeritCampaignNames]);
    system.debug('GRF nmsList: ' + nmsList);
    system.debug('GRF cmList: ' + cmList);
    for (CampaignMember cm: nmsList) {
      nationalMeritContactIds.add(cm.ContactId);
    }

    
    
    if (interestOpportunityIds.size() > 0 || interestLeadIds.size() > 0) {
      //relatedOpportunityMap = new Map<Id, Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Id IN :interestOpportunityIds]);
      interestOpportunities = new List<Opportunity>([SELECT Id, Contact__c, primary_interest__c, primary_interest__r.Type, National_Merit_Semifinalist__c FROM Opportunity WHERE Id IN :interestOpportunityIds]);
      interestLeads = new List<Lead>([SELECT Id, primary_interest__c, primary_interest__r.Type FROM Lead WHERE Id IN :interestLeadIds]);
      List<CampaignMember> allCmList = new List<CampaignMember>([SELECT Id, Status, ContactId, LeadId, CampaignId, Campaign.Type, CreatedDate FROM CampaignMember WHERE (ContactId IN :interestContactIds OR LeadId IN :interestLeadIds) AND Campaign.Type IN ('PSMajors', 'Academic', 'ASU College', 'Degree Search by Interest') AND Campaign.RecordType.DeveloperName = 'Interest' AND Status = 'Interested' ORDER BY Last_Member_Status_Change__c DESC]);
      //List<CampaignMember> allCmList = new List<CampaignMember>([SELECT Id, Status, ContactId, LeadId, CampaignId, Campaign.Type, CreatedDate FROM CampaignMember WHERE (ContactId IN :interestContactIds) AND Campaign.RecordType.DeveloperName = 'Interest' ORDER BY Last_Member_Status_Change__c DESC]);
      system.debug('GRF allCmList: ' + allCmList);
      for (CampaignMember cm: allCmList) {
        if (interestRecordsByContactOrLeadMap.containsKey(cm.ContactId)) {
          interestRecordsByContactOrLeadMap.get(cm.ContactId).add(cm);
        }
        else if (interestRecordsByContactOrLeadMap.containsKey(cm.LeadId)) {
          interestRecordsByContactOrLeadMap.get(cm.LeadId).add(cm);
        }
        else {
            List<CampaignMember> mapCmList = new List<CampaignMember>();
            mapCmList.add(cm);
            if (cm.ContactId != null) {
              interestRecordsByContactOrLeadMap.put(cm.ContactId, mapCmList);
            }
            else if (cm.LeadId != null) {
              interestRecordsByContactOrLeadMap.put(cm.LeadId, mapCmList);
            }
        }
      }
    }
    system.debug('GRF interestRecordsByContactOrLeadMap: ' + interestRecordsByContactOrLeadMap);

    //relatedCampaignMap = new Map<Id, Campaign>([SELECT Id, Type FROM Campaign WHERE Id IN :interestCampaignIds]);
    
    system.debug('GRF interestOpportunities: ' + interestOpportunities);
    for (Opportunity o: interestOpportunities) {
      Boolean updateOpportunity = false;
      
      Boolean nationalMerit = nationalMeritContactIds.contains(o.Contact__c);
      system.debug('GRF nationalMerit: ' + nationalMerit);
      system.debug('GRF contact__c: ' + o.contact__c);

      if (o.National_Merit_Semifinalist__c != nationalMerit) {
        o.National_Merit_Semifinalist__c = nationalMerit;
        updateOpportunity = true;
      }

      List<CampaignMember> oppCmList;
      if (interestRecordsByContactOrLeadMap.containsKey(o.Contact__c)) 
        oppCmList = interestRecordsByContactOrLeadMap.get(o.Contact__c);
      system.debug('GRF oppCmList: ' + oppCmList);
      if (oppCmList != null && oppCmList.size() > 0) {
        Id interestCampaignId;
        for (CampaignMember cm: oppCmList) {
          if (cm.Campaign.Type == 'PSMajors') {
            interestCampaignId = cm.CampaignId;
            break;
          }
        }
        // If we did not find a PSMajors Interest record, use the most recent other Interest
        //
        if (interestCampaignId == null)
          interestCampaignId = oppCmList[0].CampaignId;
        
        // If the Interest record we found isn't already set on the Opportunity, it's time to update it
        //  
        if (interestCampaignId != null && o.Primary_Interest__c != interestCampaignId) {
          o.Primary_Interest__c = interestCampaignId;
          updateOpportunity = true;
        }

      }
      if (updateOpportunity)
        opportunitiesToUpdate.add(o);
    }
    
    if (opportunitiestoUpdate.size() > 0) {
      update opportunitiestoUpdate;
    }

    for (Lead l: interestLeads) {
      List<CampaignMember> leadCmList;
      if (interestRecordsByContactOrLeadMap.containsKey(l.Id)) 
        leadCmList = interestRecordsByContactOrLeadMap.get(l.Id);
      if (leadCmList != null && leadCmList.size() > 0) {
        Id interestCampaignId;
        for (CampaignMember cm: leadCmList) {
          if (cm.Campaign.Type == 'PSMajors') {
            interestCampaignId = cm.CampaignId;
            break;
          }
        }
        // If we did not find a PSMajors Interest record, use the most recent other Interest
        //
        if (interestCampaignId == null)
          interestCampaignId = leadCmList[0].CampaignId;
        
        // If the Interest record we found isn't already set on the Lead, it's time to update it
        //  
        if (interestCampaignId != null && l.Primary_Interest__c != interestCampaignId) {
          l.Primary_Interest__c = interestCampaignId;
          leadsToUpdate.add(l);
        }
      }
    }
    if (leadsToUpdate.size() > 0) {
      update leadsToUpdate;
    }   
  }

}