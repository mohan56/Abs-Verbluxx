/**********************************************************
Class: InvoiceViewLwcController
Description: This is controller class of Lwc Invoice View
***********************************************************/
public with sharing class InvoiceViewLwcController {
    public static List<String> theEmailAddressList = new List<String>();
    
/**********************************************************
Method Name: invoiceProvider
Description: This method is used to get 20 recent invoice records 
***********************************************************/
    @AuraEnabled(Cacheable = true)
    public static List<wrapperClass> invoiceProvider(){
        try {
            List<wrapperClass> wrapperList = new List<wrapperClass>();
            List<Invoice_Manager__c> invoiceList = [SELECT Id, Account__r.Name,Invoice_Date__c,Invoice_Status__c,Opportunity__r.Name,
                                                    (SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLinks ORDER BY SystemModstamp DESC),Contact__c,
                                                    Contact__r.Name, Opportunity__c, Account__c, convertCurrency(Invoice_Total_Amount__c), Is_Emailed__c, 
                                                    Is_Printed__c FROM Invoice_Manager__c WHERE Invoice_Status__c ='Done' AND (Is_Emailed__c = TRUE OR Is_Printed__c=TRUE) 
                                                    WITH SECURITY_ENFORCED ORDER BY createddate DESC LIMIT 20];
            
            System.debug('invoiceList::: '+invoiceList);
            for(Invoice_Manager__c objinvoice : invoiceList){
                wrapperClass objWrapper = new wrapperClass();
                objWrapper.invoiceId=objinvoice.Id;
                objWrapper.accName=objinvoice.Account__r.Name;
                objWrapper.conName=objinvoice.Contact__r.Name;
                objWrapper.invoiceStatus=objinvoice.Invoice_Status__c;
                objWrapper.invoiceDate=String.valueOf(objinvoice.Invoice_Date__c);
                objWrapper.oppName=objinvoice.Opportunity__r.Name;
                objWrapper.invoiceAmount=objinvoice.Invoice_Total_Amount__c != null ? String.valueOf(objinvoice.Invoice_Total_Amount__c) : null; 
                objWrapper.oppId=objinvoice.Opportunity__c;
                objWrapper.accId=objinvoice.Account__c;
                objWrapper.conId=objinvoice.Contact__c;
                
                objWrapper.emailChecked=objinvoice.Is_Emailed__c;
                objWrapper.printChecked=objinvoice.Is_Printed__c;
                if(!objinvoice.ContentDocumentLinks.isEmpty()) objWrapper.invContentDocId=objinvoice.ContentDocumentLinks[0].ContentDocumentId;
                
                wrapperList.add(objWrapper);
            }
            System.debug('wrapperList::'+wrapperList);
            return wrapperList; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
/**********************************************************
Method Name: invoiceProviderFromBilling
Description: This method is used to get wrapper InvoiceListWrapperClass values.
***********************************************************/
    @AuraEnabled(cacheable = true)
    public static InvoiceListWrapperClass invoiceProviderFromBilling(String billId){
        try { 
            InvoiceListWrapperClass theInvListWrap = new invoiceListWrapperClass();
            Map<String, String> theOperaterMap = new  Map<String, String>();
            theOperaterMap.put('Greater Than', '>');
            theOperaterMap.put('Less Than', '<');
            theOperaterMap.put('Equals', '=');
            theOperaterMap.put('Not Equals', '!=');
            theOperaterMap.put('Less Than or Equal', '<=');
            theOperaterMap.put('Greater Than or Equal', '>=');
            
            List<Billing_Trigger__c> theBillRuleList = [SELECT Id, Name, Rule_Type__c, Field_Data_Type__c, Field_Label__c, Operator__c, Value__c, Billing_Record__r.Invoice_Template__c,
                                                        Billing_Record__r.Additional_Email_Addresses__c, Billing_Record__r.Invoice_Number__c, Billing_Record__r.Invoice_Date__c,
                                                        Billing_Record__r.OwnerId FROM Billing_Trigger__c WHERE Billing_Record__c = :billId WITH SECURITY_ENFORCED];
            System.debug('theBillRuleList::'+theBillRuleList);
            String invBillingOwnerId = theBillRuleList[0].Billing_Record__r.OwnerId;
            
            Integer oppRuleCount = 0;
            for(Billing_Trigger__c theBillRule: theBillRuleList){
                if(theBillRule.Rule_Type__c == System.Label.OpportunityPikFeldLabel){
                    oppRuleCount =  oppRuleCount + 1; 
                }  
            }
            if(oppRuleCount < 1){
                theInvListWrap.errMessage = 'You need at least one Opportunity Trigger. Go to the Invoice Billing and set one up.';
                return theInvListWrap;
            }
            
            List<Invoice_Template__c> theInvList = [SELECT Buisness_Name_Field__c,Business_Phone_Field__c,City_Field__c,Contact_City_Field__c,Contact_Country_Field__c,
                                                    Contact_State_Field__c,Contact_Street_Field__c,Contact_ZipCode_field__c,Country_Field__c,Id,
                                                    Invoice_Logo__c,Name, Product_Description_Field__c, Product_Quantity_Field__c,Product_Total_Amount_Field__c,
                                                    Product_Unit_Price_Field__c,State_Field__c,Street_Field__c, ZipCode_field__c FROM Invoice_Template__c 
                                                    WHERE ID =: theBillRuleList[0].Billing_Record__r.Invoice_Template__c WITH SECURITY_ENFORCED];
            System.debug('theInvList::::::'+theInvList);
            String versionDataString;   
            
            if(!theInvList.isEmpty() && theInvList[0].Invoice_Logo__c != null){
                String contVersionId = theInvList[0].Invoice_Logo__c.substringBetween('ids=','&amp');
                List<ContentVersion> theContVerList = [SELECT Id, VersionData FROM ContentVersion WHERE ID =:contVersionId WITH SECURITY_ENFORCED];
                Blob versionDataBlob = theContVerList[0].VersionData;
                versionDataString = EncodingUtil.base64Encode(versionDataBlob);  
            }
            
            String oppFilter = '';
            String oppProdFilter = '';
            for(Billing_Trigger__c theBillRule: theBillRuleList){
                // To change api name of custom lookup relation from __c to __r
                List<String> theLabelList = theBillRule.Field_Label__c.split('\\.');
                Integer lastElementIndex = theLabelList.size() - 1;
                String lastElement = theLabelList[lastElementIndex];
                List<String> newLabelList = new List<String>();
                Integer i = 0;
                for(String theStr: theLabelList){
                    if(theStr.endsWithIgnoreCase('__c') && theStr != lastElement){
                        theStr = theStr.removeEndIgnoreCase('c');
                        theStr = theStr+'r'; 
                    }
                     newLabelList.add(theStr);
                }
                theBillRule.Field_Label__c= String.join(newLabelList,',');
                theBillRule.Field_Label__c =  theBillRule.Field_Label__c.replaceAll(',', '.');
               
                System.debug('theBillRule:::: '+theBillRule);
                String operator = theOperaterMap.get(theBillRule.Operator__c);
                if(theBillRule.Field_Data_Type__c == System.Label.STRING || theBillRule.Field_Data_Type__c == System.Label.PICKLIST || theBillRule.Field_Data_Type__c == System.Label.BillRuleIdLabel || theBillRule.Field_Data_Type__c =='URL' || theBillRule.Field_Data_Type__c =='PHONE'){
                    
                    if(theBillRule.Rule_Type__c == System.Label.OpportunityPikFeldLabel){
                        oppFilter= oppFilter  + theBillRule.Field_Label__c+' '+ operator +' '+ '\'' +theBillRule.Value__c+ '\''  + ' AND ';
                    }else{
                        oppProdFilter= oppProdFilter  + theBillRule.Field_Label__c+' '+ operator +' '+ '\'' +theBillRule.Value__c+ '\''  + ' AND ';
                    }
                }else{
                    if(theBillRule.Rule_Type__c == System.Label.OpportunityPikFeldLabel){
                        oppFilter= oppFilter  + theBillRule.Field_Label__c+' '+ operator +' '+ theBillRule.Value__c + ' AND ';
                    }else{
                        oppProdFilter= oppProdFilter  + theBillRule.Field_Label__c+' '+ operator +' '+ theBillRule.Value__c + ' AND ';  
                    }
                }
            }
            oppFilter = !String.isBlank(oppFilter) ? ' WHERE '+oppFilter +'OwnerId= '+'\'' + invBillingOwnerId + '\'': '';
            oppProdFilter = !String.isBlank(oppProdFilter) ? ' WHERE '+oppProdFilter.removeEnd(' AND ') + ')': ')';
            
            List<wrapperClass> wrapperList = new List<wrapperClass>();            
            String query = 'select Id, Name, Account.Name, AccountId, account.' + String.escapeSingleQuotes(theInvList[0].Street_Field__c) + ' ,account.' + String.escapeSingleQuotes(theInvList[0].State_Field__c) + ', account.' + String.escapeSingleQuotes(theInvList[0].Country_Field__c) + ',account.' + String.escapeSingleQuotes(theInvList[0].ZipCode_field__c) + ',account.' + String.escapeSingleQuotes(theInvList[0].City_Field__c) + ' '
                + ' ,Invoice_Status__c, Invoice_Date__c, convertCurrency(Amount), Shipping_Handling__c, Sales_Tax__c,Total_Due__c, '
                + ' (Select Contact.name, Contact.Phone, Contact.Email,Contact.' + String.escapeSingleQuotes(theInvList[0].Contact_Street_Field__c) + ' ,Contact.' + String.escapeSingleQuotes(theInvList[0].Contact_State_Field__c) + ' ,Contact.' + String.escapeSingleQuotes(theInvList[0].Contact_Country_Field__c) + ' ,Contact.' + String.escapeSingleQuotes(theInvList[0].Contact_ZipCode_field__c) + ' ,Contact.' + String.escapeSingleQuotes(theInvList[0].Contact_City_Field__c) + ' '
                + ' ,Id, OpportunityId From OpportunityContactRoles WHERE IsPrimary = true), '
                + ' (SELECT Quantity, Description, convertCurrency(UnitPrice), convertCurrency(TotalPrice) FROM OpportunityLineItems' + oppProdFilter
                + ' from Opportunity ' + oppFilter;
            
            System.debug('query::: '+query); 
            List<Opportunity> theOppList = Database.query(query);
            
            if(theOppList.isEmpty()){
                theInvListWrap.errMessage = 'The are no Opportunity records that comply with the billing triggers. Check triggers values, or make sure you are using the right invoice billing.';
                return theInvListWrap;
            }
            
            for(Opportunity theOpp : theOppList){
                wrapperClass objWrapper = new wrapperClass();
                objWrapper.accName=theOpp.Account.Name;
                objWrapper.accId=theOpp.AccountId;
                
                if(!theOpp.OpportunityContactRoles.isEmpty()){
                    objWrapper.conName=theOpp.OpportunityContactRoles[0].Contact.name;
                    objWrapper.conPhone=theOpp.OpportunityContactRoles[0].Contact.Phone;
                    objWrapper.conEmail=theOpp.OpportunityContactRoles[0].Contact.Email;
                    objWrapper.conId=theOpp.OpportunityContactRoles[0].Contact.Id;
                    objWrapper.shipTo= String.valueOf(theOpp.OpportunityContactRoles[0].Contact.get(theInvList[0].Contact_Street_Field__c));
                    if(theOpp.OpportunityContactRoles[0].Contact.get(theInvList[0].Contact_Country_Field__c) != null){
                        objWrapper.shipTo= objWrapper.shipTo +', '+ String.valueOf(theOpp.OpportunityContactRoles[0].Contact.get(theInvList[0].Contact_City_Field__c))
                            +', '+ String.valueOf(theOpp.OpportunityContactRoles[0].Contact.get(theInvList[0].Contact_State_Field__c))
                            +', '+ String.valueOf(theOpp.OpportunityContactRoles[0].Contact.get(theInvList[0].Contact_ZipCode_field__c))
                            +', '+ String.valueOf(theOpp.OpportunityContactRoles[0].Contact.get(theInvList[0].Contact_Country_Field__c));
                    }
                }
                if(!theOpp.OpportunityLineItems.isEmpty()){
                    objWrapper.oliList = theOpp.OpportunityLineItems;
                }
                objWrapper.invoiceStatus=theOpp.Invoice_Status__c;
                objWrapper.invoiceDate=theOpp.Invoice_Date__c != null ? String.valueOf(theOpp.Invoice_Date__c): String.valueOf(System.today());
                if(theBillRuleList[0].Billing_Record__r.Invoice_Number__c != null) objWrapper.invoiceNumber='INV'+String.valueOf(theBillRuleList[0].Billing_Record__r.Invoice_Number__c);
                objWrapper.oppName=theOpp.Name;
                objWrapper.invoiceAmount= String.valueOf(theOpp.Amount);
                if(theOpp.Account != null) objWrapper.billTo=String.valueOf(theOpp.Account.get(theInvList[0].Street_Field__c));
                if(theOpp.Account != null && theOpp.Account.get(theInvList[0].Country_Field__c) != null){
                    objWrapper.billTo =objWrapper.billTo +', '+String.valueOf(theOpp.Account.get(theInvList[0].City_Field__c))
                        +', '+String.valueOf(theOpp.Account.get(theInvList[0].State_Field__c))
                        +', '+String.valueOf(theOpp.Account.get(theInvList[0].ZipCode_Field__c))
                        +', '+String.valueOf(theOpp.Account.get(theInvList[0].Country_Field__c));
                }
                
                objWrapper.shippinghandling = String.valueOf(theOpp.Shipping_Handling__c);
                objWrapper.salesTax = String.valueOf(theOpp.Sales_Tax__c);
                objWrapper.totalDue = String.valueOf(theOpp.Total_Due__c);
                objWrapper.oppId = theOpp.Id; 
                objWrapper.billRecordId = billId;
                wrapperList.add(objWrapper);
                System.debug('wrapperList:::::::'+wrapperList);
            }
            theInvListWrap.wrapperClassList = wrapperList;
            if(versionDataString != null) theInvListWrap.invoiceLogo =versionDataString;
            
            return theInvListWrap;
        } catch (Exception e) {
            System.debug('At line::: '+e.getLineNumber());
            if(e.getTypeName() == 'System.QueryException'){
                throw new AuraHandledException('Billing Trigger Record Error: Check triggers values, '+ e.getMessage());
            } else{
                throw new AuraHandledException('An Error Occured. Please Contact Admin '+e.getMessage());
            }
        }
    } 
    
    public class wrapperClass{ 
        @AuraEnabled
        public String invoiceId {get;set;}
        @AuraEnabled
        public String billRecordId {get;set;}
        @AuraEnabled
        public String accName {get;set;}
        @AuraEnabled
        public String conName {get;set;}
        @AuraEnabled
        public String invoiceStatus {get;set;}
        @AuraEnabled
        public String invoiceDate {get;set;}
        @AuraEnabled
        public String invoiceNumber {get;set;}
        @AuraEnabled
        public String oppName {get;set;}
        @AuraEnabled
        public String invoiceAmount {get;set;}
        @AuraEnabled
        public String shippinghandling {get;set;}
        @AuraEnabled
        public String salesTax {get;set;}
        @AuraEnabled
        public String totalDue {get;set;}
        @AuraEnabled
        public String conPhone {get;set;}
        @AuraEnabled
        public String conEmail {get;set;}
        @AuraEnabled
        public String billTo {get;set;}
        @AuraEnabled
        public String shipTo {get;set;}
        @AuraEnabled
        public String oppId {get;set;}
        @AuraEnabled
        public String accId {get;set;}
        @AuraEnabled
        public String conId {get;set;}
        @AuraEnabled
        public String oppHref {get;set;}
        @AuraEnabled
        public String accHref {get;set;}
        @AuraEnabled
        public String indx {get;set;}
        @AuraEnabled
        public String blobData {get;set;}
        @AuraEnabled
        public Boolean emailChecked {get;set;}
        @AuraEnabled
        public Boolean printChecked {get;set;}
        @AuraEnabled
        public String invContentDocId {get;set;}
        @AuraEnabled
        public List<OpportunityLineItem> oliList {get;set;}
    }
    
    public class InvoiceListWrapperClass{ 
        @AuraEnabled
        public String invoiceLogo {get;set;}
        @AuraEnabled
        public List<wrapperClass> wrapperClassList {get;set;}
        @AuraEnabled
        public String errMessage {get;set;}
    }
    
/**********************************************************
Method Name: saveInvoiceAttachment
Description: This method is save Invoice Pdf generated inside JS file.
***********************************************************/
    @AuraEnabled
    public static Map<ID, String> saveInvoiceAttachment(List<wrapperClass> invBlobData){
        try{
            Map<ID, String> contentIdOppIdMap = new Map<ID, String>();
            Map<ID, String> contentVerOppIdMap = new Map<ID, String>();
            Map<String, String>  contentLinkedIdMap= new  Map<String, String>();
            List<ContentVersion> theContentList = new List<ContentVersion>();
            List<String> theOppListForEmail = new  List<String>();
            Map<String, Invoice_Manager__c> invoiceMap = new Map<String, Invoice_Manager__c>();
            
            for(wrapperClass theWrapBlob: invBlobData){
                Invoice_Manager__c newInvoice = new Invoice_Manager__c();
                if(theWrapBlob.emailChecked != null && theWrapBlob.emailChecked){
                    newInvoice.Is_Emailed__c = true;
                    theOppListForEmail.add(theWrapBlob.oppId);
                    theEmailAddressList.add(theWrapBlob.conEmail);
                }
                if(theWrapBlob.printChecked != null && theWrapBlob.printChecked){
                    newInvoice.Is_Printed__c = true;
                }
                newInvoice.Name = theWrapBlob.oppName;
                newInvoice.Opportunity__c = theWrapBlob.oppId;
                newInvoice.Account__c = theWrapBlob.accId;
                if(theWrapBlob.conId != null) newInvoice.Contact__c = theWrapBlob.conId;
                newInvoice.Invoice_Status__c = 'Done';  
                newInvoice.Invoice_Total_Amount__c =  Decimal.valueof(theWrapBlob.invoiceAmount);
                newInvoice.Invoice_Date__c = theWrapBlob.invoiceDate !=null ? Date.valueof(theWrapBlob.invoiceDate): System.today();
                invoiceMap.put(theWrapBlob.oppId, newInvoice);
                
                ContentVersion cv = new ContentVersion();
                cv.InvoiceOppId__c = theWrapBlob.oppId;
                cv.Title = 'INV-'+System.today();
                cv.PathOnClient = 'Invoice' +'.'+'pdf'; 
                cv.VersionData = EncodingUtil.base64Decode(theWrapBlob.blobData);
                contentLinkedIdMap.put(cv.InvoiceOppId__c, theWrapBlob.oppId);
                theContentList.add(cv);
            }
            //  insert theContentList;
            
            //List<ContentVersion> theContentListToInsert = new List<ContentVersion>(); 
            Set<String> theFLSForContVersion = new Set<String>{'InvoiceOppId__c','Title','PathOnClient','VersionData'};
                if(CRUD_Helper.areFieldsCreateable(theFLSForContVersion, 'ContentVersion')){
                    insert theContentList;
                    //insert theContentListToInsert = (List<ContentVersion>)CRUD_Helper.cleanseFields(theContentList, AccessType.CREATABLE);
                }
            
            
            //List<Invoice_Manager__c> theInvoiceManagerInsertList = new List<Invoice_Manager__c>();
            Set<String> theFieldsCheckForInvManager = new Set<String>{'Is_Emailed__c','Is_Printed__c','Name','Opportunity__c','Account__c','Contact__c','Invoice_Status__c','Invoice_Total_Amount__c','Invoice_Date__c'};
                if(CRUD_Helper.areFieldsCreateable(theFieldsCheckForInvManager, 'Invoice_Manager__c')){
                    insert invoiceMap.values();
                    //insert theInvoiceManagerInsertList = (List<Invoice_Manager__c>) CRUD_Helper.cleanseFields(invoiceMap.values(), AccessType.CREATABLE);
                    
                }
            
            List<ContentVersion> conDocuList = [SELECT ContentDocumentID,InvoiceOppId__c FROM ContentVersion WHERE ID=:theContentList WITH SECURITY_ENFORCED];
            List<ContentDocumentLink> theConDocLinkList = new list<ContentDocumentLink>();
            
            for(ContentVersion theConDocId: conDocuList){
                ContentDocumentLink conDocLink = new ContentDocumentLink();
                conDocLink.LinkedEntityId = contentLinkedIdMap.get(theConDocId.InvoiceOppId__c);
                conDocLink.LinkedEntityId = invoiceMap.get(theConDocId.InvoiceOppId__c).Id;
                conDocLink.ContentDocumentId = theConDocId.ContentDocumentID;
                conDocLink.shareType = 'V';
                conDocLink.Visibility = System.Label.AllUsers;
                contentIdOppIdMap.put(theConDocId.InvoiceOppId__c, conDocLink.ContentDocumentId);
                contentVerOppIdMap.put(theConDocId.InvoiceOppId__c, theConDocId.Id);
                theConDocLinkList.add(conDocLink);
            }
            //  insert theConDocLinkList; 
            insert CRUD_Helper.cleanseFields(theConDocLinkList, AccessType.CREATABLE);
            
            if(!theOppListForEmail.isEmpty() && hasEmailQuota()){
                sendInvoiceEmails(contentVerOppIdMap, theOppListForEmail, invBlobData[0].billRecordId);
            }
            return contentIdOppIdMap;
        }catch(Exception ex){
            System.debug('At Line::: '+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
/**********************************************************
Method Name: sendInvoiceEmails
Description: This method is used to send emails with attached invoice pdf to selected emails.
***********************************************************/
    public static void sendInvoiceEmails(Map<Id, String> contentIdOppIdMap, List<String> theOppListForEmail, String billRecordId){
        try{
            List<String> ccAddresses = new List<String>();
            Messaging.SingleEmailMessage[] mails = new Messaging.SingleEmailMessage[]{};
                
                EmailTemplate emailTemp = [SELECT Id,Name,Subject,HtmlValue,Body 
                                           FROM EmailTemplate 
                                           WHERE IsActive = true
                                           And DeveloperName = 'Invoice_View_Email_Template' WITH SECURITY_ENFORCED];
            
            List<Opportunity> theOppList = [SELECT Id, Name FROM Opportunity WHERE ID IN: theOppListForEmail WITH SECURITY_ENFORCED];
            
            Invoice_Billing__c theBillRecord = [SELECT Id, Additional_Email_Addresses__c FROM Invoice_Billing__c WHERE ID=:billRecordId WITH SECURITY_ENFORCED];
            
            if(theBillRecord != null && !theBillRecord.Additional_Email_Addresses__c.split('\n').isEmpty()){
                theEmailAddressList.addAll(theBillRecord.Additional_Email_Addresses__c.split('\n'));    
            } 
            
            Set<String> emailAddressList = new Set<String>(theEmailAddressList);           
            for(Opportunity theOpp: theOppList){
                EmailTemplate emailTempEdit = createEmailTemplate(emailTemp,theOpp);
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                mail.setTemplateId(emailTempEdit.Id);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setUseSignature(false);
                mail.setToAddresses(new List<String>(emailAddressList));  
                if(!ccAddresses.isEmpty()) mail.setCcAddresses(ccAddresses);
                
                mail.setSubject(emailTemp.Subject);
                mail.setHtmlBody(emailTemp.HtmlValue);    
                mail.setWhatId(theOpp.Id); 
                mail.setEntityAttachments(new List<Id>{contentIdOppIdMap.get(theOpp.Id)});
                mail.setSaveAsActivity(true);
                mails.add(mail);
            } 
            System.debug('mails::: '+mails);
            if(!mails.isEmpty()) {
                Messaging.sendEmail(mails, false);
            }
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /**********************************************************
Method Name: createEmailTemplate
Description: This method is used to prepare email template with Opportunity field values.
***********************************************************/
    
    public static EmailTemplate createEmailTemplate(EmailTemplate emailTemp, Opportunity opp){
        emailTemp.Subject = 'Invoice' + ' for '+opp.Name;
        emailTemp.HtmlValue = emailTemp.HtmlValue.replace('oppName', opp.Name);
        return emailTemp;
    }
    
    /**********************************************************
Method Name: hasEmailQuota
Description: This method is used to check if sendEmail Method invocation not crossed governer limit 
***********************************************************/
    
    public static Boolean hasEmailQuota() {
        Integer emailInvocations = Limits.getEmailInvocations();
        Integer emailLimit = Limits.getLimitEmailInvocations();
        
        if (emailInvocations < emailLimit) {
            return true;
        } else {
            System.debug('Email limit reached. Unable to send email.');
            return false;
        }
    }
    
    /**********************************************************
Method Name: fetchBillingRecords
Description: This method is used to retrieve all Billing Records having atleast one billing rule record.
***********************************************************/
    @AuraEnabled
    public static List<Invoice_Billing__c> fetchBillingRecords(){
        try {
            List<Invoice_Billing__c> theBillRecList = [SELECT Name, (SELECT Id FROM Billing_Rules__r) FROM Invoice_Billing__c
                                                       WHERE Billing_Trigger_Count__c > 0 AND OwnerId = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
            return theBillRecList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}