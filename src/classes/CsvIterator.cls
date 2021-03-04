public with sharing class CsvIterator implements Iterator<String>, Iterable<String> {
    private String csvData;
    private String introValue;

    public CsvIterator(String fileData, String introValue) {
        this.csvData = fileData;
        this.introValue = introValue;
    }

    public Boolean hasNext() {
        return csvData.length() > 1;
    }

    public String next() {
        String row;
        if (hasNextFullLine()) {
            row = nextFullLine();
        } else {
            row = csvData;
            csvData = '';
        }
        return row;
    }

    private Boolean hasNextFullLine() {
        return csvData.indexOf(introValue) > -1;
    }

    private String nextFullLine() {
        Integer indexOfIntroValue = csvData.indexOf(introValue);
        String nextFullLine = csvData.subString(0, indexOfIntroValue);
        csvData = csvData.subString(indexOfIntroValue + introValue.length(), csvData.length());
        return nextFullLine;
    }

    public Iterator<String> Iterator() {
        return this;
    }
}
