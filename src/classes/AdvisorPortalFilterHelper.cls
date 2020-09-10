/**
* @author Mathew Ruff, Sierra-Cedar
* @date 2019-08-02
*
* Used as a helper class that filters Contacts on the Advisor Portal.
*/
public class AdvisorPortalFilterHelper {
    private static Map<String, Set<Decimal>> outlookScoresByLabels = new Map<String, Set<Decimal>>{
        'very low' => new Set<Decimal>{0, 1, 2, 3},
        'low' => new Set<Decimal>{4, 5},
        'moderate' => new Set<Decimal>{6},
        'high' => new Set<Decimal>{7},
        'very high' => new Set<Decimal>{8, 9, 10}
    };

    private static Map<String, Decimal> outlookChangeByLabels = new Map<String, Decimal>{
        'up' => 1,
        'down' => 0,
        'no change' => -1
    };

    public static List<String> getCachedOwnerIdList() {
        List<String> ownerIdList = new List<String>();
    	if (Cache.Session.contains('advisorPortalOwnerIdList')) {
    		ownerIdList = (List<String>)Cache.Session.get('advisorPortalOwnerIdList');
		}
        return ownerIdList;
    }
    
    public static String getOwnerIdsForQuery() {
        String additionalOwnerIds = '';
        String currentUserId = UserInfo.getUserId();
        String queryString = '(OwnerId = \'' + currentUserId + '\'';
        
        List<String> ownerIdList = getCachedOwnerIdList();
        if (ownerIdList != null && ownerIdList.size() > 0) {
            for (String ownerId : ownerIdList) {
                additionalOwnerIds += ' OR OwnerId = \'' + ownerId + '\'';
            }
        }
        queryString += additionalOwnerIds + ')';
        
        return queryString;
    }

    /**
     * Filters Contact records using SOSL and the provided filter.
     *
     * @param filter, the AdvisorPortalFilter to use.
     * @param contactIds, a Set of Contact Ids to use in the query.
     *
     * @return, a filtered Set of Contact Ids
     */
    public static Set<Id> filterContacts(AdvisorPortalFilter filter, Set<Id> contactIds) {
        if (String.isBlank(filter.studentString)) {
            return contactIds;
        } else {
            return new Map<Id, Contact>((List<Contact>) [
                FIND :filter.studentString
                    RETURNING Contact (Id WHERE Id IN :contactIds)
            ][0]).keySet();
        }
    }

    /**
     * Queries for Case records using the supplied filter and Contact Ids.
     *
     * @param filter, the AdvisorPortalFilter to use.
     * @param contactIds, a Set of Contact Ids to use in the query.
     *
     * @return, a filtered List of Case records.
     */
    public static List<Case> filterCases(AdvisorPortalFilter filter, Set<Id> contactIds) {
        String queryString = '' +
            'SELECT Priority, ' +
                'CaseNumber, ' +
                'Subject, ' +
                'Status, ' +
                'Followup_Date__c, ' +
                'Owner.Name, ' +
                'CreatedDate, ' +
                'CC_Category__r.Name, ' +
                'CC_Category__r.Parent__r.Name, ' +
                'RecordType.Name, ' +
                'Change_Date__c, ' +
                'Curr_Cont_Prediction_Level__c, ' +
                'Most_Recent_Outlook_Change_Direction__c, ' +
                'OwnerId, ' +
                'ContactId ' +
            'FROM Case ' +
            'WHERE ContactId IN :contactIds ' +
            'AND IsClosed = FALSE ' +
            'AND RecordTypeId = \'' + IDHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach') + '\'';

        if (!String.isBlank(filter.caseCategory)) {
            List<String> categories = filter.caseCategory.split(';');
            queryString += ' AND CC_Category__r.Name IN :categories';
        }

        if (!String.isBlank(filter.caseSubject)) {
            List<String> subjects = filter.caseSubject.split(';');
            queryString += ' AND Subject IN :subjects';
        }

        if (!String.isBlank(filter.caseStatus)) {
            List<String> statuses = filter.caseStatus.split(';');
            queryString += ' AND Status IN :statuses';
        }
        
        queryString += ' AND ' + getOwnerIdsForQuery();

        if (filter.watchlistCasesState != null && filter.watchlistCasesState) {
            queryString += ' AND CC_Category__r.Name = \'Watchlist\' AND CC_Category__r.Parent__r.Name = \'ASU Advisor Outreach\'';
        }

        if (!String.isBlank(filter.outlookScore)) {
            List<Decimal> scores = new List<Decimal>();

            for (String s : filter.outlookScore.split(';')) {
                if (outlookScoresByLabels.containsKey(s)) {
                    scores.addAll(outlookScoresByLabels.get(s));
                }
            }

            queryString += ' AND Curr_Cont_Prediction_Level__c IN :scores';
        }

        if (!String.isBlank(filter.outlookChange)) {
            List<Decimal> changeDirections = new List<Decimal>();

            for (String s : filter.outlookChange.split(';')) {
                if (outlookChangeByLabels.containsKey(s)) {
                    changeDirections.add(outlookChangeByLabels.get(s));
                }
            }

            queryString += ' AND Most_Recent_Outlook_Change_Direction__c IN :changeDirections';
        }

        if (!String.isBlank(filter.createdFromDate)) {
            queryString += ' AND CreatedDate >= ' + Datetime.valueOf(filter.createdFromDate + ' 00:00:00').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ');
        }

        if (!String.isBlank(filter.createdToDate)) {
            queryString += ' AND CreatedDate <= ' + Datetime.valueOf(filter.createdToDate + ' 00:00:00').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ');
        }

        if (!String.isBlank(filter.followUpFromDate)) {
            queryString += ' AND Followup_Date__c >= ' + filter.followUpFromDate;
        }

        if (!String.isBlank(filter.followUpToDate)) {
            queryString += ' AND Followup_Date__c <= ' + filter.followUpToDate;
        }

        if (!String.isBlank(filter.persistenceFromDate)) {
            queryString += ' AND Change_Date__c >= ' + filter.persistenceFromDate;
        }

        if (!String.isBlank(filter.persistenceToDate)) {
            queryString += ' AND Change_Date__c <= ' + filter.persistenceToDate;
        }

        queryString += ' LIMIT 10000';

        return Database.query(queryString);
    }

