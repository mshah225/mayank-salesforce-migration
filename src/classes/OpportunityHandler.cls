public without sharing class OpportunityHandler 
  implements ITrigger {
    
  private Map<Id, Id> oppToContactMap = new Map<Id, Id>();
  private Map<Id, Id> leadToContactMap = new Map<Id, Id>();    

  /**
   * bulkBefore
   *
   * This method is called prior to execution of a BEFORE trigger. Use this to cache
   * any data required into maps prior execution of the trigger.
   */
  public void bulkBefore() {
    if (Trigger.isInsert || Trigger.isUpdate) {
      Set<Id> accountIds = new Set<Id>();
      for (SObject so: Trigger.new) {
        Opportunity o = (Opportunity)so;
        if (o.AccountId != null)
          accountIds.add(o.AccountId);
      }
      if (accountIds.size() > 0) {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Contact__c FROM Account WHERE Id IN :accountIds]);
        for (SObject so: Trigger.new) {
          Opportunity o = (Opportunity)so;
//          if (accountMap.get(o.AccountId).contact__c != null)
          if (o.AccountId != null && accountMap.containsKey(o.AccountId) && accountMap.get(o.AccountId).contact__c != null)
            oppToContactMap.put(o.Id, accountMap.get(o.AccountId).contact__c);
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
    if (Trigger.isInsert || Trigger.isUpdate) {
      Set<Id> accountIds = new Set<Id>();
      for (SObject so: Trigger.new) {
        Opportunity o = (Opportunity)so;
        if (o.AccountId != null)
          accountIds.add(o.AccountId);
      }
      Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Contact__c FROM Account WHERE Id IN :accountIds]);
      for (SObject so: Trigger.new) {
        Opportunity o = (Opportunity)so;
        if (o.converted_lead_id__c != null && o.AccountId != null)
          leadToContactMap.put(ID.valueOf(o.converted_lead_id__c), accountMap.get(o.AccountId).contact__c);
      }    
    }

  }
  
  /**
   * beforeInsert
   *
   * This method is called iteratively for each record to be inserted during a BEFORE
   * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
   */
  public void beforeInsert(SObject so) {
    Opportunity o = (Opportunity)so;
    if (oppToContactMap.containsKey(o.Id))
      o.contact__c = oppToContactMap.get(o.Id);
  }
  
  /**
   * beforeUpdate
   *
   * This method is called iteratively for each record to be updated during a BEFORE
   * trigger.
   */
  public void beforeUpdate(SObject oldSo, SObject so){}

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
    if (Trigger.isInsert)
      cleanUpLeadInterests(Trigger.new);
  }
  
  private void cleanUpLeadInterests(List<Opportunity> opportunityList) {
    if (opportunityList.size() == 0)
      return;
      
    Set<Id> accountIds = new Set<Id>();
    Set<Id> contactIds = new Set<Id>();
    Set<Id> leadIds = new Set<Id>();
    
    for (Opportunity o: opportunityList) {
      //accountIds.add(o.AccountId);
      if (o.converted_lead_id__c != null)
        leadIds.add(ID.valueOf(o.converted_lead_id__c));
    }

/*    
    List<Account> accountList = new List<Account>([SELECT Id, Contact__c FROM Account WHERE Id IN :accountIds]);
    
    for (Account a: accountList) {
      contactIds.add(a.Contact__c);
    }
*/
    
    List<Lead_Interest__c> leadInterestList = new List<Lead_Interest__c>([SELECT Id, Status__c, leads__c FROM Lead_Interest__c WHERE leads__c IN :leadIds]);
    for (Lead_Interest__c li: leadInterestList) {
      //li.Status__c = 'Inactive';
      if (leadToContactMap.containsKey(li.leads__c))
        li.Contact__c = leadToContactMap.get(li.leads__c);
    }
    
    system.debug('GRF Opps: ' + opportunityList);
    system.debug('GRF LeadIDs: ' + leadIds);
    system.debug('GRF ContactIDs: ' + contactIds);
    //system.debug('GRF Accounts: ' + accountList);
    system.debug('GRF Lead Interests: ' + leadInterestList);
    
    
    if (leadInterestList.size() > 0)
      update leadInterestList;
  }

}