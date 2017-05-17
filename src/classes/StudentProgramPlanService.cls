public class StudentProgramPlanService
{
    public static List<PlanWrapper> planList;
    

    /**
    * Get the Student Program Plans for this contact
    * @param the contact Id
    * @return a list of Student Program Plans for that contact
    */
    public static List<Student_Program_Plan__c> getContactStudentProgramPlans(Id contactId)
    {
        String sPPFields = 
            'Status__c, Primary_Flag__c, Completion_Term__c, Plan_Type_Text__c, ' +
            'Plan_Description__c, Career__c, Program_Description__c, Degree__c';
                    
        String selectStudentPP = 'SELECT ' + sPPFields + ' ' +
                ', Campus__r.Name ' +
            'FROM Student_Program_Plan__c ' +
            'WHERE Contact__c = :contactId ' +
            'ORDER BY Status__c, Primary_Flag__c DESC, Completion_Term__c DESC, Plan_Type_Text__c, Plan_Description__c';
        
        List<Student_Program_Plan__c> sPPList = Database.query(selectStudentPP);
        
        // TODO: Re-factor the StudentProfileController to accept the wrapper class rather than the Student_Program_Plan__c
        // sObject. This will result in cleaner code, and allow us to eliminate some inefficiency here.
        
        planList = new List<PlanWrapper>();
        
        for (Student_Program_Plan__c plan : sPPList) {
            planList.add(new PlanWrapper(plan));
        }

        planList.sort();
        
        sPPList = new List<Student_Program_Plan__c>();
        
        for (PlanWrapper w : planList) {
            sPPList.add(w.plan);
        }
        
    	return sPPList;
    }

    /**
    * Get the Student Program Plans before today's date for this contact
    * @param the contact Id
    * @return a list of Student Program Plans for that contact
    */
    public static List<Student_Program_Plan__c> getContactStudentProgramPlansBeforeToday(
        Id contactId
    )
    {
        String sPPFields = 
            'Status__c, Primary_Flag__c, Completion_Term__c, Plan_Type_Text__c, ' +
            'Plan_Description__c, Career__c, Program_Description__c, Degree__c';
        
        List<Student_Program_Plan__c> programPlans = new List<Student_Program_Plan__c>();

        String selectStudentPP = 'SELECT ' + sPPFields + ' ' +
            ', Campus__r.Name ' +
            'FROM Student_Program_Plan__c ' +
            'WHERE Contact__c = :contactId ' +
            'AND Effective_Date__c <= TODAY ' +
            'ORDER BY Status__c, Primary_Flag__c DESC, Completion_Term__c DESC, Plan_Type_Text__c, Plan_Description__c';

        List<Student_Program_Plan__c> sPPList = Database.query(selectStudentPP);

        // TODO: Re-factor the StudentProfileController to accept the wrapper class rather than the Student_Program_Plan__c
        // sObject. This will result in cleaner code, and allow us to eliminate some inefficiency here.
        
        planList = new List<PlanWrapper>();
        
        for (Student_Program_Plan__c plan : sPPList) {
            planList.add(new PlanWrapper(plan));
        }

        planList.sort();
        
        sPPList = new List<Student_Program_Plan__c>();
        
        for (PlanWrapper w : planList) {
            sPPList.add(w.plan);
        }
        
    	return sPPList;
    }
    
    public class PlanWrapper implements Comparable {
        public Student_Program_Plan__c plan;
        
        public Map<String, Integer> planTypeMap = 
        	new Map<String, Integer>{'MAJ' => 0, 'MIN' => 1, 'CER' => 2};
        
        PlanWrapper(Student_Program_Plan__c p) {
            this.plan = p;
        }
        
        // Allows for sorting of the Program Plan list by Status ASC, Primary Flag DESC,
        // Completion Term ASC, Plan Type (MAJ, MIN, CER), and Plan Description (ASC).
        public Integer compareTo(Object compareTo) {
            PlanWrapper compareToPlan = (PlanWrapper)compareTo;
            
            if (this.plan.Status__c == compareToPlan.plan.Status__c) {
                if (this.plan.Primary_Flag__c == compareToPlan.plan.Primary_Flag__c) {
                    if (this.plan.Completion_Term__c == compareToPlan.plan.Completion_Term__c) {
                        if (this.plan.Plan_Type_Text__c == compareToPlan.plan.Plan_Type_Text__c) {
                            if (this.plan.Plan_Description__c == compareToPlan.plan.Plan_Description__c) {
                                return 0;
                            }
                            
                            if (this.plan.Plan_Description__c > compareToPlan.plan.Plan_Description__c) {
                                return 1;
                            }
                            
                            return -1;
                        }
                        
                        if (this.planTypeMap.get(this.plan.Plan_Type_Text__c) > this.planTypeMap.get(compareToPlan.plan.Plan_Type_Text__c)) {
                            return 1;
                        }
                        
                        return -1;
                    }
                    
                    if (this.plan.Completion_Term__c < compareToPlan.plan.Completion_Term__c) {
                        return 1;
                    }
                    
                    return -1;
                }
                         	
                if (String.valueOf(this.plan.Primary_Flag__c) < String.valueOf(compareToPlan.plan.Primary_Flag__c)) {
                    return 1;
                }
                
                return -1;
            }
            
            if (this.plan.Status__c > compareToPlan.plan.Status__c) {
                return 1;
            }
            
            return -1;
        }
    }
}