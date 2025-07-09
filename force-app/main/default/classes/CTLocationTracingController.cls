public with sharing class CTLocationTracingController {
    
    public static List<Location_Tracing__c> getVisitors(String locationId){
        return  [SELECT Id,Location__c,Name,Person__c,Visit_Date__c,Person__r.Token__c, Person__r.Health_Status__c FROM Location_Tracing__c where Location__c  =:locationId ORDER BY Visit_Date__c DESC NULLS LAST];
    }

    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> personIds){
         return  [SELECT Id,Location__c,Name,Person__c,Visit_Date__c FROM Location_Tracing__c where Person__c IN :personIds AND Visit_Date__c = LAST_N_DAYS:10];
    }

    public static List<Location_Tracing__c> getLocationsByLocationIds(Set<Id> locationIds){
        return [SELECT Id,Location__c,Name,Person__c,Visit_Date__c FROM Location_Tracing__c where Location__c IN :locationIds AND Person__r.Health_Status__c = 'Green' AND Visit_Date__c = LAST_N_DAYS:10];
    }

   public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newTraces) {
    // Step 1: Collect unique location and person IDs from incoming list
    Set<Id> locationIds = new Set<Id>();
    Set<Id> personIds = new Set<Id>();
    for (Location_Tracing__c trace : newTraces) {
        locationIds.add(trace.Location__c);
        personIds.add(trace.Person__c);
    }

    // Step 2: Query existing records matching these Location-Person combinations
    // Add Visit_Date__c filter if time-bound duplication is required
    List<Location_Tracing__c> existingRecords = [
        SELECT Id, Location__c, Person__c
        FROM Location_Tracing__c
        WHERE Location__c IN :locationIds
          AND Person__c IN :personIds
          // Uncomment below if needed
          // AND Visit_Date__c = LAST_N_DAYS:10
    ];

    // Step 3: Build map of existing Location__c -> Set of Person__c
    Map<Id, Set<Id>> existingMap = new Map<Id, Set<Id>>();
    for (Location_Tracing__c trace : existingRecords) {
        if (!existingMap.containsKey(trace.Location__c)) {
            existingMap.put(trace.Location__c, new Set<Id>());
        }
        existingMap.get(trace.Location__c).add(trace.Person__c);
    }

    // Step 4: Compare new entries to existing map to find duplicates
    List<Location_Tracing__c> duplicateTraces = new List<Location_Tracing__c>();
    for (Location_Tracing__c trace : newTraces) {
        Set<Id> existingPersons = existingMap.get(trace.Location__c);
        if (existingPersons != null && existingPersons.contains(trace.Person__c)) {
            duplicateTraces.add(trace);
        }
    }

    return duplicateTraces;
}

}