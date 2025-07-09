public with sharing class CTHealthHeaderController {
    @AuraEnabled
    public static Map<String, Integer> getPersonHealthStatuscount() {
        return CTPersonController.getHealthStatusCount();
    }

    @AuraEnabled
    public static Map<String, Integer> getLocationHealthStatuscount() {
        return CTLocationController.getHealthStatusCount();
    }
}
