global class SortableAcademicIntegrityData implements Comparable {
    public PS_ASU_SP_CLASS_V__x academicIntegrityDataItem { get; private set; }
    private String academicIntegrityDataParamSort;

    global SortableAcademicIntegrityData(PS_ASU_SP_CLASS_V__x academicIntegrityDataItem, String sortBy) {
        this.academicIntegrityDataItem = academicIntegrityDataItem;
        this.academicIntegrityDataParamSort = sortBy;
    }

    global Integer compareTo(Object compareTo) {
        SortableAcademicIntegrityData compareToItem = (SortableAcademicIntegrityData) compareTo;
        Integer sortDir = 0;
        if (academicIntegrityDataParamSort.equals('Term')) {
            String thatTerm = String.valueOf(compareToItem.academicIntegrityDataItem.TERM_DESCR30__c);
            String thisTerm = String.valueOf(this.academicIntegrityDataItem.TERM_DESCR30__c);

            sortDir = thatTerm.compareTo(thisTerm);
        } else if (academicIntegrityDataParamSort.equals('Class')) {
            sortDir = compareToItem.academicIntegrityDataItem.CLASS_NBR__c.compareTo(
                this.academicIntegrityDataItem.CLASS_NBR__c
            );
        } else if (academicIntegrityDataParamSort.equals('Course')) {
            String thatCourseText =
                String.valueOf(compareToItem.academicIntegrityDataItem.SUBJECT__c) +
                String.valueOf(compareToItem.academicIntegrityDataItem.CATALOG_NBR__c);
            String thisCourseText =
                String.valueOf(this.academicIntegrityDataItem.SUBJECT__c) +
                String.valueOf(this.academicIntegrityDataItem.CATALOG_NBR__c);
            sortDir = thatCourseText.compareTo(thisCourseText);
        } else if (academicIntegrityDataParamSort.equals('Title')) {
            sortDir = compareToItem.academicIntegrityDataItem.CLASS_DESCR__c.compareTo(
                this.academicIntegrityDataItem.CLASS_DESCR__c
            );
        } else if (academicIntegrityDataParamSort.equals('Units')) {
            if (compareToItem.academicIntegrityDataItem.UNT_TAKEN__c == this.academicIntegrityDataItem.UNT_TAKEN__c) {
                sortDir = 0;
            } else if (
                this.academicIntegrityDataItem.UNT_TAKEN__c > compareToItem.academicIntegrityDataItem.UNT_TAKEN__c
            ) {
                sortDir = 1;
            } else {
                sortDir = -1;
            }
        } else if (academicIntegrityDataParamSort.equals('Instructor')) {
            if (
                compareToItem.academicIntegrityDataItem.FT_FULL_NAME__c != null &&
                this.academicIntegrityDataItem.FT_FULL_NAME__c != null
            ) {
                sortDir = compareToItem.academicIntegrityDataItem.FT_FULL_NAME__c.compareTo(
                    this.academicIntegrityDataItem.FT_FULL_NAME__c
                );
            } else if (
                compareToItem.academicIntegrityDataItem.FT_FULL_NAME__c != null &&
                this.academicIntegrityDataItem.FT_FULL_NAME__c == null
            ) {
                sortDir = -1;
            } else {
                sortDir = 1;
            }
        } else if (academicIntegrityDataParamSort.equals('Days')) {
            if (
                compareToItem.academicIntegrityDataItem.SCH_HTML_DAY1__c != null &&
                this.academicIntegrityDataItem.SCH_HTML_DAY1__c != null
            ) {
                sortDir = compareToItem.academicIntegrityDataItem.SCH_HTML_DAY1__c.compareTo(
                    this.academicIntegrityDataItem.SCH_HTML_DAY1__c
                );
            } else if (
                compareToItem.academicIntegrityDataItem.SCH_HTML_DAY1__c != null &&
                this.academicIntegrityDataItem.SCH_HTML_DAY1__c == null
            ) {
                sortDir = -1;
            } else {
                sortDir = 1;
            }
        } else if (academicIntegrityDataParamSort.equals('Times')) {
            if (
                compareToItem.academicIntegrityDataItem.SCH_DAILY_TIME__c != null &&
                this.academicIntegrityDataItem.SCH_DAILY_TIME__c != null
            ) {
                sortDir = compareToItem.academicIntegrityDataItem.SCH_DAILY_TIME__c.compareTo(
                    this.academicIntegrityDataItem.SCH_DAILY_TIME__c
                );
            } else if (
                compareToItem.academicIntegrityDataItem.SCH_DAILY_TIME__c != null &&
                this.academicIntegrityDataItem.SCH_DAILY_TIME__c == null
            ) {
                sortDir = -1;
            } else {
                sortDir = 1;
            }
        } else if (academicIntegrityDataParamSort.equals('Dates')) {
            sortDir = compareToItem.academicIntegrityDataItem.ASU_SCH_DATES__c.compareTo(
                this.academicIntegrityDataItem.ASU_SCH_DATES__c
            );
        } else if (academicIntegrityDataParamSort.equals('Location')) {
            sortDir = compareToItem.academicIntegrityDataItem.SSR_MTG_LOC_LONG__c.compareTo(
                this.academicIntegrityDataItem.SSR_MTG_LOC_LONG__c
            );
        } else if (academicIntegrityDataParamSort.equals('Transcript Grade')) {
            if (
                compareToItem.academicIntegrityDataItem.CRSE_GRADE_OFF__c != null &&
                this.academicIntegrityDataItem.CRSE_GRADE_OFF__c != null
            ) {
                sortDir = compareToItem.academicIntegrityDataItem.CRSE_GRADE_OFF__c.compareTo(
                    this.academicIntegrityDataItem.CRSE_GRADE_OFF__c
                );
            } else if (
                compareToItem.academicIntegrityDataItem.CRSE_GRADE_OFF__c != null &&
                this.academicIntegrityDataItem.CRSE_GRADE_OFF__c == null
            ) {
                sortDir = -1;
            } else {
                sortDir = 1;
            }
        } else if (academicIntegrityDataParamSort.equals('Academic Integrity Grade')) {
            if (
                compareToItem.academicIntegrityDataItem.CRSE_GRADE_INPUT__c != null &&
                this.academicIntegrityDataItem.CRSE_GRADE_INPUT__c != null
            ) {
                sortDir = compareToItem.academicIntegrityDataItem.CRSE_GRADE_INPUT__c.compareTo(
                    this.academicIntegrityDataItem.CRSE_GRADE_INPUT__c
                );
            } else if (
                compareToItem.academicIntegrityDataItem.CRSE_GRADE_INPUT__c != null &&
                this.academicIntegrityDataItem.CRSE_GRADE_INPUT__c == null
            ) {
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