exports.handler = async (event, context) => {
    let response = {
        isAuthorized: false,
        context: {
            AuthInfo: 'defaultdeny',
        },
    };
    console.log(event.headers.authorization);
    console.log(event.headers.repository);
    if (event.headers.authorization === 'AUTH_TOKEN' && event.headers.repository === 'ASU/crm-salesforce-enterprise') {
        response = {
            isAuthorized: true,
            context: {
                AuthInfo: 'Customer1',
            },
        };
    }
    return response;
};
