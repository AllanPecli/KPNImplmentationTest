@RestResource(urlMapping='/apexSecurityRest')
global with sharing class ApexSecurityRest {
    @HttpGet
    global static Contact doGet() {
        Id recordId = RestContext.request.params.get('id');
        Contact result;
        if (recordId == null) {
            throw new FunctionalException('Id parameter is required');
        }
        //Refactored
        
        List<Contact> results = [SELECT id, Name, Title, Account.Name FROM Contact WHERE Id = :recordId];
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, results);
        if(!results.isEmpty()){
            result = (Contact)securityDecision?.getRecords()[0];
        	result.Description = result?.Account?.Name;
        }else{
            throw new SecurityException('You don\'t have access to all contact fields required to use this API');
        }
        
        return result;
    }
    public class FunctionalException extends Exception{}
    public class SecurityException extends Exception{}
}