public without sharing class MyASUHelpEmailService {

    public static Case submitCase(Case newCase, Contact userContact) {
        String carId = Label.MyASU_ContactUs_CAR;         

        Case_Assignment_Rule__c carRule = [
            SELECT Origin__c, CC_Functional_Group__c, CC_Category__c, Email_Template_ID__c, Reply_To_Email_Address__c
            FROM Case_Assignment_Rule__c
            WHERE Id =: carId
        ];

        newCase.ContactId = userContact.Id;
        newCase.Web_Submission__c = 'My ASU Standard';
        newCase.Origin = carRule.Origin__c;
        newCase.CC_Functional_Group__c = carRule.CC_Functional_Group__c;
        newCase.CC_Category__c = carRule.CC_Category__c;

        try {
            insert newCase;
            sendEmailOnCaseSubmition(carRule, newCase);
            return newCase;
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add('');
            ErrorLogger.log(e, vars, false);
            return null;
        }
    }
    
    public static void sendEmailOnCaseSubmition(Case_Assignment_Rule__c car, Case newlyCreatedCase) {
        OrgWideEmailAddress oweaToUse = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :car.Reply_To_Email_Address__c];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(car.Email_Template_ID__c);
        mail.setWhatId(newlyCreatedCase.Id);
        mail.setTargetObjectId(newlyCreatedCase.ContactId);
        mail.setOrgWideEmailAddressId(oweaToUse.Id);
        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}