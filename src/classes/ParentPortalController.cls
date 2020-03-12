public class ParentPortalController {
    public String parentFirstName {get; set;}
    public String parentLastName {get; set;}
    public String parentEmailAddress {get; set;}
    public String parentZipCode {get; set;}
    public List<String> chosenTopics {get; set;}
    public List<SelectOption> topicOptions =  new List<SelectOption>();

    public List<SelectOption> getTopicOptions() {
        topicOptions.clear();
        SelectOption topicOptionsScience = new SelectOption('Science', 'Science');
        SelectOption topicOptionsTechnology = new SelectOption('Technology', 'Technology');
        SelectOption topicOptionsEngineering = new SelectOption('Engineering', 'Engineering');
        SelectOption topicOptionsArts = new SelectOption('Arts', 'Arts');
        SelectOption topicOptionsMath = new SelectOption('Math', 'Math');
        topicOptions.add(topicOptionsScience);
        topicOptions.add(topicOptionsTechnology);
        topicOptions.add(topicOptionsEngineering);
        topicOptions.add(topicOptionsArts);
        topicOptions.add(topicOptionsMath);
        return topicOptions;
    }

    public PageReference parentPortal() {
        return Page.ParentPortal;
    }

    public PageReference parentPortalStep2() {
        return Page.ParentPortalStep2;
    }

    public PageReference parentPortalStep3() {
        return Page.ParentPortalStep3;
    }

    public PageReference parentPortalStep4() {
        return Page.ParentPortalStep4;
    }

    public PageReference parentPortalStep5() {
        return Page.ParentPortalStep5;
    }
}