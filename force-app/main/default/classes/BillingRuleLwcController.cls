/**********************************************************
Class: BillingRuleLwcController
Description: This is controller class of Lwc billingRuleLwc
***********************************************************/
public with sharing class BillingRuleLwcController {
    
    /**********************************************************
Method: getBillingRuleRecords
Description: This is used to retrive all billing rule related to a Billing Record
***********************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Billing_Trigger__c> getBillingRuleRecords(String parentBillRuleId){
        List<Billing_Trigger__c>  theBillRuleList = [SELECT Id, Operator__c, Field_Data_Type__c, Value__c, Rule_Type__c, Field_Label__c, Variable__c FROM Billing_Trigger__c WHERE Billing_Record__c =:parentBillRuleId WITH SECURITY_ENFORCED];
        return theBillRuleList;
    }
    
    /**********************************************************
Method: getPicklistValues
Description: This is used to retrive all the picklist values of selected field while creating billing rule
***********************************************************/
    @AuraEnabled
    public static List<PickValueWrapper> getPicklistValues(String parentObjApiName, String ObjectApiName, String FieldApiName){
        System.debug('getPicklistValuesMethod');
        if(!String.isBlank(parentObjApiName)){
            ObjectApiName = getFieldApiName(parentObjApiName, ObjectApiName);
            System.debug('ObjectApiName:::'+ObjectApiName);
        }else {
            ObjectApiName = ObjectApiName;
            
        }
        List<PickValueWrapper> thePickWrapperList = new List<PickValueWrapper>();
        if(ObjectApiName != null && FieldApiName !=null){
            if(ObjectApiName.contains('.')) ObjectApiName = ObjectApiName.substringAfterLast('.');
            Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(ObjectApiName) ;
            Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
            Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
            Schema.DescribeFieldResult fieldResult = fields.get(FieldApiName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            //System.assert(false, ple);
            for( Schema.PicklistEntry pickListVal : ple){
                PickValueWrapper thePick = new PickValueWrapper();
                thePick.label = pickListVal.getLabel();
                thePick.value = pickListVal.getValue();
                thePickWrapperList.add(thePick);
            }
        }
        return thePickWrapperList;
    }
    
    /**********************************************************
Method: getObjectFieldsLabel
Description: This is used to retrive all the fields with label, apiname & type
***********************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<LabelNameWrapper> getObjectFieldsLabel(InputDataWrapper theInputData){
        System.debug('getObjectFieldsLabel');
        if(theInputData.objectName== System.Label.OwnerLabel || theInputData.objectName== System.Label.CreatedByLabel || theInputData.objectName== System.Label.LastModifiedByLabel){
            theInputData.objectName = System.Label.UserLabel;
        }
        String lookupObjApiName;
        if(theInputData.isLookup){
            lookupObjApiName = getFieldApiName(theInputData.objectName, theInputData.apiName);
        }else {
            lookupObjApiName = theInputData.objectName;
        }
        
        List<LabelNameWrapper> theWrapList = new List<LabelNameWrapper>();
        List<String> theLabelList = new List<String>();
        Map<String, Schema.SObjectType> detail = Schema.getGlobalDescribe();
        for(Schema.SObjectField fields : detail.get(lookupObjApiName).getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldResult = fields.getDescribe();
            if(((lookupObjApiName != System.Label.OpportunityLabel  || lookupObjApiName != System.Label.OpportunityLineItemLabel && String.valueOf(fields.getDescribe().getType()) != System.Label.REFERENCE) || (lookupObjApiName == System.Label.OpportunityLabel || lookupObjApiName == System.Label.OpportunityLineItemLabel))){
                if(String.valueOf(fields.getDescribe().getType()) != System.Label.TEXTAREA && String.valueOf(fields.getDescribe().getType()) != 'ADDRESS'){
                    LabelNameWrapper theWrap = new LabelNameWrapper();
                    theWrap.label= fields.getDescribe().getLabel();
                    theWrap.value= fields.getDescribe().getName();
                    theWrap.type= String.valueOf(fields.getDescribe().getType());
                    theWrapList.add(theWrap);
                }
            }
        }
        return theWrapList;
    }
    public class PickValueWrapper{
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public string value {get;set;}
    }
    
    public class LabelNameWrapper{
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public string value {get;set;}
        @AuraEnabled
        public string type {get;set;}
    }
    
    public class InputDataWrapper{
        @AuraEnabled
        public string objectName {get;set;}
        @AuraEnabled
        public string apiName {get;set;}
        @AuraEnabled
        public Boolean isLookup {get;set;}
    }
    
    @AuraEnabled
    public static void deleteBillingRule(String billId){
        try{
            Billing_Trigger__c theBill = [SELECT Id FROM Billing_Trigger__c WHERE Id =: billId WITH SECURITY_ENFORCED];
            if(Billing_Trigger__c.sObjectType.getDescribe().isDeletable()) {
                delete theBill;
            }
            // if(CRUD_Helper.checkDeleteList(new List<Billing_Trigger__c>{theBill}, 'Billing_Trigger__c'))  delete theBill;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /**********************************************************
Method: createBillingRule
Description: This is used to create billing rules
***********************************************************/
    @AuraEnabled
    public static void createBillingRule(List<FieldValueWrapper> billingRuleDetails){
        List<Billing_Trigger__c> theBillRuleList = new List<Billing_Trigger__c>();
        try{
            for(FieldValueWrapper theFVWrap: billingRuleDetails){
                Billing_Trigger__c theBillRule = new Billing_Trigger__c();
                if(theFVWrap.billRuleId != null) theBillRule.Id = theFVWrap.billRuleId;
                theBillRule.Field_Label__c = theFVWrap.fieldName;
                theBillRule.Value__c = theFVWrap.value ;
                theBillRule.Billing_Record__c = theFVWrap.parentBillRecord;
                theBillRule.Operator__c = theFVWrap.operate;
                theBillRule.Variable__c = theFVWrap.isVariable;
                if(theFVWrap.rullType == System.Label.Opportunity_Rule || theFVWrap.rullType == System.Label.OpportunityPikFeldLabel){
                    theBillRule.Rule_Type__c = System.Label.OpportunityPikFeldLabel;
                }else{
                    theBillRule.Rule_Type__c= System.Label.OpportunityProductPicFLabel;
                }
                if(theFVWrap.billRuleId == null) theBillRule.Billing_Record__c = theFVWrap.parentBillRecord;
                theBillRule.Field_Data_Type__c = theFVWrap.fieldDataType;
                theBillRuleList.add(theBillRule);
            }
            if(!theBillRuleList.isEmpty()){
                upsert CRUD_Helper.cleanseFields(theBillRuleList, AccessType.UPSERTABLE);
            }
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public class FieldValueWrapper{
        @AuraEnabled
        public string billRuleId {get;set;}
        @AuraEnabled
        public string rullType {get;set;}
        @AuraEnabled
        public string fieldName {get;set;}
        @AuraEnabled
        public string value {get;set;}
        @AuraEnabled
        public string operate {get;set;}
        @AuraEnabled
        public string parentBillRecord {get;set;}
        @AuraEnabled
        public boolean isVariable {get;set;}
        @AuraEnabled
        public string fieldDataType {get;set;}
    }
    
    /**********************************************************
Method: getFieldApiName
Description: This is used get api name of an object using parent object name and lookup field api name
***********************************************************/
    public static string getFieldApiName(String objectName, String fieldName){      
        String fieldApiName = '';
        Schema.DescribeFieldResult f = Schema.getGlobalDescribe()
            .get(objectName)
            .getDescribe()
            .fields
            .getMap()
            .get(fieldName)
            .getDescribe();
             
        for (Schema.SObjectType reference : f.getReferenceTo()) {
            fieldApiName = reference.getDescribe().getName();
            System.debug('fieldApiName::::'+fieldApiName);
        }      
        return fieldApiName;
    }
}