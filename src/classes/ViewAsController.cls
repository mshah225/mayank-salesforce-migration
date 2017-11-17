public with sharing class ViewAsController {
    public String viewAsId {get;set;} // Id to pass to sub components
    
    /*
     * Initialize component with current user's Id
     */
    public ViewAsController() {
        viewAsId = UserInfo.getUserId();
    }
}