const {jestConfig} = require('@salesforce/sfdx-lwc-jest/config');

module.exports = {
    ...jestConfig,
    // reference: https://github.com/trailheadapps/lwc-recipes/issues/583
    moduleNameMapper: {
        '^@salesforce/apex$': '<rootDir>/force-app/main/default/test/jest-mocks/apex',
        '^@salesforce/schema$': '<rootDir>/force-app/main/default/test/jest-mocks/schema',
        '^lightning/navigation$': '<rootDir>/force-app/main/default/test/jest-mocks/lightning/navigation',
        '^lightning/platformShowToastEvent$':
            '<rootDir>/force-app/main/default/test/jest-mocks/lightning/platformShowToastEvent',
        '^lightning/uiRecordApi$': '<rootDir>/force-app/main/default/test/jest-mocks/lightning/uiRecordApi',
        '^lightning/messageService$': '<rootDir>/force-app/main/default/test/jest-mocks/lightning/messageService',
        '^lightning/actions$': '<rootDir>/force-app/main/default/test/jest-mocks/lightning/actions',
        '^lightning/alert$': '<rootDir>/force-app/main/default/test/jest-mocks/lightning/alert',
        '^lightning/confirm$': '<rootDir>/force-app/main/default/test/jest-mocks/lightning/confirm',
        '^lightning/prompt$': '<rootDir>/force-app/main/default/test/jest-mocks/lightning/prompt',
        '^lightning/modal*': '<rootDir>/force-app/main/default/test/jest-mocks/lightning/modal',
        '^lightning/refresh$': '<rootDir>/force-app/main/default/test/jest-mocks/lightning/refresh',
    },
    modulePathIgnorePatterns: ['<rootDir>/.localdevserver'],
};
