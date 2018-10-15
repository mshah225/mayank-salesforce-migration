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
                "questionOne": "What environment will be used for testing?",
                "questionTwo": "QA test plan (including test cases):",
                "questionThree": "QA tester(s):",
                "questionFour" : "What configuration changes need to be made?",
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
                "questionOne": "Brief summary of the changes:",
                "questionTwo": "What was the QA Test Plan?",
                "questionThree": "Name of Admin who tested and signed off:",
                "questionFour": "Name of stakeholder representative who signed off:",
                "questionFive": "What metadata is migration?",
                "questionSix": "What configurations need to be made before or after deploy?",
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