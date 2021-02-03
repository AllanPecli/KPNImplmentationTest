import { LightningElement, wire, api } from 'lwc';
import getProducts from '@salesforce/apex/KPN_LWCProductController.getProducts';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NAME_FIELD from '@salesforce/schema/PricebookEntry.Name';
import UNITPRICE_FIELD from '@salesforce/schema/PricebookEntry.UnitPrice';


const COLS = [
    { label: 'Name', fieldName: 'Name', editable: false },
    { label: 'List Price', fieldName: 'UnitPrice', editable: false }
];
export default class DatatableUpdateExample extends LightningElement {

    @api recordId;
    columns = COLS;
    draftValues = [];

    @wire(getProducts,{})
    PricebookEntry;

    handleSave(event) {

        const fields = {}; 
        fields[NAME_FIELD.fieldApiName] = event.detail.draftValues[0].Name;
        fields[UNITPRICE_FIELD.fieldApiName] = event.detail.draftValues[0].UnitPrice;

        const recordInput = {fields};

        updateRecord(recordInput)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Product updated',
                    variant: 'success'
                })
            );
            // Display fresh data in the datatable
            return refreshApex(this.PricebookEntry).then(() => {

                // Clear all draft values in the datatable
                this.draftValues = [];

            });
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or reloading record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
}