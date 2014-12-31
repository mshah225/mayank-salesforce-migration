global class CaseReplyTemplateSelector implements Support.EmailTemplateSelector {
    
    global CaseReplyTemplateSelector() {}
    
    global ID getDefaultEmailTemplateId(ID caseId) {
    
        List<EmailTemplate> templateList = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Case_Management_Default_Template'];

        if (templateList.size() > 0) {
            return templateList[0].Id;
        }   
        return null;
    }

}