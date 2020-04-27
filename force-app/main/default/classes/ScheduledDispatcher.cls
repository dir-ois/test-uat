global class ScheduledDispatcher implements Schedulable {
    public interface IScheduleDispatched {
        void execute(SchedulableContext sc);
    }

    global void execute(SchedulableContext sc) {
        Type targetType = Type.forName('createAccountForPublicWorksBatchSchedule');
        if (targetType != null) {
            IScheduleDispatched obj = (IScheduleDispatched)targetType.newInstance();
            obj.execute(sc);
        }
    }
}