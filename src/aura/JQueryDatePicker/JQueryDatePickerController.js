({
    handleResetForm: function (component, event, helper) {
        let j$ = jQuery.noConflict();
        if (!component.get('v.fromDate')) j$('#from').val('');
        if (!component.get('v.toDate')) j$('#to').val('');
    },
});
