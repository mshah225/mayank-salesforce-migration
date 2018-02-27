global class CivitasPersistenceController{

    global static List<String> months = new List<String>();
	global static Integer dayValue = 0;
    global static List<CivitasWrapper> dataList {get; set;}
    global static String emplId {get; set;}
    global static Decimal persistenceLevel;
    global static Contact c;

    public static String currentTerm{
        get{
            if (currentTerm == null) {
                StudentTerm__c currentTermData = StudentTerm__c.getOrgDefaults();
                currentTerm = currentTermData.CurrTerm__c;
                nextTerm = currentTermData.NextTerm__c; 
                prevTerm = currentTermData.PrevTerm__c;
            }
            return currentTerm;
        }

        set;
    }

    public static String nextTerm{ get; set;}

    public static String prevTerm { get; set;}
    
    public static Date startDate{
        get{
            if (startDate == null) {
                startDate = [Select Session_A_C_Start_Date__c
                             FROM Term__c
                             WHERE PeopleSoft_Code__c =: currentTerm
                             LIMIT 1].Session_A_C_Start_Date__c;
                startDate = startDate.addDays(22);
            }
            if(startDate >= Date.today()) {
                endDate = startDate.addDays(-22);
                startDate = [Select Session_A_C_Start_Date__c 
                             FROM Term__c 
                             WHERE PeopleSoft_Code__c =: prevTerm
                             LIMIT 1].Session_A_C_Start_Date__c;
                startDate = startdate.addDays(22);
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
            }
            return endDate;
        }
        set;
        }

    @RemoteAction
    global static List<CivitasWrapper> getData(String emplidIn){
        try {
            if(emplidIn != null && emplidIn.substring(0,3).equals('003')) {
                emplidIn = [Select EMPLID__c FROM Contact Where Id =: emplidIn LIMIT 1].EMPLID__c;
            } else if (emplidIn == null) {
                return null;
            }
        }
        catch (Exception e){ 
            return null;
        }
        dataList = new List<CivitasWrapper>();
        List<CivitasWrapper> rejected = new List<CivitasWrapper>();
        Contact c = [Select Id, FirstName, LastName FROM Contact WHERE emplid__c =: emplidIn LIMIT 1];
        CV_ASU_STDNT_TERM__x prevData;
        Integer dateIncr = startDate.day();
        CV_ASU_STDNT_TERM__x startSemesterData;
        for (CV_ASU_STDNT_TERM__x trm : [
            Select SNAP_DATE__c, CURR_CONT_PREDICTION_LEVEL__c,	CURRENT_SEGMENT_DESCR__c, CHANGE_FLG__c, ONLINE_SEGMENT__c, CAREER_SEGMENT__c
            FROM CV_ASU_STDNT_TERM__x
            WHERE Contact__c =: emplIdIn
            ORDER BY SNAP_DATE__c ASC
        ]) {
            //Checks if it's not in persson OR not an undergrad.
            if(trm.Snap_Date__c < startDate) {
                startSemesterData = trm;
            }
            if (trm.SNAP_DATE__c >= startDate && trm.SNAP_DATE__c <= endDate) {
                if (trm.ONLINE_SEGMENT__c != 'N' || trm.CAREER_SEGMENT__c != 'U') {
                    rejected.add(new CivitasWrapper('Rejected'));
                } else {
                    if(trm.Snap_Date__c > startDate && startSemesterData != null) {
                        Date tempStart = startDate;
                        while(tempStart < trm.Snap_Date__c) {
                            dataList.add(new CivitasWrapper(tempStart, startSemesterData.CURR_CONT_PREDICTION_LEVEL__c,
                                         startSemesterData.CURRENT_SEGMENT_DESCR__c, startSemesterData.CHANGE_FLG__c,  c.FirstName, c.LastName, emplidIn, dateIncr, c.Id));
                            dateIncr++;
                            tempStart = tempStart.addDays(1);
                        }
                        startSemesterData = null;
                    }
                    if(prevData == null) {
                        prevData = trm;
                    }
                    Date prevDate = prevData.Snap_Date__c;
                    prevDate = prevDate.addDays(1);
                    while(prevDate < trm.Snap_Date__c) {
                        dataList.add(new CivitasWrapper(prevDate, prevData.CURR_CONT_PREDICTION_LEVEL__c,
                                                    prevData.CURRENT_SEGMENT_DESCR__c, prevData.CHANGE_FLG__c, c.FirstName, c.LastName, emplidIn, dateIncr, c.Id));
                        dateIncr++;
                        prevDate = prevDate.addDays(1);
                    }
                    dataList.add(new CivitasWrapper(trm.SNAP_DATE__c, trm.CURR_CONT_PREDICTION_LEVEL__c,
                                                    trm.CURRENT_SEGMENT_DESCR__c, trm.CHANGE_FLG__c, c.FirstName, c.LastName, emplidIn, dateIncr, c.Id));
                    dateIncr++;
                }

                prevData = trm;
            }
        }

        if(rejected.size() > 0){
            return rejected;
        }

        if (dataList.size() > 0) {
            CivitasWrapper tmpEndPoint = dataList[dataList.size()-1];
            Integer dayValue = tmpEndPoint.day;
            while (tmpEndPoint.snapDate < endDate) {
                tmpEndPoint.snapDate = tmpEndPoint.snapDate.addDays(1);
                dayValue++;
                dataList.add(new CivitasWrapper(tmpEndPoint.snapDate, tmpEndPoint.outlookLevel,
                                                    tmpEndPoint.levelDesc, tmpEndPoint.flag, c.FirstName, c.LastName, emplidIn, dayValue, c.Id));
            }
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


            for (Integer i = startMonth; i <= endMonth+12; i++) {
                String textMonth = monthToText(Math.mod(i, 12));
                months.add(textMonth);
            }
            dataList[0].allMonths = months;
        }
        return dataList;
    }

    public String getInfo{
        get{
            emplid = apexpages.currentPage().getparameters().get('contactId');
            if (String.isEmpty(emplid)) {
                getInfo = Label.EMPLIDMissing;
                return getInfo;
            }
            List<Contact> contactList = new List<Contact>();
            if (emplid.substring(0, 3).equals('003')) {
                contactList = [Select Id, FirstName, LastName, emplid__c FROM Contact WHERE id =: emplid LIMIT 1];
            } else {
            	contactList = [Select Id, FirstName, LastName, emplid__c FROM Contact WHERE emplid__c =: emplid LIMIT 1];
            }
            if (!contactList.isEmpty()) {
            	getInfo = 'Name: ' + contactList[0].FirstName + ' ' + contactList[0].LastName + ' (' + emplid + ') Persistence Level: No Data Available';
            } else {
            	getInfo = Label.EMPLIDMissing; 
            }
            
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
        } else if(month == 0 || month == 12) {
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
        public String direction;
        public String prevDate;
        public String contactId;

        public civitasWrapper(String nameIn) {
            name = nameIn;
        }

        public civitasWrapper(Date sDate, Decimal oLevel, String description, String flagIn, String fName, String lName, String empIn, Integer valueIn, Id contactIdIn){
            snapDate = sDate;
            empl = empIn;
            outlookLevel = oLevel;
            String currMonth = monthToText(snapDate.month());
            name = fName + ' ' + lName;
            contactId = contactIdIn;

            year = snapDate.year();
            day = valueIn;
            dayDate = monthToText(snapDate.month()) + ' ' + snapDate.day();
            fullDate =  snapDate.month() + '/' + snapDate.day() + '/' + snapDate.year();
            levelDesc = description;

            flag = flagIn;
        }

    }
}