/**
 * FeatureFlagService
 *
 * This class is a helper class for interacting with our custom metadata (Feature_Flag__mdt) that allows
 * Admins to toggle features on and off without needing to make code changes.
 *
 * The primary use is the isEnabled(String context, String feature) function.
 * Whenever you need to check if a feature is enabled, this function will return either true or false.
 * If the feature does not exist, then it will make an error logger case and return false
 *
 * Feature flags are case insensitive.
 *
 * Notes:
 * Custom metadata queries do not count against the SOQL governor limits, so the primary usage of the cache is
 * to enable test-context overrides rather than to minimize redundant SOQL queries.
 *
 * Test Contexts:
 * In Salesforce, you cannot insert test custom metadata, and must use whatever custom metadata already exists in the org,
 * conveniently this is what we want in most cases (since we don't want to have to update all test classes to make fake
 * test metadata for all feature flags).
 *
 * Whenever a test needs to forcefully set a feature flag, it can use the overrideTestDefault function, which allows you
 * to set a feature to either enabled or disabled while in the test context. This is useful for writing tests that
 * specifically need to test toggle-able functionality.
 *
 * Keep in mind this overriding must occur on the @isTest-function-level rather than in the @TestSetup function,
 * since the variables used to store the test override will be reset for each @isTest function.
 */
public with sharing class FeatureFlagService {
    //                context     feature  enabled
    private static Map<String, Map<String, Boolean>> cachedFlags = new Map<String, Map<String, Boolean>>();

    /**
     * Check is a feature flag is enabled or not
     * @param context What context are we asking from (such as "Case Trigger")?
     * @param feature Which feature are we asking about?
     *
     * @warning Error logs if any exceptions occur, such as if feature and or context does not exist
     *
     * @return true if the feature is enabled, false if it is disabled (default to false)
     */
    public static Boolean isEnabled(String context, String feature) {
        try {
            context = context.toLowerCase();
            feature = feature.toLowerCase();

            // Populate feature flags for the context
            populateFeatureFlagsFor(context);

            // If context is invalid throw an error
            if (!cachedFlags.containsKey(context)) {
                throw new FeatureFlagServiceException(
                    'Could not verify if feature flag ' +
                        context +
                        ':' +
                        feature +
                        ' is enabled or not. Context ' +
                        context +
                        ' is invalid'
                );
            }

            // If context-feature pairing is invalid throw an error
            if (!cachedFlags.get(context).containsKey(feature))
                throw new FeatureFlagServiceException(
                    'Could not verify if feature flag ' +
                        context +
                        ':' +
                        feature +
                        ' is enabled or not. Feature ' +
                        feature +
                        ' is invalid'
                );

            // The context override - if it exists and is false, then all features for that context are disabled
            Boolean contextFeatureFlag = cachedFlags.get(context).containsKey('master')
                ? cachedFlags.get(context).get('master')
                : true;
            // The flag for the specific feature
            Boolean specificFeatureFlag = cachedFlags.get(context).get(feature);

            // Return the value
            return contextFeatureFlag && specificFeatureFlag;
        } catch (Exception ex) {
            // If any error happens, make an error logger case and return false (if error occurs, this means we assume the functionality is disabled by default)
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('context', context));
            vars.add(ErrorLogger.convertStringToJSON('feature', feature));
            ErrorLogger.log(ex, vars, false);
            return false;
        }
    }

    /**
     * Forcefully set a feature flag value in a test context.
     *
     * @param context What context are we overriding the state for?
     * @param feature Which feature are we changing the state for?
     * @param enabled Should this feature be forcefully enabled?
     */
    @TestVisible
    private static void overrideTestDefault(String context, String feature, Boolean enabled) {
        context = context.toLowerCase();
        feature = feature.toLowerCase();

        // Populate feature flags for the context
        populateFeatureFlagsFor(context);
        // Set an overrided value
        if (!cachedFlags.containsKey(context))
            cachedFlags.put(context, new Map<String, Boolean>());
        cachedFlags.get(context).put(feature, enabled);
    }

    /**
     * Populate the feature flags for a specific context.
     * For each context, this will search for the existing metadata
     * records and add them to the cache.
     *
     * @param context What context to retrieve custom metadata for?
     */
    private static void populateFeatureFlagsFor(String context) {
        context = context.toLowerCase();

        if (!cachedFlags.containsKey(context)) {
            List<Feature_Flag__mdt> flags = [
                SELECT Feature__c, Enabled__c
                FROM Feature_Flag__mdt
                WHERE Context__c = :context
            ];

            // only add if it exists (since we want to detect nonexistant contexts)
            if (!flags.isEmpty())
                cachedFlags.put(context, new Map<String, Boolean>());

            // Add each flag to cache
            for (Feature_Flag__mdt flag : flags)
                cachedFlags.get(context).put(flag.Feature__c.toLowerCase(), flag.Enabled__c);
        }
    }

    public class FeatureFlagServiceException extends Exception {
    }
}