    /**
     * Queries for Contact Ids based on the provided filter on Student_Group__c.
     *
     * @param filter, the AdvisorPortalFilter to use.
     * @param contactIds, a Set of Contact Ids to use in the query.
     *
     * @return filteredContactIds, a filtered Set of Contact Ids matching the filter criteria.
     */
    public static Set<Id> filterStudentGroups(AdvisorPortalFilter filter, Set<Id> contactIds) {
        Set<Id> filteredContactIds = new Set<Id>();

        if (!String.isBlank(filter.studentGroupCode)) {
            for (AggregateResult studentPlanResult : [
                SELECT SG_Contact__c
                FROM Student_Group__c
                WHERE SG_Contact__c IN :contactIds
                AND SG_PeopleSoft_Code__c = :filter.studentGroupCode
                GROUP BY SG_Contact__c
                LIMIT 2000
            ]) {
                filteredContactIds.add((Id) studentPlanResult.get('SG_Contact__c'));
            }
            return filteredContactIds;
        } else {
            return contactIds;
        }
    }

    /**
    * Queries for Contact Ids based on the provided filter on Student_Plan__c.
    *
    * @param filter, the AdvisorPortalFilter to use.
    * @param contactIds, a Set of Contact Ids to use in the query.
    *
    * @return filteredContactIds, a filtered Set of Contact Ids matching the filter criteria.
    */
    public static Set<Id> filterStudentPlans(AdvisorPortalFilter filter, Set<Id> contactIds) {
        if (!String.isBlank(filter.academicLevel)
            || !String.isBlank(filter.campus)
            || !String.isBlank(filter.residency)
            || !String.isBlank(filter.major)
        ) {
            Set<Id> filteredContactIds = new Set<Id>();
            String queryString = '' +
                'SELECT Contact__c ' +
                'FROM Student_Program_Plan__c ' +
                'WHERE Contact__c IN :contactIds';

            if (!String.isBlank(filter.academicLevel)) {
                List<String> academicLevels = filter.academicLevel.split(';');
                queryString += ' AND Cohort__c IN :academicLevels';
            }

            if (!String.isBlank(filter.campus)) {
                List<String> campuses = filter.campus.split(';');
                queryString += ' AND Campus__r.Name IN :campuses';
            }

            if (!String.isBlank(filter.residency)) {
                List<String> residencies = filter.residency.split(';');
                queryString += ' AND Residency__c IN :residencies';
            }

            if (!String.isBlank(filter.major)) {
                queryString += ' AND Plan_Description__c LIKE \'%' + filter.major + '%\'';
            }

            queryString += ' GROUP BY Contact__c LIMIT 2000';

            for (AggregateResult studentPlanResult : Database.query(queryString)) {
                filteredContactIds.add((Id) studentPlanResult.get('Contact__c'));
            }
            return filteredContactIds;
        } else {
            return contactIds;
        }
    }
}