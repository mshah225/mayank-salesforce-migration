({
    afterRender: function (component, helper) {
        this.superAfterRender();

        let j$ = jQuery.noConflict();
        let dateFormat = 'mm/dd/yy',
            from = j$('#from')
                .datepicker({
                    defaultDate: '+1w',
                    changeMonth: true,
                    changeYear: true,
                    numberOfMonths: 1,
                })
                .on('change', function () {
                    to.datepicker('option', 'minDate', getDate(this, 'from'));
                }),
            to = j$('#to')
                .datepicker({
                    defaultDate: '+1w',
                    changeMonth: true,
                    changeYear: true,
                    numberOfMonths: 1,
                })
                .on('change', function () {
                    from.datepicker('option', 'maxDate', getDate(this, 'to'));
                });

        function getDate(element, attributeToSet) {
            let j$ = jQuery.noConflict();
            let date;

            try {
                date = j$.datepicker.parseDate(dateFormat, element.value);
            } catch (error) {
                date = null;
            }

            if (attributeToSet == 'from') {
                component.set('v.fromDate', date);
            } else {
                date.setHours(23);
                date.setMinutes(59);
                date.setSeconds(59);
                component.set('v.toDate', date);
            }
            return date;
        }
    },
});
