/**
 * FeatureFlagService
 *
 * This class is a helper class for interacting with custom metadata (Feature_Flag__mdt) that allows
 * Admins to toggle features on and off without needing to make code changes.
 *
 * The primary use is the {@link #isEnabled(String, String)} function. This function checks if a feature
 * is enabled or not based on the provided context and feature names.
 *
 * Feature flags are case-insensitive.
 *
 * Notes:
 * Custom metadata queries do not count against the SOQL governor limits. The primary usage of the cache
 * is to enable test-context overrides rather than to minimize redundant SOQL queries.
 *
 * Test Contexts:
 * In Salesforce, you cannot insert test custom metadata, and must use existing custom metadata in the org.
 * This is generally preferred since it avoids the need to update all test classes with fake test metadata
 * for all feature flags.
 *
 * To forcefully set a feature flag during tests, use the {@link #overrideTestDefault(String, String, Boolean)}
 * function. This function allows setting a feature to either enabled or disabled while in the test context.
 * This is useful for writing tests that need to specifically test toggle-able functionality.
 *
 * Overriding must occur at the @isTest-function level rather than in the @TestSetup function, since the
 * variables used to store the test override will be reset for each @isTest function.
 */
public with sharing class FeatureFlagService {
    // Cached feature flags
    private static Map<String, Map<String, Boolean>> cachedFlags = new Map<String, Map<String, Boolean>>();
    private static Set<String> alreadySeenErrorMessages = new Set<String>();

    /**
     * Checks if a feature flag is enabled or not.
     *
     * @param context The context from which the feature is being requested (e.g., "Case Trigger").
     * @param feature The name of the feature being requested.
     * @return true if the feature is enabled, false if it is disabled (default to false if an error occurs).
     * @throws FeatureFlagServiceException if the context or feature is invalid.
     */
    public static Boolean isEnabled(String context, String feature) {
        Boolean DEFAULT_ENABLED = false;

        try {
            context = context.toLowerCase();
            feature = feature.toLowerCase();
            populateFeatureFlagsFor(context);

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

            if (!cachedFlags.get(context).containsKey(feature)) {
                throw new FeatureFlagServiceException(
                    'Could not verify if feature flag ' +
                        context +
                        ':' +
                        feature +
                        ' is enabled or not. Feature ' +
                        feature +
                        ' is invalid'
                );
            }

            Boolean contextFeatureFlag = cachedFlags.get(context).containsKey('master')
                ? cachedFlags.get(context).get('master')
                : true;
            Boolean specificFeatureFlag = cachedFlags.get(context).get(feature);

            return contextFeatureFlag && specificFeatureFlag;
        } catch (FeatureFlagServiceException ex) {
            if (alreadySeenErrorMessages.contains(ex.getMessage()))
                return DEFAULT_ENABLED;
            alreadySeenErrorMessages.add(ex.getMessage());

            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('context', context));
            vars.add(ErrorLogger.convertStringToJSON('feature', feature));
            ErrorLogger.log(ex, vars, false);
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('context', context));
            vars.add(ErrorLogger.convertStringToJSON('feature', feature));
            ErrorLogger.log(ex, vars, false);
        }
        return DEFAULT_ENABLED;
    }

    /**
     * Forcefully sets a feature flag value in a test context.
     *
     * @param context The context for which the state is being overridden.
     * @param feature The feature for which the state is being changed.
     * @param enabled The state to forcefully set the feature to (true for enabled, false for disabled).
     */
    @TestVisible
    private static void overrideTestDefault(String context, String feature, Boolean enabled) {
        context = context.toLowerCase();
        feature = feature.toLowerCase();
        populateFeatureFlagsFor(context);

        if (!cachedFlags.containsKey(context)) {
            cachedFlags.put(context, new Map<String, Boolean>());
        }
        cachedFlags.get(context).put(feature, enabled);
    }

    /**
     * Populates the feature flags for a specific context. This function queries the custom metadata records
     * and adds them to the cache.
     *
     * @param context The context for which to retrieve custom metadata.
     */
    private static void populateFeatureFlagsFor(String context) {
        context = context.toLowerCase();

        if (!cachedFlags.containsKey(context)) {
            List<Feature_Flag__mdt> flags = [
                SELECT Feature__c, Enabled__c
                FROM Feature_Flag__mdt
                WHERE Context__c = :context
            ];

            if (!flags.isEmpty()) {
                cachedFlags.put(context, new Map<String, Boolean>());
            }

            for (Feature_Flag__mdt flag : flags) {
                cachedFlags.get(context).put(flag.Feature__c.toLowerCase(), flag.Enabled__c);
            }
        }
    }

    /**
     * Exception class for FeatureFlagService errors.
     */
    public class FeatureFlagServiceException extends Exception {
    }
}
