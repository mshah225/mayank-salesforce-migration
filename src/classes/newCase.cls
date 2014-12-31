public class newCase {

    public newCase(ApexPages.StandardController controller) { c = new Case(); }
    public newCase(AKBController controller) { c = new Case(); }

    public Case c { get; set; }
         
    public newCase() {
        c = new Case();
    }
    
    public PageReference submitCase() {
        try {
            INSERT c;
            PageReference confirmPage = new PageReference('/studentSC?Confirm=case');
            confirmPage.setRedirect(true);
            return confirmPage;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }

    }
}