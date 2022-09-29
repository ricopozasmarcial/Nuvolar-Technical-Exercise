/**
 * @description       : 
 * @author            : Clarcat
 * @group             : 
 * @last modified on  : 09-29-2022
 * @last modified by  : Clarcat
**/
@isTest
public with sharing class CalculateFlightController_Test {

    /**
    * @description Tests the method that retrieves the airports based on its IATA code
    * @author Clarcat | 09-29-2022 
    **/
    @isTest
    static void RetrieveIATACodes_test() {

        //Create test record
        
        Airport__c ap1 = new Airport__c(
            Name = 'Test',
            IATA_Codes__c = 'TST',
            Latitude__c = 5.0,
            Longitude__c = 6.0
        );
        insert ap1;
        Test.startTest();
            List<String> airports = CalculateFlightController.retrieveIATACodes();
            system.assertEquals(airports[0], 'TST', 'Airport found using its IATA code' );
        Test.stopTest();
    }

    /**
    * @description Tests the method that registers a new flight and calculates its distance 
    * @author Clarcat | 09-29-2022 
    **/
    @isTest
    static void RegisterFlight_test() {
        
        // Create tests records

        Airport__c ap1 = new Airport__c(
            Name = 'Test',
            IATA_Codes__c = 'TST',
            Latitude__c = 5.0,
            Longitude__c = 6.0
        );
        insert ap1;

        Airport__c ap2 = new Airport__c(
            Name = 'Test',
            IATA_Codes__c = 'TMT',
            Latitude__c = 15.0,
            Longitude__c = 26.0
        );
        insert ap2;

        Test.startTest();
            //CASE 1: Both Airports exist
            System.assert(CalculateFlightController.registerFlight(ap1.IATA_Codes__c, ap2.IATA_Codes__c) != null, 'Both Airports exist');
            //CASE 2: One airport fails
            System.assert(CalculateFlightController.registerFlight(ap1.IATA_Codes__c, '') == null, 'One airport fails');
            //CASE 3: Both airport fail
            System.assert(CalculateFlightController.registerFlight('', '')== null , 'Both airport fail');
        Test.stopTest();
    }
}
