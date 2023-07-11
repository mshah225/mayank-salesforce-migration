/*eslint no-console: "error"*/
import { LightningElement, track, wire, api } from 'lwc';
import contactTags from "@salesforce/apex/TaggingComponentController.contactTags";
import fetchTags from "@salesforce/apex/TaggingComponentController.fetchTags";
import updateTag from "@salesforce/apex/TaggingComponentController.updateTag";
import removeTag from "@salesforce/apex/TaggingComponentController.removeTag";
import tagRemovalReason from "@salesforce/apex/TaggingComponentController.tagRemovalReason";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';




export default class TaggingComponent extends LightningElement {
    @api recordId;
    @api selectedTag;
    @api selectedTagId;
    @track contactTagList;
    @track tagList;
    @track tagSearch = "";
    @track tagFinalList;
    @track tagSearchKey = "";
    @track clickedButtonLabel;
    @track tagRemovalReasonSelected;
    @track boolShowPopover = false;
    @track tagRemovalOptions;
    @track currentSelectedTag;


    handleKeyUp(event) {
        const tagSearch = event.target.value;
        this.tagSearch = tagSearch;
    }

    connectedCallback() {
        //This method loads all the tags on page load of the respective conatctId
        contactTags({ recordId: this.recordId })
            .then((result) => {
                if (result) {
                    console.log("result before Map" + result);
                    var obj = result;
                    var renderFormat = [];
                    let _data = [];
                    for (var key in obj) {
                        if (obj.hasOwnProperty(key)) {
                            //Creating a temp object to get all the field values
                            // EPSF- 5016 :Chanegd the query to add all the Benefit Level Fields i.e : Benefit_Level__c,Benefit_Applied__c,Benefit_Level_Icon__c
                                    console.log('Inside records which has affiliations');
                                    var tempJson = {
                                        label: key ? key : '',
                                        color: "background-color:" + obj[key].Tag__r.Color__c + ";" + "color:" + obj[key].Tag__r.Tag_Label_Color__c ? "background-color:" + obj[key].Tag__r.Color__c + ";" + "color:" + obj[key].Tag__r.Tag_Label_Color__c : '',
                                        image: obj[key].Tag__r.Tag_Icon_URL__c ? obj[key].Tag__r.Tag_Icon_URL__c : '',
                                        title: obj[key].Tag__r.Tag_Description__c ? obj[key].Tag__r.Tag_Description__c : '',
                                        isVerified: obj[key].isVerified__c ? obj[key].isVerified__c : false,
                                        isRemovable: obj[key].Tag__r.Removeable__c ? obj[key].Tag__r.Removeable__c : '',
                                        verifiedIcon: obj[key].Verification__c ? obj[key].Verification__c : '',
                                        benefitLevel: obj[key].Affiliation__c == null  ? '' : "-BL"+ obj[key].Affiliation__r.Benefits_Level__r.Benefits_Level__c
                                    }


                                    renderFormat.push(tempJson);
                                    console.log('renderFormat' + renderFormat);

                        }
                        //This line is used to sort the tag which are verified on the UI.
                        _data = renderFormat.map((a) => { if (a.isVerified) { a.sortBy = 1; } else { a.sortBy = 0; } return a; }).sort((a, b) => b.sortBy - a.sortBy)
                        console.log('_data' + _data);
                    }


                    console.log('_data after the temp json creation' + _data);
                    this.contactTagList = _data;

                }
            }).catch((error) => {
                this.error = error;
            });

        tagRemovalReason()
            .then((result) => {
                if (result) {
                    var obj = JSON.parse(result);
                    var renderFormattwo = [];
                    for (var key in obj) {
                        if (obj.hasOwnProperty(key)) {
                            //Creating a temp object to get all the field values
                            var tempJson = {
                                label: key,
                                value: obj[key]

                            }
                            renderFormattwo.push(tempJson);

                        }

                    }
                    this.tagRemovalOptions = renderFormattwo;

                }

            })
            .catch((error) => {
                this.error = error;
                this.tagList = undefined;
            });
    }


