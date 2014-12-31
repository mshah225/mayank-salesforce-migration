public class NavLinks {

    public NavLinks(ServiceCenter controller) { }
    public NavLinks(AKBController controller) { }
    public NavLinks(ApexPages.StandardController controller) { }
    
    public string links{get; set;}
    public string headers {get; set;}
    public List<Link> linkList {get; set;}
    public Map<String, String> linkMap {get; set;}
    
    private String asurite = 'efudala';

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
        
        
        system.debug('asuriteId: ' + asuriteIdParm);
        system.debug('navbar: ' + navbarParm);
        system.debug('time: ' + timeParm);
        system.debug('signature: ' + signatureParm);
        
         
        headers='';
        MAP<string, string> hdrs = ApexPages.currentPage().getheaders();
        for (string key : hdrs.keySet() )
            headers += key + ' : ' + hdrs.get(key) + '\n';
    
        /*
        List<Contact> cList = new List<Contact>([SELECT Id, EMPLID__c, Email, LastName, Firstname FROM Contact WHERE ASURITE_ID__c = :asurite AND EMPLID__c != null]);
        
        if (cList.size() > 0) {
          List<User> uList = new List<User>([SELECT Id FROM User WHERE ContactId = :cList[0].Id]);
          
          if (uList.size() == 0) {
            
            Profile p = [SELECT Id FROM Profile WHERE Name = 'ASU Community Access'];
    
            
            // Found a valid contact, but this Contact has no valid User record; Create one
        Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.EmailHeader.triggerUserEmail = false;
            User u = new User(email=cList[0].Email, Alias='ef111',
                        emailencodingkey='UTF-8', lastname=cList[0].LastName, languagelocalekey='en_US',
                        localesidkey='en_US', profileid = p.Id, contactId= cList[0].Id,
                        timezonesidkey='America/Phoenix', username='community_'+asurite+'@asu.edu', FederationIdentifier=asurite+'@asu.edu');
            u.setOptions(dmo);
            insert u;
          }
        }
        */
        
        return null;
        
    }
    
    public PageReference doSomething() {
        return ApexPages.currentPage();
    }
    
    public class Link {
      public String name { set; get { return name; } }
      public String url { set; get { return url; }  }
    }

}