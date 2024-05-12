/**********************************************************
Class: BillingRecordLwcController
Description: This is controller class of Lwc billingRecordLwc
***********************************************************/
public with sharing class BillingRecordLwcController {
    
    @AuraEnabled
    public static Id createBillingRecord(BillingRecordWrapper billingDetails) {
        Invoice_Billing__c theBilRecord;
        List<Invoice_Billing__c> theInvBillList;
        try{
        if(billingDetails != null){
            theBilRecord = new Invoice_Billing__c();
            if(billingDetails.billingName !=null) theBilRecord.Name = billingDetails.billingName;
            if(billingDetails.billingDescription !=null) theBilRecord.Description__c = billingDetails.billingDescription;
            if(billingDetails.invoiceCounter !=null) theBilRecord.Invoice_Number__c = Integer.valueOf(billingDetails.invoiceCounter); 
            if(billingDetails.invoiceTypeValue !=null) theBilRecord.Invoice_Type__c = billingDetails.invoiceTypeValue;
            if(billingDetails.invoiceDate !=null) theBilRecord.Invoice_Date__c = Date.valueOf(billingDetails.invoiceDate);
            if(billingDetails.selectedTemplateValue !=null) theBilRecord.Invoice_Template__c = billingDetails.selectedTemplateValue;
            if(!billingDetails.selectedAllEmails.isEmpty()) theBilRecord.Additional_Email_Addresses__c =String.join( billingDetails.selectedAllEmails, '\n');
            if(billingDetails.maxInvoiceNumber !=null && billingDetails.maxInvoiceNumber > 0) theBilRecord.Max_Invoice_Number__c = billingDetails.maxInvoiceNumber;
            
            if(billingDetails.selectedAccId !=null) theBilRecord.Selected_Account_Id__c = billingDetails.selectedAccId;
            if(billingDetails.selectedConId !=null) theBilRecord.Selected_Contact_Id__c = billingDetails.selectedConId;
            if(billingDetails.selectedOppId !=null) theBilRecord.Selected_Opportunity_Id__c = billingDetails.selectedOppId;
            
            theBilRecord.Selected_Account_Emails__c = (!billingDetails.selectedAccEmails.isEmpty()) ? String.join( billingDetails.selectedAccEmails, '\n'): null;
            if(!billingDetails.selectedContactEmails.isEmpty()) theBilRecord.Selected_Contact_Emails__c =String.join( billingDetails.selectedContactEmails, '\n');
            if(!billingDetails.selectedOppEmails.isEmpty()) theBilRecord.Selected_Opportunity_Emails__c =String.join( billingDetails.selectedOppEmails, '\n'); 
            
            if(billingDetails.billRecordId != null){
                theBilRecord.Id = billingDetails.billRecordId;
            }
            //upsert theBilRecord; 
            theInvBillList = new List<Invoice_Billing__c>{theBilRecord};
            Set<String> theFieldsCheckForInvBilling = new Set<String>{'Name','Description__c','Invoice_Number__c','Invoice_Type__c','Invoice_Date__c','Invoice_Template__c','Additional_Email_Addresses__c','Max_Invoice_Number__c','Selected_Account_Id__c','Selected_Contact_Id__c','Selected_Opportunity_Id__c','Selected_Account_Emails__c','Selected_Contact_Emails__c','Selected_Opportunity_Emails__c'};
            if(CRUD_Helper.areFieldsUpsertable(theFieldsCheckForInvBilling, 'Invoice_Billing__c')){
                upsert theInvBillList;
            }
            //upsert theInvBillList = (List<Invoice_Billing__c>)CRUD_Helper.cleanseFields(new List<Invoice_Billing__c>{theBilRecord}, AccessType.UPSERTABLE);
        }
        }catch(Exception ex){
             System.debug('At Line::: '+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
        return theInvBillList[0].Id; 
    } 
    
    public class BillingRecordWrapper {
        @AuraEnabled
        public string billingName {get;set;}  
        @AuraEnabled
        public string billingDescription {get;set;}  
        @AuraEnabled
        public string invoiceCounter {get;set;}  
        @AuraEnabled
        public string invoiceTypeValue {get;set;}  
        @AuraEnabled
        public string invoiceDate {get;set;}  
        @AuraEnabled
        public string selectedTemplateValue {get;set;} 
        @AuraEnabled
        public List<String> selectedAllEmails {get;set;}
        @AuraEnabled
        public Double maxInvoiceNumber {get;set;}
        @AuraEnabled
        public string selectedAccId {get;set;}  
        @AuraEnabled
        public string selectedConId {get;set;}  
        @AuraEnabled
        public string selectedOppId {get;set;}  
        @AuraEnabled
        public List<String> selectedContactEmails {get;set;}
        @AuraEnabled
        public List<String> selectedAccEmails {get;set;}
        @AuraEnabled
        public List<String> selectedOppEmails {get;set;} 
        @AuraEnabled
        public string billRecordId {get;set;} 
    }
    
    @AuraEnabled
    public static UserAndInvoiceNumberWrapper getUser() {
        UserAndInvoiceNumberWrapper theUserInvWrap = new UserAndInvoiceNumberWrapper();
        String UserId = UserInfo.getUserId();
        User theUser = [SELECT Id, Name FROM User WHERE Id=:UserId WITH SECURITY_ENFORCED];
        
        if (Schema.sObjectType.Invoice_Billing__c.fields.Max_Invoice_Number__c.isAccessible()) {
            theUserInvWrap.maxInvoiceNumber  = [SELECT ID, Max_Invoice_Number__c FROM Invoice_Billing__c order by Max_Invoice_Number__c DESC NULLS LAST LIMIT 1].Max_Invoice_Number__c + 1;
        }
        //theUserInvWrap.maxInvoiceNumber  = [SELECT ID, Max_Invoice_Number__c FROM Invoice_Billing__c order by Max_Invoice_Number__c DESC NULLS LAST LIMIT 1].Max_Invoice_Number__c + 1;
        theUserInvWrap.user  = theUser;
        return theUserInvWrap;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Contact> fetchContactEmailList(String contId){
        List<Contact> theContactList = [SELECT Id, Email FROM Contact WHERE Id =:contId WITH SECURITY_ENFORCED]; 
        return theContactList;
    }
    @AuraEnabled(cacheable = true)
    public static List<Contact> fetchAccountConEmailList(String accId){
        List<Contact> theContactList = [SELECT Id, Email FROM Contact WHERE AccountId =:accId WITH SECURITY_ENFORCED]; 
        return theContactList;
    }
    @AuraEnabled(cacheable = true)
    public static List<Contact> fetchOppConEmailList(String oppId){
        Opportunity theOpp= [SELECT Id, AccountId FROM Opportunity WHERE Id =:oppId WITH SECURITY_ENFORCED]; 
        List<Contact> theContactList = [SELECT Id, Email FROM Contact WHERE AccountId =:theOpp.AccountId WITH SECURITY_ENFORCED]; 
        return theContactList;
    }
    
    public class UserAndInvoiceNumberWrapper {
        @AuraEnabled
        public User user {get;set;}  
        @AuraEnabled
        public Double maxInvoiceNumber {get;set;}  
    }
    
    // Edit Billing Record Functionalities Below.
    @AuraEnabled(cacheable = true)
    public static Invoice_Billing__c fetchBillRecordToEdit(String billRecordId){
        try{
            Invoice_Billing__c theBillRecord = [SELECT Id, Name, Description__c, Invoice_Number__c, Invoice_Date__c, Default_Invoice_Template__c,Invoice_Type__c,
                                               Selected_Account_Id__c, Selected_Contact_Id__c, Selected_Opportunity_Id__c, Selected_Account_Emails__c, Selected_Contact_Emails__c,Invoice_Template__c,
                                               Selected_Opportunity_Emails__c, Additional_Email_Addresses__c,Max_Invoice_Number__c FROM Invoice_Billing__c WHERE ID =:billRecordId WITH SECURITY_ENFORCED];
            return theBillRecord; 
        }catch(Exception ex){
            System.debug('At Line::: '+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        } 
    }       
}