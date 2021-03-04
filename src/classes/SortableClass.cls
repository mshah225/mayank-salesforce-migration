global class SortableClass implements Comparable {
    public PS_ASU_SP_CLASS_V__x classInfo { get; private set; }
    private String classParamSort;

    global SortableClass(PS_ASU_SP_CLASS_V__x classInfo, String sortBy) {
        this.classInfo = classInfo;
        this.classParamSort = sortBy;
    }

    global Integer compareTo(Object compareTo) {
        SortableClass compareToClass = (SortableClass) compareTo;
        Integer sortDir = 0;
        if (classParamSort.equals('Session')) {
            sortDir = compareToClass.classInfo.SESSION_CODE__c.compareTo(this.classInfo.SESSION_CODE__c);
        } else if (classParamSort.equals('Class')) {
            sortDir = compareToClass.classInfo.CLASS_NBR__c.compareTo(this.classInfo.CLASS_NBR__c);
        } else if (classParamSort.equals('Course')) {
            String thatCourseText =
                String.valueOf(compareToClass.classInfo.SUBJECT__c) +
                String.valueOf(compareToClass.classInfo.CATALOG_NBR__c);
            String thisCourseText =
                String.valueOf(this.classInfo.SUBJECT__c) + String.valueOf(this.classInfo.CATALOG_NBR__c);
            sortDir = thatCourseText.compareTo(thisCourseText);
        } else if (classParamSort.equals('Title')) {
            sortDir = compareToClass.classInfo.CLASS_DESCR__c.compareTo(this.classInfo.CLASS_DESCR__c);
        } else if (classParamSort.equals('Topic')) {
            if (
                compareToClass.classInfo.SSR_CLSTOPIC_DESCR__c != null &&
                this.classInfo.SSR_CLSTOPIC_DESCR__c != null
            ) {
                sortDir = compareToClass.classInfo.SSR_CLSTOPIC_DESCR__c.compareTo(
                    this.classInfo.SSR_CLSTOPIC_DESCR__c
                );
            } else if (
                compareToClass.classInfo.SSR_CLSTOPIC_DESCR__c != null &&
                this.classInfo.SSR_CLSTOPIC_DESCR__c == null
            ) {
                sortDir = -1;
            } else {
                sortDir = 1;
            }
        } else if (classParamSort.equals('Units')) {
            if (compareToClass.classInfo.UNT_TAKEN__c == this.classInfo.UNT_TAKEN__c) {
                sortDir = 0;
            } else if (this.classInfo.UNT_TAKEN__c > compareToClass.classInfo.UNT_TAKEN__c) {
                sortDir = 1;
            } else {
                sortDir = -1;
            }
        } else if (classParamSort.equals('Instructor')) {
            if (compareToClass.classInfo.FT_FULL_NAME__c != null && this.classInfo.FT_FULL_NAME__c != null) {
                sortDir = compareToClass.classInfo.FT_FULL_NAME__c.compareTo(this.classInfo.FT_FULL_NAME__c);
            } else if (compareToClass.classInfo.FT_FULL_NAME__c != null && this.classInfo.FT_FULL_NAME__c == null) {
                sortDir = -1;
            } else {
                sortDir = 1;
            }
        } else if (classParamSort.equals('Days')) {
            if (compareToClass.classInfo.SCH_HTML_DAY1__c != null && this.classInfo.SCH_HTML_DAY1__c != null) {
                sortDir = compareToClass.classInfo.SCH_HTML_DAY1__c.compareTo(this.classInfo.SCH_HTML_DAY1__c);
            } else if (compareToClass.classInfo.SCH_HTML_DAY1__c != null && this.classInfo.SCH_HTML_DAY1__c == null) {
                sortDir = -1;
            } else {
                sortDir = 1;
            }
        } else if (classParamSort.equals('Times')) {
            if (compareToClass.classInfo.SCH_DAILY_TIME__c != null && this.classInfo.SCH_DAILY_TIME__c != null) {
                sortDir = compareToClass.classInfo.SCH_DAILY_TIME__c.compareTo(this.classInfo.SCH_DAILY_TIME__c);
            } else if (compareToClass.classInfo.SCH_DAILY_TIME__c != null && this.classInfo.SCH_DAILY_TIME__c == null) {
                sortDir = -1;
            } else {
                sortDir = 1;
            }
        } else if (classParamSort.equals('Dates')) {
            sortDir = compareToClass.classInfo.ASU_SCH_DATES__c.compareTo(this.classInfo.ASU_SCH_DATES__c);
        } else if (classParamSort.equals('Location')) {
            sortDir = compareToClass.classInfo.SSR_MTG_LOC_LONG__c.compareTo(this.classInfo.SSR_MTG_LOC_LONG__c);
        } else if (classParamSort.equals('Grade')) {
            if (compareToClass.classInfo.CRSE_GRADE_OFF__c != null && this.classInfo.CRSE_GRADE_OFF__c != null) {
                sortDir = compareToClass.classInfo.CRSE_GRADE_OFF__c.compareTo(this.classInfo.CRSE_GRADE_OFF__c);
            } else if (compareToClass.classInfo.CRSE_GRADE_OFF__c != null && this.classInfo.CRSE_GRADE_OFF__c == null) {
                sortDir = -1;
            } else {
                sortDir = 1;
            }
        } else {
            sortDir = 0;
        }
        return sortDir * -1;
    }
}
