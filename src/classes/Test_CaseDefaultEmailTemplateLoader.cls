@isTest
public class Test_CaseDefaultEmailTemplateLoader 
{
	public static void createSetting(User u, String name, String template_name, String functionalGroup) 
	{
        System.runAs(u) 
        {
            Case_Default_Email_Templates__c conf = new Case_Default_Email_Templates__c();
            conf.Name = name;
            conf.Functional_Group__c = functionalGroup;
            conf.Template_Name__c = template_name;
        
            insert conf;
        }
    }
    public static ID createTemplate(User u, String name) 
    {
        EmailTemplate template = new EmailTemplate();
        template.FolderId = u.Id;
        template.TemplateType = 'text';
		template.DeveloperName = name;
		template.Name= 'Test name';
        template.Subject = 'Test Subject';
        template.Body = 'Hello This is test body';
        template.isActive = true;
        
        insert template;
        
		return template.id;
    }
    public static ID createCase(User u, String functionalGroup) 
    {
        Case testCase;
        
        System.runAs(u) 
        {
            testCase = new Case();
            testCase.Functional_Group__c = functionalGroup;
            testCase.Origin = 'Email';
            insert testCase;
        }

        return testCase.Id;
    }
    
    public static testmethod void testSmartLoader() 
    {
        User u = [SELECT id,name FROM User WHERE id = :userInfo.getUserid()];
        Id t1 = createTemplate(u, 'Financial_Aid_Default');
        Id t2 = createTemplate(u, 'Registrar_Default');
        Id t3 = createTemplate(u, 'Engineering_Default');
        Id t4 = createTemplate(u, 'template_default');

        createSetting(u, '1', 'Financial_Aid_Default', 'Financial Aid');
        createSetting(u, '2', 'Registrar_Default', 'Registrar');
        createSetting(u, '3', 'Engineering_Default', 'Engineering');
        createSetting(u, 'Default', 'template_default', '');
        
        Id c1 = createCase(u, 'Financial Aid');
        Id c2 = createCase(u, 'Registrar');
        Id c3 = createCase(u, 'Engineering');
        Id c4 = createCase(u, 'Help Desk');

        
        CaseDefaultEmailTemplateLoader loader = new CaseDefaultEmailTemplateLoader();
        
        Id res;
        res = loader.getDefaultEmailTemplateId(c1);
        System.assertEquals(true, res == t1);
        res = loader.getDefaultEmailTemplateId(c2);
        System.assertEquals(true, res == t2);
        res = loader.getDefaultEmailTemplateId(c3);
        System.assertEquals(true, res == t3);
        res = loader.getDefaultEmailTemplateId(c4);
        System.assertEquals(true, res == t4);
    }
}