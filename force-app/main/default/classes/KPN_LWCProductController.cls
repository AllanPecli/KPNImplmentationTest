/********************************************************************************
* @author        Allan Pecli
* @date          03/02/2021
* @description   LWC Controller to get called.
***********************************************************************************/
public with sharing class KPN_LWCProductController {

    /********************************************************************************
    * @author        Allan Pecli
    * @date          03/02/2021
    * @description   Aura method responsible to return all the Active PricebookEntries
    * for a Standard Pricebook2. I could filter taking in consideration the 
    * Order Pricebook as well, but I'm considering that we're only using the 
    * Standard Pricebook
    ***********************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getProducts() {
        return [
            SELECT ID, Name, UnitPrice, Product2Id
            FROM PricebookEntry 
            WHERE IsActive = true AND Pricebook2.IsStandard = true AND Product2.IsActive = true
        ];
    }
    
    /********************************************************************************
    * @author        Allan Pecli
    * @date          03/02/2021
    * @description   Aura method responsible to create the Order Items records.
    * We could use the LWC recod creation as well to deal with this, 
    * according to the following documentation:
    * https://developer.salesforce.com/docs/component-library/documentation/en/lwc/data_salesforce_write
    ***********************************************************************************/
    @AuraEnabled
    public static Void setOrderItens(String orderId, List<Id> products2Ids) {
        List<OrderItem> lstOrderItemsToInteract = New List<OrderItem>();
        Map<String,OrderItem> mapOrderItemQuantity = New Map<String,OrderItem>();
        Map<String,PricebookEntry> mapProductUnityPrice = New Map<String,PricebookEntry>();

        For(PricebookEntry priceBookEntry : [Select Id, Product2Id, UnitPrice From PricebookEntry where Product2Id IN: products2Ids AND IsActive = true AND Pricebook2.IsStandard = true AND Product2.IsActive = true]){
            if(!mapProductUnityPrice.ContainsKey(priceBookEntry.Product2Id)){
                mapProductUnityPrice.put(priceBookEntry.Product2Id,priceBookEntry);
            }
        }

        For(OrderItem OI : [Select Id, Product2Id, Quantity From OrderItem where OrderId =: orderId]){
            if(!mapOrderItemQuantity.ContainsKey(OI.Product2Id)){
                mapOrderItemQuantity.put(OI.Product2Id,OI);
            }
        }
        For(Id prodId : products2Ids){
            OrderItem oI = New OrderItem();
            if(!mapOrderItemQuantity.ContainsKey(prodId)){
                oI.Product2Id = prodId;
                oI.Quantity = 1;
                oI.OrderId = orderId;
                oI.UnitPrice = mapProductUnityPrice.get(prodId).UnitPrice;
                oI.PricebookEntryId = mapProductUnityPrice.get(prodId).Id;
                lstOrderItemsToInteract.add(oI);
            }else{
                oI = mapOrderItemQuantity.Get(prodId);
                oI.Quantity++;
                lstOrderItemsToInteract.add(oI);
            }
        }
        if(!lstOrderItemsToInteract.isEmpty()){
            Database.Upsert(lstOrderItemsToInteract);
        }
    }
}