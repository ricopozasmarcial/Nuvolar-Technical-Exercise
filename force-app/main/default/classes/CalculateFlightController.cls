/**
 * @description       : 
 * @author            : Clarcat
 * @group             : 
 * @last modified on  : 09-29-2022
 * @last modified by  : Clarcat
**/
public with sharing class CalculateFlightController {
    

    /**
    * @description method that searches all airports created and returns a list of strings containing its IATA codes
    * @author Clarcat | 09-29-2022 
    * @return List<String> the list of all IATA airport codes available
    **/
    @AuraEnabled(cacheable=true)
    public static List<String> retrieveIATACodes(){
        List<Airport__c> airports = new List<Airport__c>();
        List<String> stringCodes = new List<String>();

        //check access to the object
        if(Airport__c.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.Airport__c.fields.IATA_Codes__c.isAccessible()
        ) {
            airports = [SELECT IATA_Codes__c FROM Airport__c];
        }
        //parse IATA codes
        if(airports.size()> 0){
            for(Airport__c ap : airports){
                stringCodes.add(ap.IATA_Codes__c);
            }
        }
        
        System.debug(stringCodes);
        return stringCodes;
    }

    /**
    * @description Method that registers a new flight in the database
    * @author Clarcat | 09-29-2022 
    * @param String departureCode, the IATA code from the departure airport
    * @param String arrivalCode, the IATA code from the arrival airport
    * @return Flight__c, the flight created with all relevant information
    **/
    @AuraEnabled()
    public static Flight__c registerFlight(String departureCode, String arrivalCode){
        Airport__c departure;
        Airport__c arrival;
        Flight__c flight = new Flight__c();

        try{
            //check access to the object
            if(Airport__c.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.Airport__c.fields.Latitude__c.isAccessible()
            && Schema.SObjectType.Airport__c.fields.Longitude__c.isAccessible()
            && Schema.SObjectType.Airport__c.fields.IATA_Codes__c.isAccessible()
            ) {
                departure = [SELECT Id, IATA_Codes__c, Latitude__c, Longitude__c FROM Airport__c WHERE IATA_Codes__c = :departureCode LIMIT 1];
                arrival = [SELECT Id, IATA_Codes__c, Latitude__c, Longitude__c FROM Airport__c WHERE IATA_Codes__c = :arrivalCode LIMIT 1];
            }

            if(departure != null && arrival != null){
            //calculate flight distance
            flight.Distance__c = calculateDistance(departure.Latitude__c, departure.Longitude__c, arrival.Latitude__c, arrival.Longitude__c);
            //Assign Ids
            flight.Arrival_Airport__c = arrival.Id;
            flight.Departure_Airport__c = departure.Id;

            //check access to the object
            if(Flight__c.SObjectType.getDescribe().isAccessible() 
                    &&Flight__c.SObjectType.getDescribe().isCreateable()
                    && Schema.SObjectType.Flight__c.fields.Distance__c.isAccessible()
                    && Schema.SObjectType.Flight__c.fields.Arrival_Airport__c.isAccessible()
                    && Schema.SObjectType.Flight__c.fields.Departure_Airport__c.isAccessible()
                ) {
                    insert flight;
                    //we query the same flight to return the formula fields alongside the rest of the information
                    return [SELECT Distance__c, Arrival_Airport__c, Departure_Airport__c, Arrival_airport_name__c, Departure_airport_name__c FROM Flight__c WHERE Id = :flight.Id];
                }
            }
        } catch (Exception e){
            System.debug(e);
        }
        return null;
    }


    /**
    * @description method that calculates the flight distance bewteen two airports using theis coordinates
    * @author Clarcat | 09-29-2022 
    * @param Decimal latitude1, latitude of airport nº1 
    * @param Decimal longitude1, longitide of airport nº1
    * @param Decimal latitude2  latitude of airport nº2 
    * @param Decimal longitude2, longitide of airport nº2 
    * @return Decimal, the distance in Km between the two airports
    **/
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
