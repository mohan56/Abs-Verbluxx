/**********************************************************
Class: BillingRuleLwcControllerTest
Description: This is controller class of Lwc BillingRuleLwcController
***********************************************************/

@isTest
public class BillingRuleLwcControllerTest {
    
    /**********************************************************
Method: setupMethod
Description: SetUp Method to create test records 
***********************************************************/  
    @testSetup
    public static void setupMethod(){
        
        Invoice_Template__c theInvTemp = TestDataUtil.createInvoiceTemplateRecords('Test Inv Temp');
        insert theInvTemp;
        
        Invoice_Billing__c theBillRecord = TestDataUtil.createBillingrecord('Test Invoice Temp Billing');
        theBillRecord.Invoice_Template__c = theInvTemp.Id;
        insert theBillRecord;
        
        Billing_Trigger__c theBillRule = TestDataUtil.createBillingRuleRecord('Test Billing Rule');
        theBillRule.Billing_Record__c= theBillRecord.Id;
        insert theBillRule;
        
        Opportunity theOpp = TestDataUtil.CreateOpporunityRecords('Test Opportunity');
        insert theOpp;
        
    }
    
    /**********************************************************
Method: createBillingRuleForOppTest
Description: createBillingRuleForOppTestMethod to create test records 
***********************************************************/  
    
    @isTest
    public static void createBillingRuleForOppTest(){
        BillingRuleLwcController.InputDataWrapper  theInputWrap= new BillingRuleLwcController.InputDataWrapper();
        theInputWrap.objectName = 'Opportunity';
        theInputWrap.apiName = 'AccountID';
        theInputWrap.isLookup = true;
        
        List<BillingRuleLwcController.LabelNameWrapper> labelNameList  = BillingRuleLwcController.getObjectFieldsLabel(theInputWrap);  
        
        Invoice_Billing__c testBillRec = [SELECT Id FROM Invoice_Billing__c LIMIT 1];
        
        List<BillingRuleLwcController.FieldValueWrapper> feildValueWrapperList = new List<BillingRuleLwcController.FieldValueWrapper>();
        
        for (BillingRuleLwcController.LabelNameWrapper fieldLabel : labelNameList) {
            
            BillingRuleLwcController.FieldValueWrapper fieldWrapper = new BillingRuleLwcController.FieldValueWrapper();
            
            fieldWrapper.rullType = 'Opportunity Rule';  
            fieldWrapper.fieldName = fieldLabel.value; 
            fieldWrapper.parentBillRecord = testBillRec.Id; 
            fieldWrapper.isVariable = false;  
            fieldWrapper.fieldDataType = 'String'; 
            fieldWrapper.operate= 'Equals' ; 
            
            if (fieldLabel.type == 'STRING') {
                fieldWrapper.value = 'Test Value';
            } else if (fieldLabel.type == 'NUMBER') {
                fieldWrapper.value = '1000';
            } else if (fieldLabel.type == 'PICKLIST') {  
                List<BillingRuleLwcController.PickValueWrapper> feildWrapperValueList = BillingRuleLwcController.getPicklistValues('','Account', fieldLabel.value);
                feildValueWrapperList.add(fieldWrapper);
            }
            
            feildValueWrapperList.add(fieldWrapper);
        }
        
        Test.startTest();
        BillingRuleLwcController.createBillingRule(feildValueWrapperList);
        Test.stopTest();
        
        List<Billing_Trigger__c> testBillingRuleList = BillingRuleLwcController.getBillingRuleRecords(testBillRec.Id);
        System.assert(!testBillingRuleList.isEmpty());
          
        for(Billing_Trigger__c billingRuleAssert : testBillingRuleList ){
           System.assertEquals('Opportunity',billingRuleAssert.Rule_Type__c);
           System.assertEquals(false,billingRuleAssert.Variable__c);
        }
    }
    
    /**********************************************************
Method: deleteBillingRule
Description: deleteBillingRule to create test records 
***********************************************************/  
    @isTest
    public static void deleteBillingRule(){
        
        List<Billing_Trigger__c> testBillRuleList = [SELECT Id FROM Billing_Trigger__c];
        Id billruleId = testBillRuleList[0].Id;
        Test.startTest();
        BillingRuleLwcController.deleteBillingRule(billruleId);  
        Test.stopTest();
        
        List<Billing_Trigger__c>  testBillRuleListAfterDeletion = [SELECT Id FROM Billing_Trigger__c];
        
       System.assert(testBillRuleList.size() != testBillRuleListAfterDeletion.size());   
    }
    
    /**********************************************************
Method: createBillingRuleForOppProdTest
Description: createBillingRuleForOppProdTest to create test records 
***********************************************************/  
    
