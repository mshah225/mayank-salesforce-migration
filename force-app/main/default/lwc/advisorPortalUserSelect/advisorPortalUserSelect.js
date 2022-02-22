import {LightningElement, wire, track} from 'lwc';
import viewAsOptions from '@salesforce/apex/AdvisorPortalTopLevelFilterController.viewAsOptions';

export default class AdvisorPortalUserSelect extends LightningElement {
    allUserOptionsCount = 0;
    @track
    allUserOptions = [];
    @track
    filterResults = [];
    myQueueId = null;

    get selectedUserOptions() {
        const selectedUserOptions = [];
        for (let i = 0; i < this.allUserOptions.length; i++) {
            const opt = this.allUserOptions[i];
            if (opt.isSelected) {
                selectedUserOptions.push(opt);
            }
        }
        return selectedUserOptions;
    }
    get hasSelectedSomeOptions() {
        return this.selectedUserOptions.length > 0;
    }

    numberOfPillsToShowByDefault = 5;
    showAllPills = false;
    get maxNumberOfPillsToShow() {
        if (this.showAllPills) {
            return 9999;
        }
        return this.numberOfPillsToShowByDefault;
    }
    get pillButtonLabel() {
        let label;
        if (!this.showAllPills) {
            label = '+' + this.unshownPillCount + ' more';
        } else {
            label = 'Collapse Pills';
        }
        return label;
    }
    get showPillToggle() {
        return (
            // either is there are some unshown pills
            this.unshownPillCount > 0 ||
            // or if toggled open and more than 5
            (this.showAllPills && this.shownPills.length > this.numberOfPillsToShowByDefault)
        );
    }
    get unshownPillCount() {
        return this.selectedUserOptions.length - this.shownPills.length;
    }
    get shownPills() {
        const shownPills = [];
        for (let i = 0; i < this.selectedUserOptions.length && i < this.maxNumberOfPillsToShow; i++) {
            const selectedUserOption = this.selectedUserOptions[i];
            if (selectedUserOption.isSelected) {
                shownPills.push({
                    type: 'avatar',
                    label: selectedUserOption.label,
                    fallbackIconName: 'standard:groups',
                    variant: 'circle',
                });
            }
        }

        return shownPills;
    }

    get placeholder() {
        let placeholder;

        const count = this.selectedUserOptions.length;

        if (this.allUserOptions.length === 0) {
            placeholder = 'Loading...';
        } else {
            if (count === 0) {
                placeholder = '';
            } else if (count === 1) {
                placeholder = '1 option selected';
            } else {
                placeholder = count + ' options selected';
            }
        }

        return placeholder;
    }

    // Retrieve all options
    @wire(viewAsOptions, {})
    gotViewAsOptions(result) {
        let {data, error} = result;
        if (data != null) {
            let allUserOptionsCount = 0;
            let firstSelectionFound = false;
            let allUserOptions = [];

            const keys = Object.keys(data);

            for (let i = 0; i < keys.length; i++) {
                const key = keys[i];
                let option = {label: key, value: data[key], isHeader: false};

                if (key.includes('--')) {
                    option.label = option.label.replace(/--/g, '');
                    option.isHeader = true;
                }

                if (!option.isHeader) {
                    allUserOptionsCount++;

                    if (!firstSelectionFound) {
                        this.myQueueId = option.value;
                        option.isSelected = true;
                        firstSelectionFound = true;
                    }
                }

                allUserOptions.push(option);
            }

            this.allUserOptions = allUserOptions;
            this.filterResults = allUserOptions;
            this.allUserOptionsCount = allUserOptionsCount;
        } else {
            console.log(error);
        }
    }

    // Limit results to match search
    previousFilterValue = '';
    onChangeNameSearch(e) {
        let filterValue = e.detail.value;
        let previousFilterValue = this.previousFilterValue;

        if (filterValue === '') {
            this.filterResults = this.allUserOptions;
        } else {
            let optionsToConsider = [];
            let optionsToUse = [];
            if (previousFilterValue !== '' && filterValue.includes(previousFilterValue)) {
                optionsToConsider = this.filterResults;
            } else {
                optionsToConsider = this.allUserOptions;
            }

            for (let i = 0, len = optionsToConsider.length; i < len; i++) {
                const opt = optionsToConsider[i];
                if (opt.label && (opt.isHeader || opt.label.toLowerCase().includes(filterValue.toLowerCase()))) {
                    optionsToUse.push(opt);
                }
            }
            this.filterResults = optionsToUse;
            this.previousFilterValue = filterValue;
        }
    }

    // Expand/Collapse the pill group list
    togglePillGroup() {
        this.showAllPills = !this.showAllPills;
    }

    // Selections handling
    selectAll() {
        for (let i = 0; i < this.allUserOptions.length; i++) {
            const opt = this.allUserOptions[i];
            opt.isSelected = true;
        }
    }
    selectMyQueue() {
        if (this.myQueueId === null) return;
        for (let i = 0; i < this.allUserOptions.length; i++) {
            const opt = this.allUserOptions[i];
            if (opt.value === this.myQueueId) {
                opt.isSelected = true;
            } else {
                opt.isSelected = false;
            }
        }
    }
    clearSelection() {
        for (let i = 0; i < this.allUserOptions.length; i++) {
            const opt = this.allUserOptions[i];
            opt.isSelected = false;
        }
    }
    toggleOption(e) {
        const key = e.detail.key;
        const isSelected = e.detail.isSelected;

        for (let i = 0, len = this.allUserOptions.length; i < len; i++) {
            const opt = this.allUserOptions[i];
            if (opt.label + ';' + opt.value === key) {
                opt.isSelected = isSelected;
            }
        }
    }
    unselectByPill(e) {
        const removedIndex = e.detail.index;
        const elem = this.selectedUserOptions[removedIndex];
        elem.isSelected = false;
    }

    // Close modal when clicking out - must make sure click wasn't another item in modal
    closeModalTimeout = null;
    clickedOutOfModal() {
        this.closeModalTimeout = setTimeout(() => {
            this.setDropdownState(false);
        }, 40);
    }
    clickedInModal() {
        if (this.closeModalTimeout != null) {
            clearTimeout(this.closeModalTimeout);
        }
    }

    // Change dropdown state
    toggleDropdown() {
        this.setDropdownState(null);
    }
    setDropdownState(shouldOpen) {
        const openClass = 'slds-is-open';

        const dropdown = this.template.querySelector('.slds-dropdown-trigger');
        const isOpen = dropdown.classList.contains(openClass);
        if (shouldOpen == null) {
            if (isOpen) {
                dropdown.classList.remove(openClass);
            } else {
                dropdown.classList.add(openClass);
            }
        } else {
            if (shouldOpen) {
                if (!isOpen) {
                    dropdown.classList.add(openClass);
                }
            } else {
                if (isOpen) {
                    dropdown.classList.remove(openClass);
                }
            }
        }
    }

    // Raise changeusers event
    applyChanges() {
        const userIds = [];
        for (let i = 0; i < this.selectedUserOptions.length; i++) {
            const opt = this.selectedUserOptions[i];
            userIds.push(opt.value);
        }
        this.dispatchEvent(new CustomEvent('changeusers', {detail: userIds}));
    }
}
