public class CTPersonController {
    public static String getToken(String phone) {
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(phone));
        return EncodingUtil.base64Encode(hash);
    }

    public static List<Person__c> getRecentHealthChanges() {
        List<Person__c> personList = [
            SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
            FROM Person__c
            ORDER BY Status_Update_Date__c DESC NULLS LAST
            LIMIT 100
        ];
        return personList;
    }

    public static List<Person__c> searchPeople(String searchTerm) {
        searchTerm = searchTerm + '%';
        List<Person__c> personList = [
            SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
            FROM Person__c
            WHERE Name LIKE :searchTerm OR Mobile__c LIKE :searchTerm OR Token__c LIKE :searchTerm
            ORDER BY Status_Update_Date__c DESC NULLS LAST
        ];
        return personList;
    }

    public static Person__c getPersonById(String personId) {
        List<Person__c> persons = [
            SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
            FROM Person__c
            WHERE Id = :personId
            LIMIT 1
        ];
        if (!persons.isEmpty()) {
            return persons[0];
        }
        return null;
    }

    public static Set<Id> getCohabitants(Set<Id> personIds, Set<Id> alreadyProcessedIds) {
        Set<Id> cohabitants = new Set<Id>();
        List<String> healthStatuses = new List<String>{ 'Green', 'Yellow' };

        for (People_Tracing__c pt : [
            SELECT Id, Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE
                (Person_1__c IN :personIds
                OR Person_2__c IN :personIds)
                AND Contact_Type__c = 'Cohabitant'
                AND (Person_1__r.Health_Status__c IN :healthStatuses
                OR Person_2__r.Health_Status__c IN :healthStatuses)
        ]) {
            if (!alreadyProcessedIds.contains(pt.Person_1__c)) {
                cohabitants.add(pt.Person_1__c);
                alreadyProcessedIds.add(pt.Person_1__c);
            }
            if (!alreadyProcessedIds.contains(pt.Person_2__c)) {
                cohabitants.add(pt.Person_2__c);
                alreadyProcessedIds.add(pt.Person_2__c);
            }
        }
        return cohabitants;
    }
    public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessedIds) {
        Set<Id> neighbours = new Set<Id>();
        for (People_Tracing__c pt : [
            SELECT Id, Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE
                (Person_1__c IN :personIds
                OR Person_2__c IN :personIds)
                AND Contact_Type__c = 'Neighbour'
                AND (Person_1__r.Health_Status__c = 'Green'
                OR Person_2__r.Health_Status__c = 'Green')
        ]) {
            if (!alreadyProcessedIds.contains(pt.Person_1__c)) {
                neighbours.add(pt.Person_1__c);
                alreadyProcessedIds.add(pt.Person_1__c);
            }
            if (!alreadyProcessedIds.contains(pt.Person_2__c)) {
                neighbours.add(pt.Person_2__c);
                alreadyProcessedIds.add(pt.Person_2__c);
            }
        }
        return neighbours;
    }

    public static Set<Id> getPrimaryContacts(Set<Id> personIds, Set<Id> alreadyProcessedIds) {
        Set<Id> primaryContacts = new Set<Id>();
        List<String> healthStatuses = new List<String>{ 'Green', 'Yellow' };

        for (People_Tracing__c pt : [
            SELECT Id, Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE
                (Person_1__c IN :personIds
                OR Person_2__c IN :personIds)
                AND Contact_Type__c = 'Other'
                AND (Person_1__r.Health_Status__c IN :healthStatuses
                OR Person_2__r.Health_Status__c IN :healthStatuses)
                AND Contact_Date__c = LAST_N_DAYS:10
        ]) {
            if (!alreadyProcessedIds.contains(pt.Person_1__c)) {
                primaryContacts.add(pt.Person_1__c);
                alreadyProcessedIds.add(pt.Person_1__c);
            }
            if (!alreadyProcessedIds.contains(pt.Person_2__c)) {
                primaryContacts.add(pt.Person_2__c);
                alreadyProcessedIds.add(pt.Person_2__c);
            }
        }
        return primaryContacts;
    }

    public static Set<Id> getSecondaryContacts(Set<Id> primaryContacIds, Set<Id> alreadyProcessedIds) {
        Set<Id> secondaryContacts = new Set<Id>();
        for (People_Tracing__c pt : [
            SELECT Id, Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE
                (Person_1__c IN :primaryContacIds
                OR Person_2__c IN :primaryContacIds)
                AND Contact_Type__c = 'Other'
                AND (Person_1__r.Health_Status__c = 'Green'
                OR Person_2__r.Health_Status__c = 'Green')
                AND Contact_Date__c = LAST_N_DAYS:10
        ]) {
            if (!alreadyProcessedIds.contains(pt.Person_1__c)) {
                secondaryContacts.add(pt.Person_1__c);
                alreadyProcessedIds.add(pt.Person_1__c);
            }
            if (!alreadyProcessedIds.contains(pt.Person_2__c)) {
                secondaryContacts.add(pt.Person_2__c);
                alreadyProcessedIds.add(pt.Person_2__c);
            }
        }
        return secondaryContacts;
    }
    public static void setPerson(Set<Id> personToUpdateYellow) {
        List<Person__c> updatePerson = new List<Person__c>();
        for (Id newid : personToUpdateYellow) {
            updatePerson.add(new Person__c(Id = newid, Health_Status__c = 'Yellow', Status_Update_Date__c = Date.today()));
        }
        update updatePerson;
    }
    public static Map<String, Integer> getHealthStatusCount() {
        AggregateResult[] healthCountMap = [SELECT Health_Status__c, Count(Id) total FROM Person__c GROUP BY Health_Status__c];

        if (healthCountMap != null && healthCountMap.size() > 0) {
            Map<String, Integer> result = new Map<String, Integer>();
            for (AggregateResult ar : healthCountMap) {
                result.put(String.valueOf(ar.get('Health_Status__c')), Integer.valueOf(ar.get('total')));
            }
            return result;
        }
        return null;
    }
}
