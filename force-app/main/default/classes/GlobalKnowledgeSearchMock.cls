public class GlobalKnowledgeSearchMock {

    public class MockSearchResponseWithArticleId implements HttpCalloutMock {
        public String articleId;

        public MockSearchResponseWithArticleId(String id) {
            this.articleId = id;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');

            Map<String, Object> payload = new Map<String, Object>{
                'searchRecords' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'Id' => articleId,
                        'Title' => 'How to log in',
                        'Answer__c' => 'Use your ASUrite ID.',
                        'KnowledgeArticleId' => 'ka01x0000001abc',
                        'Functional_Group__c' => 'IT Support',
                        'ArticleTotalViewCount' => 123,
                        'LastPublishedDate' => '2024-12-01T12:00:00.000Z',
                        'PublishStatus' => 'Online'
                    }
                }
            };

            res.setBody(JSON.serialize(payload));
            return res;
        }
    }

    public class LargeMockSearchResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            List<Map<String, Object>> articles = new List<Map<String, Object>>();
            for (Integer i = 0; i < 25; i++) {
                articles.add(new Map<String, Object>{
                    'Id' => 'ka1FakeArticle' + i,
                    'Title' => 'Article ' + i,
                    'Answer__c' => 'Answer for article ' + i,
                    'KnowledgeArticleId' => 'ka01x000000' + i,
                    'Functional_Group__c' => 'Test Group',
                    'ArticleTotalViewCount' => i * 5,
                    'LastPublishedDate' => '2025-01-01T00:00:00.000Z',
                    'PublishStatus' => 'Online'
                });
            }

            Map<String, Object> responsePayload = new Map<String, Object>{
                'searchRecords' => articles
            };

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(responsePayload));
            return res;
        }
    }
}
