import {LightningElement, wire} from 'lwc';
import getIssuesForCurrentUser from '@salesforce/apex/JiraViewAllIssuesController.getIssuesForCurrentUser';
import getWatchedIssuesForCurrentUser from '@salesforce/apex/JiraViewAllIssuesController.getWatchedIssuesForCurrentUser';

export default class JiraViewMyTickets extends LightningElement {
    myTickets = [];
    watchedTickets = [];

    @wire(getIssuesForCurrentUser)
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
            // eslint-disable-next-line no-console
            console.error(err);
        }
        this.myTickets = myTickets;
    }

    @wire(getWatchedIssuesForCurrentUser)
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
            // eslint-disable-next-line no-console
            console.error(err);
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
