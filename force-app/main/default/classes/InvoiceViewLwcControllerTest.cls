/**********************************************************
Class: InvoiceViewLwcControllerTest
Description: This is controller class of Lwc InvoiceViewLwcController
***********************************************************/

@isTest
public class InvoiceViewLwcControllerTest {
    
/**********************************************************
Method: setupMethod
Description: SetUp Method to create test records 
***********************************************************/  
    @testSetup
    public static void setupMethod(){
        
        //Insert Account Record
        Account theAcc = TestDataUtil.createAccount('Test Account');
        insert theAcc;
         
        //Insert Contact Record
        Contact theCon =TestDataUtil.createContact('Test Contact');
        insert theCon;
        
        //Insert Product2
        Product2 theProd2 = TestDataUtil.createProduct2('Test Product2');
        insert theProd2;
        
        //Insert PricebookEntry
        PricebookEntry thePriceBookEntry = TestDataUtil.createPricebookEntry();
        thePriceBookEntry.Product2Id = theProd2.Id;
        insert thePriceBookEntry;
        
        //Insert Opportunity Record
        Opportunity theOpp =TestDataUtil.CreateOpporunityRecords('Test Opportunity');
        theOpp.Amount= 1000;
        theOpp.AccountId = theAcc.Id;
        insert theOpp;
                
        //Insert OpportunityLineItem
        OpportunityLineItem theOppLinItem = TestDataUtil.createOpportunityLineItem();
        theOppLinItem.OpportunityId = theOpp.Id; 
        theOppLinItem.Product2Id = theProd2.Id;
        theOppLinItem.PricebookEntryId = thePriceBookEntry.Id;
        insert theOppLinItem;
        
        //Insert Invoice_Billing__c Record
        Invoice_Billing__c theBillRecord = TestDataUtil.createBillingrecord('Test Billing Record');
        insert theBillRecord;
        
        //Insert Billing_Trigger__c Record
        Billing_Trigger__c theBillRule = TestDataUtil.createBillingRuleRecord('Test Billing Rule');
        theBillRule.Billing_Record__c = theBillRecord.Id;
        insert theBillRule;
        
        //Insert Invoice_Manager__c Record
        Invoice_Manager__c theInvo = TestDataUtil.createInvoiceManagerRecords('Test Invoice');
        theInvo.Account__c=theAcc.Id;
        theInvo.Contact__c=theCon.Id;
        theInvo.Billing_Record__c=theBillRecord.Id ;  
        insert theInvo;   
        
        //Insert ContentVersion Record
        ContentVersion theContent = TestDataUtil.createContentVersion('Test Content');
        insert theContent;
        
        //ContentDistribution: Represents information about sharing a document externally
        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'Test File';
        cd.ContentVersionId  = theContent.Id;
        insert cd;
         
        ContentDistribution distribution = [SELECT Name,ContentDownloadUrl FROM ContentDistribution WHERE id=: cd.id];
        String  logoToSave = '<img src="'+distribution.ContentDownloadUrl+'" width="200" height="150">'+'</img><br/>';
       
        //Insert Invoice Template
        Invoice_Template__c theInvoTemp = TestDataUtil.createInvoiceTemplateRecords('Test Invoice Template');
        theInvoTemp.Invoice_Logo__c = logoToSave;
        insert theInvoTemp;
        
        //Insert OpportunityContactRole 
        OpportunityContactRole theOppConRo = TestDataUtil.createOpportunityContactRole(theOpp.Id, theCon.Id);
        insert theOppConRo;
                             
    } 
    
/**********************************************************
Method: invoiceProviderTest
Description: Method to retrive Invoice records
***********************************************************/     
    @isTest
    public static void invoiceProviderTest(){    
        Test.startTest();
        List<InvoiceViewLwcController.wrapperClass> theWrapList = InvoiceViewLwcController.invoiceProvider(); 
        Test.stopTest();
        System.assertEquals(true, theWrapList.size() > 0); 
    }
    
/**********************************************************
Method: invoiceProviderFromBillingTest
Description: Method to retrieve Opportunity record dynamically on the basis of Billing rules
***********************************************************/     
    @isTest
    public static void invoiceProviderFromBillingTest(){      
        
        Invoice_Billing__c billingRecord = [SELECT Id,Name FROM Invoice_Billing__c WHERE Name = 'Test Billing Record'];
        
        Invoice_Template__c theInvList = [SELECT Buisness_Name_Field__c,Business_Phone_Field__c,City_Field__c,Contact_City_Field__c,Contact_Country_Field__c,
                                          Contact_State_Field__c,Contact_Street_Field__c,Contact_ZipCode_field__c,Country_Field__c,Id,
                                          Invoice_Logo__c,Name, Product_Description_Field__c, Product_Quantity_Field__c,Product_Total_Amount_Field__c,
                                          Product_Unit_Price_Field__c,State_Field__c,Street_Field__c, ZipCode_field__c FROM Invoice_Template__c 
                                          WHERE Name = 'Test Invoice Template' LIMIT 1] ;
        
        billingRecord.Invoice_Template__c = theInvList.Id;
        update billingRecord;
        
        Billing_Trigger__c billingRule = [SELECT Id,Name, Operator__c,	Billing_Record__c FROM Billing_Trigger__c WHERE Name = 'Test Billing Rule'];        
        
        Account theAcc = [SELECT Id,Name FROM Account WHERE Name = 'Test Account'];
        String accId = theAcc.Id;
        
        Contact theCon =[SELECT Id,LastName,AccountId FROM Contact WHERE LastName = 'Test Contact'];
        theCon.AccountId = accId;
        update theCon;
        
        Opportunity theOpp = [SELECT Id, Amount, accountID, (SELECT Id From OpportunityContactRoles) FROM Opportunity WHERE Name = 'Test Opportunity'];
        Test.startTest();
        InvoiceViewLwcController.InvoiceListWrapperClass result = InvoiceViewLwcController.invoiceProviderFromBilling(billingRecord.Id);  
        Test.stopTest();
        
        System.assertEquals(true, result != null); 
        System.assert(!result.wrapperClassList.isEmpty()); 
    }
    
    
/**********************************************************
Method: invoiceProviderFromBillingNegativeTest
Description: Method to retrieve Opportunity record dynamically on the basis of Billing rules
***********************************************************/     
    @isTest
    public static void invoiceProviderFromBillingNegativeTest(){      
        
        Invoice_Billing__c billingRecord = [SELECT Id,Name FROM Invoice_Billing__c WHERE Name = 'Test Billing Record'];
        
         Invoice_Template__c theInvList = [SELECT Buisness_Name_Field__c,Business_Phone_Field__c,City_Field__c,Contact_City_Field__c,Contact_Country_Field__c,
                                          Contact_State_Field__c,Contact_Street_Field__c,Contact_ZipCode_field__c,Country_Field__c,Id,
                                          Invoice_Logo__c,Name, Product_Description_Field__c, Product_Quantity_Field__c,Product_Total_Amount_Field__c,
                                          Product_Unit_Price_Field__c,State_Field__c,Street_Field__c, ZipCode_field__c FROM Invoice_Template__c 
                                          WHERE Name = 'Test Invoice Template' LIMIT 1] ;
           
        Billing_Trigger__c billingRule = [SELECT Id,Name, Operator__c,	Billing_Record__c FROM Billing_Trigger__c WHERE Name = 'Test Billing Rule'];        
        
        Account theAcc = [SELECT Id,Name FROM Account WHERE Name = 'Test Account'];
        String accId = theAcc.Id;
        
        Contact theCon =[SELECT Id,LastName,AccountId FROM Contact WHERE LastName = 'Test Contact'];
        theCon.AccountId = accId;
        update theCon;
        
        Opportunity theOpp = [SELECT Id, Amount, accountID, (SELECT Id FROM OpportunityContactRoles) FROM Opportunity WHERE Name = 'Test Opportunity'];
        Test.startTest();
        try{
           InvoiceViewLwcController.InvoiceListWrapperClass result = InvoiceViewLwcController.invoiceProviderFromBilling(billingRecord.Id); 
        }catch (AuraHandledException ex) {
           System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        
        billingRecord.Invoice_Template__c = theInvList.Id;
        update billingRecord; 
        InvoiceViewLwcController.InvoiceListWrapperClass result = InvoiceViewLwcController.invoiceProviderFromBilling(billingRecord.Id); 
        Test.stopTest();
    }
    
/**********************************************************
Method: saveInvoiceAttachmentTest
Description: Method to Save pdf invoice after getting pdf from LWC
***********************************************************/     
    @isTest
    public static void saveInvoiceAttachmentTest(){
        
        List<InvoiceViewLwcController.wrapperClass> testData = new List<InvoiceViewLwcController.wrapperClass>();
        
        Opportunity theOpp = [SELECT Id,Name FROM Opportunity LIMIT 1];
        
        Invoice_Billing__c theBillRecord = [SELECT Id,Additional_Email_Addresses__c FROM Invoice_Billing__c LIMIT 1];
        
        InvoiceViewLwcController.wrapperClass testDataItem = new InvoiceViewLwcController.wrapperClass();
        testDataItem.oppName = 'Test Opportunity';
        testDataItem.accName = 'Test Account';
        testDataItem.conName = 'Test Contact';
        testDataItem.invoiceAmount = '1000.00';
        testDataItem.invoiceDate = '2023-10-25';
        testDataItem.blobData = 'Base64EncodedBlobData';
        testDataItem.conEmail = 'test@gmail.com';
        testDataItem.printChecked = true;
        testDataItem.emailChecked = true;
        testDataItem.accHref = 'Test Account Link';
        testDataItem.oppHref = 'Test Opportunity Link';
        testDataItem.billRecordId = theBillRecord.Id;
        testDataItem.oppId = theOpp.Id;
        testData.add(testDataItem);
        Test.startTest();
        Map<Id,String> result = InvoiceViewLwcController.saveInvoiceAttachment(testData);
        System.assertEquals(testData.size(),result.size());
        Test.stopTest();
    }
  
    
/**********************************************************
Method: saveInvoiceAttachmentNegativeTest
Description: Method to Save pdf invoice after getting pdf from LWC
***********************************************************/     
    @isTest
    public static void saveInvoiceAttachmentNegativeTest(){
        
        List<InvoiceViewLwcController.wrapperClass> testData = new List<InvoiceViewLwcController.wrapperClass>();
        
        Opportunity theOpp = [SELECT Id,Name FROM Opportunity LIMIT 1];
        
        Invoice_Billing__c theBillRecord = [SELECT Id,Additional_Email_Addresses__c FROM Invoice_Billing__c LIMIT 1];
        
        InvoiceViewLwcController.wrapperClass testDataItem = new InvoiceViewLwcController.wrapperClass();
        testDataItem.oppName = 'Test Opportunity';
        testDataItem.accName = 'Test Account';
        testDataItem.conName = 'Test Contact';
        testDataItem.invoiceAmount = '1000.00';
        testDataItem.invoiceDate = '2023-10-25';
        testDataItem.blobData = 'Base64EncodedBlobData';
        testDataItem.conEmail = 'test@gmail.com';
        testDataItem.printChecked = true;
        testDataItem.emailChecked = true;
        testDataItem.accHref = 'Test Account Link';
        testDataItem.oppHref = 'Test Opportunity Link';
        testData.add(testDataItem);
        Test.startTest();
        
        try{
        Map<Id,String> result = InvoiceViewLwcController.saveInvoiceAttachment(testData);
        }catch (AuraHandledException ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        Test.stopTest();
    }
  
/**********************************************************
Method: fetchBillingRecordsTest
Description: Method to retrieve Billing Records
***********************************************************/ 

    @isTest
    public static void fetchBillingRecordsTest(){
        Test.startTest();
        List<Invoice_Billing__c> recievedBillList =  InvoiceViewLwcController.fetchBillingRecords();
        Test.stopTest();
        
        System.assertEquals(true, recievedBillList != null); 
    }   
}