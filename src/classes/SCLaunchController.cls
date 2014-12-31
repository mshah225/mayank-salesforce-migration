public without sharing class SCLaunchController {
    public string links{get; set;}
    public string headers {get; set;}
    public List<Link> linkList {get; set;}
    public Map<String, String> linkMap {get; set;}
    
    public PageReference init() {
        Cookie linksCookie;
        String linksJSON = '';
        
        String asuriteIdParm = '';
        String navbarParm = '';
        String timeParm = '';
        String signatureParm = '';
        
        system.debug('parms: ' + ApexPages.currentPage().getParameters());
        
        if (ApexPages.currentPage().getParameters().get('asuriteId') != null) 
            asuriteIdParm = ApexPages.currentPage().getParameters().get('asuriteId');
        if (ApexPages.currentPage().getParameters().get('time') != null) 
            timeParm = ApexPages.currentPage().getParameters().get('time');
        if (ApexPages.currentPage().getParameters().get('signature') != null) 
            signatureParm = ApexPages.currentPage().getParameters().get('signature');

        if (ApexPages.currentPage().getParameters().get('navbar') != null) {
            links = ApexPages.currentPage().getParameters().get('navbar');
            system.debug('links: ' + links);
            links = links.replace('{"navbarLinks":','');
            links = links.substring(0, (links.length()-1));
            //Write the cookie
            if (links != null && links != '') {
                linksCookie = new Cookie('navbarlinks',links,null,-1,false);
                ApexPages.currentPage().setCookies(new Cookie[]{linksCookie});
            }         
        }
        else {
            linksCookie = ApexPages.currentPage().getCookies().get('navbarlinks');
        }
        
        
     
        if (linksCookie != null) {
            linksJSON = linksCookie.getValue();
            system.debug('Cookie value: ' + linksJSON);
            // Clean up any HTML encoding for quotes
            linksJSON = linksJSON.replaceAll('&quot;', '"');
            linksJSON = linksJSON.replaceAll('&#34;', '"');
            system.debug(linksJSON);
            //linkList = (List<Link>) JSON.deserialize(linksJSON, List<Link>.class);
            
            linkList = new List<Link>();
            JSONParser parser = JSON.createParser(linksJSON);
            while (parser.nextToken() != null) {
                //if current token is a field name
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    Link thisLink = new Link();
                    String fieldName = parser.getText();
                    thisLink.name = fieldName;
                    // Move to token after the field name
                    parser.nextToken();
                    thisLink.url = parser.getText();
                    linkList.add(thisLink);
                }
            }
        }
        
        if (asuriteIdParm != null)
            autoProvisionCommunityUser(asuriteIdParm);
        
        
        system.debug('asuriteId: ' + asuriteIdParm);
        system.debug('navbar: ' + navbarParm);
        system.debug('time: ' + timeParm);
        system.debug('signature: ' + signatureParm);
        
        return null;
            
    }

    private void autoProvisionCommunityUser(String asurite) {
    
        String asuriteFederationId = asurite + '@asu.edu';
        List<Contact> cList = new List<Contact>([SELECT Id, EMPLID__c, Email, LastName, Firstname, CAP__c FROM Contact WHERE ASURITE_ID__c = :asurite AND EMPLID__c != null]);
        List<User> existingUserList = new List<User>([SELECT Id FROM User WHERE User.FederationIdentifier = :asuriteFederationId]);
        
        // If the asurite ID already exists as a User's Federation Identifier, skip the User creation
//        if (cList.size() > 0 && existingUserList.size() == 0) {
        // No longer skipping User creation for Users 
        if (cList.size() > 0) {
            List<User> uList = new List<User>([SELECT Id FROM User WHERE ContactId = :cList[0].Id]);
            
            // If we can't find a User associated to this Contact, create one
            if (uList.size() == 0) {
                
                List<Profile> profileList = new List<Profile>();
                
                if(cList[0].CAP__c == null) {
                    profileList = [SELECT Id FROM Profile WHERE Name = 'ASU Community'];
                } else {
                    profileList = [SELECT Id FROM Profile WHERE Name = 'ASU Community CAP'];   
                }
                
                // Can't find the Community profile; stop here
                //if (profileList.size() == 0)
                //  return;
                    
                String userAlias = asurite;
                
                /*
                if (cList[0].FirstName != null)
                    userAlias = cList[0].FirstName.substring(0,1);
                if (cList[0].LastName.length() > 4)
                    userAlias += cList[0].LastName.substring(0,4);
                else
                    userAlias += cList[0].LastName;
                */
                
                // If this Federation ID already exists for a User record, make it null for the new User record
                // GRF 6/27/14
                //
                if (existingUserList.size() > 0)
                	asuriteFederationId = null;
                
                // Found a valid contact, but this Contact has no valid User record; Create one
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.EmailHeader.triggerUserEmail = false;
                User u = new User(email=cList[0].Email, Alias=userAlias,
                                  emailencodingkey='UTF-8', lastname=cList[0].LastName, firstname=cList[0].FirstName, languagelocalekey='en_US',
                                  localesidkey='en_US', profileid = profileList[0].Id, contactId= cList[0].Id,
                                  timezonesidkey='America/Phoenix', username='community_'+asurite+'@asu.edu', FederationIdentifier=asuriteFederationId);
                u.setOptions(dmo);
                try {
                    insert u;
                }
                catch (Exception e) {
                    // Problem encountered during the User insert
                }
            }
        }
        
    }
    
    public class Link {
        public String name { set; get { return name; } }
        public String url { set; get { return url; }    }
    }
}