/******************************************************************************
@Class         TestDataUtil
@description   This is global class which will be used to created data of various object for test classes.
******************************************************************************/ 

@isTest
public class TestDataUtil {
    private static final String USER_ALIAS = 'UserAlias';
    
    
    /******************************************************************************
@param         string aName
@return        Account - objAccount
@description   Create Account  object instance and return it.
*******************************************************************************/
    public static Account createAccount(string aName){
        Account objAccount = new Account(Name=aName,BillingStreet='testBillingStreet',BillingCity='testBillingCity',BillingState='testBillingState',
                                         BillingCountry='testBillingCountry',BillingPostalCode='testPostcode',ShippingStreet='testShippingStreet ',
                                         ShippingCity='testShippingCity',ShippingState='testShippingState',ShippingCountry='ShippingCountry',
                                         ShippingPostalCode='testPostCode');
        return objAccount;
    }
    
 /******************************************************************************
@param         string cName
@return        Contact - objContact
@description   Create Account  object instance and return it.
*******************************************************************************/
    public static Contact createContact(string cName){
        Contact objContact = new Contact();
        objContact.LastName = cName;
        objContact.Email ='test@gmail.com';
        objContact.FirstName = 'Test';
        objContact.LeadSource = 'Web';
        objContact.Phone = '(014) 427-4427';
        objContact.OtherStreet = 'Test Street';
        objContact.MailingCountry = 'Test Country';
        return objContact;
    }
    
 /******************************************************************************
@param         string oppName
@return        Opportunity - objOpp
@description   Create Opportunity  object instance and return it.
*******************************************************************************/    
    public static Opportunity CreateOpporunityRecords(String oppName){
        
        Opportunity objOppo = new Opportunity();
        objOppo.CloseDate = Date.today();
        objOppo.StageName = 'Prospecting';      
        objOppo.Name = oppName;
        ObjOppo.Invoice_Status__c = 'New';
        objOppo.Probability = 20;
        ObjOppo.Amount = 500000;
        ObjOppo.Type = 'New Customer';
        return objOppo;
    }

 /******************************************************************************
@param         string cusName
@return         Customer - objCust
@description   Create Customer  object instance and return it.
*******************************************************************************/       
 
   /* public static Customer createCustomerRecords(String cusName){
        Customer objCust = new Customer();
        objCust.Name = cusName;
        objCust.PartyId = '';
        return objCust;
    } */   
    
 /******************************************************************************
@param         string bName
@return        Invoice_Billing__c - objBillRecord
@description   Create Invoice_Billing__c  object instance and return it.
*******************************************************************************/
    public static Invoice_Billing__c createBillingrecord(string bName){
        Invoice_Billing__c objBillRecord = new Invoice_Billing__c(Name = bName, Invoice_Date__c= System.today(),
                                                               Additional_Email_Addresses__c='test@gmail.com',Selected_Account_Emails__c='test1@gmail.com',
                                                               Selected_Contact_Emails__c='test3@gmail.com',Selected_Opportunity_Emails__c='test4@gmail.com',
                                                               Max_Invoice_Number__c = 1);
        return objBillRecord;
    }
    
  /******************************************************************************
@param        No Params
@return        Invoice_Manager__c 
@description   Create Invoice_Manager__c  theInvo instance and return it.
*******************************************************************************/
    
    public static Invoice_Manager__c createInvoiceManagerRecords(String invoName){
        
               
        Invoice_Manager__c objInvo = new Invoice_Manager__c();
        objInvo.Name = invoName;
        objInvo.Invoice_Date__c = Date.today();
        objInvo.Invoice_Total_Amount__c = 1000;
        objInvo.Is_Emailed__c = True;
        objInvo.Is_Printed__c = True;
     
        System.debug(objInvo);
        return objInvo;
    }
  
  /******************************************************************************
@param         String contName
@return        ContentVersion  objContent
@description   Create ContentVersion  theInvo instance and return it.
*******************************************************************************/

    public static ContentVersion createContentVersion(String contName){
        
        ContentVersion objContent = new ContentVersion();
         objContent.Title = contName;
        objContent.PathOnClient = 'test.pdf';
        objContent.VersionData = Blob.valueOf('Test content data');
         return objContent;
    }
    
  
  /******************************************************************************
@param         String contName
@return        ContentDocumentLink  objContentDocument
@description   Create ContentDocumentLink  theInvo instance and return it.
*******************************************************************************/
    
    public static ContentDocumentLink CreateContentDocumentLink(){
        
       ContentDocumentLink  objContentDoc = new ContentDocumentLink(); 
        objContentDoc.ShareType = 'T';
        objContentDoc.Visibility = 'AllUsers';
        return objContentDoc;
    }
    
  /******************************************************************************
@param         String bRuleName
@return        Billing_Trigger__c  objBillRule
@description   Create Billing_Trigger__c  theInvo instance and return it.
*******************************************************************************/

