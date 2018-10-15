({
	doInit : function(component, event, helper) {
       	helper.getIssues(component);
    },
    
    openQA : function(component, event, helper) {
        $A.createComponent(
            "c:JiraAddCommentForm",
            {
                "aura:id": "findableAuraId",
                "ticketKey": event.target.id,
                "questionOne": "DEV Testing Results and Summary:",
                "questionTwo": "QA Test Plan:",
                "questionThree": "QA Tester(s):",
                "questionFour": "Data Loads / QA Configuration Items:",
                "status": "Ready For QA Testing",
                "modalHeader" : "QA Request Form for " + event.target.getAttribute('name')
            },
            function(newModal, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newModal);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
	},
    
    openSecondTech : function(component, event, helper) {
        $A.createComponent(
            "c:JiraAddCommentForm",
            {
                "aura:id": "findableAuraId",
                "ticketKey": event.target.id,
                "questionOne": "How did QA Testing go?",
                "questionTwo": "What files are migrating?",
                "questionThree": "What configurations need to be made?",
                "questionFour": "Brief Summary of the changes: ",
                "status": "2nd Technical Review",
                "modalHeader" : "Second Tech Form for " + event.target.getAttribute('name')
            },
            function(newModal, status, errorMessage) {
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newModal);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
	}
})