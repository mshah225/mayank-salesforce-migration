public with sharing class MyASUHelpFAQController {
    public List<FAQ__kav> topFiveFinancialArticles;
    public List<FAQ__kav> topFiveTechnicalArticles;
    public List<FAQ__kav> topFiveHousingArticles;
    public String viewAllFinanceArticlesUrl;
    public String viewAllTechnicalArticlesUrl;

    public MyASUHelpFAQController() {
        setTopFiveFinancialArticles();
        setTopFiveTechnicalArticles();
        setTopFiveHousingArticles();
    }

    public List<FAQ__kav> getTopFiveFinancialArticles() {
        return topFiveFinancialArticles;
    }

    public List<FAQ__kav> getTopFiveTechnicalArticles() {
        return topFiveTechnicalArticles;
    }

    public List<FAQ__kav> getTopFiveHousingArticles() {
        return topFiveHousingArticles;
    }

    private void setTopFiveFinancialArticles() {
        try {
            topFiveFinancialArticles = [
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
                    'topFiveFinancialArticles',
                    'There was an error setting the top five financial articles for My ASU Help'
                )
            );
            ErrorLogger.log(e, vars, false);
        }
    }

    private void setTopFiveTechnicalArticles() {
        try {
            topFiveTechnicalArticles = [
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
                    'topFiveTechnologyArticles',
                    'There was an error setting the top five technical articles for My ASU Help'
                )
            );
            ErrorLogger.log(e, vars, false);
        }
    }

    private void setTopFiveHousingArticles() {
        try {
            topFiveHousingArticles = [
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
                    'topFiveHousingArticles',
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
