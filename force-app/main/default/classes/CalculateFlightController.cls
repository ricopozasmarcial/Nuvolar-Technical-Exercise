/**
 * @description       : 
 * @author            : Clarcat
 * @group             : 
 * @last modified on  : 09-29-2022
 * @last modified by  : Clarcat
**/
public with sharing class CalculateFlightController {
    

    @AuraEnabled(cacheable=true)
    public static List<String> retrieveIATACodes(){
        List<Airport__c> airports = new List<Airport__c>();
        List<String> stringCodes = new List<String>();

        if(Airport__c.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.Airport__c.fields.IATA_Codes__c.isAccessible()
        ) {
            airports = [SELECT IATA_Codes__c FROM Airport__c];
        }
        if(airports.size()> 0){
            for(Airport__c ap : airports){
                stringCodes.add(ap.IATA_Codes__c);
            }
        }
        
        System.debug(stringCodes);
        return stringCodes;
    }

    @AuraEnabled()
    public static Flight__c registerFlight(String departureCode, String arrivalCode){
        Airport__c departure;
        Airport__c arrival;
        Flight__c flight = new Flight__c();

        try{
            if(Airport__c.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.Airport__c.fields.Latitude__c.isAccessible()
            && Schema.SObjectType.Airport__c.fields.Longitude__c.isAccessible()
            && Schema.SObjectType.Airport__c.fields.IATA_Codes__c.isAccessible()
            ) {
                departure = [SELECT Id, IATA_Codes__c, Latitude__c, Longitude__c FROM Airport__c WHERE IATA_Codes__c = :departureCode LIMIT 1];
                arrival = [SELECT Id, IATA_Codes__c, Latitude__c, Longitude__c FROM Airport__c WHERE IATA_Codes__c = :arrivalCode LIMIT 1];
            }

            if(departure != null && arrival != null){
            flight.Distance__c = calculateDistance(departure.Latitude__c, departure.Longitude__c, arrival.Latitude__c, arrival.Longitude__c);
            flight.Arrival_Airport__c = arrival.Id;
            flight.Departure_Airport__c = departure.Id;

            if(Flight__c.SObjectType.getDescribe().isAccessible() 
                    &&Flight__c.SObjectType.getDescribe().isCreateable()
                    && Schema.SObjectType.Flight__c.fields.Distance__c.isAccessible()
                    && Schema.SObjectType.Flight__c.fields.Arrival_Airport__c.isAccessible()
                    && Schema.SObjectType.Flight__c.fields.Departure_Airport__c.isAccessible()
                ) {
                    insert flight;
                    return [SELECT Distance__c, Arrival_Airport__c, Departure_Airport__c, Arrival_airport_name__c, Departure_airport_name__c FROM Flight__c WHERE Id = :flight.Id];
                }
            }
        } catch (Exception e){
            System.debug(e);
        }
        return null;
    }

    static Decimal calculateDistance(Decimal latitude1, Decimal longitude1, Decimal latitude2, Decimal longitude2) {
        Integer earthRadius = 6371 * 1000; // in meters
        // Transform coordinates from degrees to radians
        Decimal latitudeRadians1 = latitude1 * Math.PI/180;
        Decimal latitudeRadians2 = latitude2 * Math.PI/180;
        // Latitude and longitude differences in radians
        Decimal latitudeDelta = (latitude2 - latitude1) * Math.PI/180;
        Decimal longitudeDelta = (longitude2 - longitude1) * Math.PI/180;
        Decimal a = Math.sin(latitudeDelta/2) * Math.sin(latitudeDelta/2) +
        Math.cos(latitudeRadians1) * Math.cos(latitudeRadians2) *
        Math.sin(longitudeDelta/2) * Math.sin(longitudeDelta/2);
        Decimal arc = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        Decimal distance = earthRadius * arc; // in metres
        return distance;
    }

}
