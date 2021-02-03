/**********************************************************************************
* @author    Allan Pecli
* @date      03/02/2021
* @description  Generic test data creation .
**********************************************************************************/
public with sharing class KPN_TestDataFactory {
    /********************************************************************************
    * @author        Allan Pecli
    * @date          03/02/2021
    * @description   Create Order test records
    ***********************************************************************************/
    public static List<Order> createOrderRecord (String accId, String contractId, Integer quantity){
        List<Order> orderLst = New List<Order>();
        for(Integer I=1; I<=quantity; I++){
            Order orderObj = new Order();
            orderObj.AccountId = accId;
            orderObj.contractId = contractId;
            orderObj.Status='Draft';
            orderObj.EffectiveDate=System.today();
            orderObj.Pricebook2Id = Test.getStandardPricebookId();
            orderLst.add(orderObj);
        }
        if(!orderLst.IsEmpty()){
            Database.Insert(orderLst);
        }
        return orderLst;
    }

    /********************************************************************************
    * @author        Allan Pecli
    * @date          03/02/2021
    * @description   Create Account test records
    ***********************************************************************************/
    public static List<Account> createAccountRecord (Integer quantity){
        List<Account> accountLst = new list<Account>();
        for(Integer I=1; I<=quantity; I++){
            Account accountObj = new Account();
            accountObj.Name ='Account Name-'+I;
            accountLst.add(accountObj);
        }
        if(!accountLst.IsEmpty()){
            Database.Insert(accountLst);
        }
        return accountLst;
    }

    /********************************************************************************
    * @author        Allan Pecli
    * @date          03/02/2021
    * @description   Create Contract test records
    ***********************************************************************************/
    public static List<Contract> createContractRecord (String accId, Integer quantity){
        List<Contract> contractLst = new list<Contract>();
        for(Integer I=1; I<=quantity; I++){
            Contract contractObj = new Contract();
            contractObj.AccountId =accId;
            contractLst.add(contractObj);
        }
        if(!contractLst.IsEmpty()){
            Database.Insert(contractLst);
        }
        return contractLst;
    }    

    /********************************************************************************
    * @author        Allan Pecli
    * @date          03/02/2021
    * @description   Create Product and PricebookEntries test records
    ***********************************************************************************/
    public static List<Product2> createProductWithPricebook(String name, Integer quantity){
        List<Product2> product2Lst = new list<Product2>();
        for(Integer I=1; I<=quantity; I++){
            Product2 prod = new Product2();
            prod.Name = name+I;
            prod.isActive = true;
            product2Lst.add(prod);
        }

        if(!product2Lst.IsEmpty()){
            Database.Insert(product2Lst);

            //Instantiate the Pricebook2 record with StandardPricebookId
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            
            //Execute an update DML on the Pricebook2 record, to make IsStandard to true
            Update standardPricebook;
            List<PricebookEntry> pricebookEntryLst = New List<PricebookEntry>();
            for(Product2 prd : product2Lst){
                PricebookEntry pbEntry = new PricebookEntry();
                pbEntry.Pricebook2Id = standardPricebook.Id;
                pbEntry.Product2Id = prd.Id;
                pbEntry.UnitPrice = 100.00;
                pbEntry.IsActive = true;
                pricebookEntryLst.add(pbEntry);
            }          
            if(!pricebookEntryLst.isEmpty()){
                Database.Insert(pricebookEntryLst);
            } 
        }
        return product2Lst;
    }
}