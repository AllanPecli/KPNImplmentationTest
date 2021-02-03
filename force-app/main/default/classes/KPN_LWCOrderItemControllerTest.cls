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

    @isTest
    static void testAllConditions(){
        test.StartTest();
        List<PricebookEntry> lstProducts = KPN_LWCProductController.getProducts();
        Id ordId = [SELECT ID FROM ORDER LIMIT 1].Id;
        List<Id> prdIds = New List<Id>();
        
        For(PricebookEntry prd : lstProducts){
            prdIds.add(prd.Product2Id);
        }
        KPN_LWCProductController.setOrderItens(ordId,prdIds);
		KPN_LWCProductController.setOrderItens(ordId,prdIds);
        
        List<OrderItem> lstOrderItems = KPN_LWCOrderItemController.getOrderItems(ordId);
        test.StopTest();
    }
}