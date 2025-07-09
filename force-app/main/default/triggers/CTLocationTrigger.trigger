trigger CTLocationTrigger on Location__c (before insert, before update,after update) {
    switch ON Trigger.operationType{
        WHEN BEFORE_INSERT{
            CTLocationTriggerHandler.beforeInsert(Trigger.New);
        }
        WHEN BEFORE_UPDATE{
            CTLocationTriggerHandler.beforeUpdate(Trigger.New,Trigger.oldMap);
        }
        WHEN AFTER_UPDATE{
            CTLocationTriggerHandler.afterUpdate(Trigger.New,Trigger.oldMap);
        }
    }
}