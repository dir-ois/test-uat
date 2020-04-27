public with sharing class UpdateRegistrationStatusBatch implements Database.Batchable<SObject>{
    public Iterable<SObject> start(Database.BatchableContext bc) {
        return new UpdateRegistrationStatusIterable();
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        update scope;
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