public class LogSuite {
    private static Set<String> activeLogTypes = new Set<String>();
    private static String testflowName = '';

    public static void activateLogType(String logType) {
        activeLogTypes.add(logType.toLowerCase());
    }

    public static void deactivateLogType(String logType) {
        activeLogTypes.remove(logType.toLowerCase());
    }

    public static void deactivateAllLogTypes() {
        activeLogTypes = new Set<String>();
    }

    public static void activateLogSuite(String logSuite) {
        if (logSuite == 'testflow') {
            activateLogType('DML');
            activateLogType('codeflow');
            activateLogType('query');
            activateLogType('testname');
            activateLogType('runstats');
        }
    }

    public static void activateTestFlowSuite(String testname) {
        testflowName = testname;
        activateLogSuite('testflow');
        log('testname', 'Starting test ' + testflowName);
    }

    public static void deactivateTestFlowSuite() {
        log('testname', 'Finishing test ' + testflowName);
        testflowName = '';
        deactivateAllLogTypes();
    }

    public static void log(String logType, String message) {
        if (activeLogTypes.contains(logType.toLowerCase())) {
            System.debug('LOGSUITE: ' + logType.toUppercase() + ' - ' + message);
        }
    }

    public static void loUntuncated(String sMsg) {
        for (Integer i = 0; i < sMsg.length(); i = i + 300) {
            Integer iEffectiveEnd = (i + 300 > (sMsg.length()) ? sMsg.length() : i + 300);
            System.debug(sMsg.substring(i, iEffectiveEnd));
        }
    }
}
