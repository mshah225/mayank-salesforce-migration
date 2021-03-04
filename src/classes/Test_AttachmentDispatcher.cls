@isTest
public class Test_AttachmentDispatcher {
    @testSetup
    static void setup() {
        List<SObject> attachments = new List<SObject>();
        List<Case> parentCases = new List<Case>();
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        Account parentAccount = TestDataFactory.createAccount('Test Account');

        // Create Grandparents
        for (Case c : TestDataFactory.createCases(6)) {
            parentCases.add(c);
        }

        insert parentCases;

        // Create Parents
        // case with emails with attachments
        for (EmailMessage em : TestDataFactory.createEmailMessages(3, parentCases[0].Id)) {
            emailMessages.add(em);
        }

        // case with attachments and emails with attachments
        for (EmailMessage em : TestDataFactory.createEmailMessages(3, parentCases[1].Id)) {
            emailmessages.add(em);
        }

        // case with emails without attachments
        for (EmailMessage em : TestDataFactory.createEmaiLMessages(3, parentCases[2].Id)) {
            emailmessages.add(em);
        }

        // case with attachments and emails without attachments
        for (EmailMessage em : TestDataFactory.createEmaiLMessages(3, parentCases[3].Id)) {
            emailmessages.add(em);
        }

        insert emailMessages;
        insert parentAccount;

        // Create Children
        // case with attachments and emails with attachments
        for (Attachment a : TestDataFactory.createAttachments(3, parentCases[1].Id)) {
            attachments.add(a);
        }

        // case with attachments and emails without attachments
        for (Attachment a : TestDataFactory.createAttachments(3, parentCases[3].Id)) {
            attachments.add(a);
        }

        // Case with attachments
        for (Attachment a : TestDataFactory.createAttachments(3, parentCases[4].Id)) {
            attachments.add(a);
        }

        // account with attachments
        for (Attachment a : TestDataFactory.createAttachments(3, parentAccount.Id)) {
            attachments.add(a);
        }

        // Email messages with attachments
        for (EmailMessage em : emailMessages) {
            if (em.parentId == parentCases[0].Id || em.parentId == parentCases[1].Id) {
                for (Attachment a : TestDataFactory.createAttachments(3, em.Id)) {
                    attachments.add(a);
                }
            }
        }
        insert attachments;
    }

    /**
     * SFE-5455 Tests dispatcher/trigger/services ability to update Attachments__c
     * field on cases when attachments are added or deleted from the case
     */
    public static testMethod void Test_VerifyCaseNumberOfFiles() {
        // Get all cases
        List<Attachment> attachments = [SELECT Id FROM Attachment];
        List<Case> cases = [SELECT Id, Attachments__c FROM Case];
        Integer hasAttachmentCount = 0;
        Integer doesNotHaveAttachmentCount = 0;

        for (Case c : cases) {
            if (c.Attachments__c != null) {
                if (integer.valueOf(c.Attachments__c) > 0) {
                    hasAttachmentCount = hasAttachmentCount + 1;
                } else {
                    doesNotHaveAttachmentCount = doesNotHaveAttachmentCount + 1;
                }
            } else {
                doesNotHaveAttachmentCount = doesNotHaveAttachmentCount + 1;
            }
        }

        system.assertEquals(4, hasAttachmentCount);
        system.assertEquals(2, doesNotHaveAttachmentCount);

        delete attachments;

        cases = [SELECT Id, Attachments__c FROM Case];
        hasAttachmentCount = 0;
        doesNotHaveAttachmentCount = 0;

        for (Case c : cases) {
            if (c.Attachments__c != null) {
                if (integer.valueOf(c.Attachments__c) > 0) {
                    hasAttachmentCount = hasAttachmentCount + 1;
                } else {
                    doesNotHaveAttachmentCount = doesNotHaveAttachmentCount + 1;
                }
            } else {
                doesNotHaveAttachmentCount = doesNotHaveAttachmentCount + 1;
            }
        }

        system.assertEquals(0, hasAttachmentCount);
        system.assertEquals(6, doesNotHaveAttachmentCount);

        undelete attachments;

        cases = [SELECT Id, Attachments__c FROM Case];
        hasAttachmentCount = 0;
        doesNotHaveAttachmentCount = 0;

        for (Case c : cases) {
            if (c.Attachments__c != null) {
                if (integer.valueOf(c.Attachments__c) > 0) {
                    hasAttachmentCount = hasAttachmentCount + 1;
                } else {
                    doesNotHaveAttachmentCount = doesNotHaveAttachmentCount + 1;
                }
            } else {
                doesNotHaveAttachmentCount = doesNotHaveAttachmentCount + 1;
            }
        }

        system.assertEquals(4, hasAttachmentCount);
        system.assertEquals(2, doesNotHaveAttachmentCount);

        for (Integer x = 0; x < attachments.size(); x++) {
            attachments[x].name = string.valueOf(x);
        }

        update attachments;

        // verify that updating attachments has no impact
        cases = [SELECT Id, Attachments__c FROM Case];
        hasAttachmentCount = 0;
        doesNotHaveAttachmentCount = 0;

        for (Case c : cases) {
            if (c.Attachments__c != null) {
                if (integer.valueOf(c.Attachments__c) > 0) {
                    hasAttachmentCount = hasAttachmentCount + 1;
                } else {
                    doesNotHaveAttachmentCount = doesNotHaveAttachmentCount + 1;
                }
            } else {
                doesNotHaveAttachmentCount = doesNotHaveAttachmentCount + 1;
            }
        }

        system.assertEquals(4, hasAttachmentCount);
        system.assertEquals(2, doesNotHaveAttachmentCount);
    }
}
