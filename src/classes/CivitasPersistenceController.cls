public class CivitasPersistenceController{

    public static List<String> months = new List<String>();
	public static Integer dayValue = 0;
    
    public static List<civitasWrapper> dataList {set; get;}
    
    /*public string emplid{
        set;
        
        get{
            emplid = '1206104779'; 
            return emplid;
        }
    }*/
    
    public static string currentTerm{
        set;
        
        get{
            if(currentTerm == null){
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
                currentTerm = currentTermInfo.CURR_TERM__c;
                if(currentTerm.length() > 4){
                    currentTerm = currentTerm.subString(1, 5);
                }
            }
            return currentTerm;
        }
    }
    
    public static string nextTerm{
        set;
        
        get{
            if(nextTerm == null){
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
                if(nextTerm.length() > 4){
                    nextTerm = nextTerm.subString(1, 5);
                }
            }
            return nextTerm;
        }
    }
    
    public static Date startDate{
        set;
        
        get{
            if(startDate == null){
                startDate = [Select Session_A_C_Start_Date__c 
                             FROM Term__c 
                             WHERE PeopleSoft_Code__c =: currentTerm
                             LIMIT 1].Session_A_C_Start_Date__c;
                startDate = startDate.addDays(21);
            }
            return startDate;
        }
    }
    
    public static Date endDate{
        set;
        
        get{
            if(endDate == null){
                endDate = [Select Session_A_C_Start_Date__c 
                             FROM Term__c 
                             WHERE PeopleSoft_Code__c =: nextTerm
                             LIMIT 1].Session_A_C_Start_Date__c;
                endDate = endDate.addDays(21);
            }
            return endDate;
        }
    }
    
    /*public List<CV_ASU_STDNT_TERM__x> dateList{
        set;
        
        get{
            if(dateList == null){
                dateList = new List<CV_ASU_STDNT_TERM__x>();
                for(CV_ASU_STDNT_TERM__x trm : [Select SNAP_DATE__c, CURR_CONT_PREDICTION_LEVEL__c	
                                                FROM CV_ASU_STDNT_TERM__x 
                                                WHERE Contact__c =: emplid
                                                ORDER BY SNAP_DATE__c ASC]) {
                    if(trm.SNAP_DATE__c >= startDate && trm.SNAP_DATE__c <= endDate){
                          dateList.add(trm);                              
                    }                  
                }
            }
            return dateList;
        }
    }
    public static getData(){
        for(CV_ASU_STDNT_TERM__x trm : [Select SNAP_DATE__c, CURR_CONT_PREDICTION_LEVEL__c	
                                        FROM CV_ASU_STDNT_TERM__x 
                                        WHERE Contact__c =: emplid
                                        ORDER BY SNAP_DATE__c ASC]) {
            if(trm.SNAP_DATE__c >= startDate && trm.SNAP_DATE__c <= endDate){
                  dataList.add(new civitasWrapper(trm.Snap_Date__c, trm.CURR_CONT_PREDICTION_LEVEL__c));                              
            }                  
        }
    }*/
    
    @RemoteAction
    public static List<civitasWrapper> getData(String emplid){
        dataList = new List<civitasWrapper>();
        Date newYear = Date.today();
        newYear = newYear.addDays(-(newYear.day() + (newYear.month()-1) * 30));
        
        for(CV_ASU_STDNT_TERM__x trm : [
            Select SNAP_DATE__c, CURR_CONT_PREDICTION_LEVEL__c,	CURRENT_SEGMENT_DESCR__c, CHANGE_FLG__c  
            FROM CV_ASU_STDNT_TERM__x 
            WHERE Contact__c =: emplid
            ORDER BY SNAP_DATE__c ASC
        ]) {
            if(trm.SNAP_DATE__c >= startDate && trm.SNAP_DATE__c <= endDate){
                  dataList.add(new civitasWrapper(trm.Snap_Date__c, trm.CURR_CONT_PREDICTION_LEVEL__c, trm.CURRENT_SEGMENT_DESCR__c, trm.CHANGE_FLG__c ));                              
            }                  
        }
        
        if(dataList.size() > 0){
            dataList[0].allMonths = months;
        }
        
        return dataList;
    }
    
    public class civitasWrapper{
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
            
            if(months == null){
                months.add(currMonth);
            }
            
            else{
                Boolean found = false;
                
                for(String m : months){
                    if(m.equals(currMonth)){
                        found = true;
                    }
                }
                
                if(!found){
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
            if(month == 1){
                return 'Jan';
            }
            else if(month == 2){
                return 'Feb';
            }
            else if(month == 3){
                return 'Mar';
            }
            else if(month == 4){
                return 'Apr';
            }
            else if(month == 5){
                return 'May';
            }
            else if(month == 6){
                return 'Jun';
            }
            else if(month == 7){
                return 'Jul';
            }
            else if(month == 8){
                return 'Aug';
            }
            else if(month == 9){
                return 'Sep';
            }
            else if(month == 10){
                return 'Oct';
            }
            else if(month == 11){
                return 'Nov';
            }
            else if(month == 12){
                return 'Dec';
            }
            else{
                return 'Error';
            }
        }
    }
}