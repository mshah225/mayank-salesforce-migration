const {jestConfig} = require('@salesforce/sfdx-lwc-jest/config');

module.exports = {
    ...jestConfig,
    // reference: https://github.com/trailheadapps/lwc-recipes/issues/583
    moduleNameMapper: {
        '^@salesforce/apex$': '<rootDir>/force-app/main/default/lwc/__jestMocks__/apex',
        '^@salesforce/schema$': '<rootDir>/force-app/main/default/lwc/__jestMocks__/schema',
        '^lightning/navigation$': '<rootDir>/force-app/main/default/lwc/__jestMocks__/lightning/navigation',
        '^lightning/platformShowToastEvent$':
            '<rootDir>/force-app/main/default/lwc/__jestMocks__/lightning/platformShowToastEvent',
        '^lightning/uiRecordApi$': '<rootDir>/force-app/main/default/lwc/__jestMocks__/lightning/uiRecordApi',
        '^lightning/messageService$': '<rootDir>/force-app/main/default/lwc/__jestMocks__/lightning/messageService',
        '^lightning/actions$': '<rootDir>/force-app/main/default/lwc/__jestMocks__/lightning/actions',
        '^lightning/alert$': '<rootDir>/force-app/main/default/lwc/__jestMocks__/lightning/alert',
        '^lightning/confirm$': '<rootDir>/force-app/main/default/lwc/__jestMocks__/lightning/confirm',
        '^lightning/prompt$': '<rootDir>/force-app/main/default/lwc/__jestMocks__/lightning/prompt',
        '^lightning/modal*': '<rootDir>/force-app/main/default/lwc/__jestMocks__/lightning/modal',
        '^lightning/refresh$': '<rootDir>/force-app/main/default/lwc/__jestMocks__/lightning/refresh',
    },
    modulePathIgnorePatterns: ['<rootDir>/.localdevserver'],
};
