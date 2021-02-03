import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getProductList from '@salesforce/apex/KPN_LWCProductController.getProducts';
import setOrderItens from '@salesforce/apex/KPN_LWCProductController.setOrderItens';
import successMessage from '@salesforce/label/c.SuccessMessage';
import errorMessage from '@salesforce/label/c.ErrorMessage';
// Import message service features required for publishing and the message channel
import { publish, MessageContext } from 'lightning/messageService';
// Importing created message.
import orderItemRefresh from '@salesforce/messageChannel/orderItemRefresh__c';

const actions = [
    { label: 'Add Product to Order', name: 'show_details' }
];

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'List Price', fieldName: 'UnitPrice' }
];

export default class ApexDatatableExample extends LightningElement {
    @api recordId;
    error;
    columns = columns;

    @wire(getProductList)
    products;

    @wire(MessageContext)
    messageContext;
    
    get showButton(){
        return true;
    }

    handleClick() {
        const selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        var ids = [];
        for(var i = 0; i < selectedRows.length; i++){
            ids.push(selectedRows[i].Product2Id);
        }
        setOrderItens({orderId: this.recordId, products2Ids: ids}).then(()=>{
            const event = new ShowToastEvent({
                "title": "Success!",
                "message": successMessage,
                "variant": "success",
            });
            publish(this.messageContext, orderItemRefresh, {});
            this.dispatchEvent(event);
        }).catch(error=>{
            const event = new ShowToastEvent({
                "title": "Error!",
                "message": errorMessage,
                "variant": "error",
            });
        })
    }

    handleSelectedRows(event) {
        const selectedRows = event.detail.selectedRows;
        let test = this.template.querySelector('lightning-button');
        if(event.detail.selectedRows.length > 0){
            test.disabled = false;
        }else{
            test.disabled = true;
        }
    }

    findRowIndexById(id) {
        let ret = -1;
        this.data.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }
}