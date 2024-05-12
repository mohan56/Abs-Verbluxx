import { LightningElement, api, wire, track} from 'lwc';
import createBillingRecord from '@salesforce/apex/BillingRecordLwcController.createBillingRecord';
import fetchContactEmailList from '@salesforce/apex/BillingRecordLwcController.fetchContactEmailList';
import fetchAccountConEmailList from '@salesforce/apex/BillingRecordLwcController.fetchAccountConEmailList';
import fetchOppConEmailList from '@salesforce/apex/BillingRecordLwcController.fetchOppConEmailList';
import fetchBillRecordToEdit from '@salesforce/apex/BillingRecordLwcController.fetchBillRecordToEdit';
import getUser from '@salesforce/apex/BillingRecordLwcController.getUser';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { customlabel  } from 'c/customLabelUtilityLwc';
import { customINVBILLlabel  } from 'c/customLabelUtilityLwc';

export default class editbillingScenarioLWC extends NavigationMixin(LightningElement) {
    @track customLabel = customlabel;
    @track customINVBILLlabel = customINVBILLlabel;
    @api isShowModal;
    @api billRecordId;
    defaultAcccountId;
    defaultContactId; 
    defaultOppId;
    @track defaultInvTempId;
    billRecord = {};
    isBillingReadyToEdit = false;
    billingOptionsValue;
    invoicingOptionsValue;
    invoiceOptionsValue;
    ownerName;
    invTemplateOptions =[];
    contactEmailOptions =[];
    oppConEmailOptions =[];
    accConEmailOptions =[];
    showAccountLookup = false;
    showContactLookup = false;
    showOppLookup = false;
    isAccountRecordSelected = false;
    isContactRecordSelected = false;
    isOppRecordSelected = false;
    maxInvoiceNumber = 0;
    invoiceCounterReceived = false;
    showSpinner = false;
    invTempError;

    selectedTemplateValue = '';
    _selectedContactEmails = [];
    _selectedAllEmails=[];
    _selectedAccountEmails=[];
    _selectedOppEmails=[];
    billingName = '';
    billingDescription = '';
    invoiceCounter = '';
    invoiceTypeValue = '';
    invoiceDate = new Date().toJSON().slice(0, 10);

