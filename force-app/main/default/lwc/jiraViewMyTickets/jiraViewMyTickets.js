import {LightningElement, api, wire} from 'lwc';
import getIssuesForUser from '@salesforce/apex/JiraViewAllIssuesController.getIssuesForUserStr';
import getWatchedIssuesForUser from '@salesforce/apex/JiraViewAllIssuesController.getWatchedIssuesForUserStr';

export default class JiraViewMyTickets extends LightningElement {
    @api jiraUserId;
    myTickets = [
        {
            issueId: '799922',
            key: 'SFE-41805',
            url: 'https://asudev.jira.com/browse/SFE-41805',
            issueType: 'Task',
            summary: 'Modal testing ticket',
            status: 'In Progress',
        },
    ];
    watchedTickets = [];

    @wire(getIssuesForUser, {jiraUserId: '$jiraUserId'})
    gotIssuesForUser(result) {
        let {data, err} = result;
        const myTickets = [];
        if (data) {
            let parsedData = JSON.parse(data);
            for (let i = 0; i < parsedData.issues.length; i++) {
                const issue = parsedData.issues[i];
                myTickets.push(this.createTicketWrapper(issue));
            }
        } else {
            console.log(err);
        }
        this.myTickets = myTickets;
    }

    @wire(getWatchedIssuesForUser, {jiraUserId: '$jiraUserId'})
    gotWatchedIssuesForUser(result) {
        let {data, err} = result;
        const watchedTickets = [];
        if (data) {
            let parsedData = JSON.parse(data);
            for (let i = 0; i < parsedData.issues.length; i++) {
                const issue = parsedData.issues[i];
                watchedTickets.push(this.createTicketWrapper(issue));
            }
        } else {
            console.log(err);
        }
        this.watchedTickets = watchedTickets;
    }

    createTicketWrapper(parsedIssue) {
        return {
            issueId: parsedIssue.id,
            key: parsedIssue.key,
            url: 'https://asudev.jira.com/browse/' + parsedIssue.key,
            issueType: parsedIssue.fields.issuetype.name,
            summary: parsedIssue.fields.summary,
            status: parsedIssue.fields.status.name,
        };
    }
}
