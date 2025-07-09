public with sharing class CTPeopleTracingController {

    public static List<People_Tracing__c> getTraces(String personId){
        return [
            SELECT Contact_Date__c, Contact_Type__c, Name, Person_1__c, Person_2__c 
            FROM People_Tracing__c 
            WHERE Person_1__c = :personId OR Person_2__c = :personId 
            ORDER BY Contact_Date__c DESC NULLS LAST
        ];
    }

    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> peopleTraces){
        List<People_Tracing__c> duplicateTraces = new List<People_Tracing__c>();
        Set<Id> personIds = new Set<Id>();

        // Collect all Person_1__c and Person_2__c IDs from input traces
        for (People_Tracing__c trace : peopleTraces) {
            if (trace.Person_1__c != null) personIds.add(trace.Person_1__c);
            if (trace.Person_2__c != null) personIds.add(trace.Person_2__c);
        }

        // Query existing People_Tracing__c records involving the same people
        List<People_Tracing__c> existingRecords = [
            SELECT Id, Person_1__c, Person_2__c 
            FROM People_Tracing__c 
            WHERE Person_1__c IN :personIds OR Person_2__c IN :personIds
        ];

        // Build a map of PersonId -> Set of connected PersonIds
        Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();
        for (People_Tracing__c record : existingRecords) {
            // Add Person_2__c to Person_1__c's set
            if (!mapOfExistingRecords.containsKey(record.Person_1__c)) {
                mapOfExistingRecords.put(record.Person_1__c, new Set<Id>());
            }
            mapOfExistingRecords.get(record.Person_1__c).add(record.Person_2__c);

            // Add Person_1__c to Person_2__c's set
            if (!mapOfExistingRecords.containsKey(record.Person_2__c)) {
                mapOfExistingRecords.put(record.Person_2__c, new Set<Id>());
            }
            mapOfExistingRecords.get(record.Person_2__c).add(record.Person_1__c);
        }

        // Compare input traces with map to detect duplicates
        for (People_Tracing__c trace : peopleTraces) {
            Id p1 = trace.Person_1__c;
            Id p2 = trace.Person_2__c;

            if (
                (p1 != null && mapOfExistingRecords.containsKey(p1) && mapOfExistingRecords.get(p1).contains(p2)) ||
                (p2 != null && mapOfExistingRecords.containsKey(p2) && mapOfExistingRecords.get(p2).contains(p1))
            ) {
                duplicateTraces.add(trace);
            }
        }

        return duplicateTraces;
    }
}
