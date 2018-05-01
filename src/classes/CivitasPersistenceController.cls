public class CivitasPersistenceController {    
    private static final Integer CENSUS_OFFSET = 22;
    private static String emplId;
    private Integer endMonth;
    private String nextTerm;
    private String prevTerm;
    private String currentTerm;
    private Integer startMonth;
    
    public List<String> months = new List<String>();
    public static Integer dayValue = 0;
    public static List<CivitasWrapper> dataList { get; set; }
    public static final Date TODAY = System.today();
    
    private String contactEmplId;
    
    public List<CivitasWrapper> civitasData { get; set; }
    
    public CivitasPersistenceController() {
        StudentTerm__c currentTermData = StudentTerm__c.getOrgDefaults();
        currentTerm = currentTermData.CurrTerm__c;
        nextTerm = currentTermData.NextTerm__c; 
        prevTerm = currentTermData.PrevTerm__c;
        contactEmplId = ApexPages.currentPage().getParameters().get('contactId');
        civitasData = getCivitasData();
    }
    
    public String civitasDataInJson { get 
        {
            return Json.serialize(civitasData, true);
        }
        set;
    }
    
    public String getInfo {
        get {
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
    
    public Date startDate {
        get {
            if (startDate == null) {
                startDate = [SELECT Session_A_C_Start_Date__c
                    FROM Term__c
                    WHERE PeopleSoft_Code__c =: currentTerm
                    LIMIT 1
                ].Session_A_C_Start_Date__c;
                startMonth = startDate.month();
                startDate = startDate.addDays(CENSUS_OFFSET);
                modifyDatesIfTodayIsBeforeCensusDate();
            }
            return startDate;
        }
        set;
    }
    
    private void modifyDatesIfTodayIsBeforeCensusDate() {
        if (startDate >= TODAY) {
                endMonth = startDate.month();
                endDate = startDate.addDays(CENSUS_OFFSET*-1);
                startDate = [Select Session_A_C_Start_Date__c 
                             FROM Term__c 
                             WHERE PeopleSoft_Code__c =: prevTerm
                             LIMIT 1].Session_A_C_Start_Date__c;
                startMonth = startDate.month();
                startDate = startdate.addDays(CENSUS_OFFSET);
        }
    }

    public Date endDate {
        get {
            if (endDate == null) {
                endDate = [SELECT Session_A_C_Start_Date__c
                    FROM Term__c
                    WHERE PeopleSoft_Code__c =: nextTerm
                    LIMIT 1
                ].Session_A_C_Start_Date__c;
                endDate = endDate.addDays(CENSUS_OFFSET);
                endMonth = endDate.month();
            }
            return endDate;
        }
        set;
    }

    private List<CivitasWrapper> getCivitasData() {
        civitasData = new List<CivitasWrapper>();
        List<CivitasWrapper> rejected = new List<CivitasWrapper>();
        Contact thisContact = [Select Id, FirstName, LastName, EmplId__c FROM Contact WHERE EmplId__c = :contactEmplId LIMIT 1];
        Persistence_Outlook__c prevData;
        Integer dateIncr = startDate.day();
        for (Persistence_Outlook__c outlook : [SELECT 
                Change_Date__c, Change_Direction__c,
                Curr_Cont_Prediction_Level__c, Prev_Cont_Prediction_Level__c, 
                Career_Segment__c, Current_Flag__c, Current_Level_Descr__c, 
                Online_Segment__c, Prediction_STRM__c, Snap_Date__c,
                Change_Flg__c
            FROM Persistence_Outlook__c
            WHERE Contact__c = :thisContact.Id
            ORDER BY Snap_Date__c ASC 
        ]) {
            Persistence_Outlook__c trm = new Persistence_Outlook__c(
                Snap_Date__c = outlook.Snap_Date__c,
                Curr_Cont_Prediction_Level__c = outlook.Curr_Cont_Prediction_Level__c,
                Current_Level_Descr__c = outlook.Current_Level_Descr__c,
                Change_Flg__c = outlook.Change_Flg__c,
                Online_Segment__c = outlook.Online_Segment__c,
                Career_Segment__c = outlook.Career_Segment__c
            );
            System.debug(trm);
            Persistence_Outlook__c startSemesterData;
            if (trm.Snap_Date__c < startDate) {
                startSemesterData = trm;
            }
            if (trm.Snap_Date__c >= startDate && trm.Snap_Date__c <= endDate) {
                if (trm.Snap_Date__c > startDate && startSemesterData != null) {
                    Date tempStart = startDate;
                    while (tempStart < trm.Snap_Date__c) {
                        civitasData.add(new CivitasWrapper(thisContact, tempStart, startSemesterData.Curr_Cont_Prediction_Level__c, startSemesterData.Current_Level_Descr__c, startSemesterData.Change_Flg__c, dateIncr));
                        dateIncr++;
                        tempStart = tempStart.addDays(1);
                    }
                    startSemesterData = null;
                }
                if (prevData == null) {
                    prevData = trm;
                }
                Date prevDate = prevData.Snap_Date__c;
                prevDate = prevDate.addDays(1);
                while (prevDate < trm.Snap_Date__c) {
                    civitasData.add(new CivitasWrapper(thisContact, prevDate, prevData.Curr_Cont_Prediction_Level__c, prevData.Current_Level_Descr__c, prevData.Change_Flg__c, dateIncr));
                    dateIncr++;
                    prevDate = prevDate.addDays(1);
                }
                civitasData.add(new CivitasWrapper(thisContact, trm.Snap_Date__c, trm.Curr_Cont_Prediction_Level__c, trm.Current_Level_Descr__c, trm.Change_Flg__c, dateIncr));
                dateIncr++;
            }

            prevData = trm;
        }
        
        if (rejected.size() > 0) {
            return rejected;
        }

        if (civitasData.size() > 0) {
            CivitasWrapper tmpEndPoint = civitasData[civitasData.size()-1];
            System.debug(tmpEndPoint.levelDesc);
            String lastUpdatedDate = civitasData[civitasData.size()-1].fullDate;
            Integer dayValue = tmpEndPoint.day;
            while ((endDate < TODAY && tmpEndPoint.snapDate < endDate) || tmpEndPoint.snapDate < TODAY) {
                tmpEndPoint.snapDate = tmpEndPoint.snapDate.addDays(1);
                dayValue++;
                Boolean flagVal = tmpEndPoint.flag == 'Y' ? true : false;
                civitasData.add(new CivitasWrapper(tmpEndPoint.snapDate, tmpEndPoint.outlookLevel, tmpEndPoint.levelDesc, flagVal, thisContact.FirstName, thisContact.LastName, thisContact.EmplId__c, dayValue, thisContact.Id));
            }
            civitasData[civitasData.size()-1].fullDate = lastUpdatedDate;
            
            Decimal persistenceLevel = civitasData[civitasData.size()-1].outlookLevel;
            if (currentTerm.subString(3).equals('1')) {
                civitasData[0].termInfo = 'Spring';
            } else if (currentTerm.subString(3).equals('4')) {
                civitasData[0].termInfo = 'Summer';
            } else {
                civitasData[0].termInfo = 'Fall';
            }

            if (endMonth < startMonth) {
                endMonth += 12;
            }
            for (Integer i = startMonth; i <= endMonth; i++) {
                String textMonth = monthToText(Math.mod(i, 12));
                months.add(textMonth);
            }
            civitasData[0].allMonths = months;
        }
           
        return civitasData;
    }
    
    private static String monthToText(Integer month) {
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

    public class CivitasWrapper {
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

        public CivitasWrapper(String nameIn) {
            name = nameIn;
        }

        public CivitasWrapper(Date snapeDate, Decimal outlookLevel, String levelDesc, Boolean flag, String firstName, String lastName, String empl, Integer day, Id contactId){
            this.snapDate = snapeDate;
            this.empl = empl;
            this.outlookLevel = outlookLevel;
            String currMonth = CivitasPersistenceController.monthToText(snapDate.month());
            name = firstName + ' ' + lastName;
            this.contactId = contactId;

            year = snapDate.year();
            this.day = day;
            dayDate = CivitasPersistenceController.monthToText(snapDate.month()) + ' ' + snapDate.day();
            fullDate =  snapDate.month() + '/' + snapDate.day() + '/' + snapDate.year();
            this.levelDesc = levelDesc;
            this.flag = flag == true ? 'Y' : 'N';
        }
        
        public CivitasWrapper(Contact contactDetails, Date snapeDate, Decimal outlookLevel, String levelDesc, Boolean flag, Integer day){
            this.snapDate = snapeDate;
            this.empl = contactDetails.EmplId__c;
            this.outlookLevel = outlookLevel;
            String currMonth = CivitasPersistenceController.monthToText(snapDate.month());
            name = contactDetails.FirstName + ' ' + contactDetails.LastName;
            this.contactId = contactDetails.Id;

            year = snapDate.year();
            this.day = day;
            dayDate = CivitasPersistenceController.monthToText(snapDate.month()) + ' ' + snapDate.day();
            fullDate =  snapDate.month() + '/' + snapDate.day() + '/' + snapDate.year();
            this.levelDesc = levelDesc;
            this.flag = flag == true ? 'Y' : 'N';
        }
    }
}