    @isTest
    public static void createBillingRuleForOppProdTest(){
        BillingRuleLwcController.InputDataWrapper  theInputWrap= new BillingRuleLwcController.InputDataWrapper();
        theInputWrap.objectName = 'OpportunityLineItem';
        theInputWrap.apiName = 'OpportunityId';
        theInputWrap.isLookup = true;
        List<BillingRuleLwcController.LabelNameWrapper> labelNameList  = BillingRuleLwcController.getObjectFieldsLabel(theInputWrap);  
        
        Invoice_Billing__c testBillRec = [SELECT Id, (SELECT Id, Rule_Type__c from Billing_Rules__r WHERE Rule_Type__c = 'Opportunity') FROM Invoice_Billing__c LIMIT 1];
      
        List<BillingRuleLwcController.FieldValueWrapper> feildValueWrapperList = new List<BillingRuleLwcController.FieldValueWrapper>();
        
        for (BillingRuleLwcController.LabelNameWrapper fieldLabel : labelNameList) {
            
            BillingRuleLwcController.FieldValueWrapper fieldWrapper = new BillingRuleLwcController.FieldValueWrapper();
            
            fieldWrapper.rullType = 'Opportunity Product';  
            fieldWrapper.fieldName = fieldLabel.value; 
            fieldWrapper.parentBillRecord =testBillRec.Id; 
            fieldWrapper.isVariable = false;  
            fieldWrapper.fieldDataType = 'String'; 
            fieldWrapper.operate= 'Equals' ; 
            
            if (fieldLabel.type == 'STRING') {
                fieldWrapper.value = 'Test Value';
            } else if (fieldLabel.type == 'NUMBER') {
                fieldWrapper.value = '1000';
            } else if (fieldLabel.type == 'PICKLIST') {  
                List<BillingRuleLwcController.PickValueWrapper> feildWrapperValueList = BillingRuleLwcController.getPicklistValues('', 'Opportunity', fieldLabel.value);
                feildValueWrapperList.add(fieldWrapper);
            }
            feildValueWrapperList.add(fieldWrapper);
        }
        Test.startTest();
        BillingRuleLwcController.deleteBillingRule(testBillRec.Billing_Rules__r[0].Id);
        BillingRuleLwcController.createBillingRule(feildValueWrapperList);   
        Test.stopTest();
        List<Invoice_Billing__c> testBillingRecordsWithRules = [SELECT Id,(SELECT Id, Rule_Type__c FROM Billing_Rules__r) FROM Invoice_Billing__c WHERE ID=:testBillRec.Id ORDER BY createddate ASC];
        System.assertEquals('Opportunity Product', testBillingRecordsWithRules[0].Billing_Rules__r[0].Rule_Type__c);
    }  
    
    /**********************************************************
Method: negativeTestforgetPicklistValues
Description: negativeTestforgetPicklistValues to create test records 
***********************************************************/
    
    @isTest
    public static void negativeTestforgetPicklistValues(){
        Test.startTest();
        List<BillingRuleLwcController.PickValueWrapper> pickListValuesList = BillingRuleLwcController.getPicklistValues('', 'Account','Rating');
        Test.stopTest();
        System.assert(!pickListValuesList.isEmpty());
    }
    
    
    /**********************************************************
Method: NegativetestCreateBillingRuleExceptionHandling
Description: NegativetestCreateBillingRuleExceptionHandling to create test records 
***********************************************************/
    
    @isTest
    public static void NegativetestCreateBillingRuleExceptionHandling() {
        
        Billing_Trigger__c theBillRule = [select Id,Rule_Type__c from Billing_Trigger__c];
       
        List<BillingRuleLwcController.FieldValueWrapper> fieldValuesList = new List<BillingRuleLwcController.FieldValueWrapper>();
        BillingRuleLwcController.FieldValueWrapper theFeildValueWrapper = new  BillingRuleLwcController.FieldValueWrapper();
        theFeildValueWrapper.fieldName = 'Test Billing invoice' ;
        theFeildValueWrapper.billRuleId = 'invalidId';
        theFeildValueWrapper.value = 'Test Value';
        theFeildValueWrapper.operate = 'Equals';
        theFeildValueWrapper.isVariable = false;
        theFeildValueWrapper.fieldDataType = 'STRING';
        if(theFeildValueWrapper.rullType == 'Opportunity Rule'){
            theBillRule.Rule_Type__c = 'Opportunity';
        }
        else{
            theBillRule.Rule_Type__c = 'Opportunity Product';
        }
        fieldValuesList.add(theFeildValueWrapper);   
        
        Test.startTest();
        try {
            BillingRuleLwcController.createBillingRule(fieldValuesList);
        } catch (Exception e) {
            System.assert(e.getMessage() != null);
        }
        Test.stopTest();
    }
    
    /**********************************************************
Method: testNegativeDeleteBillingRuleExceptionHandling
Description: testNegativeDeleteBillingRuleExceptionHandling to create test records 
***********************************************************/
    
    @isTest
    public static void testNegativeDeleteBillingRuleExceptionHandling() {
        String nonInvalidId = 'invalidId';
        
        Test.startTest();
        try {
            //Calling the DeleteBillingRule Method By Providing Invalid Id 
            BillingRuleLwcController.deleteBillingRule(nonInvalidId);
        } catch (Exception e) {
           System.assert(e.getMessage() != null);
        }
        Test.stopTest();
    }
}