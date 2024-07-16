global class StudentProfileSortAcademicIntegrity implements Comparable {
    public PS_ASU_SP_CLASS_V__x academicIntegrityDataItem { get; private set; }
    private String academicIntegrityDataParamSort;

    public StudentProfileSortAcademicIntegrity(PS_ASU_SP_CLASS_V__x academicIntegrityDataItem, String sortBy) {
        this.academicIntegrityDataItem = academicIntegrityDataItem;
        this.academicIntegrityDataParamSort = sortBy;
    }

    public Integer compareTo(Object compareTo) {
        StudentProfileSortAcademicIntegrity compareToItem = (StudentProfileSortAcademicIntegrity) compareTo;
        Integer sortDir = 0;

        if (academicIntegrityDataParamSort.equals('Class')) {
            String thisValue = this.academicIntegrityDataItem.CLASS_NBR__c;
            String thatValue = compareToItem.academicIntegrityDataItem.CLASS_NBR__c;
            sortDir = compareStrings(thisValue, thatValue);
        } else if (academicIntegrityDataParamSort.equals('Course')) {
            String thisValue =
                this.academicIntegrityDataItem.SUBJECT__c + this.academicIntegrityDataItem.CATALOG_NBR__c;
            String thatValue =
                compareToItem.academicIntegrityDataItem.SUBJECT__c +
                compareToItem.academicIntegrityDataItem.CATALOG_NBR__c;
            sortDir = compareStrings(thisValue, thatValue);
        } else if (academicIntegrityDataParamSort.equals('Dates')) {
            String thisValue = this.academicIntegrityDataItem.ASU_SCH_DATES__c;
            String thatValue = compareToItem.academicIntegrityDataItem.ASU_SCH_DATES__c;
            sortDir = compareStrings(thisValue, thatValue);
        } else if (academicIntegrityDataParamSort.equals('Days')) {
            String thisValue = this.academicIntegrityDataItem.SCH_HTML_DAY1__c;
            String thatValue = compareToItem.academicIntegrityDataItem.SCH_HTML_DAY1__c;
            sortDir = compareStrings(thisValue, thatValue);
        } else if (academicIntegrityDataParamSort.equals('Grade')) {
            String thisValue = this.academicIntegrityDataItem.CRSE_GRADE_OFF__c;
            String thatValue = compareToItem.academicIntegrityDataItem.CRSE_GRADE_OFF__c;
            sortDir = compareStrings(thisValue, thatValue);
        } else if (academicIntegrityDataParamSort.equals('Instructor')) {
            String thisValue = this.academicIntegrityDataItem.FT_FULL_NAME__c;
            String thatValue = compareToItem.academicIntegrityDataItem.FT_FULL_NAME__c;
            sortDir = compareStrings(thisValue, thatValue);
        } else if (academicIntegrityDataParamSort.equals('Location')) {
            String thisValue = this.academicIntegrityDataItem.SSR_MTG_LOC_LONG__c;
            String thatValue = compareToItem.academicIntegrityDataItem.SSR_MTG_LOC_LONG__c;
            sortDir = compareStrings(thisValue, thatValue);
        } else if (academicIntegrityDataParamSort.equals('Session')) {
            String thisValue = this.academicIntegrityDataItem.SESSION_CODE__c;
            String thatValue = compareToItem.academicIntegrityDataItem.SESSION_CODE__c;
            sortDir = compareStrings(thisValue, thatValue);
        } else if (academicIntegrityDataParamSort.equals('Times')) {
            String thisValue = this.academicIntegrityDataItem.SCH_DAILY_TIME__c;
            String thatValue = compareToItem.academicIntegrityDataItem.SCH_DAILY_TIME__c;
            sortDir = compareStrings(thisValue, thatValue);
        } else if (academicIntegrityDataParamSort.equals('Title')) {
            String thisValue = this.academicIntegrityDataItem.CLASS_DESCR__c;
            String thatValue = compareToItem.academicIntegrityDataItem.CLASS_DESCR__c;
            sortDir = compareStrings(thisValue, thatValue);
        } else if (academicIntegrityDataParamSort.equals('Topic')) {
            String thisValue = this.academicIntegrityDataItem.SSR_CLSTOPIC_DESCR__c;
            String thatValue = compareToItem.academicIntegrityDataItem.SSR_CLSTOPIC_DESCR__c;
            sortDir = compareStrings(thisValue, thatValue);
        } else if (academicIntegrityDataParamSort.equals('Units')) {
            Double thisValue = this.academicIntegrityDataItem.UNT_TAKEN__c;
            Double thatValue = compareToItem.academicIntegrityDataItem.UNT_TAKEN__c;
            sortDir = compareDoubles(thisValue, thatValue);
        } else {
            sortDir = 0;
        }

        return sortDir;
    }

    private Integer compareStrings(String thisValue, String thatValue) {
        if (thisValue != null && thatValue != null) {
            return thisValue.compareTo(thatValue);
        } else if (thisValue == null && thatValue != null) {
            return -1;
        } else if (thisValue != null && thatValue == null) {
            return 1;
        } else {
            return 0;
        }
    }

    private Integer compareDoubles(Double thisValue, Double thatValue) {
        if (thisValue != null && thatValue != null) {
            return thisValue > thatValue ? 1 : (thisValue < thatValue ? -1 : 0);
        } else if (thisValue == null && thatValue != null) {
            return -1;
        } else if (thisValue != null && thatValue == null) {
            return 1;
        } else {
            return 0;
        }
    }
}