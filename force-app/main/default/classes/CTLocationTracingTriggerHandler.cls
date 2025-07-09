public with sharing class CTLocationTracingTriggerHandler {
    public static void beforeInsert(List<Location_Tracing__c> newRecords){
        List<Location_Tracing__c> duplicateRecords = CTLocationTracingController.checkDuplicates(newRecords);
        for(Location_Tracing__c duplicateFound:duplicateRecords){
            duplicateFound.addError('Duplicate Location Tracing Record found where Location: ' +duplicateFound.Location__c +' and Person: '+ duplicateFound.Person__c );
        }
    }
}