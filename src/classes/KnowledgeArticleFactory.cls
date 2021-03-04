@isTest
public class KnowledgeArticleFactory {
    public class FAQKnowledgeArticle extends TestFactory {
        public FAQKnowledgeArticle() {
            super(
                new FAQ__kav(
                    Title = 'Test Article',
                    Summary = 'Testing From Apex',
                    Answer__c = 'This is a Test',
                    URLName = 'FAQURL',
                    IsVisibleInPkb = true
                )
            );
            this.addToFieldsToIncrement('URLName');
        }
    }
}
