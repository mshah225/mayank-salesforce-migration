public with sharing class CsvIterator implements Iterator<String>, Iterable<String> {
    private String csvData;
    private String introValue;
    
    public CsvIterator(String fileData, String introValue) {
        this.csvData = fileData;
        this.introValue = introValue;
    }

    public Boolean hasNext() {
        return csvData.length() > 1 ? true : false;
    }

    public String next() {
        String row;
        if (csvData.indexOf(introValue) > -1) {
            row = csvData.subString(0, csvData.indexOf(introValue));
            csvData = csvData.subString(csvData.indexOf(introValue) + introValue.length(), csvData.length());
        } else {
            row = csvData;
            csvData = '';
        }
        return row;
    }

    public Iterator<String> Iterator() {
        return this;
    }
}
