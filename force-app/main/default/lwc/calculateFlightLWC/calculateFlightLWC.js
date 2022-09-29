/**
 * @description       : 
 * @author            : Clarcat
 * @group             : 
 * @last modified on  : 09-29-2022
 * @last modified by  : Clarcat
**/

import { LightningElement, track, api ,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getIATACodes from '@salesforce/apex/CalculateFlightController.retrieveIATACodes';
import getCreateFlight from '@salesforce/apex/CalculateFlightController.registerFlight';

//toast messages
const ERRORBLANK = 'Please, select a departure and an arrival airport to calculate flight distance';
const ERROR = 'Error';
const SUCCESS = 'Success';
const SUCCESSMSG = 'Flight distance calculated with success';
const ERRORCREATING = 'A problem occurred calculating flight distance';

export default class CalculateFlightLWC extends LightningElement {
    departureCode = '';
    departureCodeStatic = ''; //used to show the code after the flight has been created
    arrivalCode = '';
    arrivalCodeStatic = ''; //used to show the code after the flight has been created
    departureName = ''; //used to show the full airport name after the flight has been created
    arrivalName = ''; //used to show the full airport name after the flight has been created
    distance = 0.0;
    options = [];
    loaded = false; //if true, it shows the IATA Code's picklists
    calculated = false; //if true, it shows the flight information

    @wire(getIATACodes) //wired function to retrieve IATA Codes 
    airports({error, data}){
        if (data) {
            for (let i = 0; i < data.length; i++) {
                this.options.push({ label: data[i], value: data[i] }); //push data to both picklists
            }
            this.loaded = true;
        } else if (error) {
            console.log('An error has occurred:');
            console.log(error);
            // handle your error.
        }
    }

    // handled the change in the option selected for the departure airport IATA code
    handleChangeDeparture(event) {
        this.departureCode = event.detail.value;
        console.log(this.departureCode);
    }

    // handled the change in the option selected for the arrival airport IATA code
    handleChangeArrival(event) {
        this.arrivalCode = event.detail.value;
        console.log(this.arrivalCode);
    }

    // handled the creation of the flight given two IATA codes
    handleCreateFlight(){
        if(this.arrivalCode == '' || this.departureCode == ''){
            this.showToast(ERROR,ERRORBLANK);
        } else{
            getCreateFlight({departureCode:this.departureCode, arrivalCode:this.arrivalCode}) //call apex method
            .then(result => {
                //if created, we transfer information from the object to show on the component
                if(result != null){ 
                    this.showToast(SUCCESS,SUCCESSMSG);
                    this.distance = result.Distance__c;
                    this.departureName = result.Departure_airport_name__c;
                    this.departureCodeStatic = this.departureCode;
                    this.arrivalName = result.Arrival_airport_name__c;
                    this.arrivalCodeStatic = this.arrivalCode;
                    this.calculated = true;
                } 
                // else, we show an error toast
                else{
                    this.showToast(ERROR,ERRORCREATING);
                }
            })
            .catch(error => {
                console.log('Error: ', error);
            });;
        }
    }

    //funtion that shows toasts with diverse information
    showToast(title, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
        });
        this.dispatchEvent(event);
    }
}