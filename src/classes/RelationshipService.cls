/**
 * Created by aesanch2 on 12/13/15.
 */

public class RelationshipService
{
    /**
    * Generates a relationship for a scanbiz created contact
    * @param Id contactId
    * @param Id accountId
    * @param id relationRT
    * @return Relationship__c relation
    */
    public static Relationship__c createScanbizRelationship(Id contactId, Id accountId, Id relationRT)
    {
        Relationship__c relation = new Relationship__c();
        relation.Account__c = accountId;
        relation.Contact__c = contactId;
        relation.Relationship_Type__c = 'Employee';
        relation.RecordTypeId = relationRT;

        return relation;
    }
}