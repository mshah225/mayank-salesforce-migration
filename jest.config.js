const {jestConfig} = require('@salesforce/sfdx-lwc-jest/config');

module.exports = {
    ...jestConfig,
    modulePathIgnorePatterns: ['<rootDir>/.localdevserver'],
    // Maps mock test items
    moduleNameMapper: {
        '^lightning/modal$': '<rootDir>/force-app/main/default/lwc/__jestMocks__/lightning/modal',
        '^lightning/modalHeader$': '<rootDir>/force-app/main/default/lwc/__jestMocks__/lightning/modalHeader',
        '^lightning/modalBody$': '<rootDir>/force-app/main/default/lwc/__jestMocks__/lightning/modalBody',
        '^lightning/modalFooter$': '<rootDir>/force-app/main/default/lwc/__jestMocks__/lightning/modalFooter',
    },
};
