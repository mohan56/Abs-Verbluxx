public with sharing class InvoiceTemplateLwcController {
    
    @AuraEnabled(cacheable=true)
    public static List<LabelNameWrapper> getObjectFieldsLabel(String sObjectName){
        
        List<LabelNameWrapper> theWrapList = new List<LabelNameWrapper>();
        List<String> theLabelList = new List<String>();
        Map<String, Schema.SObjectType> detail = Schema.getGlobalDescribe();
        for(Schema.SObjectField fields : detail.get(sObjectName).getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldResult = fields.getDescribe();
            LabelNameWrapper theWrap = new LabelNameWrapper();
            if(sObjectName != System.Label.OpportunityLineItemLabel){
                if((String.valueOf(fields.getDescribe().getType()) == System.Label.STRING) || (String.valueOf(fields.getDescribe().getType()) == System.Label.PHONE) || (String.valueOf(fields.getDescribe().getType()) ==System.Label.TEXTAREA)){
                    theWrap.label= fields.getDescribe().getLabel();
                    theWrap.value= fields.getDescribe().getName();
                    theWrap.type= String.valueOf(fields.getDescribe().getType());
                    theWrapList.add(theWrap); 
            }    
            }else if(sObjectName == System.Label.OpportunityLineItemLabel){
                    theWrap.label= fields.getDescribe().getLabel();
                    theWrap.value= fields.getDescribe().getName();
                    theWrap.type= String.valueOf(fields.getDescribe().getType());
                    theWrapList.add(theWrap); 
            }
        }
        return theWrapList;
    } 
    
    public class LabelNameWrapper{
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public string value {get;set;}
        @AuraEnabled
        public string type {get;set;} 
    }
    
    @AuraEnabled
    /* sfge-disable-stack InternalExecutionError */
    public static String saveData(TemplateDataWrapper thetemplateDetails){
        Invoice_Template__c theTemp;
        
        if(thetemplateDetails != null){
            theTemp = new Invoice_Template__c();
            if(thetemplateDetails.tempName != null) theTemp.Name = thetemplateDetails.tempName;
            if(thetemplateDetails.bizname != null) theTemp.Buisness_Name_Field__c = thetemplateDetails.bizname; 
            if(thetemplateDetails.bizphone != null) theTemp.Business_Phone_Field__c = thetemplateDetails.bizphone; 
            if(thetemplateDetails.bizcity != null) theTemp.City_Field__c = thetemplateDetails.bizcity; 
            if(thetemplateDetails.bizstate != null) theTemp.State_Field__c = thetemplateDetails.bizstate; 
            if(thetemplateDetails.bizcountry != null) theTemp.Country_Field__c = thetemplateDetails.bizcountry; 
            if(thetemplateDetails.bizzipcode != null) theTemp.ZipCode_field__c = thetemplateDetails.bizzipcode;
            if(thetemplateDetails.bizstreet != null) theTemp.Street_Field__c = thetemplateDetails.bizstreet;
            
            if(thetemplateDetails.concity != null) theTemp.Contact_City_Field__c = thetemplateDetails.concity; 
            if(thetemplateDetails.constate != null) theTemp.Contact_State_Field__c = thetemplateDetails.constate; 
            if(thetemplateDetails.concountry != null) theTemp.Contact_Country_Field__c = thetemplateDetails.concountry; 
            if(thetemplateDetails.conzipcode != null) theTemp.Contact_ZipCode_field__c = thetemplateDetails.conzipcode;
            if(thetemplateDetails.constreet != null) theTemp.Contact_Street_Field__c = thetemplateDetails.constreet;
            
            if(thetemplateDetails.prodquantity != null) theTemp.Product_Quantity_Field__c = thetemplateDetails.prodquantity; 
            if(thetemplateDetails.proddecsp != null) theTemp.Product_Description_Field__c = thetemplateDetails.proddecsp; 
            if(thetemplateDetails.unitprice != null) theTemp.Product_Unit_Price_Field__c = thetemplateDetails.unitprice;
            if(thetemplateDetails.totalamount != null) theTemp.Product_Total_Amount_Field__c = thetemplateDetails.totalamount;
            
            if(thetemplateDetails.invId != null){
                theTemp.Id =thetemplateDetails.invId; 
            }
            if(thetemplateDetails.removeLogo){
               theTemp.Invoice_Logo__c = null; 
            }
        } 
       // upsert theTemp;
        List<Invoice_Template__c> theInvTempList = new List<Invoice_Template__c>();
        upsert theInvTempList = CRUD_Helper.cleanseFields(new List<Invoice_Template__c>{theTemp}, AccessType.UPSERTABLE);
        //upsert theInvTempList;
        
        if(!String.isBlank(thetemplateDetails.logoname) && !String.isBlank(thetemplateDetails.base64Content)){
         uploadFile(thetemplateDetails.logoname, thetemplateDetails.base64Content, theInvTempList[0].Id);
        }
        return theInvTempList[0].Id;
    }
    
    public class TemplateDataWrapper{
        @AuraEnabled
        public string invId {get;set;}
        @AuraEnabled
        public string logoname {get;set;}
        @AuraEnabled
        public string base64Content {get;set;} 
        @AuraEnabled
        public string tempName {get;set;}
        @AuraEnabled
        public string bizname {get;set;}
        @AuraEnabled
        public string bizphone {get;set;}
        @AuraEnabled
        public string bizcity {get;set;} 
        @AuraEnabled
        public string bizstreet {get;set;} 
        @AuraEnabled
        public string bizcountry {get;set;}
        @AuraEnabled
        public string bizzipcode {get;set;}
        @AuraEnabled
        public string bizstate {get;set;} 
        @AuraEnabled
        public string prodquantity {get;set;} 
        @AuraEnabled
        public string proddecsp {get;set;}
        @AuraEnabled
        public string unitprice {get;set;}
        @AuraEnabled
        public string totalamount {get;set;} 
        @AuraEnabled
        public string concity {get;set;} 
        @AuraEnabled
        public string constreet {get;set;} 
        @AuraEnabled
        public string concountry {get;set;}
        @AuraEnabled
        public string conzipcode {get;set;} 
        @AuraEnabled
        public string constate {get;set;} 
        @AuraEnabled
        public boolean removeLogo {get;set;} 
    }
    
    public static void uploadFile(String filename, String base64Content, String invTempId) {
        ContentVersion objContentVersion = new ContentVersion();
        List<ContentVersion> theConVersionList = new  List<ContentVersion>();
        base64Content = EncodingUtil.urlDecode(base64Content,'UTF-8');
        
        objContentVersion.VersionData = EncodingUtil.base64Decode(base64Content);
        objContentVersion.Title = filename;
        objContentVersion.PathOnClient = filename;
        try {
            //insert objContentVersion;
            insert theConVersionList = CRUD_Helper.cleanseFields(new List<ContentVersion>{objContentVersion}, AccessType.CREATABLE);
            //insert theConVersionList;

           } catch( DMLException e ) {
            System.debug('Error while uploading the file ' + e.getMessage()); 
        }        
        ContentDocumentLink objContentDocumentLink = new ContentDocumentLink();
        objContentDocumentLink.ContentDocumentId = [ SELECT ContentDocumentId FROM ContentVersion WHERE Id =: theConVersionList[0].Id].ContentDocumentId;
        objContentDocumentLink.ShareType = 'V';
        objContentDocumentLink.LinkedEntityId = invTempId;
        try {
            //insert objContentDocumentLink;
            List<ContentDocumentLink> objContentDocumentLinkList = new List<ContentDocumentLink>();
            insert objContentDocumentLinkList = CRUD_Helper.cleanseFields(new List<ContentDocumentLink>{objContentDocumentLink}, AccessType.CREATABLE);
            //insert objContentDocumentLinkList;
                
        } catch( DMLException e ) {
            System.debug('Error while uploading the file ' + e.getMessage());
        }
        // Content Distribution Starts
        
        //ContentDistribution: Represents information about sharing a document externally
        ContentDistribution cd = new ContentDistribution();
        cd.Name = filename;
        cd.ContentVersionId  = theConVersionList[0].Id;
        //insert cd;
        List<ContentDistribution> cdList = new List<ContentDistribution>();
        insert cdList = CRUD_Helper.cleanseFields(new List<ContentDistribution>{cd}, AccessType.CREATABLE);
        //insert cdList;
         
        ContentDistribution distribution = [select Name,ContentDownloadUrl from ContentDistribution where id=: cdList[0].id WITH SECURITY_ENFORCED];
        String  logoToSave = '<img src="'+distribution.ContentDownloadUrl+'" width="200" height="150">'+'</img><br/>';
        
        Invoice_Template__c theNewInv = new Invoice_Template__c();
        theNewInv.Invoice_Logo__c = logoToSave;
        theNewInv.Id = invTempId;
        //update theNewInv;
        List<Invoice_Template__c> theInvListToUpdate = new List<Invoice_Template__c>();
        update theInvListToUpdate = CRUD_Helper.cleanseFields(new List<Invoice_Template__c>{theNewInv}, AccessType.UPDATABLE);
        //update theInvListToUpdate;
        // Content Distribution Ends
    }
    
    // Edit Invoice Template Functionalities Below.
    @AuraEnabled(cacheable = true)
    public static TemplateContentIdWrapper fetchInvoiceTemplateToEdit(String invTempId){
        TemplateContentIdWrapper theWrap = new TemplateContentIdWrapper();
        
        Invoice_Template__c theInvTemplateRecord = [SELECT Id, Name, Buisness_Name_Field__c,Business_Phone_Field__c,City_Field__c,Country_Field__c,State_Field__c,Invoice_Logo__c,
                                                    Street_Field__c, ZipCode_field__c, Product_Quantity_Field__c,Product_Total_Amount_Field__c, Product_Unit_Price_Field__c,
                                                    Product_Description_Field__c,Contact_City_Field__c, Contact_State_Field__c,Contact_Street_Field__c,Contact_ZipCode_field__c,
                                                    Contact_Country_Field__c FROM Invoice_Template__c WHERE ID =:invTempId WITH SECURITY_ENFORCED];
        
        List<ContentVersion> cvs = new List<ContentVersion>();
        List<ContentDocumentLink> cdls = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:invTempId WITH SECURITY_ENFORCED order by ContentDocument.CreatedDate DESC];
        if(!cdls.isEmpty())cvs = [SELECT Id, VersionDataUrl FROM ContentVersion WHERE ContentDocumentId =:cdls[0].ContentDocumentId WITH SECURITY_ENFORCED];
        
        theWrap.tempObj = theInvTemplateRecord;
        if(!cvs.isEmpty() && !String.isBlank(theInvTemplateRecord.Invoice_Logo__c)){
             theWrap.contVerUrl = cvs[0].VersionDataUrl;
        }else {
            theWrap.contVerUrl = null;
        }
        return theWrap;
    }  
    
    public class TemplateContentIdWrapper{
        @AuraEnabled
        public Invoice_Template__c tempObj {get;set;}
        @AuraEnabled
        public string contVerUrl {get;set;}
    }
}