({
    afterRender: function (component, helper) {
        this.superAfterRender();
    },

    rerender: function (component, helper) {
        this.superRerender();

        helper.windowClick = function (e) {
            //If its normal div element, close drodown
            if (e.currentTarget.toString().includes('combobox-drop')) {
                helper.closeDropdown(component);
                //Remove event listner so that it doesn't interfere in other clicks in remaining document
                document.removeEventListener('click', helper.windowClick);
            } else {
                //do nothing, helper methods will handle click of icon
            }
        };
        document.addEventListener('click', helper.windowClick);
    },
});
