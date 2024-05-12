/**********************************************************
Class: InvoiceTemplateLwcControllerTest
Description: This is controller class of Lwc InvoiceTemplateLwcController
***********************************************************/
  @isTest
  public class InvoiceTemplateLwcControllerTest {
    @testsetup
    public static void invoicetestsetupmethod(){
        //Insert Invoice Template
        Invoice_Template__c invoicetemp = TestDataUtil.createInvoiceTemplateRecords('invotempname');
        insert invoicetemp;
    }  
    
    /**********************************************************
Method: createInvoiceTemplateTest
Description: Method to create Invoice template record
***********************************************************/
    @isTest
    public static void createInvoiceTemplateTest(){
        //Invoke method getObjectFieldsLabel for Account
        InvoiceTemplateLwcController.getObjectFieldsLabel('Account');
        
        //Invoke method getObjectFieldsLabel for Opportunity
        InvoiceTemplateLwcController.getObjectFieldsLabel('OpportunityLineItem');
        
        //Create a file 
        Blob file = Blob.valueof('Sample text');
        
        Invoice_Template__c invtemp = [SELECT Id,Name,Buisness_Name_Field__c,Business_Phone_Field__c,City_Field__c,State_Field__c,
                                       Country_Field__c,ZipCode_field__c,Street_Field__c,Contact_City_Field__c,Contact_State_Field__c,Contact_Country_Field__c,
                                       Contact_ZipCode_field__c,Contact_Street_Field__c,Product_Quantity_Field__c,Product_Description_Field__c,Product_Unit_Price_Field__c,
                                       Product_Total_Amount_Field__c FROM Invoice_Template__c];
        
        //Create Invoice Template
        InvoiceTemplateLwcController.TemplateDataWrapper tempwrap = new InvoiceTemplateLwcController.TemplateDataWrapper();
        tempwrap.tempName = invtemp.Name;
        tempwrap.bizname = invtemp.Buisness_Name_Field__c;
        tempwrap.bizphone = invtemp.Business_Phone_Field__c;
        tempwrap.bizstate = invtemp.State_Field__c;
        tempwrap.bizcity  = invtemp.City_Field__c;
        tempwrap.bizcountry = invtemp.Country_Field__c;
        tempwrap.bizstreet = invtemp.Street_Field__c;
        tempwrap.bizzipcode = invtemp.ZipCode_field__c;
        tempwrap.concity = invtemp.Contact_City_Field__c;
        tempwrap.concountry = invtemp.Contact_Country_Field__c;
        tempwrap.constate = invtemp.Contact_State_Field__c;
        tempwrap.constreet = invtemp.Contact_Street_Field__c;
        tempwrap.conzipcode = invtemp.Contact_ZipCode_field__c;
        tempwrap.proddecsp = invtemp.Product_Description_Field__c;
        tempwrap.prodquantity = invtemp.Product_Quantity_Field__c;
        tempwrap.totalamount = invtemp.Product_Total_Amount_Field__c;
        tempwrap.unitprice = invtemp.Product_Unit_Price_Field__c;
        
        //Convert the file into string
        string str = Encodingutil.base64Encode(file);
        tempwrap.base64Content = str;
        tempwrap.logoname = 'Test logo';
        
        Test.startTest();
        InvoiceTemplateLwcController.saveData(tempwrap);
        Test.stopTest();
        
        List<Invoice_Template__c> invstr =[SELECT Id FROM Invoice_Template__c WHERE Name='invoTempName'];
        for(Invoice_Template__c inv:invstr){
            InvoiceTemplateLwcController.fetchInvoiceTemplateToEdit(inv.Id);
        }
        //Assertions
        System.assertEquals('invotempname',tempwrap.tempName,'Name should match');
        System.assertEquals(null,tempwrap.invId);
    } 
    /**********************************************************
Method: editInvoiceTemplateTest
Description: Method to edit Invoice template record
***********************************************************/
    @istest
    public static void editInvoiceTemplateTest(){
        //Invoke method getObjectFieldsLabel for Account
        InvoiceTemplateLwcController.getObjectFieldsLabel('Account');
        
        //Invoke method getObjectFieldsLabel for Opportunity
        InvoiceTemplateLwcController.getObjectFieldsLabel('OpportunityLineItem');
        
        //create a file
        Blob file = Blob.valueof('Sample text');
        
        Invoice_Template__c invtempate = [SELECT Id,Name,Buisness_Name_Field__c,Business_Phone_Field__c,City_Field__c,State_Field__c,
                                          Country_Field__c,ZipCode_field__c,Street_Field__c,Contact_City_Field__c,Contact_State_Field__c,Contact_Country_Field__c,
                                          Contact_ZipCode_field__c,Contact_Street_Field__c,Product_Quantity_Field__c,Product_Description_Field__c,Product_Unit_Price_Field__c,
                                          Product_Total_Amount_Field__c FROM Invoice_Template__c];
        
        //Create a Invoice Template
        InvoiceTemplateLwcController.TemplateDataWrapper tempwrap = new InvoiceTemplateLwcController.TemplateDataWrapper();
        tempwrap.invId = invtempate.Id;
        tempwrap.bizname = invtempate.Buisness_Name_Field__c;
        tempwrap.bizphone = invtempate.Business_Phone_Field__c;
        tempwrap.bizstate = invtempate.State_Field__c;
        tempwrap.bizcity  = invtempate.City_Field__c;
        tempwrap.bizcountry = invtempate.Country_Field__c;
        tempwrap.bizstreet = invtempate.Street_Field__c;
        tempwrap.bizzipcode = invtempate.ZipCode_field__c;
        tempwrap.concity = invtempate.Contact_City_Field__c;
        tempwrap.concountry = invtempate.Contact_Country_Field__c;
        tempwrap.constate = invtempate.Contact_State_Field__c;
        tempwrap.constreet = invtempate.Contact_Street_Field__c;
        tempwrap.conzipcode = invtempate.Contact_ZipCode_field__c;
        tempwrap.proddecsp = invtempate.Product_Description_Field__c;
        tempwrap.prodquantity = invtempate.Product_Quantity_Field__c;
        tempwrap.totalamount = invtempate.Product_Total_Amount_Field__c;
        tempwrap.unitprice = invtempate.Product_Unit_Price_Field__c;
        
        List<Invoice_Template__c> invlist = [SELECT Id FROM Invoice_Template__c WHERE id=:tempwrap.invId];
        for(Invoice_Template__c inv:invlist){
            tempwrap.invId =inv.Id;
        }
        //Convert the file
        string str = Encodingutil.base64Encode(file);
        tempwrap.base64Content = str;
        tempwrap.logoname = 'Test logo';
        
        //Invoke method saveData
        Test.startTest();
        String tempID = InvoiceTemplateLwcController.saveData(tempwrap);
        Test.stopTest();
       System.assert(tempID != null);
    }
}