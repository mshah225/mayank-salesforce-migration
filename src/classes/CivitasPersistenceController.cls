public class CivitasPersistenceController{

    public string emplid{
        set;
        
        get{
            emplid = '1206104779'; 
            return emplid;
        }
    }
    
    public string currentTerm{
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
    
    public string nextTerm{
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
    
    public Date startDate{
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
    
    public Date endDate{
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
    
    public List<CV_ASU_STDNT_TERM__x> dateList{
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
}