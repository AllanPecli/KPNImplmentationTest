/********************************************************************************
* @author        Allan Pecli
* @date          03/02/2021
* @description   LWC Controller to get called.
***********************************************************************************/
public with sharing class KPN_LWCOrderItemController {
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderItems(String orderId) {
        return [
            SELECT ID, Product2.Name, UnitPrice, Quantity, TotalPrice
            FROM OrderItem 
            WHERE OrderId =: orderId
        ];
    }
}