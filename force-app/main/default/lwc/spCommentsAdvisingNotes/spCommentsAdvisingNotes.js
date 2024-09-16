import {LightningElement, api, wire} from 'lwc';
import getPSAdvisorNotes from '@salesforce/apex/StudentProfileController.getPSAdvisorNotesLWC';
import {refreshApex} from '@salesforce/apex';
import {extractErrorMessages} from 'c/helperFunctions';
import {NavigationMixin} from 'lightning/navigation';
import {cloneObj} from 'c/helperFunctions';

export default class SpCommentsAdvisingNotes extends NavigationMixin(LightningElement) {
    // If embedded on a contact record page
    @api set recordId(val) {
        this.contactId = val;
    }
    get recordId() {
        return this.contactId;
    }

    @api contactId;

    /**
     * Get the Peoplesoft Advisor Notes
     */
    @wire(getPSAdvisorNotes, {contactId: '$contactId'})
    gotPSAdvisorNotes(resp) {
        this.dataWire = resp;
        let {error, data} = resp;

        if (error !== undefined) {
            this.dataWrapper = undefined;
            this.dataError = error;
        }

        if (data !== undefined) {
            this.dataWrapper = data;
            this.dataError = undefined;
            this.regenerateUserIdsToUrls();
        }
    }
    dataWire = undefined;
    dataError = undefined;
    dataWrapper = undefined;

    /**
     * Errors
     */
    get hasError() {
        return this.dataError !== undefined;
    }
    get errorMessage() {
        return extractErrorMessages(this.dataError)[0];
    }
    errorReload() {
        if (this.dataError) {
            this.dataError = undefined;
            refreshApex(this.dataWire).catch((e) => {
                this.dataError = e;
                this.dataWrapper = undefined;
            });
        }
    }

    /**
     * Use the NavigationMixin.GenerateUrl function to generate URLs for each user that appears in the comment list
     * we need to do this like so because NavigationMixin.GenerateUrl returns a promise and we can't wait for that directly in the getter
     * Usually people use the openUserLink function, but setting the href allows us to trivially support middle-click (open in new tab)
     */
    async regenerateUserIdsToUrls() {
        let userIdsToUrls = {};
        let promiseList = [];

        for (let c of this.dataWrapper ?? []) {
            promiseList.push(
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        objectApiName: 'User',
                        actionName: 'view',
                        recordId: c.authorUserId,
                    },
                }).then((url) => {
                    userIdsToUrls[c.authorUserId] = url;
                })
            );
        }

        await Promise.all(promiseList);

        this.userIdsToUrls = userIdsToUrls;
    }
    userIdsToUrls = {};

    /**
     * Uses NavigationMixin.Navigate to go to the record page for the user
     * This means no need to reload window and will open in whatever form the containing format expects
     */
    openUserLink(evnt) {
        const userId = evnt.target.dataset.userid;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: userId,
                objectApiName: 'User',
                actionName: 'view',
            },
        });

        evnt.stopPropagation();
        evnt.stopImmediatePropagation();
        evnt.preventDefault();

        return false;
    }

    /**
     * Get the advisor note list (which we then manually create a table using)
     */
    get rows() {
        let rows = [];

        let indx = 1;

        const advisorNoteList = this.dataWrapper ?? [];

        for (let c of advisorNoteList) {
            let dateStr = '--';
            try {
                const d = new Date(c.commentDt); // format date time
                dateStr = `${d.getMonth() + 1}/${d.getDate()}/${d.getFullYear()}`;
            } catch (e) {
                console.error(e);
            }

            // Set all fields
            rows.push({
                c__UserName: c.authorName,
                c__UserId: c.authorUserId,
                href: c.authorUserId != null ? this.userIdsToUrls[c.authorUserId] ?? '#' : null, // add urls once they are ready
                c__ProgramName: c.programName,
                c__PlanName: c.planName,
                c__Date: dateStr,
                c__Comment: c.comment,
                id1: `ID-${indx}a`,
                id2: `ID-${indx}b`,
            });
            indx += 1;
        }

        return rows;
    }

    /**
     * Force component to reload contents
     */
    @api reload() {
        this.loadingOverride = true;
        refreshApex(this.dataWire).finally(() => {
            this.loadingOverride = false;
        });
    }

    loadingOverride = false;

    get loading() {
        return this.loadingOverride || this.dataWrapper === undefined;
    }

    get hasData() {
        return this.rows.length > 0;
    }
}

export class SpCommentsAdvisingNotesTest extends SpCommentsAdvisingNotes {
    @api get loading() {
        return super.loading;
    }

    @api get hasData() {
        return super.hasData;
    }
}
