public class CivitasPersistenceController{

    public static List<String> months = new List<String>();
	public static Integer dayValue = 0;
    public static List<CivitasWrapper> dataList {get; set;}
    public static String emplId {get; set;}
    
    public static string currentTerm{
        get{
            if (currentTerm == null) {
                JBT_RET_TERMS_VW__x currentTermInfo = 
                [
                    SELECT  CURR_TERM__c, CURR_TERM_INCLUDE_SUMMER__c, 
                            NEXT_TERM_INCLUDE_SUMMER__c,
                            DisplayUrl, ExternalId, Id, 
                            NEXT_TERM__c, PREV_TERM__c, PREV_PREV_TERM__c 
                    FROM    JBT_RET_TERMS_VW__x
                    LIMIT 1
                ];
                currentTerm = currentTermInfo.CURR_TERM__c;
                
                if (currentTerm.length() > 4) {
                    currentTerm = currentTerm.subString(1, 5);
                }
            }
            return currentTerm;
        }
    
        set;
    }
        
    public static string nextTerm{
        get{
            if (nextTerm == null) {
                JBT_RET_TERMS_VW__x currentTermInfo = 
                [
                            SELECT CURR_TERM__c,
                                   CURR_TERM_INCLUDE_SUMMER__c, 
                                   NEXT_TERM_INCLUDE_SUMMER__c,
                                   DisplayUrl, ExternalId, Id, 
                                   NEXT_TERM__c, 
                                   PREV_TERM__c,
                                   PREV_PREV_TERM__c 
                            FROM JBT_RET_TERMS_VW__x
                            LIMIT 1
                ];
                nextTerm = currentTermInfo.NEXT_TERM_INCLUDE_SUMMER__c;
                if (nextTerm.length() > 4) {
                    nextTerm = nextTerm.subString(1, 5);
                }
            }
            return nextTerm;
        }
        set;
    }
    
    public static Date startDate{
        get{
            if (startDate == null) {
                startDate = [Select Session_A_C_Start_Date__c 
                             FROM Term__c 
                             WHERE PeopleSoft_Code__c =: currentTerm
                             LIMIT 1].Session_A_C_Start_Date__c;
                startDate = startDate.addDays(21);
            }
            return startDate;
        }
    
        set;
    }
        
    public static Date endDate{
        get{
            if (endDate == null) {
                endDate = [Select Session_A_C_Start_Date__c 
                             FROM Term__c 
                             WHERE PeopleSoft_Code__c =: nextTerm
                             LIMIT 1].Session_A_C_Start_Date__c;
                endDate = endDate.addDays(21);
            }
            return endDate;
        }
        set;
        }
    
    @RemoteAction
    public static List<CivitasWrapper> getData(String emplidIn){
        dataList = new List<CivitasWrapper>();
        System.debug(emplId);
        for (CV_ASU_STDNT_TERM__x trm : [
            Select SNAP_DATE__c, CURR_CONT_PREDICTION_LEVEL__c,	CURRENT_SEGMENT_DESCR__c, CHANGE_FLG__c  
            FROM CV_ASU_STDNT_TERM__x 
            WHERE Contact__c =: emplIdIn
            ORDER BY SNAP_DATE__c ASC
        ]) {
            if (trm.SNAP_DATE__c >= startDate && trm.SNAP_DATE__c <= endDate) {
                dataList.add(new CivitasWrapper(trm.Snap_Date__c, trm.CURR_CONT_PREDICTION_LEVEL__c, 
                                                trm.CURRENT_SEGMENT_DESCR__c, trm.CHANGE_FLG__c ));                              
            }                  
        }
        
        if (dataList.size() > 0) {
            dataList[0].allMonths = months;
        }
        
        return dataList;
    }
    
    public class CivitasWrapper{
        public Date snapDate;
        public Decimal outlookLevel;
        public Integer day;
        public String dayDate;
        public Integer year;
        public List<String> allMonths;
        public String levelDesc;
        public String fullDate;
        public String flag;
        
        public civitasWrapper(Date sDate, Decimal oLevel, String description, String flagIn){
            snapDate = sDate;
            outlookLevel = oLevel;  
            String currMonth = monthToText(snapDate.month());
            
            if (months == null) {
                months.add(currMonth);
            } else{
                Boolean found = false;
                
                for (String m : months) {
                    if (m.equals(currMonth)) {
                        found = true;
                    }
                }
                
                if (!found) {
                    months.add(currMonth);
                }
            }
        
            year = snapDate.year();
            day = snapDate.day() + (30 * (months.size()-1));
            dayDate = monthToText(snapDate.month()) + ' ' + snapDate.day();
            fullDate =  snapDate.month() + '/' + snapDate.day() + '/' + snapDate.year();
            
            levelDesc = description;
            flag = flagIn;
        }
        
        private string monthToText(Integer month){
            if (month == 1) {
                return 'Jan';
            } else if (month == 2) {
                return 'Feb';
            } else if (month == 3) {
                return 'Mar';
            } else if (month == 4) {
                return 'Apr';
            } else if (month == 5) {
                return 'May';
            } else if (month == 6) {
                return 'Jun';
            } else if (month == 7) {
                return 'Jul';
            } else if (month == 8) {
                return 'Aug';
            } else if (month == 9) {
                return 'Sep';
            } else if(month == 10) {
                return 'Oct';
            } else if(month == 11) {
                return 'Nov';
            } else if(month == 12) {
                return 'Dec';
            } else {
                return 'Error';
            }
        }
    }
}