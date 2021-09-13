public inherited sharing class AdvisorPortalFilterSavingService {
    @AuraEnabled(cacheable=true)
    public static AdvisorPortalFilter getDefaultFilter() {
        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.campus = 'Tempe';
        filter.major = 'Comp Sci';
        filter.residency = 'International';
        filter.caseStatus = 'In Progress;Email Sent';
        filter.caseSubject = 'Example 2';
        filter.academicLevel = 'Freshman;Junior';
        filter.caseCategory = '';
        filter.studentGroupCode = '';
        filter.outlookScore = 'Very Low';
        filter.outlookChange = 'Up';
        filter.caseCount = 3;
        filter.createdFromDate = '';
        filter.createdToDate = '';
        filter.followUpFromDate = '';
        filter.followUpToDate = '';
        filter.persistenceFromDate = '';
        filter.persistenceToDate = '';
        filter.watchlistCasesState = false;
        filter.proactiveCasesState = true;
        filter.allCasesState = false;
        filter.gradStudentsOnly = true;
        return filter;
    }

    @AuraEnabled(cacheable=true)
    public static void setDefaultFilter() {
    }
}
