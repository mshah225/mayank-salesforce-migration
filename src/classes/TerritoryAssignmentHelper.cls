public without sharing class TerritoryAssignmentHelper {

    public static Boolean accountTADone = false;
    public static Boolean contactTADone = false;
    public static Boolean opportunityTADone = false;
    public static Boolean previousEducationTADone = false;
    public static Boolean leadTADone = false;
    public static Boolean territoryAssignmentRuleTADone = false;
    static List<sObject> triggerNew;
    //static Map<Id, sObject> triggerOldMap;
    
    private static Boolean batchMode = false;
/*
    public TerritoryAssignmentHelper () {
        batchMode = false;
        triggerNew = Trigger.New;
    }

    public TerritoryAssignmentHelper (List<sObject> deferredTaList) {
        batchMode = true;
        triggerNew = deferredTaList;
    }
*/

    ////////////////////////////////////////////////////////////////////
    //Account
    //
    ////////////////////////////////////////////////////////////////////

    public void AccountTA() {
        if (accountTADone)
            return;
        if (Trigger.isBefore){ 
            //Id KVRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Geomarket_Code_Map' AND SObjectType = 'Key_Value__c' LIMIT 1].Id;
            Map<String, String> KVMap = new Map<String, String>();
            Set<String> ZipsInTrigger = new Set<String>();
            
            for (Account InsZip :(List<Account>)Trigger.New){
                ZipsInTrigger.add(InsZip.ShippingPostalCode);
            } 
            
            //LIST<Key_Value__c> KVList = [SELECT Id, Geomarket_ZIP__c, Geomarket_Code__c FROM Key_Value__c WHERE RecordTypeId = :KVRecordType AND Geomarket_ZIP__c IN :ZipsInTrigger];
            LIST<Key_Value__c> KVList = [SELECT Id, Geomarket_ZIP__c, Geomarket_Code__c FROM Key_Value__c WHERE RecordType.DeveloperName = 'Geomarket_Code_Map' AND Geomarket_ZIP__c IN :ZipsInTrigger];
            
            for (Key_Value__c K :KVList){        
                KVMap.put(K.Geomarket_ZIP__c,K.Geomarket_Code__c);
            }
            
            for (Account AccGeo :(List<Account>)Trigger.New){
                AccGeo.Geomarket_Code__c = KVMap.get(AccGeo.ShippingPostalCode);
            }

            if (Trigger.isUpdate) {
                Map<ID, Account> AcountOldMap = (Map<ID, Account>)Trigger.oldMap; 
                //Set<Id> UserIdSet = new Set<Id>();
                for (Account A: (List<Account>)Trigger.New) {
                    if (A.Defer_Territory_Assignment__c == false && AcountOldMap.get(A.Id).Defer_Territory_Assignment__c == true)
                        continue;
                    if(A.Territory_Manager__c != null && AcountOldMap.get(A.Id).Territory_Manager__c != A.Territory_Manager__c && AcountOldMap.get(A.Id).Territory_Manager__c != null){
                        //UserIdSet.add(AcountOldMap.get(A.Id).Territory_Manager__c);
                        system.debug('got here: ' + AcountOldMap.get(A.Id).Territory_Manager__c);
                        A.Defer_Territory_Assignment__c = true;
                        A.Previous_Territory_Manager_ID__c = AcountOldMap.get(A.Id).Territory_Manager__c;
                    }                   
                }
            }
        } 
        
        /*
        if (Trigger.isAfter && Trigger.isUpdate){
            Map<ID, Account> AcountOldMap = (Map<ID, Account>)Trigger.oldMap; 
            Set<Id> UserIdSet = new Set<Id>();
            for (Account A: (List<Account>)Trigger.New) {
                if (A.Defer_Territory_Assignment__c == false && AcountOldMap.get(A.Id).Defer_Territory_Assignment__c == true)
                    continue;
                if(A.Defer_Territory_Assignment__c == false && A.Territory_Manager__c != null && AcountOldMap.get(A.Id).Territory_Manager__c != A.Territory_Manager__c && AcountOldMap.get(A.Id).Territory_Manager__c != null){
                    //UserIdSet.add(AcountOldMap.get(A.Id).Territory_Manager__c);
                    A.Defer_Territory_Assignment__c = true;
                    A.Previous_Territory_Manager_ID__c = AcountOldMap.get(A.Id).Territory_Manager__c;
                }    
            }
            
            // Do we want to further limit the scope of this query?
            LIST<Opportunity> OpportunityList = [SELECT Id,Territory_Assignment_Required__c FROM Opportunity WHERE IsClosed = false AND Territory_Assignment_Last_Rule_Type__c != null AND OwnerId IN :UserIdSet LIMIT 4000];
            for(Opportunity Opp :OpportunityList){Opp.Territory_Assignment_Required__c = true;}
            if(!OpportunityList.IsEmpty()){update OpportunityList;}

            // If Account is an Institution, update any related Leads GeoMarket info
            List<Lead> leadList = [SELECT Id, Territory_Assignment_Required__c FROM Lead WHERE Territory_Assignment_Last_Rule_Type__c != null AND OwnerId IN :UserIdSet LIMIT 4000];
            for(Lead l:leadList){l.Territory_Assignment_Required__c = true;}
            if(!LeadList.isEmpty()){update leadList;}


            
        }
        */
        if (Trigger.isAfter)
            accountTADone = true;
        
    }

    ////////////////////////////////////////////////////////////////////
    //Contact
    //
    ////////////////////////////////////////////////////////////////////

    public void ContactTA() {
        if (contactTADone)
            return;
        if (Trigger.isAfter && Trigger.isUpdate) {
            Set<Id> contactIdsWithTAChanges = new Set<Id>();
            Map<Id, Contact> oldContactMap = (Map<Id, Contact>)Trigger.oldMap;
            for (Contact c: (List<Contact>)Trigger.new) {
                /*
                if (c.Geomarket_Code__c != oldContactMap.get(c.Id).Geomarket_Code__c) {
                    contactIdsWithTAChanges.add(c.Id);
                    continue;
                }
                */
                system.debug('GRF ContactTA States: ' + c.MailingState + ' -> ' + oldContactMap.get(c.Id).MailingState);
                if (c.MailingState != oldContactMap.get(c.Id).MailingState)
                    contactIdsWithTAChanges.add(c.Id);
            }
            List<Opportunity> oppList = new List<Opportunity>([SELECT Id, Territory_Assignment_Required__c FROM Opportunity WHERE Contact__c IN :contactIdsWithTAChanges]);
            if (oppList.size() > 0) {
                for (Opportunity o: oppList) {
                    o.Territory_Assignment_Required__c = true;
                }
                update oppList;
                contactTADone = true;
            }

        }

    } 

    
    ////////////////////////////////////////////////////////////////////
    //Opportunity
    //
    ////////////////////////////////////////////////////////////////////
    public void OpportunityTA() {
        //if (opportunityTADone)
        //  return;

        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> locationSet = new Set<Id>();
     
        ////////////////////////////// START CONTACT GEOMARKET CODE EVALUATION //////////////////////////////
    //    if (Trigger.isBefore && Trigger.isUpdate){
        if (Trigger.isBefore){
            Set<String> ContactZips = new Set<String>();
            Map<String, String> KVMap = new Map<String, String>();
            Set<Id> InstitutionIdSet = new Set<Id>();
            Set<Id> ConIdsInTrigger = new Set<Id>();
            Set<Id> ContactIsFTF = new Set<Id>();
            Id KVRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Geomarket_Code_Map' AND SObjectType = 'Key_Value__c' LIMIT 1].Id;
            for (Opportunity OppsToGetContact : (List<Opportunity>)trigger.new){
                ConIdsInTrigger.Add(OppsToGetContact.Contact__c);
                if(OppsToGetContact.Type =='First Time Freshman'){
                    ContactIsFTF.add(OppsToGetContact.Contact__c);
                }       
            }
            List<Contact> ConsToUpdate = [SELECT Id, MailingPostalCode,Geomarket_Code__c, Last_HS_Attended__c, Last_College_Attended__c FROM Contact WHERE Id IN :ConIdsInTrigger];
            for (Contact c : ConsToUpdate ) {
                if(!InstitutionIdSet.contains(c.Last_HS_Attended__c)){InstitutionIdSet.add(c.Last_HS_Attended__c);}
                if(!InstitutionIdSet.contains(c.Last_College_Attended__c)){InstitutionIdSet.add(c.Last_College_Attended__c);}
                ContactZips.add(c.MailingPostalCode);
            }
            Map<Id, Account> InstMap = new Map<Id, Account>([SELECT Id, Geomarket_Code__c FROM Account WHERE Id IN :InstitutionIdSet]);
            List<Key_Value__c> KVList = [SELECT Id, Geomarket_ZIP__c, Geomarket_Code__c FROM Key_Value__c WHERE RecordTypeId = :KVRecordType AND Geomarket_ZIP__c IN :ContactZips];
            system.debug('GRF KVList: ' + KVList);
            for (Key_Value__c K :KVList){KVMap.put(K.Geomarket_ZIP__c,K.Geomarket_Code__c);}
        
           for (Contact Cons :ConsToUpdate){   
                if(Cons.Last_HS_Attended__c != null && ContactIsFTF.contains(Cons.Id)){
                    Account thisInstitution = InstMap.get(Cons.Last_HS_Attended__c);
                    if (thisInstitution.Geomarket_Code__c != null){
                        Cons.Geomarket_Code__c = thisInstitution.Geomarket_Code__c;
                    }
                    else {
                        Cons.Geomarket_Code__c = KVMap.get(Cons.MailingPostalCode);
                    }    
                }
                else if (Cons.Last_College_Attended__c != null && !ContactIsFTF.contains(Cons.Id)){
                    Account thisInstitution = InstMap.get(Cons.Last_College_Attended__c);
                    if (thisInstitution.Geomarket_Code__c != null){
                        Cons.Geomarket_Code__c = thisInstitution.Geomarket_Code__c;
                    }
                    else {
                        Cons.Geomarket_Code__c = KVMap.get(Cons.MailingPostalCode);
                    }    
                }
                else Cons.Geomarket_Code__c = KVMap.get(Cons.MailingPostalCode);
            }
            if(ConsToUpdate.size()>0){Update ConsToUpdate;}        
        }    
        ////////////////////////////// END CONTACT GEOMARKET CODE EVALUATION //////////////////////////////
    
        ////////////////////////////// START TERRITORY ASSIGNMENT EVALUATION //////////////////////////////
     
      //if (Trigger.isAfter) {
        for (Opportunity o: (List<Opportunity>)Trigger.new) {
            if(!contactIdSet.contains(o.Contact__c)){contactIdSet.add(o.Contact__c);}
            locationSet.add(o.Admitted_Location__c==null?o.Location__c:o.Admitted_Location__c);
        }
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Geomarket_Code__c, MailingState, Last_HS_Attended__c, Last_HS_Attended__r.Territory_Manager__c, Last_HS_Attended__r.Territory_Manager__r.IsActive, Last_HS_Attended__r.Territory_Manager__r.Name, Last_College_Attended__r.Territory_Manager__c,Last_College_Attended__r.Territory_Manager__r.Name, Last_College_Attended__r.Territory_Manager__r.IsActive FROM Contact WHERE Id IN :contactIdSet]);
        Map<Id, Location__c> locationMap = new Map<Id, Location__c>([SELECT Id, Name, Location_Code__c FROM Location__c WHERE Id IN :locationSet]);
        Map<String, Territory_Assignment_Rule__c> autoAssignmentRuleMap = new Map<String, Territory_Assignment_Rule__c>();
        
        // Build map with Territory_Assignment_Rule__c Rule_Key__c values
        Map<String,Territory_Assignment_Rule__c> TerritoryAssignmentRuleMap = new Map<String,Territory_Assignment_Rule__c>();
        List<Territory_Assignment_Rule__c> TerritoryAssignmentRuleList = new List<Territory_Assignment_Rule__c>([SELECT Id,Rule_Key__c,User__c,User__r.IsActive FROM Territory_Assignment_Rule__c]);    
        for (Territory_Assignment_Rule__c TARM : TerritoryAssignmentRuleList){TerritoryAssignmentRuleMap.put(TARM.Rule_Key__c,TARM);}
        
        //force all new opportunities to be evaluated for territory assignment
        if (Trigger.isInsert){
            for (Opportunity NewOpps : (List<Opportunity>)Trigger.New){
                NewOpps.Territory_Assignment_Required__c = true;
            }    
        }
        
        // only evaluate territory assignment for opportunities where a field changes that could impact an assignment
        if (Trigger.isUpdate){
            Map<ID, Opportunity> OpportunityOldMap = (Map<ID, Opportunity>)Trigger.oldMap;
            for (Opportunity OppsToAssign : (List<Opportunity>)Trigger.New){
                if(OppsToAssign.Territory_Assignment_Required__c == true || OpportunityOldMap.get(OppsToAssign.Id).Type != OppsToAssign.Type || OpportunityOldMap.get(OppsToAssign.Id).International_Student__c != OppsToAssign.International_Student__c || OpportunityOldMap.get(OppsToAssign.Id).Location__c != OppsToAssign.Location__c || OpportunityOldMap.get(OppsToAssign.Id).Potential_National_Scholar__c != OppsToAssign.Potential_National_Scholar__c){
                    OppsToAssign.Territory_Assignment_Required__c = true;
                }
            }
        }    
        
        for(Opportunity Opp: (List<Opportunity>)Trigger.New){
            Boolean inactiveUserFound = false;
            Contact thisContact = contactMap.get(Opp.Contact__c);
            Location__c thisLocation = locationMap.get(Opp.Admitted_Location__c==null?Opp.Location__c:Opp.Admitted_Location__c);
            if (thisLocation == null) thisLocation = new Location__c();
        
            // Start Territory Assignment Rules Evaluation
            if (Opp.Territory_Assignment_Required__c && thisContact != null){
                Opp.Territory_Assignment_Required__c = false;
                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
        
                ////////////////////////////////////////////////////////////// Freshman Scholar
                System.Debug('About to Test Freshman Scholar');
                
                if (Opp.Type == 'First Time Freshman' && Opp.Potential_National_Scholar__c){
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Freshman Scholar');
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else {
                            Opp.OwnerId = tar.User__c;  
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Freshman Scholar';
                            Continue;
                        }
                    }
                }
        
                ////////////////////////////////////////////////////////////// International       
                System.Debug('About to Test International');
                
                if (Opp.International_Student__c){
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('International');
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else {
                            Opp.OwnerId = tar != null && Opp.Territory_Assignment_Last_Rule_Type__c != 'International'? tar.User__c : Opp.OwnerId;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'International';
                            Continue;
                        } 
                    }
               }
        
                ////////////////////////////////////////////////////////////// Location
                System.Debug('About to Test Location');  
                if (thisLocation != null && thisLocation.Location_Code__c != null && thisLocation.Location_Code__c.equalsIgnoreCase('CALHC')){
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Location' + '|' + 'Lake Havasu');
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else {
                            Opp.OwnerId = tar.User__c; 
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Location - Lake Havasu';
                            Continue;
                        }
                    }
                }
        
                ////////////////////////////////////////////////////////////// Last High School Attended
                System.Debug('About to Test Last HS');  
                      
                if(thisContact.Last_HS_Attended__c != null && thisContact.Last_HS_Attended__r.Territory_Manager__c != null && Opp.Type == 'First Time Freshman'){
                    if (thisContact.Last_HS_Attended__r.Territory_Manager__r.IsActive == false) {
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        inactiveUserFound = true;
                    }
                    else {
                        Opp.OwnerId = thisContact.Last_HS_Attended__r.Territory_Manager__c;
                        Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended High School';
                        Continue;                        
                    }
                } 

                ////////////////////////////////////////////////////////////// Last College Attended  
                System.Debug('About to Test Last College');  
    
                System.Debug('About to Test Last College -- First Time Freshman');
                if (thisContact.Last_College_Attended__c != null && thisContact.Last_College_Attended__r.Territory_Manager__c != null && Opp.Type == 'First Time Freshman'){
                    if (thisContact.Last_College_Attended__r.Territory_Manager__r.IsActive == false) {
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        inactiveUserFound = true;
                    }
                    else {
                        Opp.OwnerId = thisContact.Last_College_Attended__r.Territory_Manager__c; 
                        Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended College, Type First Time Freshman';
                        Continue;                        
                    }
                }
                            
                System.Debug('About to Test Last College -- Readmission');
                if (thisContact.Last_College_Attended__c != null && thisContact.Last_College_Attended__r.Territory_Manager__c != null && Opp.Type == 'Readmission'){
                    if (thisContact.Last_College_Attended__r.Territory_Manager__r.IsActive == false) {
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        inactiveUserFound = true;
                    }
                    else {
                        Opp.OwnerId = thisContact.Last_College_Attended__r.Territory_Manager__c; 
                        Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended College, Type Readmission';
                        Continue;                        
                    }

                }  
                
                if (thisContact.Last_College_Attended__c != null && thisContact.Last_College_Attended__r.Territory_Manager__c != null && Opp.Type == 'Transfer'){
                    if (thisContact.Last_College_Attended__r.Territory_Manager__r.IsActive == false) {
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        inactiveUserFound = true;
                    }
                    else {
                        Opp.OwnerId = thisContact.Last_College_Attended__r.Territory_Manager__c; 
                        Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                        Opp.Territory_Assignment_Last_Rule_Type__c = 'Last Attended College, Type Transfer';
                        Continue;
                    }
                }    
       
                ////////////////////////////////////////////////////////////// Geomarket Code 
                System.Debug('About to Test Geomarket');   
                
                if (thisContact.Geomarket_Code__c != null && Opp.Type == 'First Time Freshman'){
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Geomarket' + '|' + Opp.Type + '|' + thisContact.Geomarket_Code__c);
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else {
                            Opp.OwnerId = tar.User__c; 
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type First Time Freshman';
                            Continue;
                        }
                    }
                }
                
                if (thisContact.Geomarket_Code__c != null  && Opp.Type == 'Readmission'){
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Geomarket' + '|' + Opp.Type + '|' + thisContact.Geomarket_Code__c);
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else {
                            Opp.OwnerId = tar.User__c;
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type Readmission';
                            Continue;
                        }
                    }
                }
                
                if (thisContact.Geomarket_Code__c != null  && Opp.Type == 'Transfer'){
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Geomarket' + '|' + Opp.Type + '|' + thisContact.Geomarket_Code__c);
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else {
                            Opp.OwnerId = tar.User__c;    
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type Transfer';
                            Continue;
                        }
                    }
                }                                  
        
                ////////////////////////////////////////////////////////////// State        
                System.Debug('About to Test Mailing State');
                
                if (thisContact.MailingState != null){
                    String USState = thisContact.MailingState;
                    //if (thisContact.MailingState != null && Opp.Type == 'First Time Freshman'){
                        Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('State' + '|' + Opp.Type + '|' +  USState);
                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            }
                            else {
                                Opp.OwnerId = tar.User__c;  
                                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'State, ' + USState + ', Type ' + Opp.Type;
                                Continue;
                            }
                        }
                    //}
                }
