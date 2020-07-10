public class ObjectScrambleBatch implements Database.Batchable<Sobject>, Database.Stateful, Database.AllowsCallouts {
    private String query;
    private CsvManager fileManager;
    private ObjectScrambleService scrambleService;

    private final Integer RECORDS_PER_CALLOUT = 10000;

    public ObjectScrambleBatch(ObjectScrambleService.objectTypes objectType) {
        scrambleService = new ObjectScrambleService(objectType);
        String header = scrambleService.getObjectHeader();
        fileManager = new CsvManager(header, RECORDS_PER_CALLOUT, objectType);

        this.query = scrambleService.getQueryFromObject();
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Sobject> scope) {
        for (Sobject objectToScramble : scope) {
            ObjectScramble scrambleRow;
            scrambleRow = scrambleService.getScrambleClassForObject(objectToScramble);
            scrambleRow.scrambleFields();
            String csvRow = scrambleRow.toCsvString();
            fileManager.addRow(csvRow);
        }
    }

    public void finish(Database.BatchableContext BC) {
        fileManager.closeJob();
    }

    public void setQuery(String query) {
        this.query = query;
    }
}
