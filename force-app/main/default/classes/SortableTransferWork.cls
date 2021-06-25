global class SortableTransferWork implements Comparable {
    public JBT_RET_CLASS_XFER__x transferInfo { get; private set; }
    private String transferParamSort;

    global SortableTransferWork(JBT_RET_CLASS_XFER__x transferInfo, String sortBy) {
        this.transferInfo = transferInfo;
        this.transferParamSort = sortBy;
    }

    global Integer compareTo(Object compareTo) {
        SortableTransferWork compareToTransfer = (SortableTransferWork) compareTo;
        Integer sortDir = 0;
        if (transferParamSort.equals('Term')) {
            sortDir = compareToTransfer.transferInfo.TERM__c.compareTo(this.transferInfo.TERM__c);
        } else if (transferParamSort.equals('Institution')) {
            sortDir = compareToTransfer.transferInfo.INSTITUTION__c.compareTo(this.transferInfo.INSTITUTION__c);
        } else if (transferParamSort.equals('Course')) {
            sortDir = compareToTransfer.transferInfo.COURSE__c.compareTo(this.transferInfo.COURSE__c);
        } else if (transferParamSort.equals('Title')) {
            sortDir = compareToTransfer.transferInfo.TITLE__c.compareTo(this.transferInfo.TITLE__c);
        } else if (transferParamSort.equals('Topic')) {
            if (compareToTransfer.transferInfo.TOPIC__c != null && this.transferInfo.TOPIC__c != null) {
                sortDir = compareToTransfer.transferInfo.TOPIC__c.compareTo(this.transferInfo.TOPIC__c);
            } else if (compareToTransfer.transferInfo.TOPIC__c != null && this.transferInfo.TOPIC__c == null) {
                sortDir = -1;
            } else {
                sortDir = 1;
            }
        } else if (transferParamSort.equals('Grade')) {
            sortDir = compareToTransfer.transferInfo.GRADE__c.compareTo(this.transferInfo.GRADE__c);
        } else if (transferParamSort.equals('RCredit')) {
            if (compareToTransfer.transferInfo.RCREDIT__c == this.transferInfo.RCREDIT__c) {
                sortDir = 0;
            } else if (this.transferInfo.RCREDIT__c > compareToTransfer.transferInfo.RCREDIT__c) {
                sortDir = 1;
            } else {
                sortDir = -1;
            }
        } else if (transferParamSort.equals('ECredit')) {
            if (compareToTransfer.transferInfo.ECREDIT__c == this.transferInfo.ECREDIT__c) {
                sortDir = 0;
            } else if (this.transferInfo.ECREDIT__c > compareToTransfer.transferInfo.ECREDIT__c) {
                sortDir = 1;
            } else {
                sortDir = -1;
            }
        } else if (transferParamSort.equals('Hours')) {
            if (compareToTransfer.transferInfo.GPAHRS__c == this.transferInfo.GPAHRS__c) {
                sortDir = 0;
            } else if (this.transferInfo.GPAHRS__c > compareToTransfer.transferInfo.GPAHRS__c) {
                sortDir = 1;
            } else {
                sortDir = -1;
            }
        } else if (transferParamSort.equals('Points')) {
            if (compareToTransfer.transferInfo.GPAPTS__c == this.transferInfo.GPAPTS__c) {
                sortDir = 0;
            } else if (this.transferInfo.GPAPTS__c > compareToTransfer.transferInfo.GPAPTS__c) {
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
