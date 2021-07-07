global class SortableCreditByExam implements Comparable {
    public PS_ASU_SP_TRNSFR_V__x examInfo { get; private set; }
    private String examParamSort;

    global SortableCreditByExam(PS_ASU_SP_TRNSFR_V__x examInfo, String sortBy) {
        this.examInfo = examInfo;
        this.examParamSort = sortBy;
    }

    global Integer compareTo(Object compareTo) {
        SortableCreditByExam compareToExam = (SortableCreditByExam) compareTo;
        Integer sortDir = 0;
        if (examParamSort.equals('Title')) {
            sortDir = compareToExam.examInfo.Title__c.compareTo(this.examInfo.TITLE__c);
        } else if (examParamSort.equals('Course Title')) {
            sortDir = compareToExam.examInfo.COURSE_TITLE__c.compareTo(this.examInfo.COURSE_TITLE__c);
        } else if (examParamSort.equals('Score')) {
            if (compareToExam.examInfo.SCORE__c == this.examInfo.SCORE__c) {
                sortDir = 0;
            } else if (this.examInfo.SCORE__c > compareToExam.examInfo.SCORE__c) {
                sortDir = 1;
            } else {
                sortDir = -1;
            }
        } else if (examParamSort.equals('Transfer')) {
            if (compareToExam.examInfo.UNT_TRNSFR__c == this.examInfo.UNT_TRNSFR__c) {
                sortDir = 0;
            } else if (this.examInfo.UNT_TRNSFR__c > compareToExam.examInfo.UNT_TRNSFR__c) {
                sortDir = 1;
            } else {
                sortDir = -1;
            }
        } else {
            sortDir = 0;
        }
        return sortDir * -1;
    }
}
