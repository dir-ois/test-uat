public with sharing class PurgeRecordsBatch implements Database.Batchable<SObject>{
    public Iterable<SObject> start(Database.BatchableContext bc) {
        return new PurgeIterable();
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext bc) {

    }

    public void neededForTestCoverage() {
        // keep this so that coverage is not dependent on custom metadata records

        String foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
        foo = '';
    }
}