    public static Billing_Trigger__c createBillingRuleRecord(String bRuleName){
              
        Billing_Trigger__c objBillRule = new Billing_Trigger__c();
        objBillRule.Name = bRuleName ;
        objBillRule.Field_Data_Type__c = 'STRING';
        objBillRule.Field_Label__c = 'Name';
        objBillRule.Operator__c='Equals';
        objBillRule.Rule_Type__c = 'Opportunity';
        objBillRule.Value__c ='Test Opportunity';
        return objBillRule;
    }

   
  /******************************************************************************
@param         String invoTempName
@return        Invoice_Template__c  objInvoiceTemp
@description   Create Invoice_Template__c  theInvo instance and return it.
*******************************************************************************/

    public static Invoice_Template__c createInvoiceTemplateRecords(String invoTempName){
        
        Invoice_Template__c objInvoiceTemp = new Invoice_Template__c();
        objInvoiceTemp.Name = invoTempName;
        objInvoiceTemp.Buisness_Name_Field__c='Name';
        objInvoiceTemp.Business_Phone_Field__c='Phone';
        objInvoiceTemp.Contact_City_Field__c='MailingCity';
        objInvoiceTemp.Contact_Country_Field__c='MailingCountry';
        objInvoiceTemp.Contact_State_Field__c='MailingState';
        objInvoiceTemp.Contact_Street_Field__c='OtherStreet';
        objInvoiceTemp.Contact_ZipCode_field__c='MailingPostalCode';
        objInvoiceTemp.City_Field__c ='BillingCity';
        objInvoiceTemp.State_Field__c='ShippingState';
        objInvoiceTemp.Street_Field__c='BillingStreet';
        objInvoiceTemp.Country_Field__c='ShippingCountry';
        objInvoiceTemp.Invoice_Logo__c = 'https://verbluxcom-dev-ed.develop.file.force.com/sfc/dist/version/download/?oid=00DHo000001aov9&ids=068Ho00000OVJpR&d=%2Fa%2FHo000001ASae%2Fqdy79JGDL7MLkCGAUQkoRwAZjp4xT2kNBmOs18DjlHM&asPdf';
        objInvoiceTemp.ZipCode_field__c ='ShippingPostalCode'; 
        objInvoiceTemp.Product_Quantity_Field__c = 'Quantity';
        objInvoiceTemp.Product_Total_Amount_Field__c = '';
        objInvoiceTemp.Product_Unit_Price_Field__c ='UnitPrice';
        objInvoiceTemp.State_Field__c = 'BillingState';
        objInvoiceTemp.Street_Field__c= 'ShippingStreet';
        objInvoiceTemp.ZipCode_field__c= 'BillingPostalCode';
        objInvoiceTemp.Product_Description_Field__c = 'Description';
         return objInvoiceTemp;
    }
    
 /******************************************************************************
@param         null
@return        OpportunityContactRole  objOppoConRo
@description   Create OpportunityContactRole  objOppoConRo instance and return it.
*******************************************************************************/

    public static OpportunityContactRole createOpportunityContactRole(String oppId, String conId){
        
        OpportunityContactRole objOppoConRo = new OpportunityContactRole();
        objOppoConRo.IsPrimary = true;
        objOppoConRo.Role = 'Economic Buyer';
        objOppoConRo.OpportunityId = oppId;
        objOppoConRo.ContactId = conId;    
        return objOppoConRo;       
    }
    
  /******************************************************************************
@param         String bookName
@return        Pricebook2  objPrice
@description   Create createPricebook2  objOppoConRo instance and return itobjPrice
*******************************************************************************/
    
    public static Pricebook2 createPricebook2(String bookName){
        
        Pricebook2 objPrice = new Pricebook2();
        objPrice.Name = bookName;
        objPrice.Description = 'Price Book Description';
        objPrice.IsActive = True;
       
        return objPrice;
    }
       
  /******************************************************************************
@param         String bookName
@return        Pricebook2  objPrice
@description   Create createPricebook2  objOppoConRo instance and return itobjPrice
*******************************************************************************/
    
     public static Product2 createProduct2(String proName){
        
        Product2 objProduct = new Product2();
        objProduct.Name = proName;
        objProduct.ProductCode = 'GC1040';
        objProduct.IsActive = True;
        return objProduct;
    }
    
      /******************************************************************************
@param         null
@return        PricebookEntry  thePriceEntry
@description   Create createPricebookEntry  thePriceEntry instance and return it.
*******************************************************************************/
   
    public static PricebookEntry createPricebookEntry(){
        Id pricebookId = Test.getStandardPricebookId();
       
        PricebookEntry thePriceEntry = new PricebookEntry();
         thePriceEntry.Pricebook2Id= pricebookId;
        thePriceEntry.IsActive = True;
        thePriceEntry.UnitPrice = 1000;
        return thePriceEntry;
    }
    
 /******************************************************************************
@param         null
@return        OpportunityLineItem  objOppoConRo
@description   Create OpportunityLineItem  objOppoConRo instance and return it.
*******************************************************************************/
    
    public static OpportunityLineItem createOpportunityLineItem(){    
        
        OpportunityLineItem objOppoLinItem = new OpportunityLineItem();
         objOppoLinItem.Quantity = 10;
         objOppoLinItem.Description = 'Description for Opp Line';
         objOppoLinItem.TotalPrice = 90000;
         objOppoLinItem.ServiceDate = Date.Today();
          return objOppoLinItem;
    }   
}