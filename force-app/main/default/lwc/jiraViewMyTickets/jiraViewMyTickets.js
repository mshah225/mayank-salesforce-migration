/* eslint-disable no-use-before-define */
import {LightningElement, wire, api} from 'lwc';
import getIssuesForCurrentUser from '@salesforce/apex/JiraViewAllIssuesController.getIssuesForCurrentUser';
import getWatchedIssuesForCurrentUser from '@salesforce/apex/JiraViewAllIssuesController.getWatchedIssuesForCurrentUser';
import {TicketItem} from 'c/jiraTicketTable';

export default class JiraViewMyTickets extends LightningElement {
    myTickets = [];
    watchedTickets = [];
    testFormQuestionList = [];
    techReviewQuestionList = [];

    @api set testFormQuestionListJSON(val) {
        if (val != null && val !== '') this.testFormQuestionList = JSON.parse(val);
        else this.testFormQuestionList = [];

        for (let i = 0; i < this.testFormQuestionList.length; i++) this.testFormQuestionList[i].key = 'test-key-' + i;
    }
    get testFormQuestionListJSON() {
        return this.testFormQuestionList;
    }

    @api set techReviewQuestionListJSON(val) {
        if (val != null && val !== '') this.techReviewQuestionList = JSON.parse(val);
        else this.techReviewQuestionList = [];

        for (let i = 0; i < this.techReviewQuestionList.length; i++)
            this.techReviewQuestionList[i].key = 'tech_review-key-' + i;
    }
    get techReviewQuestionListJSON() {
        return this.techReviewQuestionList;
    }

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
