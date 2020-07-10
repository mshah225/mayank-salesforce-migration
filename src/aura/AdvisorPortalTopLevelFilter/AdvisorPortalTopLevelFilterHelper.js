({
    setCountSelected: function (component) {
       
        let countSelected = 0;
        let allUserOpts = component.get("v.AllUserOptions");

        allUserOpts.forEach((option) => {
            if (!option.isHeader && option.isSelected) {
                countSelected++;
            }
        });

        if (countSelected === 1) {
            component.find("top-combobox").set("v.placeholder", countSelected + " option selected");
        } else if (countSelected > 0) {
            component.find("top-combobox").set("v.placeholder", countSelected + " options selected");
        } else {
            component.find("top-combobox").set("v.placeholder", "");
        }

        component.set("v.SelectedOptionsCount", countSelected);
                    
    },
    closeDropdown : function(component){
        component.set('v.isFilterClosed', true);
    }
})