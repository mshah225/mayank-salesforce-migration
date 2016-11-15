public class RelationshipService
{
    public static Relationship__c createContactAccountRelationship(Id c, Id a, Id rt, String title)
    {
        Relationship__c r = new Relationship__c(
            Account__c = a,
            Contact__c = c,
            Relationship_Type__c = 'Employee',
            RecordTypeId = rt,
            Title__c = title
        );

        return r;
    }
}