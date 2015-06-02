@isTest
private class Test_DataComHierarchiesController 
{
    private static Account createAccount(Id DandBId)
    {
        Account newAccount = new Account(
            Name = 'TestAccount',
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'SF Mastered Org'].Id
        );
        
        if (DandBId != null)
        {
            newAccount.DandbCompanyId = DandBId;
        }
        
        insert newAccount;
        return newAccount;
    }
    
    private static DandBCompany createDandBCompany(String duns, String parentDuns)
    {
        DandBCompany newDandB = new DandBCompany(
            Name = duns,
            DunsNumber = duns,
            PrimarySicDesc = duns,
            ParentOrHqDunsNumber = parentDuns
        );
               
        insert newDandB;
        return newDandB;
    }

    private static DandBCompany createDandBCompany(String duns, String parentDuns, String globalDuns)
    {
        DandBCompany newDandB = new DandBCompany(
            Name = duns,
            DunsNumber = duns,
            PrimarySicDesc = duns,
            ParentOrHqDunsNumber = parentDuns,
            GlobalUltimateDunsNumber = globalDuns
        );
               
        insert newDandB;
        return newDandB;
    }
    
    private static testmethod void TestAccountNoDandB()
    {
        Account noDandBAcct = createAccount(null);
        DataComHierarchiesControllerExtension c = new DataComHierarchiesControllerExtension(noDandBAcct.Id);
        List<Map<String, Object>> hierarchies = c.getHierarchy();
        System.assert(hierarchies.size() == 0);
    }
    
    private static testmethod void TestAccountDandBParent()
    {
        DandBCompany parentCompany = createDandBCompany('1', '1', '1');
        DandBCompany childCompany1 = createDandBCompany('2', '1', '1');
        DandBCompany childCompany2 = createDandBCompany('3', '1', '1');
        
        Account acct = createAccount(parentCompany.Id);
        DataComHierarchiesControllerExtension c = new DataComHierarchiesControllerExtension(acct.Id);
        List<Map<String, Object>> hierarchies = c.getHierarchy();

        System.assert(hierarchies.size() == 3);
        System.assert(hierarchies[0].get('Name') == '1');
    }
    
    private static testmethod void TestAccountDandBChild()
    {
        DandBCompany parentCompany = createDandBCompany('1', '1', '1');
        DandBCompany childCompany1 = createDandBCompany('2', '1', '1');
        DandBCompany childCompany2 = createDandBCompany('3', '1', '1');
        
        Account acct = createAccount(childCompany1.Id);
        DataComHierarchiesControllerExtension c = new DataComHierarchiesControllerExtension(acct.Id);
        List<Map<String, Object>> hierarchies = c.getHierarchy();
        System.assert(hierarchies.size() == 3);
        System.assert(hierarchies[0].get('Name') == '1');
    }
    
    private static testmethod void TestAccountDandBChildWithoutParent()
    {
        DandBCompany childCompany = createDandBCompany('2', '1', '1');        
        Account acct = createAccount(childCompany.Id);
        
        DataComHierarchiesControllerExtension c = new DataComHierarchiesControllerExtension(acct.Id);
        List<Map<String, Object>> hierarchies = c.getHierarchy();
        System.assert(hierarchies.size() == 1);
        System.assert(hierarchies[0].get('Name') == '2');
    }

    private static testmethod void TestAccountWithGlobalDuns()
    {
        DandBCompany globalCompany = createDandBCompany('0', '0', '0');
        DandBCompany parentCompany = createDandBCompany('1', '0', '0');
        DandBCompany childCompany1 = createDandBCompany('2', '1', '0');
        DandBCompany childCompany2 = createDandBCompany('3', '1', '0');
        
        Account acct = createAccount(childCompany1.Id);
        DataComHierarchiesControllerExtension c = new DataComHierarchiesControllerExtension(acct.Id);
        List<Map<String, Object>> hierarchies = c.getHierarchy();
        System.assert(hierarchies.size() == 4);
        System.assert(hierarchies[0].get('Name') == '0');
    }

    private static testmethod void TestAccountWithoutGlobalDuns()
    {
        DandBCompany globalCompany = createDandBCompany('0', '0', '0');
        DandBCompany parentCompany = createDandBCompany('1', '1', '1');
        DandBCompany childCompany1 = createDandBCompany('2', '1', '1');
        DandBCompany childCompany2 = createDandBCompany('3', '1', '1');
        
        Account acct = createAccount(childCompany1.Id);
        DataComHierarchiesControllerExtension c = new DataComHierarchiesControllerExtension(acct.Id);
        List<Map<String, Object>> hierarchies = c.getHierarchy();
        System.assert(hierarchies.size() == 3);
        System.assert(hierarchies[0].get('Name') == '1');
    }

    private static testmethod void TestAccountGlobalDunsIncomplete()
    {
        DandBCompany globalCompany = createDandBCompany('0', '0', '0');
        DandBCompany childCompany1 = createDandBCompany('2', '1', '0');
        DandBCompany childCompany2 = createDandBCompany('3', '1', '0');
        
        Account acct = createAccount(childCompany1.Id);
        DataComHierarchiesControllerExtension c = new DataComHierarchiesControllerExtension(acct.Id);
        List<Map<String, Object>> hierarchies = c.getHierarchy();
        Map<Id, DandBCompany> allCompanies = c.getAllCompanies();
        System.debug(hierarchies);
        System.debug(allCompanies);
        System.assert(hierarchies.size() == 3);
        System.assert(hierarchies[0].get('Name') == '0');
    }

    private static testmethod void TestAccountMissingParent()
    {
        DandBCompany parentCompany = createDandBCompany('1', '1', '0');
        DandBCompany childCompany1 = createDandBCompany('2', '1', '0');
        DandBCompany childCompany2 = createDandBCompany('3', '1', '0');
        
        Account acct = createAccount(childCompany1.Id);
        DataComHierarchiesControllerExtension c = new DataComHierarchiesControllerExtension(acct.Id);
        List<Map<String, Object>> hierarchies = c.getHierarchy();
        System.assert(hierarchies.size() == 3);
        System.assert(hierarchies[0].get('Name') == '1'); 
    }
}