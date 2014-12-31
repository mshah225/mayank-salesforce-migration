trigger upsertUserTrigger on User (before insert, before update) 
{
    String helpDeskProfileId = '00ed00000019z6C';
    CallCenter cc = [SELECT Id FROM CallCenter WHERE InternalName = 'inContactCallCenter'];

    for(User u : Trigger.new)
    {
        if(u.ProfileId == helpDeskProfileId)
        {
            u.CallCenterId = cc.Id;
        }
    }
}