/*                
                if (thisContact.MailingState != null){
                    String USState = thisContact.MailingState;
                    if (thisContact.MailingState != null && Opp.Type == 'Readmission'){
                        Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('State' + '|' + Opp.Type + '|' +  USState);
                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            }
                            else {
                                Opp.OwnerId = tar.User__c;  
                                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'State, ' + USState + ', Type Readmission';
                                Continue;
                            }
                        }
                    }
                }

                if (thisContact.MailingState != null){
                    String USState = thisContact.MailingState;
                    if (thisContact.MailingState != null && Opp.Type == 'Transfer'){
                        Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('State' + '|' + Opp.Type + '|' +  USState);
                        if (tar != null) {
                            if (tar.User__r.IsActive == false) {
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                                inactiveUserFound = true;
                            }
                            else {
                                Opp.OwnerId = tar.User__c;  
                                Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                                Opp.Territory_Assignment_Last_Rule_Type__c = 'State, ' + USState + ', Type Transfer';
                                Continue;
                            }
                        }
                    }
                }                        
*/        
                ////////////////////////////////////////////////////////////// Default User        
                System.Debug('About to Test Default Users');
                
                if (Opp.Type == 'Graduate'){
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Default User' + '|' + Opp.Type);
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else {
                            Opp.OwnerId = tar.User__c;  
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';
                            Continue;
                        }
                    }
                }
                else if (Opp.Type == 'Law'){
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Default User' + '|' + Opp.Type);
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else {
                            Opp.OwnerId = tar.User__c;  
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';
                            Continue;
                        }
                    }
                }
                else if (Opp.Type == 'First Time Freshman'){
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Default User' + '|' + Opp.Type);
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else {
                            Opp.OwnerId = tar.User__c;  
                            if (!inactiveUserFound) Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';
                            Opp.Territory_Assignment_Required__c = false;
                            Continue;
                        }
                    }
                }
                else if (Opp.Type == 'Transfer'){
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Default User' + '|' + Opp.Type);
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else {
                            Opp.OwnerId = tar.User__c;  
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';
                            Continue;
                        }
                    }
                }
                else if (Opp.Type == 'Non-Degree'){
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Default User' + '|' + Opp.Type);
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else {
                            Opp.OwnerId = tar.User__c;  
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';
                            Continue;
                        }
                    }
                }
                else if (Opp.Type == 'Readmission'){
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Default User' + '|' + Opp.Type);
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            inactiveUserFound = true;
                        }
                        else {
                            Opp.OwnerId = tar.User__c;  
                            Opp.Territory_Assignment_Last_Run__c = Datetime.Now();
                            Opp.Territory_Assignment_Last_Rule_Type__c = 'Default User';
                            Continue;
                        }
                    }
                }
            }
        }
        opportunityTADone = true;
      //}   
    }
        ////////////////////////////// END TERRITORY ASSIGNMENT EVALUATION //////////////////////////////
        
    ////////////////////////////////////////////////////////////////////
    //Previous Education
    //
    ////////////////////////////////////////////////////////////////////    
    public void PreviousEducationTA() {
        if (previousEducationTADone)
            return;
        previousEducationTADone = true;
        
        List<Previous_Education__c> peTriggerList = new List<Previous_Education__c>(); 
        if (Trigger.IsDelete) {
            peTriggerList = (List<Previous_Education__c>)Trigger.old;
        }
        else {
            peTriggerList = (List<Previous_Education__c>)Trigger.new;
        }

        Set<Id> contactIdSet = new Set<Id>();
        for (Previous_Education__c PE: peTriggerList){contactIdSet.add(PE.Contact__c);}
        
        //List<Contact> hsContactsToUpdate = new List<Contact>();
        //List<Contact> collegeContactsToUpdate = new List<Contact>();
        //Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Last_HS_Attended__c, Last_College_Attended__c, (SELECT Id, Account__r.Institution_Type__c FROM Previous_Education__r) FROM Contact WHERE Id IN :contactIdSet]);
        //Map<string, Previous_Education__c> peMap = new Map<string, Previous_Education__c>();   
        //List<Previous_Education__c> peList = new List<Previous_Education__c>([SELECT Id, Contact__c, Account__c, Institution_Type__c, CreatedDate, LastModifiedDate FROM Previous_Education__c WHERE Contact__c IN :contactIdSet]);


        
        if(Trigger.IsInsert || Trigger.isUpdate || Trigger.isDelete){
        
            Map<Id,Account> contactAccountMap = new Map<Id, Account>();
            Map<Id, Id> oppIdToContactIdMap = new Map<Id, Id>();
            Set<Id> peAccountIdSet = new Set<Id>();
            //for (Previous_Education__c pe: (List<Previous_Education__c>)Trigger.new) {
            for (Previous_Education__c pe: peTriggerList) {
                peAccountIdSet.add(pe.Account__c);
            }
            Map<Id, Account> peAccountMap = new Map<Id, Account>([Select Id, Institution_Type__c, Territory_Manager__c, Territory_Manager__r.Name, Territory_Manager__r.IsActive from Account where Id in :peAccountIdSet]);
            List<Opportunity> oppList = new List<Opportunity>([select Id, contact__c from opportunity where contact__c in :contactIdSet]);
            for(Opportunity o1 : oppList ){
                oppIdToContactIdMap.put(o1.Id, o1.contact__c);
            }
            for (Previous_Education__c prevEd: peTriggerList){
                //contactAccountMap.put(prevEd.Contact__c, [Select Id, Institution_Type__c, Territory_Manager__c from Account where Id=:prevEd.Account__c]);
                if (prevEd.Contact__c != null && prevEd.Account__c != null && peAccountMap.containsKey(prevEd.Account__c))
                    contactAccountMap.put(prevEd.Contact__c, peAccountMap.get(prevEd.Account__c));
                
            }
            
            
            List<Opportunity> opp = new List<Opportunity>([select Id, contact__c, account.name, Account.Institution_Type__c, Account.Territory_Manager__c, Type, ownerId from opportunity where contact__c IN :contactIdSet]);
            List<Opportunity> oppToUpdate = new List<Opportunity>();
            
            for(Opportunity o : opp){
                o.Territory_Assignment_Required__c = true;
                oppToUpdate.add(o);

                /*
                if(o.Type == 'First Time Freshman' && contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Institution_Type__c == 'HS'){
                    if(contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Territory_Manager__c!=null){
                        if (o.OwnerId != contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Territory_Manager__c) {
                            if (contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Territory_Manager__r.IsActive == false) {
                                o.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            }
                            else {
                                o.OwnerId = contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Territory_Manager__c;
                                o.Territory_Assignment_Last_Rule_Type__c = 'Last Attended High-School';
                            }
                            o.Territory_Assignment_Last_Run__c = Datetime.now();
                            //o.Territory_Assignment_UserID__c = contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Territory_Manager__c;
                            //o.Territory_Assignment_User_Name__c = contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Territory_Manager__r.Name;
                            oppToUpdate.add(o);
                        }
                    }
                }
                else if((o.Type == 'Transfer' || o.Type == 'Readmission') && (contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Institution_Type__c == '2YR' || contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Institution_Type__c == '4YR' || contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Institution_Type__c == 'CC' || contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Institution_Type__c == 'COL')){
                    if(contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Territory_Manager__c!=null){
                        if (o.OwnerId != contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Territory_Manager__c) {
                            o.OwnerId = contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Territory_Manager__c;
                            if (contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Territory_Manager__r.IsActive == false) {
                                o.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                            }
                            else {
                                o.OwnerId = contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Territory_Manager__c;
                                o.Territory_Assignment_Last_Rule_Type__c = 'Last Attended College';
                            }
                            o.Territory_Assignment_Last_Run__c = Datetime.now();
                            //o.Territory_Assignment_UserID__c = contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Territory_Manager__c;
                            //o.Territory_Assignment_User_Name__c = contactAccountMap.get(oppIdToContactIdMap.get(o.Id)).Territory_Manager__r.Name;
                            oppToUpdate.add(o);
                        }
                    }
                }
                */
            }
            if(oppToUpdate.size()>0) update oppToUpdate;
        }

        /*
        
        for (Previous_Education__c pe: peList) {
            if (Trigger.isDelete) {

            }
            string mapKey;
            if (pe.Contact__c != null) {
                if (pe.Institution_Type__c != null && pe.Institution_Type__c == 'HS')
                    mapKey  = pe.Contact__c + '|H';
                else 
                    mapKey  = pe.Contact__c + '|C';
                if(!peMap.containsKey(mapKey) || (peMap.get(mapKey).LastModifiedDate < pe.LastModifiedDate )) {
                    peMap.put(mapKey, pe);
                }
            }
        }
            
        for (Previous_Education__c PEsToUpdate: peTriggerList){
            Contact thisContact = contactMap.get(PEsToUpdate.Contact__c);
            if (thisContact == null)continue;
            if(PEsToUpdate.Institution_Type__c == 'HS'){
                if (thisContact.Last_HS_Attended__c == null) {
                    thisContact.Last_HS_Attended__c = PEsToUpdate.Account__c;
                    hsContactsToUpdate.add(thisContact);
                }
                else if (peMap.containsKey(thisContact.Id + '|H') && peMap.get(thisContact.Id + '|H').Id != thisContact.Last_HS_Attended__c) {
                    thisContact.Last_HS_Attended__c = peMap.get(thisContact.Id +'|H').Account__c;
                    hsContactsToUpdate.add(thisContact);
                }
            }
            else if(PEsToUpdate.Institution_Type__c == '2YR' || PEsToUpdate.Institution_Type__c == '4YR'){
                if (thisContact.Last_College_Attended__c == null) {
                    thisContact.Last_College_Attended__c = PEsToUpdate.Account__c;
                    collegeContactsToUpdate.add(thisContact);
                }
                else if ((thisContact.Last_College_Attended__c == null) || (peMap.containsKey(thisContact.Id + '|C') && peMap.get(thisContact.Id + '|C').Id != thisContact.Last_College_Attended__c)) {
                    thisContact.Last_College_Attended__c = peMap.get(thisContact.Id +'|C').Account__c;
                    collegeContactsToUpdate.add(thisContact);
                }
            }
        }
        if(hsContactsToUpdate.size()>0) update hsContactsToUpdate;
        if(collegeContactsToUpdate.size()>0) update collegeContactsToUpdate;   
        */
    }  

    ////////////////////////////////////////////////////////////////////
    //Lead
    //
    ////////////////////////////////////////////////////////////////////

    public void LeadTA() {
        if (leadTADone)
            return;
        leadTADone = true;

        ////////////////////////////// START LEAD GEOMARKET CODE EVALUATION //////////////////////////////
        Set<Id> LeadInstitutionSet = new Set<Id>();
        Set<Id> leadsWithNoLastInstitution = new Set<Id>();
        for (Lead l: (List<Lead>)Trigger.new) {
            if (l.Last_Institution_Attended__c != null)
                leadInstitutionSet.add(l.Last_Institution_Attended__c);
            else
                leadsWithNoLastInstitution.add(l.Id);
        }
        Map<Id, Account> institutionMap = new Map<Id, Account>([SELECT Id, Institution_Type__c, Geomarket_Code__c FROM Account WHERE Id IN :leadInstitutionSet]);

        Id KVRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Geomarket_Code_Map' AND SObjectType = 'Key_Value__c' LIMIT 1].Id;
        Map<String, String> KVMap = new Map<String, String>();
        Set<String> ZipsInTrigger = new Set<String>();
        
        for (Lead InsZip :(List<Lead>)Trigger.New){
            ZipsInTrigger.add(InsZip.PostalCode);
        } 
        
        LIST<Key_Value__c> KVList = [SELECT Id, Geomarket_ZIP__c, Geomarket_Code__c FROM Key_Value__c WHERE RecordTypeId = :KVRecordType AND Geomarket_ZIP__c IN :ZipsInTrigger];
        
        for (Key_Value__c K :KVList){        
            KVMap.put(K.Geomarket_ZIP__c,K.Geomarket_Code__c);
        }
        
        for (Lead leadGeo :(List<Lead>)Trigger.New){
            // TODO: Also, is institution type relevant for the Lead type?  Need clarification on this condition
            if (leadGeo.Last_Institution_Attended__c != null && institutionMap.get(leadGeo.Last_Institution_Attended__c).Geomarket_Code__c != null) {
                LeadGeo.Geomarket_Code__c = institutionMap.get(leadGeo.Last_Institution_Attended__c).Geomarket_Code__c;
            }
            else if (leadGeo.PostalCode != null && KVMap.containsKey(leadGeo.PostalCode)) {
                leadGeo.Geomarket_Code__c = KVMap.get(leadGeo.PostalCode);
            }
        }   
        ////////////////////////////// END LEAD GEOMARKET CODE EVALUATION //////////////////////////////

        ////////////////////////////// START TERRITORY ASSIGNMENT EVALUATION //////////////////////////////

        // Build map with Territory_Assignment_Rule__c Rule_Key__c values
        Map<String,Territory_Assignment_Rule__c> TerritoryAssignmentRuleMap = new Map<String,Territory_Assignment_Rule__c>();
        List<Territory_Assignment_Rule__c> TerritoryAssignmentRuleList = new List<Territory_Assignment_Rule__c>([SELECT Id,Rule_Key__c,User__c,User__r.IsActive FROM Territory_Assignment_Rule__c]);    
        for (Territory_Assignment_Rule__c TARM : TerritoryAssignmentRuleList){TerritoryAssignmentRuleMap.put(TARM.Rule_Key__c,TARM);}
        
        //force all new leads to be evaluated for territory assignment
        if (Trigger.isInsert){
            for (Lead l: (List<Lead>)Trigger.New){
                l.Territory_Assignment_Required__c = true;
            }    
        }
        
        // only evaluate territory assignment for leads where a field changes that could impact an assignment
        if (Trigger.isUpdate){
            Map<ID, Lead> LeadOldMap = (Map<ID, Lead>)Trigger.oldMap;
            for (Lead l: (List<Lead>)Trigger.New){
                system.debug('GRF State: ' + l.State);
                system.debug('GRF OlDState: ' + LeadOldMap.get(l.Id).State);
                if(l.Territory_Assignment_Required__c == true || LeadOldMap.get(l.Id).Type__c != l.Type__c || LeadOldMap.get(l.Id).Geomarket_Code__c != l.Geomarket_Code__c || LeadOldMap.get(l.Id).State != l.State || LeadOldMap.get(l.Id).Last_Institution_Attended__c != l.Last_Institution_Attended__c || LeadOldMap.get(l.Id).International_Student__c != l.International_Student__c || LeadOldMap.get(l.Id).Potential_National_Scholar__c != l.Potential_National_Scholar__c) {
                    l.Territory_Assignment_Required__c = true;
                }
            }
        }

        Map<Id, Account> InstMap = new Map<Id, Account>([SELECT Id, Geomarket_Code__c, Institution_Type__c, Territory_Manager__c, Territory_Manager__r.IsActive FROM Account WHERE Id IN :leadInstitutionSet]);


        system.debug('GRF TARMap: ' + TerritoryAssignmentRuleMap);

        for (Lead l: (List<Lead>)Trigger.new) {
            if (l.Territory_Assignment_Required__c) {
                l.Territory_Assignment_Required__c = false;
                l.Territory_Assignment_Last_Run__c = Datetime.Now();
                
                // Freshman National Scholar
                System.Debug('About to Test Freshman Scholar');

                if (l.Type__c == 'First Time Freshman' && l.Potential_National_Scholar__c) {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Freshman Scholar');
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        }
                        else {
                            l.OwnerId = tar.User__c;  
                            l.Territory_Assignment_Last_Rule_Type__c = 'Freshman Scholar';
                            continue;
                        }
                    }
                }

                // International       
                System.Debug('About to Test International');
                
                if (l.International_Student__c){
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('International');
                    if (tar != null) {
                        // If already set by International rule, skip it
                        if (l.Territory_Assignment_Last_Rule_Type__c == 'International')
                            continue;
                        if (tar.User__r.IsActive == false) {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        }
                        else {
                            l.OwnerId = tar.User__c;
                            l.Territory_Assignment_Last_Rule_Type__c = 'International';
                            continue;
                        }
                    }
                }

                // Last Institution Attended
                System.Debug('About to Test Last Institution Attended');
                if (l.Last_Institution_Attended__c != null) {
                    if ((l.Type__c == 'First Time Freshman' && instMap.containsKey(l.Last_Institution_Attended__c) && instMap.get(l.Last_Institution_Attended__c).Institution_Type__c == 'HS' && instMap.get(l.Last_Institution_Attended__c).Territory_Manager__c != null) ||
                       ((l.Type__c == 'Transfer' || l.Type__c == 'Readmission') &&  instMap.get(l.Last_Institution_Attended__c).Institution_Type__c != 'HS' && instMap.get(l.Last_Institution_Attended__c).Territory_Manager__c != null)) {
                       system.debug('GRF TM: ' + instMap.get(l.Last_Institution_Attended__c).Territory_Manager__c);
                        if (instMap.get(l.Last_Institution_Attended__c).Territory_Manager__r.IsActive == false) {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        }
                        else {
                            l.OwnerId = instMap.get(l.Last_Institution_Attended__c).Territory_Manager__c;
                            l.Territory_Assignment_Last_Rule_Type__c = 'Last Institution Attended';
                            continue;
                        }
                    }
                }

                // GeoMarket
                System.Debug('About to Test GeoMarket');

                if (l.Geomarket_Code__c != null && TerritoryAssignmentRuleMap.containsKey('Geomarket' + '|' + l.Type__c + '|' + l.Geomarket_Code__c )) {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Geomarket' + '|' + l.Type__c + '|' + l.Geomarket_Code__c);
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        }
                        else {
                            l.OwnerId = tar.User__c;  
                            l.Territory_Assignment_Last_Rule_Type__c = 'Geomarket, Type ' + l.Type__c;
                            continue;
                        }
                    }                
                }

                // Mailing State
                System.Debug('About to Test State');

                if (l.State != null && TerritoryAssignmentRuleMap.containsKey('State' + '|' + l.Type__c + '|' + l.State)) {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('State' + '|' + l.Type__c + '|' + l.State );
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        }
                        else {
                            l.OwnerId = tar.User__c;  
                            l.Territory_Assignment_Last_Rule_Type__c = 'State, Type ' + l.Type__c;
                            continue;
                        }
                    }                   
                }

                // Default User
                System.Debug('About to Default User');

                if (TerritoryAssignmentRuleMap.containsKey('Default User' + '|' + l.Type__c)) {
                    Territory_Assignment_Rule__c tar = TerritoryAssignmentRuleMap.get('Default User' + '|' + l.Type__c);
                    system.debug('GRF Default TAR: ' + tar);
                    if (tar != null) {
                        if (tar.User__r.IsActive == false) {
                            l.Territory_Assignment_Last_Rule_Type__c = 'Inactive Territory Manager';
                        }
                        else {
                            l.OwnerId = tar.User__c;  
                            l.Territory_Assignment_Last_Rule_Type__c = 'Default User';
                            //l.Territory_Assignment_Last_Rule_Type__c = 'Default User ' + l.Type__c;
                            continue;
                        }
                    }
                }

            }
        }           

    }

    ////////////////////////////////////////////////////////////////////
    //Territory Assignment Rule
    //
    ////////////////////////////////////////////////////////////////////

    public void TerritoryAssignmentRuleTA() {
        if (territoryAssignmentRuleTADone)
            return;
        
        if (Trigger.isBefore && Trigger.isUpdate) { 
            Map<ID, Territory_Assignment_Rule__c> tarOldMap = (Map<ID, Territory_Assignment_Rule__c>)Trigger.oldMap; 
            for (Territory_Assignment_Rule__c tar: (List<Territory_Assignment_Rule__c>)Trigger.New) {
                if (tar.User__c != null && tarOldMap.get(tar.Id).User__c != tar.User__c) {
                    tar.Defer_Territory_Assignment__c = true;
                    tar.Previous_User_ID__c = tarOldMap.get(tar.Id).User__c;
                }
            }
        }
        
        territoryAssignmentRuleTADone = true;
    }


}