/********************************************************************************
* @author        Allan Pecli
* @date          03/02/2021
* @description   Test Class for KPN_LWCOrderItemController
***********************************************************************************/
@isTest
public class KPN_LWCOrderItemControllerTest {
    @testSetup
    static void setupData(){
        List<Product2> lstProds =  KPN_TestDataFactory.createProductWithPricebook('Test KPN Product', 1);
        List<Account> lstAccounts =  KPN_TestDataFactory.createAccountRecord(1);
        
        //We could use N Accounts here if we need, Taking in consideration I'm only using one, I'm using [0] to get the value.
        List<Contract> lstContracts =  KPN_TestDataFactory.createContractRecord(lstAccounts[0].Id,1);
        
        //Same applies here
        List<Order> lstOrders =  KPN_TestDataFactory.createOrderRecord(lstAccounts[0].Id,lstContracts[0].Id, 1);
    }
    
    /********************************************************************************
    * @author        Allan Pecli
    * @date          03/02/2021
    * @description   This test Method are responsible to test and confirm all the 
    * acceptance criteria related to the business perspective:
    * 	1) No Order Item on the Order
    * 	2) One Order Item created on the Order related to the desired Product
    * 	3) One Order Item updated on the Order related to the desired Product (Now with Quantity of 2)
    ***********************************************************************************/
    @isTest
    static void testAllConditions(){
        test.StartTest();
        List<PricebookEntry> lstProducts = KPN_LWCProductController.getProducts();
        Id ordId = [SELECT ID FROM Order LIMIT 1].Id;
        List<Id> prdIds = New List<Id>();
        
        For(PricebookEntry prd : lstProducts){
            prdIds.add(prd.Product2Id);
        }
        //First assert to check if we don't have ANY OrderItem for that Order Id.
        system.assertequals(0,[SELECT Count() FROM OrderItem WHERE OrderId =:ordId]);
        
        KPN_LWCProductController.setOrderItens(ordId,prdIds);
        //Second assert to check if we have one new OrderItem for that Order Id.
        system.assertequals(1,[SELECT Count() FROM OrderItem WHERE OrderId =:ordId]);
        
        KPN_LWCProductController.setOrderItens(ordId,prdIds);
        //Third assert to check if we have the quantity of 2 for that same Product on that existing OrderItem for that Order Id.
        system.assertequals(2,[SELECT Quantity FROM OrderItem WHERE OrderId =:ordId].Quantity);
        
        List<OrderItem> lstOrderItems = KPN_LWCOrderItemController.getOrderItems(ordId);
        test.StopTest();
    }
}