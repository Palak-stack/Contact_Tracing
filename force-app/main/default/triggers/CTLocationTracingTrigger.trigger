trigger CTLocationTracingTrigger on Location_Tracing__c (before insert) {
    SWITCH ON Trigger.operationType{
        WHEN BEFORE_INSERT{
            CTLocationTracingTriggerHandler.beforeInsert(Trigger.New);
        }
    }
}