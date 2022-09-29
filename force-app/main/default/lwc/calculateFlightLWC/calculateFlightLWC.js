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

const ERRORBLANK = 'Please, select a departure and an arrival airport to calculate flight distance';
const ERROR = 'Error';
const SUCCESS = 'Success';
const SUCCESSMSG = 'Flight distance calculated with success';
const ERRORCREATING = 'A problem occurred calculating flight distance';

export default class CalculateFlightLWC extends LightningElement {
    departureCode = '';
    departureCodeStatic = '';
    arrivalCode = '';
    arrivalCodeStatic = '';
    departureName = '';
    arrivalName = '';
    distance = 0.0;
    options = [];
    loaded = false;
    calculated = false;

    @wire(getIATACodes)
    airports({error, data}){
        if (data) {
            for (let i = 0; i < data.length; i++) {
                this.options.push({ label: data[i], value: data[i] });
            }
            this.loaded = true;
        } else if (error) {
            console.log('An error has occurred:');
            console.log(error);
            // handle your error.
        }
    }

    handleChangeDeparture(event) {
        this.departureCode = event.detail.value;
        console.log(this.departureCode);
    }

    handleChangeArrival(event) {
        this.arrivalCode = event.detail.value;
        console.log(this.arrivalCode);
    }

    handleCreateFlight(){
        if(this.arrivalCode == '' || this.departureCode == ''){
            this.showToast(ERROR,ERRORBLANK);
        } else{
            getCreateFlight({departureCode:this.departureCode, arrivalCode:this.arrivalCode})
            .then(result => {
                if(result != null){
                    this.showToast(SUCCESS,SUCCESSMSG);
                    this.distance = result.Distance__c;
                    this.departureName = result.Departure_airport_name__c;
                    this.departureCodeStatic = this.departureCode;
                    this.arrivalName = result.Arrival_airport_name__c;
                    this.arrivalCodeStatic = this.arrivalCode;
                    this.calculated = true;
                } else{
                    this.showToast(ERROR,ERRORCREATING);
                }
            })
            .catch(error => {
                console.log('Error: ', error);
            });;
        }
    }

    showToast(title, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
        });
        this.dispatchEvent(event);
    }
}