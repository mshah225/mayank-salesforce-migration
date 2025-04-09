import {LightningElement, api} from 'lwc';

export default class AdvisorPortalUserSelect extends LightningElement {
    @api userAndPodOptions;

    @api set ownerIds(v) {
        this._ownerIds = v;
    }
    get ownerIds() {
        return this._ownerIds;
    }
    _ownerIds;

    @api myQueueId;
    @api isLoading;

    get placeholder() {
        return this.isLoading ? 'Loading...' : undefined;
    }

    get ownerIdsArr() {
        return this.ownerIds != null && this.ownerIds !== '' ? this.ownerIds.split(';') : [];
    }

    /**
     * Pills for each selected user/pod
     */
    get allPills() {
        let ownerIdToName = (this.userAndPodOptions ?? []).reduce((prev, cur) => {
            prev[cur.value] = cur.label;
            return prev;
        }, {});

        return this.ownerIdsArr.map((v) => {
            return {
                type: 'avatar',
                label: ownerIdToName[v],
                fallbackIconName: 'standard:groups',
                variant: 'circle',
                name: v,
            };
        });
    }
    get hasPills() {
        return this.allPills.length !== 0;
    }

    /** List of all shown pills */
    get shownPills() {
        return this.allPills.filter((v, indx) => {
            return this.showAllPills || indx < 5;
        });
    }
    showAllPills = true;

    /** Pills that are not shown */
    get unshownPillCount() {
        return this.allPills.length - this.shownPills.length;
    }

    /** Are there any hidden pills */
    get showPillToggle() {
        return (
            // either is there are some unshown pills
            this.unshownPillCount > 0 ||
            // or if toggled open and more than 5
            (this.showAllPills && this.shownPills.length > 5)
        );
    }

    /**
     * Toggle pill expansion
     */
    togglePillExpansion() {
        this.showAllPills = !this.showAllPills;
    }

    // Selections handling
    selectAll() {
        this.ownerIds = this.userAndPodOptions
            .filter((v) => !v.isLabel)
            .map((v) => v.value)
            .join(';');
        this.sendChangeEvent();
    }
    selectMyQueue() {
        this.ownerIds = this.myQueueId;
        this.sendChangeEvent();
    }
    clearSelection() {
        this.ownerIds = '';
        this.sendChangeEvent();
    }

    /**
     * Change from dropdown
     */
    changeHandler(e) {
        e.stopPropagation();
        e.stopImmediatePropagation();
        e.preventDefault();

        const value = e.detail.value;
        this.ownerIds = value;
        this.sendChangeEvent();
    }

    /**
     * Unselect using pill
     */
    removeHandler(e) {
        const removeVal = e.detail.item.name;
        this.ownerIds = this.ownerIdsArr.filter((v) => v !== removeVal).join(';');
        this.sendChangeEvent();
    }

    // Raise changeusers event
    applyChanges() {
        this.dispatchEvent(new CustomEvent('commitusers', {detail: {value: this.ownerIds}}));
    }

    sendChangeEvent() {
        this.dispatchEvent(new CustomEvent('changeusers', {detail: {value: this.ownerIds}}));
    }
}
