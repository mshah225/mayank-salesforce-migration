/**
 * A helper class that provides utility methods to check if the current environment is a sandbox and retrieve sandbox-specific details.
 */
public with sharing class SandboxHelper {
    /**
     * Boolean property that indicates whether the current environment is a sandbox.
     *
     * @return True if the current environment is a sandbox; false otherwise.
     */
    public static Boolean isSandbox {
        get {
            if (isSandbox == null) {
                isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return isSandbox;
        }
        set;
    }

    /**
     * String property that retrieves the name of the sandbox, if applicable.
     *
     * @return The sandbox name if in a sandbox environment; an empty string otherwise.
     */
    public static String sandboxName {
        get {
            if (sandboxName == null) {
                // Get the actual sandbox name if in a sandbox environment
                if (isSandbox) {
                    String domain = URL.getOrgDomainUrl().toExternalForm();
                    sandboxName = System.DomainParser.parse(domain).getSandboxName() != null
                        ? System.DomainParser.parse(domain).getSandboxName()
                        : '';
                } else {
                    sandboxName = '';
                }
            }
            return sandboxName;
        }
        set;
    }

    /**
     * String property that retrieves the name of the sandbox instance.
     *
     * @return The sandbox instance name.
     */
    public static String sandboxInstanceName {
        get {
            if (sandboxInstanceName == null) {
                sandboxInstanceName = [SELECT InstanceName FROM Organization LIMIT 1].InstanceName;
            }
            return sandboxInstanceName;
        }
        set;
    }

    /**
     * Boolean property that checks if a valid sandbox field exists on the User object.
     *
     * @return True if the sandbox field exists on the User object; false otherwise.
     */
    public static Boolean hasValidSandboxField {
        get {
            if (hasValidSandboxField == null) {
                hasValidSandboxField = ObjectHelper.fieldExistsOnObject('User', sandboxFieldName);
            }
            return hasValidSandboxField;
        }
        set;
    }

    /**
     * String property that constructs the sandbox field name based on the sandbox name.
     *
     * @return The constructed sandbox field name.
     */
    public static String sandboxFieldName {
        get {
            if (sandboxName != null && sandboxName != '') {
                sandboxFieldName = 'Sandbox_' + sandboxName.toUpperCase() + '__c';
            }
            return sandboxFieldName;
        }
        set;
    }
}