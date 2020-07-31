public with sharing class MyASUHelpFAQController {
    public List<FAQ__kav> topThreeFinancialArticles;
    public List<FAQ__kav> topThreeTechnicalArticles;
    public List<FAQ__kav> topThreeHousingArticles;
    public String viewAllFinanceArticlesUrl;
    public String viewAllTechnicalArticlesUrl;

    public MyASUHelpFAQController() {
        setTopThreeFinancialArticles();
        setTopThreeTechnicalArticles();
        setTopThreeHousingArticles();
    }

    public List<FAQ__kav> getTopThreeFinancialArticles() {
        return topThreeFinancialArticles;
    }

    public List<FAQ__kav> getTopThreeTechnicalArticles() {
        return topThreeTechnicalArticles;
    }

    public List<FAQ__kav> getTopThreeHousingArticles() {
        return topThreeHousingArticles;
    }

    private void setTopThreeFinancialArticles() {
        try {
            topThreeFinancialArticles = [
                SELECT Id, Title, UrlName
                FROM FAQ__kav
                WHERE IsDeleted = false AND Functional_Group__c = 'Financial Aid'
                ORDER BY ArticleTotalViewCount DESC
                LIMIT 5
            ];
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(
                ErrorLogger.convertStringToJSON(
                    'topThreeFinancialArticles',
                    'There was an error setting the top five financial articles for My ASU Help'
                )
            );
            ErrorLogger.log(e, vars, false);
        }
    }

    private void setTopThreeTechnicalArticles() {
        try {
            topThreeTechnicalArticles = [
                SELECT Id, Title, UrlName
                FROM FAQ__kav
                WHERE IsDeleted = false AND Functional_Group__c LIKE '%Technical Resources%'
                ORDER BY ArticleTotalViewCount DESC
                LIMIT 5
            ];
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(
                ErrorLogger.convertStringToJSON(
                    'topThreeTechnicalArticles',
                    'There was an error setting the top five technical articles for My ASU Help'
                )
            );
            ErrorLogger.log(e, vars, false);
        }
    }

    private void setTopThreeHousingArticles() {
        try {
            topThreeHousingArticles = [
                SELECT Id, Title, UrlName
                FROM FAQ__kav
                WHERE IsDeleted = false AND Functional_Group__c = 'Housing'
                ORDER BY ArticleTotalViewCount DESC
                LIMIT 5
            ];
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(
                ErrorLogger.convertStringToJSON(
                    'topThreeHousingArticles',
                    'There was an error setting the top five housing articles for My ASU Help'
                )
            );
            ErrorLogger.log(e, vars, false);
        }
    }

    public String getViewAllFinancialArticlesLink() {
        return '/kb/pkb_Home?l=en_US&c=Finances%3AMy_ASU_Financial_Aid';
    }

    public String getViewAllTechnicalArticlesLink() {
        return '/kb/pkb_Home?l=en_US&c=Campus_Services%3ATechnical_Resources';
    }

    public String getViewAllHousingArticlesLink() {
        return '/kb/pkb_Home?l=en_US&c=Campus_Services%3AHousing';
    }
}
