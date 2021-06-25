@isTest
public class SuccessResourcePodAssociationFactory {
    public class DefaultSuccessResourcePodAssociation extends TestFactory {
        public DefaultSuccessResourcePodAssociation(Id relatedSuccessResourceId, Id relatedSuccessPodId) {
            super(
                new Success_Resource_Pod_Association__c(
                    Success_Resource__c = relatedSuccessResourceId,
                    Success_Pod__c = relatedSuccessPodId
                )
            );
        }
    }

    public List<Success_Resource_Pod_Association__c> createSuccessResourcePodAssociations(
        Success_Resource__c relatedAdvisorResource,
        List<Success_Pod__c> relatedSuccessPods
    ) {
        List<Success_Resource_Pod_Association__c> successResourcePodAssociations = new List<Success_Resource_Pod_Association__c>();

        for (Success_Pod__c sp : relatedSuccessPods) {
            DefaultSuccessResourcePodAssociation successResourcePodAssociationMaker = new DefaultSuccessResourcePodAssociation(
                relatedAdvisorResource.Id,
                sp.Id
            );
            successResourcePodAssociations.add(
                (Success_Resource_Pod_Association__c) successResourcePodAssociationMaker.create(1)[0]
            );
        }
        insert successResourcePodAssociations;
        return successResourcePodAssociations;
    }
}
