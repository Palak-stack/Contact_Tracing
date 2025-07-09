trigger CTPeopleTracingTrigger on People_Tracing__c (before insert) {
    SWITCH ON Trigger.Operationtype{
        when BEFORE_INSERT{
            CTPeopleTracingTriggerHandler.beforeInsert(Trigger.New);
        }
    }
}