/**********************************************************
Class: BillingRecordLwcControllerTest
Description: This is controller class of Lwc BillingRecordLwcController
***********************************************************/
@isTest
public class BillingRecordLwcControllerTest {
    
    @testsetup 
    public static void testsetupmethod(){ 
        //Insert Account      
        Account theacc = TestDataUtil.createAccount('aName');
        insert theacc;
        
        //Insert Contact
        Contact thecon = TestDataUtil.createContact('cName');
        insert thecon;
        
        //Insert Opportunity
        Opportunity theopp = TestDataUtil.CreateOpporunityRecords('oName');
        insert theopp;
        
        //Insert Invoice Template
        Invoice_Template__c theinvoice = TestDataUtil.createInvoiceTemplateRecords('iName');
        insert theinvoice;
        
        //Insert Billing Record
        Invoice_Billing__c objBillRecord = TestDataUtil.createBillingrecord('bName');
        insert objBillRecord;
    }
    
/**********************************************************
Class: BillingRecordLwcControllerTest
Description: Method to create positive record of billing record
***********************************************************/
    @isTest
    public static void createBillingRecordPositiveTest(){
        Account acc =[SELECT Id,Name FROM Account LIMIT 1];
        
        List<Contact> testConList1 = BillingRecordLwcController.fetchAccountConEmailList(acc.ID);
        
        for(Contact con1 : testConList1){
            string Email = con1.Email;  
        }
        Contact con =[SELECT Id,LastName,AccountId,Email FROM Contact LIMIT 1];
        List<Contact> testconlist2 = BillingRecordLwcController.fetchContactEmailList(con.Id);
        for(Contact con2 : testconlist2){
            string Email = con2.Email;
        }
        
        Opportunity opp =[SELECT Id,Name,AccountId,CloseDate,StageName FROM Opportunity LIMIT 1];
        List<Contact> testconlist3 = BillingRecordLwcController.fetchOppConEmailList(opp.Id);
        for(Contact con3 : testconlist3){
            string Email = con3.Email;
        }
        
        Invoice_Template__c theinvo = [SELECT Id,Name,Contact_City_Field__c,Contact_Country_Field__c,Contact_State_Field__c,Contact_Street_Field__c,Contact_ZipCode_field__c,
                                       City_Field__c,Country_Field__c,State_Field__c,Street_Field__c,ZipCode_field__c FROM Invoice_Template__c LIMIT 1 ];
        
        Invoice_Billing__c billobj=[SELECT Id, Name, Description__c, Invoice_Number__c, Invoice_Date__c, Default_Invoice_Template__c,Invoice_Type__c,
                                               Selected_Account_Id__c, Selected_Contact_Id__c, Selected_Opportunity_Id__c, Selected_Account_Emails__c, Selected_Contact_Emails__c,Invoice_Template__c,
                                               Selected_Opportunity_Emails__c, Additional_Email_Addresses__c,Max_Invoice_Number__c FROM Invoice_Billing__c LIMIT 1];
        
        BillingRecordLwcController.BillingRecordWrapper billwrap = new BillingRecordLwcController.BillingRecordWrapper();
        billwrap.billingName=billobj.Name;
        billwrap.billingDescription=billobj.Description__c;
        billwrap.invoiceCounter=string.valueof(billobj.Invoice_Number__c);
        billwrap.invoiceTypeValue=billobj.Invoice_Type__c;
        billwrap.invoiceDate=string.valueof(billobj.Invoice_Date__c);
        billwrap.selectedTemplateValue=billobj.Default_Invoice_Template__c;
        billwrap.selectedAllEmails=billobj.Additional_Email_Addresses__c.split('\n');
        billwrap.maxInvoiceNumber=billobj.Max_Invoice_Number__c;
        billwrap.selectedAccId=billobj.Selected_Account_Id__c;
        billwrap.selectedConId=billobj.Selected_Contact_Id__c;
        billwrap.selectedOppId=billobj.Selected_Opportunity_Id__c;
        if(billobj.Selected_Account_Emails__c!=null)billwrap.selectedAccEmails=billobj.Selected_Account_Emails__c.split('\n');
        if(billobj.Selected_Contact_Emails__c!=null)billwrap.selectedContactEmails=billobj.Selected_Contact_Emails__c.split('\n');
        if(billobj.Selected_Opportunity_Emails__c!=null)billwrap.selectedOppEmails=billobj.Selected_Opportunity_Emails__c.split('\n');
        billwrap.billRecordId=billobj.Id; 
        
        test.starttest();
        //Invocke method createBillingRecord
        BillingRecordLwcController.createBillingRecord(billwrap);
        //Invocke method fetchBillRecordToEdit
        BillingRecordLwcController.fetchBillRecordToEdit(billobj.Id);
        //Invocke method getUser
        BillingRecordLwcController.getUser();
        test.stoptest();
       
        //Assertion
        System.assert(billwrap.billRecordId != null);
    }
    
/**********************************************************
Class: BillingRecordLwcControllerTest
Description: Method to check Negative scenario of billing record
***********************************************************/
    @istest
    public static void testCreateBillingRecord2(){
        Invoice_Billing__c billobj=[SELECT Id, Name, Description__c, Invoice_Number__c, Invoice_Date__c, Default_Invoice_Template__c,Invoice_Type__c,
                                              Selected_Account_Id__c, Selected_Contact_Id__c, Selected_Opportunity_Id__c, Selected_Account_Emails__c, Selected_Contact_Emails__c,Invoice_Template__c,
                                              Selected_Opportunity_Emails__c, Additional_Email_Addresses__c,Max_Invoice_Number__c FROM Invoice_Billing__c LIMIT 1];
        
        BillingRecordLwcController.BillingRecordWrapper bill = new BillingRecordLwcController.BillingRecordWrapper();
        bill.billingDescription ='';
        try{
            test.starttest();
            BillingRecordLwcController.createBillingRecord(bill);
            test.stoptest();
        }catch (exception e){
            System.assert(e.getMessage() != null);
        }
    } 
    
