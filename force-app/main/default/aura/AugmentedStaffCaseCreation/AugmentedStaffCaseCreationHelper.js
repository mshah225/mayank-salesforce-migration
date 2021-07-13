({
    getPermissions: function (component) {
        var action = component.get('c.doesUserHavePermission');
        action.setCallback(this, function (response) {
            component.set('v.properPermission', response.getReturnValue());
        });
        $A.enqueueAction(action);
    },

    getCategoryOptions: function (component) {
        var action = component.get('c.getCategories');
        action.setCallback(this, function (response) {
            component.set('v.categoryOptions', response.getReturnValue());
            component.set('v.category', response.getReturnValue()[0].value);

            this.getSubCategoryOptions(component);
        });
        $A.enqueueAction(action);
    },

    getSubCategoryOptions: function (component) {
        var action = component.get('c.getSubCategories');
        action.setParams({
            category: component.get('v.category'),
        });
        action.setCallback(this, function (response) {
            component.set('v.subCategoryOptions', response.getReturnValue());
            component.set('v.subCategory', response.getReturnValue()[0].value);
        });
        $A.enqueueAction(action);
    },

    checkValidId: function (component) {
        var action = component.get('c.verifyStudentId');
        action.setParams({
            studentId: component.get('v.studentID'),
        });
        action.setCallback(this, function (response) {
            if (response.getReturnValue()) {
                component.set('v.foundStudent', 'true');
                component.set('v.studentNotFound', 'false');
            } else {
                component.set('v.studentNotFound', 'true');
                component.set('v.foundStudent', 'false');
            }
        });
        $A.enqueueAction(action);
    },

    createACase: function (component) {
        var action = component.get('c.createTheCase');
        action.setParams({
            description: component.get('v.description'),
            category: component.get('v.category'),
            subCategory: component.get('v.subCategory'),
            phoneNumber: component.get('v.phoneNumber'),
            studentID: component.get('v.studentID'),
            closed: component.get('v.caseClosed'),
        });
        action.setCallback(this, function (response) {
            if (response.getReturnValue()) {
                component.set('v.message', 'Case was created successfully!');
                this.clearFields(component);
            } else {
                component.set('v.message', 'There was a problem trying to create the case!');
            }
        });
        $A.enqueueAction(action);
    },

    clearFields: function (component) {
        this.getCategoryOptions(component);
        this.getSubCategoryOptions(component);
        component.set('v.studentID', '');
        component.set('v.phoneNumber', '');
        component.set('v.description', '');
        component.set('v.caseClosed', 'false');
        component.set('v.studentNotFound', 'false');
        component.set('v.foundStudent', 'false');
    },
});
