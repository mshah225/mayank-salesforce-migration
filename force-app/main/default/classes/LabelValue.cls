/**
 * Simple label value pairing to return label-value pairs to LWCs
 * Often times you can just return a Map<String, String>. But if you care about order,
 * or need duplicates, you canr eturn a List<LabelValue>
 *
 * Also, if you return a list of these, you can apss the result from Apex directly into
 * a combobox without needing to convert from Map to List in JS.
 */
public class LabelValue {
    @AuraEnabled
    public String label;

    @AuraEnabled
    public String value;

    public LabelValue() {
    }
    public LabelValue(String l, String v) {
        label = l;
        value = v;
    }
}
