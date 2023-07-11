/* Test class for ContactTagApex.apxc */
@IsTest
public class TaggingComponentControllerTest 
{
    @IsTest
	public static void testContactTags()
    {
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) 
        {
            Profile pf= [Select Id from profile where Name='System Administrator'];
            String orgId=UserInfo.getOrganizationId();
            String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
            
            Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000));
            String uniqueName=orgId+dateString+RandomId;
            
            
            test.startTest();
            User testUser =new User(firstname = 'Test_FName2',
                                     lastName = 'Test_LName2',
                                     email = uniqueName + '@test' + orgId + '.org',
                                     Username = uniqueName + '@test22' + orgId + '.org',
                                     EmailEncodingKey = 'ISO-8859-1',
                                     Alias = uniqueName.substring(18, 23),
                                     TimeZoneSidKey = 'America/Los_Angeles',
                                     LocaleSidKey = 'en_US',
                                     LanguageLocaleKey = 'en_US',
                                     ProfileId = pf.Id
                                    );
            insert testUser;
            
            
            
           
            
            //Create Contacts
            List<Contact> con = new List<Contact>();
            Contact cons1 = new Contact(FirstName = 'abc',
                                        LastName = 'Test1',
                                        OwnerId = testUser.Id);
            con.add(cons1);
            
            Contact cons2 = new Contact(FirstName = 'abc',
                                        LastName = 'Test2', 
                                        OwnerId = testUser.Id);
            con.add(cons2);
            
            Contact cons3 = new Contact(FirstName = 'abc',
                                        LastName = 'Test3', 
                                        OwnerId = testUser.Id);
            con.add(cons3);
            
            Contact cons4 = new Contact(FirstName = 'abc',
                                        LastName = 'Test4', 
                                        OwnerId = testUser.Id);
            con.add(cons4);
            
            Contact cons5 = new Contact(FirstName = 'abc',
                                        LastName = 'Test5', 
                                        OwnerId = testUser.Id);
            con.add(cons5);
            
            Contact cons6 = new Contact(FirstName = 'abc',
                                        LastName = 'Test6', 
                                        OwnerId = testUser.Id);
            con.add(cons6);
            
            Insert con;
            
            //Create Tags
            Tag__c tag1 = new Tag__c(Name = 'tag1',
                                     OwnerId = testUser.Id,
                                     Removeable__c = false,
                                     Searchable__c = false);
            Insert tag1;
            
            Tag__c tag2 = new Tag__c(Name = 'tag2',
                                     OwnerId = testUser.Id,
                                     Removeable__c = false,
                                     Searchable__c = true);
            Insert tag2;
            
            Tag__c tag3 = new Tag__c(Name = 'tag3',
                                     OwnerId = testUser.Id,
                                     Removeable__c = true,
                                     Searchable__c = false);
            Insert tag3;
            
            Tag__c tag4 = new Tag__c(Name = 'tag4',
                                     OwnerId = testUser.Id,
                                     Removeable__c = true,
                                     Searchable__c = true);
            Insert tag4;
            
            Tag__c tag5 = new Tag__c(Name = 'tag5',
                                     OwnerId = testUser.Id,
                                     Removeable__c = true,
                                     Searchable__c = true);
            Insert tag5;
            
            
            
        	//Create Contact Tags
            Contact_Tag__c c1 = new Contact_Tag__c(Contact__c = cons1.Id,
                                                   Name = 'test_con_tag1',
                                                   CP_Stage__c = 'CP Verified',
                                                   OwnerId = testUser.Id,
                                                   isActive__c=true,
                                                   Tag__c = tag1.Id);
            Insert c1;
            
            Contact_Tag__c c2 = new Contact_Tag__c(Contact__c = cons1.Id,
                                                   Name = 'test_con_tag2',
                                                   CP_Stage__c = 'CP Eligible',
                                                   OwnerId = testUser.Id,
                                                   isActive__c=true,
                                                   Tag__c = tag2.Id);
            Insert c2;
            
            Contact_Tag__c c3 = new Contact_Tag__c(Contact__c = cons1.Id,
                                                   Name = 'test_con_tag3',
                                                   CP_Stage__c = 'Benefit Ready',
                                                   OwnerId = testUser.Id,
                                                   isActive__c=true,
                                                   Tag__c = tag3.Id);
            Insert c3;
            
            Contact_Tag__c c4 = new Contact_Tag__c(Contact__c = cons1.Id,
                                                   Name = 'test_con_tag4',
                                                   CP_Stage__c = 'Benefit Applied',
                                                   OwnerId = testUser.Id,
                                                   isActive__c=true,
                                                   Tag__c = tag4.Id);
            Insert c4;
            
            
            taggingComponentController.contactTags(cons1.Id);
            taggingComponentController.fetchTags('tag1');
            taggingComponentController.fetchTags('tag2');
            taggingComponentController.fetchTags('tag3');
            taggingComponentController.fetchTags('tag4');
            taggingComponentController.updateTag('tag5', cons1.Id);
            taggingComponentController.removeTag('tag5',cons1.Id,'');
            taggingComponentController.tagRemovalReason();
            test.stopTest();
        }
    }
}