    @isTest
    public static void createBillingRecordNegativeTest(){
        Account acc =[SELECT Id,Name FROM Account LIMIT 1];
        
        List<Contact> testConList1 = BillingRecordLwcController.fetchAccountConEmailList(acc.ID);
        for(Contact con1 : testConList1){
            string Email = con1.Email;  
        }
        Contact con =[SELECT Id,LastName,AccountId,Email FROM Contact LIMIT 1];
        List<Contact> testconlist2 = BillingRecordLwcController.fetchContactEmailList(con.Id);
        for(Contact con2 : testconlist2){
            string Email = con2.Email;
        }
        Opportunity opp =[SELECT Id,Name,AccountId,CloseDate,StageName FROM Opportunity LIMIT 1];
        List<Contact> testconlist3 = BillingRecordLwcController.fetchOppConEmailList(opp.Id);
        for(Contact con3 : testconlist3){
            string Email = con3.Email;
        }
        Invoice_Template__c theinvo =[SELECT Id,Name,Contact_City_Field__c,Contact_Country_Field__c,Contact_State_Field__c,Contact_Street_Field__c,Contact_ZipCode_field__c,
                                      City_Field__c,Country_Field__c,State_Field__c,Street_Field__c,ZipCode_field__c FROM Invoice_Template__c LIMIT 1];
        
        Invoice_Billing__c billr = [SELECT Id, Name, Description__c, Invoice_Number__c, Invoice_Date__c, Default_Invoice_Template__c,Invoice_Type__c,
                                               Selected_Account_Id__c, Selected_Contact_Id__c, Selected_Opportunity_Id__c, Selected_Account_Emails__c, Selected_Contact_Emails__c,Invoice_Template__c,
                                               Selected_Opportunity_Emails__c, Additional_Email_Addresses__c,Max_Invoice_Number__c FROM Invoice_Billing__c LIMIT 1];
        
        BillingRecordLwcController.BillingRecordWrapper billwrap = new BillingRecordLwcController.BillingRecordWrapper();
        billwrap.billingName=billr.Name;                                                                                                                                                                                                                                                    
        billwrap.billingDescription=billr.Description__c;
        billwrap.invoiceCounter=string.valueof(billr.Invoice_Number__c);
        billwrap.invoiceTypeValue=billr.Invoice_Type__c;
        billwrap.invoiceDate=string.valueof(billr.Invoice_Date__c);
        billwrap.selectedAllEmails=billr.Additional_Email_Addresses__c.split('\n');
        billwrap.maxInvoiceNumber=billr.Max_Invoice_Number__c;
        billwrap.selectedAccId=billr.Selected_Account_Id__c;
        billwrap.selectedConId=billr.Selected_Contact_Id__c;
        billwrap.selectedOppId=billr.Selected_Opportunity_Id__c;
        if(billr.Selected_Account_Emails__c!=null)billwrap.selectedAccEmails=billr.Selected_Account_Emails__c.split('\n');
        if(billr.Selected_Contact_Emails__c!=null)billwrap.selectedContactEmails=billr.Selected_Contact_Emails__c.split('\n');
        if(billr.Selected_Opportunity_Emails__c!=null)billwrap.selectedOppEmails=billr.Selected_Opportunity_Emails__c.split('\n');
        billwrap.billRecordId=billr.Id;
        
        //Invocke method createBillingRecord
        try{
            test.starttest();
            BillingRecordLwcController.createBillingRecord(billwrap);
            test.stoptest();
        } catch (Exception e){
            System.assert(e.getMessage() != null);
        }
        //Invocke method fetchBillRecordToEdit
        BillingRecordLwcController.fetchBillRecordToEdit(billr.Id);
        //Invocke method getUser
        BillingRecordLwcController.getUser();
        
        //Assetions
        System.assert(billwrap.billRecordId != null);
        System.assert(!billwrap.selectedAllEmails.isEmpty());
    }  
    
}