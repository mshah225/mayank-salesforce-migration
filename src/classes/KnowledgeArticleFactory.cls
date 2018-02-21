public class KnowledgeArticleFactory {
    public class DefaultKnowledgeArticle extends TestFactory {
        public DefaultKnowledgeArticle () {
            super(new FAQ__kav(
            Title = 'test apex',
            Summary = 'test from apex',
            Answer__c = 'test',
            language ='en_US',
            URLName = 'test'
        	));
            this.addToFieldsToIncrement('URLName');
        }
    }
}