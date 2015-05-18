/*
* Name: ChangeCaseOwnerController.cls
* Written by: Mathew Ruff
* Date Created: Oct. 22nd 2014
* 
* Last Updated: Feb. 26th 2015
* What was Changed: Adding queues to page based off completed naming convention (prefix) in DEV.
*/
public class ChangeCaseOwnerController {

    private final Case c;
    public ChangeCaseOwnerController(ApexPages.StandardController stdController) {
        this.c = (Case)stdController.getRecord();
        c.Functional_Group__c = [SELECT Functional_Group__c FROM Case WHERE Id = :c.Id].Functional_Group__c;
    }

    public Id queueId { get;set; }
    public List<Group> adm = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'ADM_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> bbss = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'BBSS_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> da = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'DA_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> edu = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'EDU_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> eng = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'ENG_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> esm = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'ESM_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> fa = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'FA_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> graded = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'GRADED_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> help = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'HELP_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> honors = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'HONORS_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> hs = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'HS_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> im = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'IM_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> jour = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'JOUR_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> letters = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'LETTERS_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> libarts = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'LIBARTS_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> library = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'LIBRARY_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> nc = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'NC_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> nursing = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'NURSING_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> online = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'ONLINE_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> pp = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'PP_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> pres = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'PRES_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> sbs = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'SBS_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> sci = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'SCI_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> sus = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'SUS_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> techstudio = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'TECHSTUDIO_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> urs = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'URS_%' AND Type = 'Queue' ORDER BY Name ASC];
    public List<Group> wpc = [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName LIKE 'WPC_%' AND Type = 'Queue' ORDER BY Name ASC];

    public Case getC() { return c; }
    public List<Group> getADM() { return adm; }
    public List<Group> getBBSS() { return bbss; }
    public List<Group> getDA() { return da; }
    public List<Group> getEDU() { return edu; }
    public List<Group> getENG() { return eng; }
    public List<Group> getESM() { return esm; }
    public List<Group> getFA() { return fa; }
    public List<Group> getGRADED() { return graded; }
    public List<Group> getHELP() { return help; }
    public List<Group> getHONORS() { return honors; }
    public List<Group> getHS() { return hs; }
    public List<Group> getIM() { return im; }
    public List<Group> getJOUR() { return jour; }
    public List<Group> getLETTERS() { return letters; }
    public List<Group> getLIBARTS() { return libarts; }
    public List<Group> getLIBRARY() { return library; }
    public List<Group> getNC() { return nc; }
    public List<Group> getNURSING() { return nursing; }
    public List<Group> getONLINE() { return online; }
    public List<Group> getPP() { return pp; }
    public List<Group> getPRES() { return pres; }
    public List<Group> getSBS() { return sbs; }
    public List<Group> getSCI() { return sci; }
    public List<Group> getSUS() { return sus; }
    public List<Group> getTECHSTUDIO() { return techstudio; }
    public List<Group> getURS() { return urs; }
    public List<Group> getWPC() { return wpc; }

    public PageReference assignOwnerToQueue() {
        try {
            c.OwnerId = queueId;
            update c;
        } catch(Exception e) {
            ApexPages.addMessages(e);
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());
            return null;
        }
        PageReference save = new PageReference('/' + c.id);
        save.setRedirect(true);
        return save;
    }
}