    //This method updates the tag selected on UI 
    onTagSelection(event) {
        this.selectedTagId = event.target.dataset.key;
        this.selectedTag = event.target.dataset.name;
        this.tagSearchKey = "";
        this.onSelectedTagUpdate();
        this.insertTag();
    }

    //This method resets the seachTag on the UI
    onLeave(event) {
        setTimeout(() => {
            this.tagSearchKey = "";
            this.tagFinalList = null;
        }, 300);
    }

    //This method is used to Handle the TagSearch and Capture the TagSeach Text
    handleTagSearch(event) {
        const tagSearchKey = event.target.value;
        this.tagSearchKey = tagSearchKey;
        this.getContactTags();

    }

    //Method is there to remove the tag on UI 
    removeTagName(event) {
        this.tagSearchKey = "";
        this.selectedTag = null;
        this.selectedTagId = null;
        this.onSelectedTagUpdate();
    }

    //This method takes the tagSeachKey as a parameter and shows the result which tag can be searched on UI
    getContactTags() {
        fetchTags({ tagSearch: this.tagSearchKey })
            .then((result) => {
                var formattedArray = [];
                var tagList = result;
                tagList.forEach((element, iter) => {
                    var temp = {
                        id: iter,
                        name: element
                    }
                    formattedArray.push(temp);

                });

                this.tagFinalList = formattedArray;

            })
            .catch((error) => {
                this.error = error;
                this.tagList = undefined;
            });
    }

    //This method updates the TagSearched on the UI
    onSelectedTagUpdate() {
        const passEventr = new CustomEvent("recordselection", {
            detail: {
                selectedTagId: this.selectedTagId,
                selectedTag: this.selectedTag
            }
        });
        this.dispatchEvent(passEventr);
    }

    //This method inserts the tag onto the ContactTag__c Object
    insertTag() {
        updateTag({ tag: this.selectedTag, recordId: this.recordId })
            .then((result) => {
                if (result == "Success") {
                    const event = new ShowToastEvent({
                        "title": "Success",
                        "message": "Record Inserted",
                        variant: 'Success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    this.connectedCallback();

                }
                else if (result == "Error") {
                    const event = new ShowToastEvent({
                        "title": "error",
                        "message": "Can't udpate this tag",
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                }
            })
            .catch((error) => {
                this.error = error;
                this.tagList = undefined;
            });
    }

    //Captures the TagName/Label and does the updation on ContactTag__c Object
    captureTagLabel(event) {
        this.clickedButtonLabel = event.target.dataset.id;
        this.removeTagFromUI();
        this.isModalOpen = false;
    }

    @track isModalOpen = false;
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }


    onSelectedReason(event) {
        this.tagRemovalReasonSelected = event.target.value;
    }


    //This method here is used to update the ContactTag on ContactTag object and will uncheck and update the ineffective date on ContactTag__c Object
    removeTagFromUI() {
        removeTag({ tag: this.clickedButtonLabel, recordId: this.recordId, tagRemovalReason: this.tagRemovalReasonSelected })
            .then((result) => {
                if (result == "Success") {
                    const event = new ShowToastEvent({
                        "title": "Success",
                        "message": "Tag removed succesfully",
                        variant: 'Success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    this.boolShowPopover = false;
                    this.connectedCallback();
                }
                else if (result == "Error") {
                    const event = new ShowToastEvent({
                        "title": "error",
                        "message": "Tag can't be removed",
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                }
            })
            .catch((error) => {
                this.error = error;
                this.tagList = undefined;
            });
    }

    //This method is used to pop the modal on click of the tag for the tag description.
    ModalPopOver(event) {
        this.boolShowPopover = true;
        this.currentSelectedTag = {
            title: event.target
                && event.target.dataset ? event.target.dataset.title : '',
            color: event.target
                && event.target.dataset ? event.target.dataset.color : '',
            label: event.target
                && event.target.dataset ? event.target.dataset.label : '',
            image: event.target
                && event.target.dataset ? event.target.dataset.image : ''
        };



    }


    //This method is used to close the modal on click of the tag for the tag description.
    ModalPopUpClose(event) {
        this.boolShowPopover = false;
        this.currentSelectedTag = {
            title: '',
            color: '',
            label: '',
            image: ''
        };
    }
}