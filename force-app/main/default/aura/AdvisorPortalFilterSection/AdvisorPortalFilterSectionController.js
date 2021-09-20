({
    toggleFilterListPanel: function (component, event, helper) {
        component.set('v.isFilterSectionShown', !component.get('v.isFilterSectionShown'));
        helper.handleToggleFilterButtons(component, event, helper, 'FilterToggleState', 'filtersToggle');
    },

    applyFilters: function (component, event, helper) {
        helper.applyFilters(component);
    },

    clearFilters: function (component, event, helper) {
        component.set('v.Student', '');
        component.find('campusPicklist').resetMultiSelect();
        component.set('v.Major', '');
        component.find('residencyPicklist').resetMultiSelect();
        component.find('caseStatusPicklist').resetMultiSelect();
        component.find('caseSubjectPicklist').resetMultiSelect();
        component.find('caseCategoryPicklist').resetMultiSelect();
        component.find('academicLevelPicklist').resetMultiSelect();
        component.set('v.StudentGroup', '');
        component.find('outlookScoreOptionsPicklist').resetMultiSelect();
        component.find('outlookChangePicklist').resetMultiSelect();
        component.set('v.CaseCount', null);
        component.set('v.CreatedFromDate', '');
        component.set('v.CreatedToDate', '');
        component.set('v.FollowUpFromDate', '');
        component.set('v.FollowUpToDate', '');
        component.set('v.PersistenceFromDate', '');
        component.set('v.PersistenceToDate', '');
        component.set('v.CaseTypeState', 'ProactiveCasesState');
        helper.applyFilters(component);
    },

    refreshView: function (component, event, helper) {
        helper.applyFilters(component);
    },

    returnKeyPressed: function (component, event, helper) {
        if (event.which === 13) {
            helper.applyFilters(component);
        }
    },

    toggleCaseTypeState: function (component, event, helper) {
        helper.applyFilters(component);
    },

    validateDates: function (component, event, helper) {
        helper.validateDateFields(component);
    },

    viewAsUsersHasChanged: function (component, event, helper) {
        let userIds = component.get('v.SelectedViewAsUserOptions').map((option) => option.value);
        component.set('v.HasLoadedSelectedViewAsUserOptions', true);
        component.set('v.UserIds', userIds);

        if (helper.isReady(component)) {
            helper.loadAsyncs(component);
        }
    },

    graduateStudentsOnlyHasChanged: function (component, event, helper) {
        if (helper.isReady(component)) {
            helper.loadAsyncs(component);
        }
    },

    loadDefaultFilter: function (component, event, helper) {
        if (!component.get('v.HasLoadedDefaultFilter')) {
            component.set('v.HasLoadedDefaultFilter', true);

            const defaultFilter = component.get('v.DefaultFilter');

            if (defaultFilter.caseCategory != null && defaultFilter.caseCategory !== '')
                component.set('v.CaseCategory', defaultFilter.caseCategory);
            if (defaultFilter.caseSubject != null && defaultFilter.caseSubject !== '')
                component.set('v.CaseSubject', defaultFilter.caseSubject);
            if (defaultFilter.caseStatus != null && defaultFilter.caseStatus !== '')
                component.set('v.CaseStatus', defaultFilter.caseStatus);
            if (defaultFilter.caseCount != null && defaultFilter.caseCount !== '')
                component.set('v.CaseCount', defaultFilter.caseCount);
            if (defaultFilter.caseTypeState != null && defaultFilter.caseTypeState !== '')
                component.set('v.CaseTypeState', defaultFilter.caseTypeState);
            if (defaultFilter.gradStudentsOnly != null && defaultFilter.gradStudentsOnly !== '')
                component.set('v.GraduateStudentsOnly', defaultFilter.gradStudentsOnly);
            if (defaultFilter.outlookScore != null && defaultFilter.outlookScore !== '')
                component.set('v.OutlookScore', defaultFilter.outlookScore);
            if (defaultFilter.outlookChange != null && defaultFilter.outlookChange !== '')
                component.set('v.OutlookChange', defaultFilter.outlookChange);
            if (defaultFilter.createdFromDate != null && defaultFilter.createdFromDate !== '')
                component.set('v.CreatedFromDate', defaultFilter.createdFromDate);
            if (defaultFilter.createdToDate != null && defaultFilter.createdToDate !== '')
                component.set('v.CreatedToDate', defaultFilter.createdToDate);
            if (defaultFilter.followUpFromDate != null && defaultFilter.followUpFromDate !== '')
                component.set('v.FollowUpFromDate', defaultFilter.followUpFromDate);
            if (defaultFilter.followUpToDate != null && defaultFilter.followUpToDate !== '')
                component.set('v.FollowUpToDate', defaultFilter.followUpToDate);
            if (defaultFilter.persistenceFromDate != null && defaultFilter.persistenceFromDate !== '')
                component.set('v.PersistenceFromDate', defaultFilter.persistenceFromDate);
            if (defaultFilter.persistenceToDate != null && defaultFilter.persistenceToDate !== '')
                component.set('v.PersistenceToDate', defaultFilter.persistenceToDate);
            if (defaultFilter.studentGroupCode != null && defaultFilter.studentGroupCode !== '')
                component.set('v.StudentGroup', defaultFilter.studentGroupCode);
            if (defaultFilter.academicLevel != null && defaultFilter.academicLevel !== '')
                component.set('v.AcademicLevel', defaultFilter.academicLevel);
            if (defaultFilter.campus != null && defaultFilter.campus !== '')
                component.set('v.Campus', defaultFilter.campus);
            if (defaultFilter.major != null && defaultFilter.major !== '')
                component.set('v.Major', defaultFilter.major);
            if (defaultFilter.residency != null && defaultFilter.residency !== '')
                component.set('v.Residency', defaultFilter.residency);

            if (helper.isReady(component)) {
                helper.loadAsyncs(component);
            }
        }
    },

    getFilter: function (component, event, helper) {
        const currentFilter = {};

        if (component.get('v.CaseCategory') != null && component.get('v.CaseCategory') !== '')
            currentFilter.caseCategory = component.get('v.CaseCategory');
        if (component.get('v.CaseSubject') != null && component.get('v.CaseSubject') !== '')
            currentFilter.caseSubject = component.get('v.CaseSubject');
        if (component.get('v.CaseStatus') != null && component.get('v.CaseStatus') !== '')
            currentFilter.caseStatus = component.get('v.CaseStatus');
        if (component.get('v.CaseCount') != null && component.get('v.CaseCount') !== '')
            currentFilter.caseCount = component.get('v.CaseCount');
        if (component.get('v.CaseTypeState') != null && component.get('v.CaseTypeState') !== '')
            currentFilter.caseTypeState = component.get('v.CaseTypeState');
        if (component.get('v.GraduateStudentsOnly') != null && component.get('v.GraduateStudentsOnly') !== '')
            currentFilter.gradStudentsOnly = component.get('v.GraduateStudentsOnly');
        if (component.get('v.OutlookScore') != null && component.get('v.OutlookScore') !== '')
            currentFilter.outlookScore = component.get('v.OutlookScore');
        if (component.get('v.OutlookChange') != null && component.get('v.OutlookChange') !== '')
            currentFilter.outlookChange = component.get('v.OutlookChange');
        if (component.get('v.CreatedFromDate') != null && component.get('v.CreatedFromDate') !== '')
            currentFilter.createdFromDate = component.get('v.CreatedFromDate');
        if (component.get('v.CreatedToDate') != null && component.get('v.CreatedToDate') !== '')
            currentFilter.createdToDate = component.get('v.CreatedToDate');
        if (component.get('v.FollowUpFromDate') != null && component.get('v.FollowUpFromDate') !== '')
            currentFilter.followUpFromDate = component.get('v.FollowUpFromDate');
        if (component.get('v.FollowUpToDate') != null && component.get('v.FollowUpToDate') !== '')
            currentFilter.followUpToDate = component.get('v.FollowUpToDate');
        if (component.get('v.PersistenceFromDate') != null && component.get('v.PersistenceFromDate') !== '')
            currentFilter.persistenceFromDate = component.get('v.PersistenceFromDate');
        if (component.get('v.PersistenceToDate') != null && component.get('v.PersistenceToDate') !== '')
            currentFilter.persistenceToDate = component.get('v.PersistenceToDate');
        if (component.get('v.StudentGroup') != null && component.get('v.StudentGroup') !== '')
            currentFilter.studentGroupCode = component.get('v.StudentGroup');
        if (component.get('v.AcademicLevel') != null && component.get('v.AcademicLevel') !== '')
            currentFilter.academicLevel = component.get('v.AcademicLevel');
        if (component.get('v.Campus') != null && component.get('v.Campus') !== '')
            currentFilter.campus = component.get('v.Campus');
        if (component.get('v.Major') != null && component.get('v.Major') !== '')
            currentFilter.major = component.get('v.Major');
        if (component.get('v.Residency') != null && component.get('v.Residency') !== '')
            currentFilter.residency = component.get('v.Residency');

        event.getParam('arguments').callback(JSON.stringify(currentFilter));
    },
});
