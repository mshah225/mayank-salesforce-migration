public class DataComHierarchiesControllerExtension
{
    private final Account account;
    private Map<Id, DandBCompany> allCompanies;
    public List<Map<String, Object>> hierarchicalList;
    private Set<Id> DandBIds = new Set<Id>();
    private Integer key = 0;
    private Map<Id, Account> account_map = new Map<Id, Account>();
    public DataComHierarchiesControllerExtension(ApexPages.StandardController stdController)
    {
        this.account = (Account)stdController.getRecord();
        DataComHierarchiesControllerSetupAllCompanies();
        DataComHierarchiesControllerSetupHierarchies();
    }
    
    public DataComHierarchiesControllerExtension(String accountId)
    {
        this.account = [SELECT Id FROM Account WHERE Id = :accountId];
        DataComHierarchiesControllerSetupAllCompanies();
        DataComHierarchiesControllerSetupHierarchies();
    }
    
    public List<Map<String, Object>> getHierarchy()
    {
        return hierarchicalList;
    }
    
    public Map<Id, DandBCompany> getAllCompanies()
    {
        return allCompanies;
    }
    
    public void DataComHierarchiesControllerSetupAllCompanies()
    {
        if (allCompanies == null)
        {
            allCompanies = new Map<Id, DandBCompany>();
            
            List<DandBCompany> companies = [SELECT Id, Name, DunsNumber, ParentOrHqDunsNumber, GlobalUltimateDunsNumber, PrimarySicDesc FROM DandBCompany];
            List<Account> accounts_with_dandb = [SELECT Id, DandBCompanyId FROM Account WHERE DandBCompanyId != ''];

            for(Account a : accounts_with_dandb)
            {
                account_map.put(a.DandbCompanyId, a);
            }
            for (DandBCompany c : companies)
            {
                allCompanies.put(c.Id, c);    
            }
        }
    }
    
    public void DataComHierarchiesControllerSetupHierarchies()
    {
        Id DandBCompanyId = [SELECT DandbCompanyId FROM Account WHERE Id = :account.Id].DandbCompanyId;
        hierarchicalList = new List<Map<String, Object>>();
        
        if (DandBCompanyId != null)
        {
            DataComHierarchiesControllerGetHierarchiesFromDandB(DandBCompanyId);
        }
    }
        
    public void DataComHierarchiesControllerGetHierarchiesFromDandB(Id DandBCompanyId)
    {
        DandBCompany currentCompany = allCompanies.get(DandBCompanyId);
        if (currentCompany.DunsNumber != currentCompany.ParentOrHqDunsNumber || currentCompany.DunsNumber != currentCompany.GlobalUltimateDunsNumber)
        {
            if(currentCompany.DunsNumber != currentCompany.ParentOrHqDunsNumber)
            {
                String parentDunsNumber = currentCompany.ParentOrHqDunsNumber;
                
                //The current company is not the parent
                //Find the parent
                for (Id companyId : allCompanies.keySet())
                {
                    if (allCompanies.get(companyId).DunsNumber == parentDunsNumber)
                    {
                        DataComHierarchiesControllerGetHierarchiesFromDandB(companyId);
                        return; //This return is extremely important
                    }
                }
            }
            
            if(currentCompany.DunsNumber != currentCompany.GlobalUltimateDunsNumber)
            {
                String globalDunsNumber = currentCompany.GlobalUltimateDunsNumber;
            
                //The current company is not the parent
                //Find the parent
                for (Id companyId : allCompanies.keySet())
                {
                    if (allCompanies.get(companyId).DunsNumber == globalDunsNumber)
                    {
                        DataComHierarchiesControllerGetHierarchiesFromDandB(companyId);
                        return; //This return is extremely important
                    }
                }
                
                //If we somehow got here, this means that there is a subsidiary company with a DUNS that does not exist.
                System.debug(allCompanies);
                System.debug(DandBCompanyId);
                DataComHierarchiesControllerBuildHierarchies(DandBCompanyId, 0);
            }
        }
        else
        {
            //At this point we have found the complete parent
            //Now iterate down through the children
            System.debug(allCompanies);
            System.debug(DandBCompanyId);
            DataComHierarchiesControllerBuildHierarchies(DandBCompanyId, 0);
        }
    }
    
    public void DataComHierarchiesControllerBuildHierarchies(Id DandBCompanyId, Integer weight)
    {
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(allCompanies.get(DandBCompanyId)));
        m.put('weight', weight);
        if(account_map.get(DandBCompanyId) != null)
        {
            m.put('AccountId', account_map.get(DandBCompanyId).Id);
        }
        else
        {
            m.put('AccountId', '');
        }
        
        hierarchicalList.add(m);
        Boolean found = FALSE;
        
        for (Id companyId : allCompanies.keySet())
        {
            if (!DandBIds.contains(companyId) && allCompanies.get(companyId).ParentOrHqDunsNumber == m.get('DunsNumber') && allCompanies.get(companyId).DunsNumber != allCompanies.get(companyId).ParentOrHqDunsNumber)
            {
                DandBIds.add(companyId);
                DataComHierarchiesControllerBuildHierarchies(companyId, weight + 1);
            }
        }
        for(Id companyId : allCompanies.keySet())
        {
            if (!DandBIds.contains(companyId) && allCompanies.get(companyId).GlobalUltimateDunsNumber == m.get('DunsNumber') && allCompanies.get(companyId).DunsNumber != allCompanies.get(companyId).GlobalUltimateDunsNumber)
            {
                DandBIds.add(companyId);
                DataComHierarchiesControllerBuildHierarchies(companyId, weight + 1);
            }
        }
    }
}