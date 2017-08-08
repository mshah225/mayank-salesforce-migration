global class CivitasPersistenceController{

    global static List<String> months = new List<String>();
	global static Integer dayValue = 0;
    global static List<CivitasWrapper> dataList {get; set;}
    global static String emplId {get; set;}
    global static Decimal persistenceLevel;
    
    public static string currentTerm{
        get{
            if (currentTerm == null) {
                JBT_RET_TERMS_VW__x currentTermInfo = 
                [
                    SELECT  CURR_TERM__c
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
                            SELECT NEXT_TERM__c
                            FROM JBT_RET_TERMS_VW__x
                            LIMIT 1
                ];
                nextTerm = currentTermInfo.NEXT_TERM__c;
                
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
    global static List<CivitasWrapper> getData(String emplidIn){
        dataList = new List<CivitasWrapper>();
        List<CivitasWrapper> rejected = new List<CivitasWrapper>();
        Contact c = [Select Id, FirstName, LastName FROM Contact WHERE emplid__c =: emplidIn LIMIT 1];
        for (CV_ASU_STDNT_TERM__x trm : [
            Select SNAP_DATE__c, CURR_CONT_PREDICTION_LEVEL__c,	CURRENT_SEGMENT_DESCR__c, CHANGE_FLG__c, ONLINE_SEGMENT__c, CAREER_SEGMENT__c  
            FROM CV_ASU_STDNT_TERM__x 
            WHERE Contact__c =: emplIdIn
            ORDER BY SNAP_DATE__c ASC
        ]) {
            // Reject this data if student is an online student, or if student isn't an undergrad
            if (trm.SNAP_DATE__c >= startDate && trm.SNAP_DATE__c <= endDate) {
                if (trm.ONLINE_SEGMENT__c != 'N' || trm.CAREER_SEGMENT__c != 'U') {
                    rejected.add(new CivitasWrapper('Rejected'));
                } else {
                    dataList.add(new CivitasWrapper(trm.Snap_Date__c, trm.CURR_CONT_PREDICTION_LEVEL__c, 
                                                    trm.CURRENT_SEGMENT_DESCR__c, trm.CHANGE_FLG__c, c.FirstName, c.LastName, emplidIn));    
                }
            }                  
        }
        
	// Break out of the method and return the rejected wrapper, which will display a "No data found" message to the user
        if (rejected.size() > 0) {
            return rejected;
        }
        
        if (dataList.size() > 0) {
            Integer startMonth = startDate.month();
            Integer endMonth = endDate.month();
        	persistenceLevel = dataList[dataList.size()-1].outlookLevel;
            if(currentTerm.subString(3).equals('1')){
                dataList[0].termInfo = 'Spring';
            } else if (currentTerm.subString(3).equals('4')) {
                dataList[0].termInfo = 'Summer';
            } else {
                dataList[0].termInfo = 'Fall';
            }
            
            
            for (Integer i = startMonth; i <= endMonth; i++) {
                String textMonth = monthToText(i);
                months.add(textMonth);
            }
            dataList[0].allMonths = months;
        }
        return dataList;
    }
    
    public String getInfo{
        get{
            Contact c = [Select Id, FirstName, LastName FROM Contact WHERE emplid__c =: emplid LIMIT 1];
            getInfo = 'Name: ' + c.FirstName + ' ' + c.LastName + ' Persistence Level: ' + persistenceLevel;
            
            
            return getInfo;
        }
        
        set;
    }
    
    
    private static string monthToText(Integer month){
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
    
    global class CivitasWrapper{
        public String empl;
        public String name;
        public Date snapDate;
        public Decimal outlookLevel;
        public Integer day;
        public String dayDate;
        public Integer year;
        public List<String> allMonths;
        public String levelDesc;
        public String fullDate;
        public String flag;
        public String termInfo;
        
        public civitasWrapper(String nameIn) {
            name = nameIn;
        }
        
        public civitasWrapper(Date sDate, Decimal oLevel, String description, String flagIn, String fName, String lName, String empIn){
            snapDate = sDate;
            empl = empIn;
            outlookLevel = oLevel;  
            String currMonth = monthToText(snapDate.month());
            name = fName + ' ' + lName;
            
            year = snapDate.year();
            day = snapDate.day()  + (30 * (snapDate.month()-1));
            dayDate = monthToText(snapDate.month()) + ' ' + snapDate.day();
            fullDate =  snapDate.month() + '/' + snapDate.day() + '/' + snapDate.year();
            levelDesc = description;
            flag = flagIn;
        }
        
    }
}
