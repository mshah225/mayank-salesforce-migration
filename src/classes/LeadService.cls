public class LeadService
{
    /**
    * Generates a test lead
    * @return Lead a Lead with dummy data
    */
    public static Lead createTestLead()
    {
        Lead testLead = new Lead();
        testLead.FirstName = 'Jonny';
        testLead.LastName = 'Test';
        testLead.Email = 'test@nomail.com';
        testLead.Company = 'Test Company';
        return testLead;
    }

    /**
    * Generates a set of test leads to convert
    * @param List<Contact> a set of Contacts to convert to
    * @return List<Lead> a list of test lead data
    */
    public static List<Lead> createTestLeadsToConvert(List<Contact> contactsToConvertOn)
    {
        List<Lead> leads = new List<Lead>();

        for (Contact con : contactsToConvertOn)
        {
            Lead testLead = new Lead();
            testLead.FirstName = con.FirstName;
            testLead.LastName = con.LastName;
            testLead.Email = con.Email;
            testLead.LeadSource = 'Email';
            testLead.Company = 'TestCompany';
            testLead.Career__c = 'Undergraduate';
            testLead.Online__c = true;
            testLead.International_Student__c = true;
            testLead.First_Generation__c = true;
            testLead.Potential_National_Scholar__c = true;
            testLead.Potential_WUE__c = true;
            testLead.Search_Segment__c = 'Scholar';
            testLead.Self_Reported_SES__c = 'Moderate';
            testLead.Veteran_Status__c = 'Veteran';
            testLead.Convert_Contact__c = con.Id;

            leads.add(testLead);
        }

        return leads;
    }
}