import { LightningElement, wire, track, api } from 'lwc';
import getProducts from '@salesforce/apex/KPN_LWCOrderItemController.getOrderItems';
import {refreshApex} from '@salesforce/apex';

const cols = [
    { label: 'Name', fieldName: 'Product2.Name', editable: false, },
    { label: 'Unit Price', fieldName: 'UnitPrice', editable: false },
    { label: 'Quantity', fieldName: 'Quantity', editable: false },
    { label: 'Total Price', fieldName: 'TotalPrice', editable: false }
];
export default class DatatableUpdateExample extends LightningElement {

    @api recordId;
    @track allOrderItems = [];
    @track columns = cols;

    @wire(getProducts,{ orderId: '$recordId' })
    wiredProducts({ error, data }) {
        if(data) {
           //this is the final array into which the flattened response will be pushed. 
           let orderItemArrays = [];
           for (let row of data) {
                // this const stroes a single flattened row. 
                const flattenedRow = {}
                // get keys of a single row — Name, Phone, LeadSource and etc
                let rowKeys = Object.keys(row); 
                //iterate 
                rowKeys.forEach((rowKey) => {
                    //get the value of each key of a single row. John, 999-999-999, Web and etc
                    const singleNodeValue = row[rowKey];
                    //check if the value is a node(object) or a string
                    if(singleNodeValue.constructor === Object){
                        //if it's an object flatten it
                        this._flatten(singleNodeValue, flattenedRow, rowKey)        
                    }else{
                        //if it’s a normal string push it to the flattenedRow array
                        flattenedRow[rowKey] = singleNodeValue;
                    }
                    
                });
                //push all the flattened rows to the final array 
                orderItemArrays.push(flattenedRow);
            }
            //assign the array to an array that's used in the template file
            this.allOrderItems = orderItemArrays;
        } else if (error) {
            this.error = error;
        }
    }
    //create keys in the format of Account.Id, Account.Rating, Account.Industry and etc
    //we can avoid using this function by reusing the above function. To understand in easily I used a separate function 
    //Feel free to refactor it
    _flatten = (nodeValue, flattenedRow, nodeName) => {        
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.'+ key;
            flattenedRow[finalKey] = nodeValue[key];
        })
    }

}