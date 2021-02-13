public with sharing class DuoUtil {
    /**
     * Formats a provided Datetime in the RFC2822 format
     *
     * @param dateToFormat a Datetime instance to format
     *
     * @return a String representation of the provided Datetime in RFC2822
     */
    public static String formatAsRFC2822(Datetime dateToFormat, String timezone) {
        String RFC2822_FORMAT = 'E, dd MMM YYYY hh:mm:ss Z';

        return dateToFormat.format(RFC2822_FORMAT, timezone);
    }

    /**
     * Url encodes the key value pairs from a Map collection
     *
     * @param params a Map of parameters to url encode
     *
     * @return a UTF-8 encoded url string of the provided parameters
     */
    public static String urlEncodeParams(Map<String, Object> params) {
        String urlParams = '';

        for (String param : params.keySet()) {
            urlParams += param + '=' + String.valueOf(params.get(param)) + '&';
        }

        urlParams = urlParams.substringBeforeLast('&');

        return EncodingUtil.urlEncode(urlParams, 'UTF-8');
    }

    /**
     * Parses a successful response from the Duo API and reads the value as
     * the provided ApexType
     *
     * @param body an HttpResponse body from a DuoRequest
     * @param success an ApexType that defines the response we're looking for
     *
     * @return an Object defining the response from the Duo API
     */
    public static Object parseResponse(String body, Type success) {
        JSONParser parser = JSON.createParser(body);

        while (parser.nextToken() != null) {
            if (parser.getCurrentName() == 'response') {
                break;
            } else {
                parser.nextToken();
            }
        }

        return parser.readValueAs(success);
    }
}
