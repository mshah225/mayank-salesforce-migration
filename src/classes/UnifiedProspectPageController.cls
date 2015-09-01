public class UnifiedProspectPageController 
{
    public Contact contact;
    public Case caseC;
    public CampaignMember camMemInterest;
    public CampaignMember camMemEvent;
    public Opportunity opportunity;
    public Previous_Education__c previousEducation;
    public Id selectedInterestId { get;set; }
    public Id accId;
    public Id oppRecType;
    public Id walkInOrig;
    public Id phoneOrig;
    public Id emailOrig;
    public Id elId { get;set; }
    public Id instId { get;set; }
    public String eventName { get;set; }
    public String pickSelection { get;set; }
    public String originSelection { get;set; }
    public String eventSearchString { get;set; }
    public Boolean smsText { get;set; }
    public List<SelectOption> careers;
    public List<Account> instList;
    public List<Campaign> eventList;
    public String career { get; set; }
    public String collegeSelected { get; set; }
    public String planSelected { get; set; }
    
    public void setContact(Contact contact)
    {
        this.contact = contact;
    }

    public void setOpportunity(Opportunity opportunity)
    {
        this.opportunity = opportunity;
    }

    public void setPreviousEducation(Previous_Education__c previousEducation)
    {
        this.previousEducation = previousEducation;
    }

    public void setCampaignMemberInterest(CampaignMember camMemInterest) 
    {
        this.camMemInterest = camMemInterest;
    }

    public void setCampaignMemberEvent(CampaignMember camMemEvent) 
    {
        this.camMemEvent = camMemEvent;
    }

    public void setCaseC(Case caseC)
    {
        this.caseC = caseC;
    }

    public Contact getContact()
    {
        if (contact == null) 
        {
            contact= new Contact();
        }

        return contact;
    }

    public Opportunity getOpportunity() 
    {
        if (opportunity == null) 
        {
            opportunity = new Opportunity();
        }

        if(career == 'graduate' || career == 'law')
        {
            oppRecType = [SELECT Id FROM RecordType WHERE Name = 'Graduate Prospect' LIMIT 1].Id;
        }
        else
        {
            oppRecType = [SELECT Id FROM RecordType WHERE Name = 'Undergraduate Prospect' LIMIT 1].Id;
        }
        opportunity.RecordTypeId = oppRecType;
        return opportunity;
    }

    public Previous_Education__c getPreviousEducation() 
    {
        if (previousEducation == null) 
        {
            previousEducation = new Previous_Education__c();
        }

        return previousEducation;
    }

    public CampaignMember getCampaignMemberInterest() 
    {
        if (camMemInterest == null) 
        {
            camMemInterest = new CampaignMember();
        }

        return camMemInterest;
    }

    public CampaignMember getCampaignMemberEvent() 
    {
        if(camMemEvent == null) 
        {
            camMemEvent = new CampaignMember();
        }

        return camMemEvent;
    }
    
    public List<SelectOption> ProgramList
    {
        get
        {
            List<Program__c> ProgramTemp = [SELECT p.Name, p.Id FROM Program__c p WHERE Career__c = :career AND Program_Status__c = true];
            ProgramList = new List<SelectOption>();
            ProgramList.add(new SelectOption('0', '-- None --'));
            
            for(Program__c temp : ProgramTemp)
            {
                ProgramList.add(new SelectOption(temp.Id, temp.Name));
            }
            return ProgramList;
        }
        set;
    }

    public List<SelectOption> PlanList
    {
        get
        {
            PlanList = new List<SelectOption>();
            if(collegeSelected != null && collegeSelected != '0')
            {
                List<Plan__c> PlanTemp = [SELECT p.Name, p.Id FROM Plan__c p WHERE p.Program__c = :collegeSelected];
                
                PlanList.add(new SelectOption('0', '-- None --'));
                for(Plan__c temp : PlanTemp)
                {
                    PlanList.add(new SelectOption(temp.Id, temp.Name));
                }
            }
            return PlanList;
        }
        set;
    }

    public Case getCaseC() 
    {
        if (caseC == null) 
        {
            caseC = new Case();
            Id asuAdmissionRecId = [SELECT Id, Name FROM RecordType WHERE Name = 'ASU Admission Services' LIMIT 1].Id;
            caseC.RecordTypeId = asuAdmissionRecId;
        }

        return caseC;
    }
    
    public List<Campaign> getEventList() 
    {
        return eventList;
    }

    public void eventSearch() 
    {
        Id eventRecId = [SELECT Id FROM RecordType WHERE Name = 'Event'].Id;
        Id eossRecId = [SELECT Id FROM RecordType WHERE Name = 'EOSS Event'].Id;
        String searchQuery = 'SELECT Id, Name, Type, Category__c, Event_Start_Date__c, Event_Start_Time__c, Campus_Location__c, Event_Location__c, RecordTypeId FROM Campaign WHERE (Name LIKE \'%' + String.escapeSingleQuotes(eventSearchString) + '%\' OR Type LIKE \'%' + String.escapeSingleQuotes(eventSearchString) + '%\' OR Category__c LIKE \'%' + String.escapeSingleQuotes(eventSearchString) + '%\') AND (RecordTypeId = :eventRecId OR RecordTypeID = :eossRecId) AND IsActive = true ORDER BY Name ASC LIMIT 40';
        eventList = Database.query(searchQuery);
    }
    
    public List<Account> getInstList() 
    {
        return instList;
    }

    public List<SelectOption> getCareers()
    {
        if(careers == null)
        {
            careers = new List<SelectOption>();
            careers.add(new SelectOption('--Select--', '--Select--'));
            careers.add(new SelectOption('undergraduate', 'Undergraduate'));
            careers.add(new SelectOption('graduate', 'Graduate'));
            careers.add(new SelectOption('law', 'Law'));
        }
        return careers;
    }

    public void instSearch() 
    {
        String instSearchTerm = 'SELECT Id, Name, BillingCity, BillingState, Institution_Type__c FROM Account WHERE Id = ' + instId;
        instList = Database.query(instSearchTerm);
    }

    public List<SelectOption> getASULocationIntList() 
    {
        Id interestRecId = [SELECT Id FROM RecordType WHERE Name = 'Interest'].Id;
        List<Campaign> interests = [SELECT Id, Name, RecordTypeId 
                                    FROM Campaign 
                                    WHERE RecordTypeId = :interestRecId 
                                    AND Type = 'ASU Location' 
                                    AND IsActive = true 
                                    ORDER BY Name ASC];
        List<SelectOption> asuLocationIntList = new List<SelectOption>();
        asuLocationIntList.add(new SelectOption( '' ,'--Select--'));
        for (Campaign i : interests ) 
        {
            asuLocationIntList.add(new SelectOption(i.Id , i.Name));
        }
        
        return asuLocationIntList;
    }

    public List<SelectOption> getAcademicIntList() 
    {
        Id interestRecId = [SELECT Id FROM RecordType WHERE Name = 'Interest'].Id;
        List<Campaign> interests = [SELECT Id, Name, RecordTypeId 
                                    FROM Campaign 
                                    WHERE RecordTypeId = :interestRecId 
                                    AND Type = 'Academic' 
                                    AND IsActive = true 
                                    ORDER BY Name ASC];
        List<SelectOption> academicIntList = new List<SelectOption>();
        academicIntList.add(new SelectOption( '' ,'--Select--'));
        for (Campaign i : interests ) 
        {
            academicIntList.add(new SelectOption(i.Id , i.Name));
        }

        return academicIntList;
    }

    public List<SelectOption> getASUCollegesIntList() 
    {
        Id interestRecId = [SELECT Id FROM RecordType WHERE Name = 'Interest'].Id;
        List<Campaign> interests = [SELECT Id, Name, RecordTypeId 
                                    FROM Campaign 
                                    WHERE RecordTypeId = :interestRecId 
                                    AND Type = 'ASU Colleges' 
                                    AND IsActive = true 
                                    ORDER BY Name ASC];
        List<SelectOption> asuCollegesIntList = new List<SelectOption>();
        asuCollegesIntList.add(new SelectOption( '' ,'--Select--'));
        for (Campaign i : interests ) 
        {
            asuCollegesIntList.add(new SelectOption(i.Id , i.Name));
        }

        return asuCollegesIntList;
    }

    public Boolean save() {
        getCaseC();
        try 
        {
            if(career == '--Select--')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a career!'));
                return false; 
            }
            else if (originSelection != '--Select--' && elId != null) 
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select either ONE case OR ONE event.'));
                return false; 
            }
            else if (originSelection == '--Select--' && elId == null) 
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select either ONE case OR ONE event.'));
                return false;
            }
            else if (pickSelection != null && pickSelection != '--Select--' && selectedInterestId == null) 
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'After selecting a type of interest, you must select an interest.'));
                return false;
            }
            else if (originSelection != '--Select--' && elId == null && caseC.Functional_Group__c == null) 
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'When selecting an Origin, you must also select a Functional Group.'));
                return false;
            }
            else if(contact.Phone == null && contact.MailingPostalCode == null)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide either a Phone number or a Zip code!'));
                return false;
            }
            else if(career == 'graduate' && collegeSelected == '0')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a college!'));
                return false;
            }
            else 
            {
                //Create Contact
                contact.Id = null;
                contact.SF_First_Name__c = contact.FirstName;
                contact.SF_First_Name_Updated__c = Datetime.now();
                contact.SF_Last_Name__c = contact.LastName;
                contact.SF_Last_Name_Updated__c = Datetime.now();
                contact.SF_Mobile__c = contact.MobilePhone;
                Pattern SMSValidate = Pattern.compile('[^0-9]');
                if (contact.MobilePhone != null && smsText == true) 
                {
                    contact.SMS_Phone__c = contact.MobilePhone;
                    contact.SMS_Phone__c = SMSValidate.matcher(contact.SMS_Phone__c).replaceAll('');
                }

                contact.SF_Mobile_Updated__c = Datetime.now();
                contact.SF_Mailing_Street__c = contact.MailingStreet;
                contact.SF_Mailing_City__c = contact.MailingCity;
                contact.SF_Mailing_Country__c = contact.MailingCountryCode;
                contact.SF_Mailing_State__c = contact.MailingStateCode;
                contact.SF_Mailing_ZIP__c = contact.MailingPostalCode;
                contact.SF_Mailing_Address_Updated__c = Datetime.now();
                contact.SF_Birthdate__c = contact.Birthdate;
                contact.SF_Birthdate_Updated__c = Datetime.now();
                
                Integer hasMailingCode = contact.MailingPostalCode == null ? 0 : 1;
                Integer hasPhone = contact.Phone == null ? 0 : 1;
                Integer result = hasMailingCode + hasPhone;
                if (result < 1)
                {
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must fill out these required fields in order to save the contact: First Name, Last Name, Email, and one of these two fields: Phone or Zip Code.'));
                    return false;
                }

                insert contact;
    
                //Create Opportunity
                opportunity.Id = null;
                if(career == 'undergraduate')
                {
                    opportunity.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Undergraduate Prospect' LIMIT 1].Id;
                }
                else
                {
                    opportunity.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Graduate Prospect' LIMIT 1].Id;
                }
                opportunity.Career__c = career;

                Datetime DatePreString = Datetime.now();
                String TodayString = DatePreString.format('yyyy-MM-dd');
                opportunity.Contact__c = contact.id;
                opportunity.Name = contact.FirstName + ' ' + contact.LastName + ' ' + TodayString;
                opportunity.CloseDate = Date.Today() + 365;
                accId = [SELECT AccountId FROM Contact WHERE Id = :Contact.Id][0].AccountId;
                opportunity.AccountId = accId;
                opportunity.StageName = 'Prospect';
                
                if (contact.Country_of_Citizenship__r.Name == 'United States') 
                {
                    opportunity.International_Student__c = false;
                }
                else if (contact.Country_of_Citizenship__c == null) 
                {
                    opportunity.International_Student__c = false;
                }
                else 
                {
                    opportunity.International_Student__c = true;
                }

                if(collegeSelected != null && collegeSelected != '0')
                {
                   opportunity.College__c = collegeSelected; 
                }
                if(planSelected != null && planSelected != '0')
                {
                   opportunity.Academic_Plan__c = planSelected; 
                }

                insert opportunity;
    
                //Create Previous Education
                getPreviousEducation();
                if (previousEducation.Account__c != null) 
                {
                    previousEducation.Id = null;
                    previousEducation.Contact__c = contact.id;
                    insert previousEducation;
                }
    
                //Create CampaignMember Event
                if (elId != null && originSelection == '--Select--') 
                {
                    getCampaignMemberEvent();
                    camMemEvent.Id = null;
                    camMemEvent.CampaignId = elId;
                    //It appears that this value is not being preserved, but is instead being switched to 'Sent'?
                    camMemEvent.Status = 'Registered';
                    camMemEvent.ContactId = contact.Id;
                    camMemEvent.Opportunity__c = opportunity.Id;
                    camMemEvent.Inbound_Interaction__c = true;
    
                    insert camMemEvent;
                }
                //Create Case
                else if (originSelection != '--Select--' && elId == null) 
                {
                    caseC.Id = null;
                    caseC.Status = 'Closed: Resolved';
                    caseC.ContactId = contact.Id;
                    caseC.Opportunity__c = opportunity.Id;
                    if (originSelection == 'Incoming Call') 
                    {
                        if (phoneOrig == null) 
                        {
                            Campaign phoneCamp = [SELECT Id FROM Campaign WHERE Name = 'Phone Call' LIMIT 1];
                            if(phoneCamp != null)
                            {
                                caseC.Case_Source__c = phoneCamp.Id;
                            }
                        }
                    }
                    else if (originSelection == 'Email') 
                    {
                        if (emailOrig == null) 
                        {
                            Campaign emailCamp = [SELECT Id FROM Campaign WHERE Name = 'Email' LIMIT 1];
                            if(emailCamp != null)
                            {
                                caseC.Case_Source__c = emailCamp.Id;
                            }
                        }
                    }
                    else 
                    {
                        if (walkInOrig == null) 
                        {
                            Campaign walkCamp = [SELECT Id FROM Campaign WHERE Name = 'Walk In' LIMIT 1];
                            if(walkCamp != null)
                            {
                                caseC.Case_Source__c = walkCamp.Id;
                            }
                        }
                    }

                    caseC.Origin__c = originSelection;
                    caseC.Inbound_Interaction__c = true;
                    caseC.Priority = 'Normal';
                    String termName = opportunity.Term__c;

                    termName = [SELECT Term__r.Name FROM Opportunity WHERE Term__c = :opportunity.Term__c LIMIT 1].Term__r.Name;

                    if (caseC.Subject == null && caseC.Description == null) 
                    {
                        caseC.Subject = caseC.Origin__c + ' Submission - ' + termName;
                    }
                    insert caseC;
                    
                    //Update Opportunity's case with case Id
                    opportunity.Prospect_Case__c = caseC.Id;
                    update opportunity;
                }
                else if (originSelection != '--Select--' && elId != null) 
                {
                    return false;
                }
                else if (originSelection == '--Select--' && elId == null) 
                {
                    return false;
                }
                else 
                {
                    return false;
                }
                
                //Create CampaignMember Interest
                if (pickSelection != null && pickSelection != '--Select--') 
                {
                    if (selectedInterestId != null) 
                    {
                        getCampaignMemberInterest();
                        camMemInterest.Id = null;
                        camMemInterest.CampaignId = selectedInterestId;
                        //This doesn't seem to work either, Status once again is set to 'Sent'
                        camMemInterest.Status = 'Interested';
                        camMemInterest.ContactId = contact.Id;
                        camMemInterest.Opportunity__c = opportunity.Id;
        
                        insert camMemInterest;
                    }
                    else 
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'After selecting a type of interest, you must select an interest.'));
                        return false;
                    }
                }
                //Save success, return true.
                return true;
            }
        } 
        catch (Exception e) 
        {
            ApexPages.addMessages(e);
            return false;
        }
    }

    public PageReference savePage() 
    {
        if (save()) 
        {
            PageReference save = new PageReference('/apex/Unified_Prospect_Page?saved=true');
            save.setRedirect(true);
            return save;
        }
        else 
        {
            return null;
        }
    }
}