    connectedCallback() {
        console.log('billRecord::: '+JSON.stringify(this.billRecordId));
        fetchBillRecordToEdit({billRecordId:this.billRecordId})
        .then(billRecord=>{
       // preselcted lookup values START
         this.defaultAcccountId = billRecord.Selected_Account_Id__c;
         this.defaultContactId = billRecord.Selected_Contact_Id__c;
         this.defaultOppId = billRecord.Selected_Opportunity_Id__c;
         this.defaultInvTempId = billRecord.Invoice_Template__c;
         this.selectedTemplateValue =  billRecord.Invoice_Template__c;
         this.billRecord = billRecord;
         this.billingName = billRecord.Name;
         this.billingDescription = billRecord.Description__c;
         this.invoiceTypeValue = billRecord.Invoice_Type__c;
        // preselcted lookup values END

        // Account
           if(this.billRecord.Selected_Account_Emails__c && billRecord.Selected_Account_Id__c){
            this.template.querySelector(`[data-id="accountCheckbox"]`).checked = true;
          
            console.log('AccId:::'+JSON.stringify(billRecord.Selected_Account_Id__c));

            fetchAccountConEmailList({accId:billRecord.Selected_Account_Id__c})
		    .then(result => {
                 this.accConEmailOptions =this.generateEmailOptions(result);

                 let emaillist = [];
                 emaillist = this.billRecord.Selected_Account_Emails__c.split('\n');
                 this._selectedAccountEmails.push(...emaillist);

                 this.showAccountLookup = true;
                 this.isAccountRecordSelected = true;
		    })
           } 

         // Contact
           if(this.billRecord.Selected_Contact_Emails__c && billRecord.Selected_Contact_Id__c){
            this.template.querySelector(`[data-id="contactCheckbox"]`).checked = true;
            fetchContactEmailList({contId:billRecord.Selected_Contact_Id__c})
            .then(result => {
                this.contactEmailOptions =this.generateEmailOptions(result);
            let emaillist = [];
            emaillist = this.billRecord.Selected_Contact_Emails__c.split('\n');
            this._selectedContactEmails.push(...emaillist);

            this.showContactLookup = true;
            this.isContactRecordSelected = true;
            })
           }

        // Opportunity
           if(this.billRecord.Selected_Opportunity_Emails__c && billRecord.Selected_Opportunity_Id__c){
            this.template.querySelector(`[data-id="oppCheckbox"]`).checked = true;
            fetchOppConEmailList({oppId:billRecord.Selected_Opportunity_Id__c})
		    .then(result => {
            this.oppConEmailOptions =this.generateEmailOptions(result);
 
            let emaillist = [];
            emaillist = this.billRecord.Selected_Opportunity_Emails__c.split('\n');
            this._selectedOppEmails.push(...emaillist);
           
            this.showOppLookup = true;
            this.isOppRecordSelected = true;
		    })       
           }
        })
        .catch(error=>{
            const evt = new ShowToastEvent({
                title: 'Error !',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        console.log('error111:::'+JSON.stringify(error));
        });

        getUser()
        .then(result=>{
           
            this.ownerName = result.user.Name;
            this.invoiceCounterReceived = true;
            this.maxInvoiceNumber = result.maxInvoiceNumber;
            this.invoiceCounter = result.maxInvoiceNumber.toString();
           
        }).catch(error=>{
        });
        this.isBillingReadyToEdit = true;
    }

     generatePicklist(data) {
        return data.map(item => ({ "label": item.Name, "value": item.Name}))
    }

    generateEmailOptions(data) {
        return data.map(item => ({"label": item.Email, "value": item.Email}))
    }

    generateEmailOptions2(data) {
        return data.map(item => ({"label": item, "value": item}))
    }

    billinghandleChange(e) {
        this.billingOptionsValue = e.detail.value;
    }
   
 /*  get selected() {
        return this.selectedAccountEmails.length ? this.selectedAccountEmails : 'none';
    }*/

    get invoicingOptions() {
        return [
            { label: 'Opportunities Invoicing', value: 'Opportunities Invoicing' },
            { label: 'Account Invoicing', value: 'Account Invoicing' },
        ];
    }

    invoicingHandleChange(event) {
        this.invoiceTypeValue = event.detail.value;

    }


    invoicehandleChange(e) {
        this.invoiceOptionsValue = e.detail.value;
    }
   
    handleSaveRecord() {
    this._selectedAllEmails =  this._selectedAllEmails.concat(this._selectedAccountEmails, this._selectedContactEmails,this._selectedOppEmails);
    if(this.selectedTemplateValue != null){

        this.showSpinner = true;
      console.log('Saving Record');
        var billingRecordData = { 
            billRecordId:this.billRecordId,
            billingName:this.billingName,
            billingDescription: this.billingDescription,
            invoiceCounter:this.invoiceCounter,
            invoiceTypeValue:this.invoiceTypeValue,
            invoiceDate:this.invoiceDate,
            selectedTemplateValue:this.selectedTemplateValue,
            selectedAllEmails:this._selectedAllEmails,
            maxInvoiceNumber:this.maxInvoiceNumber,
            selectedAccId:this.selectedAccountId,
            selectedConId:this.selectedContactId,
            selectedOppId:this.selectedOppId,
            selectedContactEmails:this._selectedContactEmails,
            selectedAccEmails:this._selectedAccountEmails,
            selectedOppEmails:this._selectedOppEmails
         }
         createBillingRecord({billingDetails: billingRecordData })
         .then(result=>{
            this.invTempError = null;
            this.showSpinner = false;
            console.log('Saved Success');
             const evt = new ShowToastEvent({
                title: 'Success!',
                message: 'Record Saved Successfully.',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.billingName ='';
            this.billingDescription ='';
            this.invoiceTypeValue ='';
            this.selectedTemplateValue ='';
            this._selectedContactEmails =[];
            this._selectedAccountEmails =[];
            this._selectedOppEmails =[];
            this._selectedAllEmails =[];

        window.parent.location =window.location.origin +'/'+result;
        //  this[NavigationMixin.Navigate]({
        //         type: 'standard__recordPage',
        //         attributes: {
        //             recordId: result,
        //             objectApiName: 'Billing_Record__c', 
        //             actionName: 'view'
        //         }
        //     });

         }).catch(error=>{
           this.invTempError = null;
           this.showSpinner = false;
           const evt = new ShowToastEvent({
                title: 'Error!',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);

 
         });
        }else{
            this.invTempError = 'Invoice Template is required.'
        }
     }

     handleCancel(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Invoice_Billing__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });
     }
     handleINVDateChage(event){
        this.invoiceDate = event.target.value;
     
     }
     handleAccountCheckToEmail(event){
        if(event.target.checked){
            this.showAccountLookup = true;
        }else{
            this.showAccountLookup = false;
        }
       
        
     }
     handleContactCheckToEmail(event){ 
        if(event.target.checked){
            this.showContactLookup = true;
        }else{
            this.showContactLookup = false;
        }
       
        
     }
     handleOppCheckToEmail(event){
        if(event.target.checked){
            this.showOppLookup = true;
        }else{
            this.showOppLookup = false;
        } 
     }

     lookupInvoiceTemplateRecord(event){
        if(event.detail.selectedRecord != null){
            this.selectedTemplateValue = event.detail.selectedRecord.Id;
                   }else{
            this.selectedTemplateValue = null;
        }
     }

     lookupAccountRecord(event){
        this._selectedAccountEmails = [];
        if(event.detail.selectedRecord != null || event.detail.selectedRecord != undefined){
        this.selectedAccountId = event.detail.selectedRecord.Id;
        fetchAccountConEmailList({accId:event.detail.selectedRecord.Id})
		.then(result => {
            this.accConEmailOptions =this.generateEmailOptions(result);
            this.isAccountRecordSelected = true;
		})
		.catch(error => {
			console.log('error:::'+JSON.stringify(error));
		})

        }else{
            this.isAccountRecordSelected = false;
        }  
    }

    lookupContactRecord(event){
        this._selectedContactEmails = [];
        if(event.detail.selectedRecord != null || event.detail.selectedRecord != undefined){
            this.selectedContactId = event.detail.selectedRecord.Id;
        fetchContactEmailList({contId:event.detail.selectedRecord.Id})
		.then(result => {
            this.contactEmailOptions =this.generateEmailOptions(result);
            this.isContactRecordSelected = true;
		})
		.catch(error => {
			console.log('error:::'+JSON.stringify(error));
		})

         }else{
            this.contactEmailOptions =[];
            this.isContactRecordSelected = false;
        }
    }

    lookupOppRecord(event){
        this._selectedOppEmails = [];
        if(event.detail.selectedRecord != null || event.detail.selectedRecord != undefined){
        this.selectedOppId = event.detail.selectedRecord.Id;
           
        fetchOppConEmailList({oppId:event.detail.selectedRecord.Id})
		.then(result => {
            this.oppConEmailOptions =this.generateEmailOptions(result);
            this.isOppRecordSelected = true;
		})
		.catch(error => {
			console.log('error:::'+JSON.stringify(error));
		})

         }else{
            this.isOppRecordSelected = false;
        }
    }


    handleBillingName(event){
    this.billingName = event.target.value;
    }
    
    handleDescription(event){
    this.billingDescription = event.target.value;
    }

    handleBillingName(event){
        this.billingName = event.target.value;
        }

    handleInvoiceNunmber(event){
        this.invoiceCounter = event.target.value;
        if(this.maxInvoiceNumber <  parseInt(this.invoiceCounter))
        this.maxInvoiceNumber = parseInt(this.invoiceCounter);
        }

     handleAccEmailChange(event){
         var selectedAccEmails = [];
         selectedAccEmails = [...event.detail.value];
         this._selectedAccountEmails = [...event.detail.value];
       //  this._selectedAccountEmails = this._selectedAccountEmails.concat(selectedAccEmails);
      //   this._selectedAccountEmails = [...new Set( this._selectedAccountEmails)];
     }

     handleContactEmailChange(event){
        var selectedConEmails = [];
        selectedConEmails = [...event.detail.value];
        this._selectedContactEmails =  [...event.detail.value];
        // this._selectedContactEmails = this._selectedContactEmails.concat(selectedConEmails);
        // this._selectedContactEmails = [...new Set( this._selectedContactEmails)];
     }

     handleOppEmailChange(event){
        var selectedOppEmails = [];
        selectedOppEmails =  [...event.detail.value];
        this._selectedOppEmails = [...event.detail.value];
        // this._selectedOppEmails = this._selectedOppEmails.concat(selectedOppEmails);
        // this._selectedOppEmails = [...new Set( this._selectedOppEmails)];
     }

     handleCheckValidation() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.mandatoryfield');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
     
    handleValidation(event){
    if(this.handleCheckValidation()){
      //this.showSpinner = true;
      this.handleSaveRecord();
    }
}

}