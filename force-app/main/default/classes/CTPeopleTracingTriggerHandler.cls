public with sharing class CTPeopleTracingTriggerHandler {
   public static void beforeInsert(List<People_Tracing__c> newRecords){
        List<People_Tracing__c> duplicatesFound = CTPeopleTracingController.checkDuplicates(newRecords);
        for(People_Tracing__c trace:duplicatesFound){
            trace.addError('Duplicate found, Person 1: '+ trace.Person_1__c +' and Person 2: '+ trace.Person_2__c);
        }
   }
}