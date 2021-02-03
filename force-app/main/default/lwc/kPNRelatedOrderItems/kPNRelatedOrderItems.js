import { LightningElement, wire, track, api } from 'lwc';
import getProducts from '@salesforce/apex/KPN_LWCOrderItemController.getOrderItems';
import {refreshApex} from '@salesforce/apex';
// Import message service features required for subscribing and the message channel
import {
    subscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import orderItemRefresh from '@salesforce/messageChannel/orderItemRefresh__c';

const cols = [
    { label: 'Name', fieldName: 'Product2.Name', editable: false, },
    { label: 'Unit Price', fieldName: 'UnitPrice', editable: false },
    { label: 'Quantity', fieldName: 'Quantity', editable: false },
    { label: 'Total Price', fieldName: 'TotalPrice', editable: false }
];
export default class DatatableUpdateExample extends LightningElement {
    subscription = null;
    @api recordId;
    @track allOrderItems = [];
    @track columns = cols;

    @wire(MessageContext)
    messageContext;

    wiredProductData;

    @wire(getProducts,{ orderId: '$recordId' })
    wiredProducts(result) {
        this.wiredProductData = result;
        if(result.data) {
           let orderItemArrays = [];
           for (let row of result.data) {
                const flattenedRow = {}
                let rowKeys = Object.keys(row); 
                rowKeys.forEach((rowKey) => {
                    const singleNodeValue = row[rowKey];
                    if(singleNodeValue.constructor === Object){
                        this._flatten(singleNodeValue, flattenedRow, rowKey)        
                    }else{
                        flattenedRow[rowKey] = singleNodeValue;
                    }
                });
                orderItemArrays.push(flattenedRow);
            }
            this.allOrderItems = orderItemArrays;
        } else if (result.error) {
            this.error = result.error;
        }
    }
    _flatten = (nodeValue, flattenedRow, nodeName) => {        
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.'+ key;
            flattenedRow[finalKey] = nodeValue[key];
        })
    }

    connectedCallback() {
        this.subscribe();
    }

    subscribe() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                orderItemRefresh,
                (message) => refreshApex(this.wiredProductData),
                { scope: APPLICATION_SCOPE }
            );
        }
    }
}