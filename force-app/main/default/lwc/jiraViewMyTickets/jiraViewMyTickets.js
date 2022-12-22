/* eslint-disable no-use-before-define */
import {LightningElement, wire} from 'lwc';
import getIssuesForCurrentUser from '@salesforce/apex/JiraViewAllIssuesController.getIssuesForCurrentUser';
import getWatchedIssuesForCurrentUser from '@salesforce/apex/JiraViewAllIssuesController.getWatchedIssuesForCurrentUser';

export default class JiraViewMyTickets extends LightningElement {
    myTickets = [];
    watchedTickets = [];

    @wire(getIssuesForCurrentUser)
    gotIssuesForUser(result) {
        let {data, error} = result;
        const myTickets = [];
        if (data) {
            let parsedData = JSON.parse(data);
            for (let i = 0; i < parsedData.issues.length; i++) {
                const issue = parsedData.issues[i];
                myTickets.push(new TicketItem(issue));
            }
        } else if (error) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
        this.myTickets = myTickets;
    }

    @wire(getWatchedIssuesForCurrentUser)
    gotWatchedIssuesForUser(result) {
        let {data, error} = result;
        const watchedTickets = [];
        if (data) {
            let parsedData = JSON.parse(data);
            for (let i = 0; i < parsedData.issues.length; i++) {
                const issue = parsedData.issues[i];
                watchedTickets.push(new TicketItem(issue));
            }
        } else if (error) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
        this.watchedTickets = watchedTickets;
    }
}

class TicketItem {
    issueId = null;
    key = null;
    url = null;
    issueType = null;
    summary = null;
    status = null;

    constructor(parsedIssue) {
        this.issueId = parsedIssue.id;
        this.key = parsedIssue.key;
        this.url = 'https://asudev.jira.com/browse/' + parsedIssue.key;
        this.issueType = parsedIssue.fields.issuetype.name;
        this.summary = parsedIssue.fields.summary;
        this.status = parsedIssue.fields.status.name;
    }
}
