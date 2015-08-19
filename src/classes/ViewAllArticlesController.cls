public with sharing class ViewAllArticlesController
{
    private ServiceCenter sc;

    public List<KnowledgeArticleVersion> articles;

    public ViewAllArticlesController(ServiceCenter sc)
    {
        this.sc = sc;
        String q = ApexPages.currentPage().getParameters().get('q');
        if (q != null)
        {
            sc.searchString = q;
        }
    }

    public void clearSearchString()
    {
        sc.searchString = '';
    }
}