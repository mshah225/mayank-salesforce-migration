public class AdvisorPortalFilterQueryMaker {
    List<Id> viewAsOptions;
    AdvisorPortalFilter filter;

    private QueryWith whenToQueryStudentGroups = QueryWith.STANDALONE;
    private QueryWith whenToQueryStudentProgramPlans = QueryWith.STANDALONE;
    private QueryWith whenToQuerySuccessStudents = QueryWith.STANDALONE;
    private QueryWith whenToQuerySpecialPopulations = QueryWith.STANDALONE;
    private QueryWith whenWithBaseQuery = QueryWith.STANDALONE;

    private List<Id> prefilteredContactIds = null;

    public AdvisorPortalFilterQueryMaker(List<Id> viewAsOptions, AdvisorPortalFilter filter, QueryWith basemode) {
        this.viewAsOptions = viewAsOptions;
        this.filter = filter;
        this.whenWithBaseQuery = basemode;
    }

    /**
     * Primary query method
     * Calling this will trigger the filter to query the needed records and will return the AdvisorPortalContact wrapper objects for those records
     */
    public List<AdvisorPortalContact> query() {
        List<AdvisorPortalContact> advisorPortalContactResults = new List<AdvisorPortalContact>();

        // Set defaults for subquery vs STANDALONES
        if (whenWithBaseQuery == QueryWith.WITH_CASE) {
            whenToQueryStudentProgramPlans = QueryWith.WITH_CASE;
            whenToQueryStudentGroups = QueryWith.WITH_CASE;
            whenToQuerySpecialPopulations = QueryWith.STANDALONE;
        } else {
            whenToQueryStudentProgramPlans = QueryWith.WITH_CONTACT;
            whenToQuerySuccessStudents = QueryWith.WITH_CONTACT;
            whenToQueryStudentGroups = QueryWith.STANDALONE;
            whenToQuerySpecialPopulations = QueryWith.STANDALONE;
        }

        minimizeSOQLQueries(); // figures out which subqueries will be needed, and re-arranges WHEN different queries are run to try to avoid uneccessary SOQL calls

        // Perform the base query
        List<AdvisorPortalContact> tmpAdvisorPortalContactResults = new List<AdvisorPortalContact>();
        if (whenWithBaseQuery == QueryWith.WITH_CASE) {
            List<Case> allCases = generateCaseQuery().query();

            // group cases by contact id
            Set<Id> contactIds = new Set<Id>();
            Map<Id, List<Case>> contactIdToCasesMap = new Map<Id, List<Case>>();
            for (Case c : allCases) {
                Id contactId = c.ContactId;
                if (contactId != null) {
                    contactIds.add(contactId);
                    if (!contactIdToCasesMap.containsKey(contactId))
                        contactIdToCasesMap.put(contactId, new List<Case>());
                    contactIdToCasesMap.get(contactId).add(c);
                }
            }

            // convert to wrappers
            for (Id contactId : contactIdToCasesMap.keySet()) {
                if (!contactIds.contains(contactId))
                    continue;

                // Create the corresponding contact object from the contact of this case
                Contact contact = contactIdToCasesMap.get(contactId)[0].Contact;

                AdvisorPortalContact contactWrapper = new AdvisorPortalContact(contact);

                List<AdvisorPortalCase> caseWrappers = new List<AdvisorPortalCase>();
                for (Case c : contactIdToCasesMap.get(contactId)) {
                    caseWrappers.add(new AdvisorPortalCase(c));
                }
                if (!caseWrappers.isEmpty()) {
                    contactWrapper.addCases(caseWrappers);
                }
                tmpAdvisorPortalContactResults.add(contactWrapper);
            }
        } else {
            List<Contact> allContacts = generateContactQuery().query();

            for (Contact contact : allContacts) {
                AdvisorPortalContact contactWrapper = new AdvisorPortalContact(contact);

                List<AdvisorPortalCase> caseWrappers = new List<AdvisorPortalCase>();
                for (Case c : contact.cases) {
                    caseWrappers.add(new AdvisorPortalCase(c));
                }
                if (!caseWrappers.isEmpty()) {
                    contactWrapper.addCases(caseWrappers);
                }
                tmpAdvisorPortalContactResults.add(contactWrapper);
            }
        }

        // While we now have the base results we still need to run some post-query filtering
        // this include checking the caseCount as well as running any post-base-query secondary
        // filters (such as for Special Population or (potentially) student groups)

        Set<Id> validContactIds = new Set<Id>();
        for (AdvisorPortalContact contactWrapper : tmpAdvisorPortalContactResults) {
            // Skip contact if we filter by Case count, but there aren't correct amount
            if (filter.shouldUse('caseCount'))
                if (contactWrapper.cases.size() != filter.getCaseCount())
                    continue;

            // Mark if in grad or ugrad mode
            contactWrapper.isGradStudent = (filter.career == 'GRD');

            validContactIds.add(contactWrapper.portalContact.Id);
        }

        // If student groups needed to be run as standalone, do that now
        if (whenToQueryStudentGroups == QueryWith.STANDALONE) {
            prefilteredContactIds = new List<Id>(validContactIds);
            DynamicSoqlBuilder sgQuery = generateStudentGroupQuery();
            if (sgQuery != null) {
                List<Student_Group__c> studentGroups = sgQuery.query();

                // store list of contact ids that the student group filter returned
                validContactIds.clear();
                for (Student_Group__c sg : studentGroups)
                    validContactIds.add(sg.SG_Contact__c);
            }
        }

        // If the special populations need to be run as standalone (which is everytime they run, since they cannot run alongside the base query),
        // then we must apply the needed special population filters.
        if (whenToQuerySpecialPopulations == QueryWith.STANDALONE) {
            prefilteredContactIds = new List<Id>(validContactIds);

            Set<Id> specialPopulationContactIds = new Set<Id>();

            DynamicSoqlBuilder specialPop1 = generateSpecialPopulationDualOrAppliedToGradQuery();
            DynamicSoqlBuilder specialPop2 = generateSpecialPopulationFormatStudents();
            DynamicSoqlBuilder specialPop3 = generateSpecialPopulationProvisionalAdmitsAndRegistrationHold();
            DynamicSoqlBuilder specialPop4 = generateSpecialPopulationStudentGroups();
            DynamicSoqlBuilder specialPop5 = generateSpecialPopulationAssistants();

            if (specialPop1 != null) {
                List<String> specialPopulations = filter.getSpecialPopulations();
                List<Student_Program_Plan__c> specialPopSPPs = specialPop1.query();

                Id previousContactId = null;
                Integer numberOfPlans = 0;

                List<String> dualEnrollmentCareers = new List<String>{ 'Graduate', 'Law' };
                List<String> appliedToGraduateCodes = new List<String>{ 'AG', 'AP', 'GD', 'IR', 'PN' };

                for (Student_Program_Plan__c spp : specialPopSPPs) {
                    Id contactId = spp.Contact__c;

                    // meet requirements for applied to graduate
                    if (specialPopulations.contains('applied to graduate')) {
                        if (
                            spp.Career__c == 'Graduate' &&
                            appliedToGraduateCodes.contains(spp.Degree_Chkout_Stat_Code__c)
                        ) {
                            specialPopulationContactIds.add(contactId);
                        }
                    }

                    // need to count plans to determine if in multiple at same time
                    if (specialPopulations.contains('concurrent enrollment')) {
                        if (previousContactId != contactId)
                            numberOfPlans = 0;

                        if (dualEnrollmentCareers.contains(spp.Career__c)) {
                            numberOfPlans++;

                            if (numberOfPlans > 1) {
                                specialPopulationContactIds.add(contactId);
                            }
                        }
                        previousContactId = contactId;
                    }
                }
            }

            if (specialPop2 != null) {
                List<AggregateResult> specialPopStudentMilestones = specialPop2.query();
                for (AggregateResult sm : specialPopStudentMilestones) {
                    specialPopulationContactIds.add((Id) sm.get('Contact__c'));
                }
            }

            if (specialPop3 != null) {
                List<AggregateResult> specialPopServInds = specialPop3.query();
                for (AggregateResult si : specialPopServInds) {
                    specialPopulationContactIds.add((Id) si.get('SI_Contact__c'));
                }
            }

            if (specialPop4 != null) {
                List<AggregateResult> specialPopStuGrps = specialPop4.query();
                for (AggregateResult sg : specialPopStuGrps) {
                    specialPopulationContactIds.add((Id) sg.get('SG_Contact__c'));
                }
            }

            if (specialPop5 != null) {
                List<Contact> specialPopContacts = specialPop5.query();
                for (Contact con : specialPopContacts) {
                    specialPopulationContactIds.add(con.Id);
                }
            }

            // If any of the special population filters ran, then use the contact ids it returned
            if (
                specialPop1 != null ||
                specialPop2 != null ||
                specialPop3 != null ||
                specialPop4 != null ||
                specialPop5 != null
            ) {
                validContactIds.clear();
                for (Id i : specialPopulationContactIds) {
                    validContactIds.add(i);
                }
            }
        }

        // Copy over any contacts that passed the post-base-filter stages - limit to 3000
        for (AdvisorPortalContact contactWrapper : tmpAdvisorPortalContactResults) {
            if (advisorPortalContactResults.size() >= 3000)
                break;
            if (validContactIds.contains(contactWrapper.portalContact.Id)) {
                advisorPortalContactResults.add(contactWrapper);
            }
        }

        return advisorPortalContactResults;
    }

    /**
     * Attempts to reorder WHEN each of the queries are done in order to avoid running additional queries if possible.
     * If any of the potential subqueries are not needed, it will promote a different subquery from STANDALONE to run alongside the base query
     */
    private void minimizeSOQLQueries() {
        if (generateStudentProgramPlanQuery() == null) {
            whenToQueryStudentProgramPlans = QueryWith.NONE;
            promoteNextSubquery();
        }
        if (generateSuccessStudentQuery() == null) {
            whenToQuerySuccessStudents = QueryWith.NONE;
            promoteNextSubquery();
        }
        if (generateStudentGroupQuery() == null) {
            whenToQueryStudentGroups = QueryWith.NONE;
            promoteNextSubquery();
        }
    }

    /**
     * If a query needs to be ran and it is currently going to be run STANDALONE, promote it to run
     * as a subquery of the base query.
     * If order of preference:
     *      1. Success_Students__c is always promoted first
     *      2. Student_Program_Plan__c is always promoted second
     *      3. Student_Group__c is always promoted third
     * if we are unable to promote a query (since we can only ever have 2 promoted (bc governor limits))
     * then it must be run separately as a STANDALONE query
     */
    private void promoteNextSubquery() {
        Integer promotedCnt = 0;
        if (whenToQuerySuccessStudents != QueryWith.NONE && promotedCnt < 2)
            whenToQuerySuccessStudents = whenWithBaseQuery;
        if (whenToQuerySuccessStudents == whenWithBaseQuery)
            promotedCnt++;

        if (whenToQueryStudentProgramPlans != QueryWith.NONE && promotedCnt < 2)
            whenToQueryStudentProgramPlans = whenWithBaseQuery;
        if (whenToQueryStudentProgramPlans == whenWithBaseQuery)
            promotedCnt++;

        if (whenToQueryStudentGroups != QueryWith.NONE && promotedCnt < 2)
            whenToQueryStudentGroups = whenWithBaseQuery;
        if (whenToQueryStudentGroups == whenWithBaseQuery)
            promotedCnt++;
    }

    /**
     * Generate the SOQL query to be performed against the Contact records.
     * This will obey the QueryWith flags - so make sure you don't include to many semi-joins or Salesforce will throw an error (2 semi-joins at max)
     * This is the base query for any success-student-owner based queries
     */
    private DynamicSoqlBuilder generateContactQuery() {
        DynamicSoqlBuilder contactQuery = new DynamicSoqlBuilder('Contact')
            .returnField('Id')
            .returnField('Name')
            .returnField('FirstName')
            .returnField('Preferred_Full_Name__c')
            .returnField('Preferred_First_Name__c')
            .returnField('LastName')
            .returnField('EmplId__c')
            .returnField('ASURite_Id__c')
            .returnField('US_Citizen__c')
            .returnField('Change_Date__c')
            .returnField('Most_Recent_Outlook_Change_Direction__c')
            .returnField('Curr_Cont_Prediction_Level__c')
            .returnField(generateCaseQuery());

        // If querying contacts as base query - need to apply order and limits
        if (whenWithBaseQuery == QueryWith.WITH_CONTACT) {
            contactQuery.setOrder('LastName, Preferred_First_Name__c ASC').setLimit(30000);
        }

        if (filter.shouldUse('outlookScore') && filter.getCaseTypeState() == 'AllCasesState') {
            contactQuery.restrictIn('Curr_Cont_Prediction_Level__c', filter.getOutlookScores());
        }

        if (filter.shouldUse('outlookChange') && filter.getCaseTypeState() == 'AllCasesState') {
            contactQuery.restrictIn('Most_Recent_Outlook_Change_Direction__c', filter.getOutlookChanges());
        }

        if (filter.shouldUse('persistenceFromDate') && filter.getCaseTypeState() == 'AllCasesState') {
            contactQuery.restrictGreaterThanOrEqual('Change_Date__c', filter.getPersistenceFromDate());
        }

        if (filter.shouldUse('persistenceToDate') && filter.getCaseTypeState() == 'AllCasesState') {
            contactQuery.restrictLessThanOrEqual('Change_Date__c', filter.getPersistenceToDate());
        }

        if (filter.shouldUse('studentString') && filter.getCaseTypeState() == 'AllCasesState') {
            contactQuery.restrict(
                new DynamicSoqlBuilderRestriction.OrRestriction(
                    new List<DynamicSoqlBuilderRestriction>{
                        new DynamicSoqlBuilderRestriction.EqualRestriction(
                            'Preferred_Full_Name__c',
                            filter.getStudentString()
                        ),
                        new DynamicSoqlBuilderRestriction.EqualRestriction('Name', filter.getStudentString()),
                        new DynamicSoqlBuilderRestriction.EqualRestriction('EmplId__c', filter.getStudentString()),
                        new DynamicSoqlBuilderRestriction.EqualRestriction('ASURite_ID__c', filter.getStudentString())
                    }
                )
            );
        }

        // If we are meant to filter success students as part of query on contacts, do that now
        if (whenToQuerySuccessStudents == QueryWith.WITH_CONTACT) {
            contactQuery.restrictIn('Id', generateSuccessStudentQuery());
        }

        // If we are meant to filter student groups as part of the query on contacts, do that now
        if (whenToQueryStudentGroups == QueryWith.WITH_CONTACT) {
            DynamicSoqlBuilder sgQuery = generateStudentGroupQuery();
            if (sgQuery != null)
                contactQuery.restrictIn('Id', sgQuery);
        }

        // If we are meant to filter student program plan as part of the query on contacts, do that now
        if (whenToQueryStudentProgramPlans == QueryWith.WITH_CONTACT) {
            DynamicSoqlBuilder sppQuery = generateStudentProgramPlanQuery();
            if (sppQuery != null)
                contactQuery.restrictIn('Id', sppQuery);
        }

        // If we have any prefitlered contact ids to limit the query, apply them
        if (prefilteredContactIds != null)
            contactQuery
                .bind('prefilteredContactIds', prefilteredContactIds)
                .restrictIn('Id', new DynamicSoqlBuilderRestriction.Bind('prefilteredContactIds'));

        return contactQuery;
    }

    /**
     * Generate the SOQL query to be performed against the Case records.
     * This will obey the QueryWith flags - so make sure you don't include to many semi-joins or Salesforce will throw an error (2 semi-joins at max)
     * This is the base query for any case-owner based queries
     */
    private DynamicSoqlBuilder generateCaseQuery() {
        DynamicSoqlBuilder caseQuery = new DynamicSoqlBuilder('Case')
            .returnField('Id')
            .returnField('CaseNumber')
            .returnField('Subject')
            .returnField('Status')
            .returnField('Followup_Date__c')
            .returnField('OwnerId')
            .returnField('Owner.Name')
            .returnField('CreatedDate')
            .returnField('CC_Category__r.Name')
            .returnField('CC_Category__r.Parent__r.Name')
            .returnField('RecordType.Name')
            .returnField('Change_Date__c')
            .returnField('Curr_Cont_Prediction_Level__c')
            .returnField('Most_Recent_Outlook_Change_Direction__c')
            .returnField('Most_Recent_Queue__c')
            .returnField('Priority')
            .restrictEqual('IsClosed', false)
            .restrictEqual(
                'RecordTypeId',
                filter.getCareer() == 'GRD'
                    ? RecordIdHelper.getRecordTypeId('Case', 'ASU_Graduate_Advisor_Portal')
                    : RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach')
            );

        // If querying cases as base query - need to grab contact details and apply order and limits
        if (whenWithBaseQuery == QueryWith.WITH_CASE) {
            caseQuery
                .returnField('ContactId')
                .returnField('Contact.Id')
                .returnField('Contact.Name')
                .returnField('Contact.FirstName')
                .returnField('Contact.Preferred_Full_Name__c')
                .returnField('Contact.Preferred_First_Name__c')
                .returnField('Contact.LastName')
                .returnField('Contact.EmplId__c')
                .returnField('Contact.ASURite_Id__c')
                .returnField('Contact.US_Citizen__c')
                .returnField('Contact.Change_Date__c')
                .returnField('Contact.Most_Recent_Outlook_Change_Direction__c')
                .returnField('Contact.Curr_Cont_Prediction_Level__c')
                .setOrder('Contact.LastName, Contact.Preferred_First_Name__c ASC')
                .setLimit(30000);
        }

        if (filter.shouldUse('caseCategory'))
            caseQuery
                .bind('caseCategories', filter.getCaseCategories())
                .restrictIn('CC_Category__r.Name', new DynamicSoqlBuilderRestriction.Bind('caseCategories'));

        if (filter.shouldUse('caseSubCategory'))
            caseQuery
                .bind('caseSubCategories', filter.getCaseSubCategories())
                .restrictIn('CC_Sub_Category__r.Name', new DynamicSoqlBuilderRestriction.Bind('caseSubCategories'));

        if (filter.shouldUse('caseSubject'))
            caseQuery
                .bind('caseSubjects', filter.getCaseSubjects())
                .restrictIn('Subject', new DynamicSoqlBuilderRestriction.Bind('caseSubjects'));

        if (filter.shouldUse('caseStatus'))
            caseQuery
                .bind('caseStatuses', filter.getCaseStatuses())
                .restrictIn('Status', new DynamicSoqlBuilderRestriction.Bind('caseStatuses'));

        // If AllCasesState - we look at outlook on Contact records, not case records
        if (filter.shouldUse('outlookScore') && filter.getCaseTypeState() != 'AllCasesState')
            caseQuery
                .bind('outlookedScores', filter.getOutlookScores())
                .restrictIn('Curr_Cont_Prediction_Level__c', new DynamicSoqlBuilderRestriction.Bind('outlookedScores'));

        // If AllCasesState - we look at outlook on Contact records, not case records
        if (filter.shouldUse('outlookChange') && filter.getCaseTypeState() != 'AllCasesState')
            caseQuery
                .bind('outlookDirections', filter.getOutlookChanges())
                .restrictIn(
                    'Most_Recent_Outlook_Change_Direction__c',
                    new DynamicSoqlBuilderRestriction.Bind('outlookDirections')
                );

        if (filter.shouldUse('createdFromDate'))
            caseQuery.restrictGreaterThanOrEqual('CreatedDate', filter.getCreatedFromDate());

        if (filter.shouldUse('createdToDate'))
            caseQuery.restrictLessThanOrEqual('CreatedDate', filter.getCreatedToDate());

        if (filter.shouldUse('followUpFromDate'))
            caseQuery.restrictGreaterThanOrEqual('Followup_Date__c', filter.getFollowUpFromDate());

        if (filter.shouldUse('followUpToDate'))
            caseQuery.restrictLessThanOrEqual('Followup_Date__c', filter.getFollowUpToDate());

        // If AllCasesState - we look at persistence on Contact records, not case records
        if (filter.shouldUse('persistenceFromDate') && filter.getCaseTypeState() != 'AllCasesState')
            caseQuery.restrictGreaterThanOrEqual('Change_Date__c', filter.getPersistenceFromDate());

        // If AllCasesState - we look at persistence on Contact records, not case records
        if (filter.shouldUse('persistenceToDate') && filter.getCaseTypeState() != 'AllCasesState')
            caseQuery.restrictLessThanOrEqual('Change_Date__c', filter.getPersistenceToDate());

        // If AllCasesState - we look at name directly on Contact records, not via case lookup fields
        if (filter.shouldUse('studentString') && filter.getCaseTypeState() != 'AllCasesState') {
            caseQuery.restrict(
                new DynamicSoqlBuilderRestriction.OrRestriction(
                    new List<DynamicSoqlBuilderRestriction>{
                        new DynamicSoqlBuilderRestriction.EqualRestriction(
                            'Contact.Preferred_Full_Name__c',
                            filter.getStudentString()
                        ),
                        new DynamicSoqlBuilderRestriction.EqualRestriction('Contact.Name', filter.getStudentString()),
                        new DynamicSoqlBuilderRestriction.EqualRestriction(
                            'Contact.EmplId__c',
                            filter.getStudentString()
                        ),
                        new DynamicSoqlBuilderRestriction.EqualRestriction(
                            'Contact.ASURite_ID__c',
                            filter.getStudentString()
                        )
                    }
                )
            );
        }

        if (filter.getCaseTypeState() == 'WatchlistCasesState')
            caseQuery
                .restrictEqual('CC_Category__r.Name', 'Watchlist')
                .restrictEqual(
                    'CC_Category__r.Parent__r.Name',
                    filter.getCareer() == 'GRD' ? 'ASU Graduate Advisor Portal' : 'ASU Advisor Outreach'
                );

        // In the AllCasesState - we use success student ownership model, not case owner model
        if (filter.getCaseTypeState() != 'AllCasesState')
            caseQuery
                .bind('caseOwnerIds', viewAsOptions)
                .restrictIn('OwnerId', new DynamicSoqlBuilderRestriction.Bind('caseOwnerIds'));

        // If we are meant to filter student groups as part of the query on cases, do that now
        if (whenToQueryStudentGroups == QueryWith.WITH_CASE) {
            DynamicSoqlBuilder sgQuery = generateStudentGroupQuery();
            if (sgQuery != null)
                caseQuery.restrictIn('ContactId', sgQuery);
        }

        // If we are meant to filter student program plan as part of the query on case, do that now
        if (whenToQueryStudentProgramPlans == QueryWith.WITH_CASE) {
            DynamicSoqlBuilder sppQuery = generateStudentProgramPlanQuery();
            if (sppQuery != null)
                caseQuery.restrictIn('ContactId', sppQuery);
        }

        // If we have any prefitlered contact ids to limit the query, apply them
        if (prefilteredContactIds != null)
            caseQuery
                .bind('prefilteredContactIds', prefilteredContactIds)
                .restrictIn('ContactId', new DynamicSoqlBuilderRestriction.Bind('prefilteredContactIds'));

        return caseQuery;
    }

    /**
     * Query that filters based on student program plan fields.  The only field returned is Contact__c.
     * The main use is as a subquery semijoin, though it can be used post-query filtering step if the semijoin limit
     * has already been reached.
     */
    private DynamicSoqlBuilder generateStudentProgramPlanQuery() {
        DynamicSoqlBuilder sppQuery = new DynamicSoqlBuilder('Student_Program_Plan__c')
            .returnField('Contact__c')
            .restrictLessThanOrEqual('Effective_Date__c', new DynamicSoqlBuilderRestriction.Keyword('TODAY'))
            .restrictEqual('Status__c', 'Active in Program');

        Boolean appliedRestriction = false;

        if (filter.shouldUse('degreeLevel')) {
            DynamicSoqlBuilderRestriction.OrRestriction degreeLevelRestrict = new DynamicSoqlBuilderRestriction.OrRestriction();
            List<String> requirements = new List<String>();
            List<String> degreeLevels = filter.getDegreeLevels();

            if (degreeLevels.contains('masters')) {
                degreeLevelRestrict.add(
                    new DynamicSoqlBuilderRestriction.AndRestriction(
                        new List<DynamicSoqlBuilderRestriction>{
                            new DynamicSoqlBuilderRestriction.EqualRestriction('Plan_Type_Text__c', 'MAJ'),
                            new DynamicSoqlBuilderRestriction.EqualRestriction('Education_Level__c', '17')
                        }
                    )
                );
            }
            if (degreeLevels.contains('doctorate')) {
                degreeLevelRestrict.add(
                    new DynamicSoqlBuilderRestriction.AndRestriction(
                        new List<DynamicSoqlBuilderRestriction>{
                            new DynamicSoqlBuilderRestriction.EqualRestriction('Plan_Type_Text__c', 'MAJ'),
                            new DynamicSoqlBuilderRestriction.EqualRestriction('Education_Level__c', '21')
                        }
                    )
                );
            }
            if (degreeLevels.contains('certificate')) {
                degreeLevelRestrict.add(new DynamicSoqlBuilderRestriction.EqualRestriction('Plan_Type_Text__c', 'CER'));
            }
            if (degreeLevels.contains('non-degree')) {
                degreeLevelRestrict.add(new DynamicSoqlBuilderRestriction.EqualRestriction('Plan_Type_Text__c', 'NDG'));
            }

            if (degreeLevelRestrict.isNotEmpty())
                sppQuery.restrict(degreeLevelRestrict);

            appliedRestriction = true;
        }

        if (filter.shouldUse('academicProgram')) {
            sppQuery
                .bind('sppAcadPrograms', filter.getAcademicPrograms())
                .restrictIn('Program_Code__c', new DynamicSoqlBuilderRestriction.Bind('sppAcadPrograms'));
            appliedRestriction = true;
        }

        if (filter.shouldUse('schoolDepartment')) {
            sppQuery
                .bind('sppSchoolDepartments', filter.getSchoolDepartments())
                .restrictIn(
                    'Organization_Code__r.Organization_Code__c',
                    new DynamicSoqlBuilderRestriction.Bind('sppSchoolDepartments')
                );
            appliedRestriction = true;
        }

        if (filter.shouldUse('academicPlan')) {
            sppQuery
                .bind('sppAcadPlans', filter.getAcademicPlans())
                .restrictIn('Plan_Code__c', new DynamicSoqlBuilderRestriction.Bind('sppAcadPlans'));
            appliedRestriction = true;
        }

        if (filter.shouldUse('admitTermFrom')) {
            sppQuery.restrict(
                new DynamicSoqlBuilderRestriction.OrRestriction(
                    new List<DynamicSoqlBuilderRestriction>{
                        new DynamicSoqlBuilderRestriction.GreaterThanOrEqualRestriction(
                            'Admit_Term__r.PeopleSoft_Code__c',
                            filter.getAdmitTermFrom()
                        ),
                        new DynamicSoqlBuilderRestriction.GreaterThanOrEqualRestriction(
                            'Requirement_Term__c',
                            filter.getAdmitTermFrom()
                        )
                    }
                )
            );
            appliedRestriction = true;
        }

        if (filter.shouldUse('admitTermTo')) {
            sppQuery.restrict(
                new DynamicSoqlBuilderRestriction.OrRestriction(
                    new List<DynamicSoqlBuilderRestriction>{
                        new DynamicSoqlBuilderRestriction.LessThanOrEqualRestriction(
                            'Admit_Term__r.PeopleSoft_Code__c',
                            filter.getAdmitTermTo()
                        ),
                        new DynamicSoqlBuilderRestriction.LessThanOrEqualRestriction(
                            'Requirement_Term__c',
                            filter.getAdmitTermTo()
                        )
                    }
                )
            );
            appliedRestriction = true;
        }

        if (filter.shouldUse('academicLevel')) {
            sppQuery
                .bind('sppAcadLevels', filter.getAcademicLevels())
                .restrictIn('Cohort__c', new DynamicSoqlBuilderRestriction.Bind('sppAcadLevels'));
            appliedRestriction = true;
        }

        if (filter.shouldUse('major')) {
            sppQuery
                .restrictEqual('Plan_Type_Text__c', 'MAJ')
                .restrict(
                    new DynamicSoqlBuilderRestriction.OrRestriction(
                        new List<DynamicSoqlBuilderRestriction>{
                            new DynamicSoqlBuilderRestriction.LikeRestriction(
                                'Plan_Description__c',
                                '%' + filter.getMajor() + '%'
                            ),
                            new DynamicSoqlBuilderRestriction.LikeRestriction(
                                'Plan_Code__c',
                                '%' + filter.getMajor() + '%'
                            )
                        }
                    )
                );
            appliedRestriction = true;
        }

        if (filter.shouldUse('campus')) {
            sppQuery
                .bind('sppCampuses', filter.getCampuses())
                .restrictIn('Campus__r.Location_Code__c', new DynamicSoqlBuilderRestriction.Bind('sppCampuses'));
            appliedRestriction = true;
        }

        if (filter.shouldUse('residency')) {
            sppQuery
                .bind('sppResidencies', filter.getResidencies())
                .restrictIn('Residency__c', new DynamicSoqlBuilderRestriction.Bind('sppResidencies'));
            appliedRestriction = true;
        }

        // If we have any prefitlered contact ids to limit the query, apply them
        if (prefilteredContactIds != null)
            sppQuery
                .bind('prefilteredContactIds', prefilteredContactIds)
                .restrictIn('Contact__c', new DynamicSoqlBuilderRestriction.Bind('prefilteredContactIds'));

        // Only return the query IF it actually has some sub-restrictions, otherwise we will return null
        // and won't run the subquery on SPP (this happens whenever we aren't filtering using SSP-connected fields)
        if (appliedRestriction)
            return sppQuery;
        else
            return null;
    }

    /**
     * Query that filters based on student group fields.  The only field returned is SG_Contact__c.
     * The main use is as a subquery semijoin, though it can be used post-query filtering step if the semijoin limit
     * has already been reached.
     */
    private DynamicSoqlBuilder generateStudentGroupQuery() {
        DynamicSoqlBuilder sgQuery = new DynamicSoqlBuilder('Student_Group__c')
            .returnField('SG_Contact__c')
            .restrictLessThanOrEqual('SG_Effective_Date__c', new DynamicSoqlBuilderRestriction.Keyword('TODAY'))
            .restrictEqual('SG_Status__c', true);
        Boolean appliedRestriction = false;

        if (filter.shouldUse('studentGroupCode')) {
            sgQuery.restrictEqual('SG_PeopleSoft_Code__c', filter.getStudentGroupCode());
            appliedRestriction = true;
        }

        // If we have any prefitlered contact ids to limit the query, apply them
        if (prefilteredContactIds != null)
            sgQuery
                .bind('prefilteredContactIds', prefilteredContactIds)
                .restrictIn('SG_Contact__c', new DynamicSoqlBuilderRestriction.Bind('prefilteredContactIds'));

        // Only return the query IF it actually has some sub-restrictions, otherwise we will return null
        // and won't run the subquery on SPP (this happens whenever we aren't filtering using SSP-connected fields)
        if (appliedRestriction)
            return sgQuery;
        else
            return null;
    }

    /**
     * Query that filters based on success student fields (owner).  The only field returned is Student__c.
     * The main use is as a subquery semijoin, though it can be used post-query filtering step if the semijoin limit
     * has already been reached.
     */
    private DynamicSoqlBuilder generateSuccessStudentQuery() {
        DynamicSoqlBuilder ssQuery = new DynamicSoqlBuilder('Success_Student__c')
            .returnField('Student__c')
            .restrictEqual('Is_Active__c', true)
            .restrictEqual(
                'RecordTypeId',
                filter.getCareer() == 'GRD'
                    ? RecordIdHelper.getRecordTypeId('Success_Student__c', 'Grad')
                    : RecordIdHelper.getRecordTypeId('Success_Student__c', 'Advisor')
            );

        // In the AllCasesState - we use success student ownership model, not case owner model, so add that restriction
        if (filter.getCaseTypeState() == 'AllCasesState')
            ssQuery
                .bind('studentOwnerIds', viewAsOptions)
                .restrictIn('Success_Pod__r.OwnerId', new DynamicSoqlBuilderRestriction.Bind('studentOwnerIds'));

        // If we have any prefitlered contact ids to limit the query, apply them
        if (prefilteredContactIds != null)
            ssQuery
                .bind('prefilteredContactIds', prefilteredContactIds)
                .restrictIn('Student__c', new DynamicSoqlBuilderRestriction.Bind('prefilteredContactIds'));

        return ssQuery;
    }

    /**
     * Query that filters for the students that are have concurrent enrollment or which have
     * applied to graduate
     * Because Special Population filters require UNIONs, we cannot do them as part of the primary query and they
     * must be done as post-base-query steps. However, in order to avoid governor limits, we've had to consolidate
     * their queries to the extent possible, hence the combo here.
     *
     * @return If either filter is relevant to the current query (if either special population is selected)
     *         returns a DynamicSoqlBuilder for the query which would return the records - if neither is
     *         selected, then returns null
     */
    private DynamicSoqlBuilder generateSpecialPopulationDualOrAppliedToGradQuery() {
        DynamicSoqlBuilder sppQuery = new DynamicSoqlBuilder('Student_Program_Plan__c')
            .returnField('Contact__c')
            .returnField('Career__c')
            .returnField('Status__c')
            .returnField('Degree_Chkout_Stat_Code__c')
            .restrictLessThanOrEqual('Effective_Date__c', new DynamicSoqlBuilderRestriction.Keyword('TODAY'))
            .restrictEqual('Status__c', 'Active in Program')
            .setOrder('Contact__c, Effective_Date__c, Plan_Sequence__c DESC NULLS LAST')
            .setLimit(2000);
        Boolean appliedRestriction = false;

        List<String> dualEnrollmentCareers = new List<String>{ 'Graduate', 'Law' };
        List<String> appliedToGraduateCodes = new List<String>{ 'AG', 'AP', 'GD', 'IR', 'PN' };

        if (filter.shouldUse('specialPopulation')) {
            List<String> specialPopulations = filter.getSpecialPopulations();
            DynamicSoqlBuilderRestriction.OrRestriction restrict = new DynamicSoqlBuilderRestriction.OrRestriction();
            sppQuery.restrict(restrict);

            if (specialPopulations.contains('applied to graduate')) {
                restrict.add(
                    new DynamicSoqlBuilderRestriction.AndRestriction(
                        new List<DynamicSoqlBuilderRestriction>{
                            new DynamicSoqlBuilderRestriction.EqualRestriction('Career__c', 'Graduate'),
                            new DynamicSoqlBuilderRestriction.InRestriction(
                                'Degree_Chkout_Stat_Code__c',
                                appliedToGraduateCodes
                            )
                        }
                    )
                );
                appliedRestriction = true;
            }

            if (specialPopulations.contains('concurrent enrollment')) {
                restrict.add(new DynamicSoqlBuilderRestriction.InRestriction('Career__c', dualEnrollmentCareers));
                appliedRestriction = true;
            }
        }

        // If we have any prefitlered contact ids to limit the query, apply them
        if (prefilteredContactIds != null)
            sppQuery
                .bind('prefilteredContactIds', prefilteredContactIds)
                .restrictIn('Contact__c', new DynamicSoqlBuilderRestriction.Bind('prefilteredContactIds'));

        if (appliedRestriction)
            return sppQuery;
        else
            return null;
    }

    /**
     * Query that filters for the students that are format students
     * Because Special Population filters require UNIONs, we cannot do them as part of the primary query and they
     * must be done as post-base-query steps.
     *
     * @return If this Special Population is selected, then it returns DynamicSoqlBuilder for the query which
     *         would return the records - if neither is selected, then returns null
     */
    private DynamicSoqlBuilder generateSpecialPopulationFormatStudents() {
        DynamicSoqlBuilder smQuery = new DynamicSoqlBuilder('Student_Milestone__c')
            .returnField('Contact__c')
            .restrictEqual('Milestone__c', 'GRFORMAT')
            .restrictLessThanOrEqual('Effdt__c', new DynamicSoqlBuilderRestriction.Keyword('TODAY'))
            .setGroupBy('Contact__c')
            .setLimit(2000);
        Boolean appliedRestriction = false;

        if (filter.shouldUse('specialPopulation')) {
            List<String> specialPopulations = filter.getSpecialPopulations();

            if (specialPopulations.contains('format students')) {
                // Term_Required__c = '' OR Term_Required__r.PeopleSoft_Code__c >= :currentTerm
                smQuery.restrict(
                    new DynamicSoqlBuilderRestriction.OrRestriction(
                        new List<DynamicSoqlBuilderRestriction>{
                            new DynamicSoqlBuilderRestriction.EqualRestriction('Term_Required__c', ''),
                            new DynamicSoqlBuilderRestriction.GreaterThanOrEqualRestriction(
                                'Term_Required__r.PeopleSoft_Code__c',
                                getCurrentPeoplesoftTermCode()
                            )
                        }
                    )
                );
                appliedRestriction = true;
            }
        }

        // If we have any prefitlered contact ids to limit the query, apply them
        if (prefilteredContactIds != null)
            smQuery
                .bind('prefilteredContactIds', prefilteredContactIds)
                .restrictIn('Contact__c', new DynamicSoqlBuilderRestriction.Bind('prefilteredContactIds'));

        if (appliedRestriction)
            return smQuery;
        else
            return null;
    }

    /**
     * Query that filters for the students that are either provisional admints or which have a registration hold.
     * Because Special Population filters require UNIONs, we cannot do them as part of the primary query and they
     * must be done as post-base-query steps.
     *
     * @return If either filter is relevant to the current query (if either special population is selected)
     *         returns a DynamicSoqlBuilder for the query which would return the records - if neither is
     *         selected, then returns null
     */
    private DynamicSoqlBuilder generateSpecialPopulationProvisionalAdmitsAndRegistrationHold() {
        DynamicSoqlBuilder siQuery = new DynamicSoqlBuilder('Service_Indicator__c')
            .returnField('SI_Contact__c')
            .restrict(
                // (SI_Start_Term__c = '' OR SI_Start_Term__r.PeopleSoft_Code__c <= :currentTerm)
                new DynamicSoqlBuilderRestriction.OrRestriction(
                    new List<DynamicSoqlBuilderRestriction>{
                        new DynamicSoqlBuilderRestriction.EqualRestriction('SI_Start_Term__c', ''),
                        new DynamicSoqlBuilderRestriction.LessThanOrEqualRestriction(
                            'SI_Start_Term__r.PeopleSoft_Code__c',
                            getCurrentPeoplesoftTermCode()
                        )
                    }
                )
            )
            .restrict(
                // (SI_End_Term__c = '' OR SI_End_Term__r.PeopleSoft_Code__c >= :currentTerm)
                new DynamicSoqlBuilderRestriction.OrRestriction(
                    new List<DynamicSoqlBuilderRestriction>{
                        new DynamicSoqlBuilderRestriction.EqualRestriction('SI_End_Term__c', ''),
                        new DynamicSoqlBuilderRestriction.GreaterThanOrEqualRestriction(
                            'SI_End_Term__r.PeopleSoft_Code__c',
                            getCurrentPeoplesoftTermCode()
                        )
                    }
                )
            )
            .setGroupBy('SI_Contact__c')
            .setLimit(2000);
        Boolean appliedRestriction = false;

        if (filter.shouldUse('specialPopulation')) {
            List<String> specialPopulations = filter.getSpecialPopulations();
            DynamicSoqlBuilderRestriction.OrRestriction restrict = new DynamicSoqlBuilderRestriction.OrRestriction();
            siQuery.restrict(restrict);

            if (specialPopulations.contains('provivisional admits, not met yet')) {
                restrict.add(
                    new DynamicSoqlBuilderRestriction.AndRestriction(
                        new List<DynamicSoqlBuilderRestriction>{
                            new DynamicSoqlBuilderRestriction.EqualRestriction('SI_Code__c', 'AD4'),
                            new DynamicSoqlBuilderRestriction.EqualRestriction('SI_Reason__c', 'Provisional Admission'),
                            new DynamicSoqlBuilderRestriction.EqualRestriction('SI_Positive_Service_Indicator__c', true)
                        }
                    )
                );
                appliedRestriction = true;
            }
            if (specialPopulations.contains('active students with registation hold')) {
                restrict.add(
                    new DynamicSoqlBuilderRestriction.AndRestriction(
                        new List<DynamicSoqlBuilderRestriction>{
                            new DynamicSoqlBuilderRestriction.EqualRestriction('Enrollment_Impact__c', true),
                            new DynamicSoqlBuilderRestriction.EqualRestriction(
                                'SI_Positive_Service_Indicator__c',
                                false
                            )
                        }
                    )
                );
                appliedRestriction = true;
            }
        }

        // If we have any prefitlered contact ids to limit the query, apply them
        if (prefilteredContactIds != null)
            siQuery
                .bind('prefilteredContactIds', prefilteredContactIds)
                .restrictIn('SI_Contact__c', new DynamicSoqlBuilderRestriction.Bind('prefilteredContactIds'));

        if (appliedRestriction)
            return siQuery;
        else
            return null;
    }

    /**
     * Query that filters for the students that are either 4+1 students, vetermans, mayo students, or cintana students.
     * Because Special Population filters require UNIONs, we cannot do them as part of the primary query and they
     * must be done as post-base-query steps.
     *
     * @return If any of the filters are relevant to the current query (if one of those special populations are selected)
     *         returns a DynamicSoqlBuilder for the query which would return the records - if none of them are
     *         selected, then returns null
     */
    private DynamicSoqlBuilder generateSpecialPopulationStudentGroups() {
        DynamicSoqlBuilder sgQuery = new DynamicSoqlBuilder('Student_Group__c')
            .returnField('SG_Contact__c')
            .restrictEqual('SG_Status__c', true)
            .restrictLessThanOrEqual('SG_Effective_Date__c', new DynamicSoqlBuilderRestriction.Keyword('TODAY'))
            .setGroupBy('SG_Contact__c')
            .setLimit(2000);
        Boolean appliedRestriction = false;

        if (filter.shouldUse('specialPopulation')) {
            List<String> specialPopulations = filter.getSpecialPopulations();
            Set<String> acceptablePeoplesoftCodesSet = new Set<String>();

            if (specialPopulations.contains('accelerated 4+1 degrees')) {
                acceptablePeoplesoftCodesSet.add('GRAH'); // Active undergrad, 4 + 1 applicant
                acceptablePeoplesoftCodesSet.add('GRAI'); // When matriculated as a student
                acceptablePeoplesoftCodesSet.add('ADIP'); // International Accelerated (IADP) students
            }
            if (specialPopulations.contains('veterans')) {
                acceptablePeoplesoftCodesSet.add('SR1B');
                acceptablePeoplesoftCodesSet.add('SR1D');
            }
            if (specialPopulations.contains('mayo students')) {
                acceptablePeoplesoftCodesSet.add('SRKY');
            }
            if (specialPopulations.contains('cintana students')) {
                acceptablePeoplesoftCodesSet.add('ADAD'); // Cintana Students
            }

            if (!acceptablePeoplesoftCodesSet.isEmpty()) {
                appliedRestriction = true;
                List<String> acceptablePeoplesoftCodesList = new List<String>(acceptablePeoplesoftCodesSet);
                sgQuery.restrictIn('SG_PeopleSoft_Code__c', acceptablePeoplesoftCodesList);
            }
        }

        // If we have any prefitlered contact ids to limit the query, apply them
        if (prefilteredContactIds != null)
            sgQuery
                .bind('prefilteredContactIds', prefilteredContactIds)
                .restrictIn('SG_Contact__c', new DynamicSoqlBuilderRestriction.Bind('prefilteredContactIds'));

        if (appliedRestriction)
            return sgQuery;
        else
            return null;
    }

    /**
     * Query that filters for the students that are either research or teaching assistants.
     * Because Special Population filters require UNIONs, we cannot do them as part of the primary query and they
     * must be done as post-base-query steps.
     *
     * @return If any of the filters are relevant to the current query (if one of those special populations are selected)
     *         returns a DynamicSoqlBuilder for the query which would return the records - if none of them are
     *         selected, then returns null
     */
    private DynamicSoqlBuilder generateSpecialPopulationAssistants() {
        DynamicSoqlBuilder contactQuery = new DynamicSoqlBuilder('Contact').returnField('Id');
        Boolean appliedRestriction = false;

        if (filter.shouldUse('specialPopulation')) {
            List<String> specialPopulations = filter.getSpecialPopulations();
            DynamicSoqlBuilderRestriction.OrRestriction assistantRestrict = new DynamicSoqlBuilderRestriction.OrRestriction();
            contactQuery.restrict(assistantRestrict);

            if (specialPopulations.contains('teaching assistants')) {
                assistantRestrict.add(
                    new DynamicSoqlBuilderRestriction.EqualRestriction('Teaching_Assistant__c', true)
                );
                appliedRestriction = true;
            }
            if (specialPopulations.contains('research assistants')) {
                assistantRestrict.add(
                    new DynamicSoqlBuilderRestriction.EqualRestriction('Research_Assistant__c', true)
                );
                appliedRestriction = true;
            }
        }

        // If we have any prefitlered contact ids to limit the query, apply them
        if (prefilteredContactIds != null)
            contactQuery
                .bind('prefilteredContactIds', prefilteredContactIds)
                .restrictIn('Id', new DynamicSoqlBuilderRestriction.Bind('prefilteredContactIds'));

        if (appliedRestriction)
            return contactQuery;
        else
            return null;
    }

    // Enum indicating WHEN certain component of the filter are applied - either as a subquery/join when querying contact or case, or as a separate standalone query
    public enum QueryWith {
        WITH_CASE,
        WITH_CONTACT,
        STANDALONE,
        NONE
    }

    private static String getCurrentPeoplesoftTermCode() {
        StudentTerm__c currentTermData = StudentTerm__c.getOrgDefaults();
        return currentTermData.CurrTerm__c;
    }
}
