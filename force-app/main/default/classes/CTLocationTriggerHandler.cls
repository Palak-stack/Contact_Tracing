public with sharing class CTLocationTriggerHandler {
    public static void beforeInsert(List<Location__c> newLocations){
        for(Location__c location:newLocations){
            location.Status__c = 'Green';
        }
    }
    public static void beforeUpdate(List<Location__c> newLocations,Map<Id,Location__c> oldLocations){
        for(Location__c location:newLocations){
            String newStatus = location.Status__c;
            String previousStatus = oldLocations.get(location.Id).Status__c;
            if(newStatus != previousStatus){
                location.Status_Update_Date__c = Date.today();
                
            }
            
        }
    }
    public static void afterUpdate(List<Location__c> newLocations,Map<Id,Location__c> oldLocations){
        Set<Id> newRedLocations = new Set<Id>();
        Set<Id> updatePersonList = new Set<Id>();
        for(Location__c location:newLocations){
            String newStatus = location.Status__c;
            String previousStatus = oldLocations.get(location.Id).Status__c;
            if(newStatus != previousStatus && newStatus == 'Red'){
                newRedLocations.add(location.Id);
            }
            
        }
        if(newRedLocations != null){
            List<Location_Tracing__c> updatePeople = CTLocationTracingController.getLocationsByLocationIds(newRedLocations);
             for(Location_Tracing__c locationTracing:updatePeople){
                updatePersonList.add(locationTracing.Person__c);
             }
             CTPersonController.setPerson(updatePersonList);
        }
    }
}
