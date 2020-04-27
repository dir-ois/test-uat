public with sharing class PurgeRecordsScheduler implements Schedulable {
    public interface ISchedulePurge {
        void execute(SchedulableContext sc);
    }

    public void execute(SchedulableContext sc) {
        Type targetType = Type.forName('PurgeRecords');
        if (targetType != null) {
            ISchedulePurge obj = (ISchedulePurge)targetType.newInstance();
            obj.execute(sc);
        }
    }
}