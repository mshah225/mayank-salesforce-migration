/**
 * Because custom metadata cannot be inserted for tests, this test class is limited
 * cannot test that it correctly maps the metadata records.
 * However, we still are able to test the testOverride functionality and ensure things
 * like the master toggle work as intended
 */
@isTest
public class FeatureFlagServiceTest {
    @isTest
    private static void testTrueFeatureFlag() {
        FeatureFlagService.overrideTestDefault('Feature Flag Test', 'True', true);
        Assert.areEqual(true, FeatureFlagService.isEnabled('Feature Flag Test', 'True'));
    }

    @isTest
    private static void testFalseFeatureFlag() {
        FeatureFlagService.overrideTestDefault('Feature Flag Test', 'False', false);
        Assert.areEqual(false, FeatureFlagService.isEnabled('Feature Flag Test', 'False'));
    }

    @isTest
    private static void testMasterFeatureFlag() {
        FeatureFlagService.overrideTestDefault('Feature Flag Test', 'True', true);
        FeatureFlagService.overrideTestDefault('Feature Flag Test', 'Master', false);
        Assert.areEqual(false, FeatureFlagService.isEnabled('Feature Flag Test', 'True')); // false b/c master override
    }

    @isTest
    private static void testMultipleFeatures() {
        FeatureFlagService.overrideTestDefault('Feature Flag Test', 'a', false);
        FeatureFlagService.overrideTestDefault('Feature Flag Test', 'b', false);
        FeatureFlagService.overrideTestDefault('Feature Flag Test', 'c', true);

        Assert.areEqual(false, FeatureFlagService.isEnabled('Feature Flag Test', 'a'));
        Assert.areEqual(false, FeatureFlagService.isEnabled('Feature Flag Test', 'b'));
        Assert.areEqual(true, FeatureFlagService.isEnabled('Feature Flag Test', 'c'));
    }

    @isTest
    private static void testMultipleContexts() {
        FeatureFlagService.overrideTestDefault('Feature Flag Test', 'a', false);
        FeatureFlagService.overrideTestDefault('Feature Flag Test 2', 'b', false);
        FeatureFlagService.overrideTestDefault('Feature Flag Test 3', 'c', true);

        Assert.areEqual(false, FeatureFlagService.isEnabled('Feature Flag Test', 'a'));
        Assert.areEqual(false, FeatureFlagService.isEnabled('Feature Flag Test 2', 'b'));
        Assert.areEqual(true, FeatureFlagService.isEnabled('Feature Flag Test 3', 'c'));
    }

    @isTest
    private static void testNonexistantContext() {
        Assert.areEqual(false, FeatureFlagService.isEnabled('Feature Flag Test', 'a')); // default to false

        List<Case> errorCases = new List<Case>([SELECT Id, Subject, Description FROM Case]);

        Assert.isFalse(errorCases.isEmpty(), 'Should have created error logger case'); // created error logger case
        for (Case c : errorCases) {
            Assert.isTrue(c.Subject.contains('FeatureFlagServiceException'));
            Assert.isTrue(
                c.Description.contains(
                    'Could not verify if feature flag feature flag test:a is enabled or not. Context feature flag test is invalid'
                )
            );
        }
    }

    @isTest
    private static void testNonExistantFeature() {
        FeatureFlagService.overrideTestDefault('Feature Flag Test', 'a', false);

        Assert.areEqual(false, FeatureFlagService.isEnabled('Feature Flag Test', 'b')); // default to false

        List<Case> errorCases = new List<Case>([SELECT Id, Subject, Description FROM Case]);

        Assert.isFalse(errorCases.isEmpty(), 'Should have created error logger case'); // created error logger case
        for (Case c : errorCases) {
            Assert.isTrue(c.Subject.contains('FeatureFlagServiceException'));
            Assert.isTrue(
                c.Description.contains(
                    'Could not verify if feature flag feature flag test:b is enabled or not. Feature b is invalid'
                )
            );
        }
    }
}
