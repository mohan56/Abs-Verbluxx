import { LightningElement, api, wire, track} from 'lwc';
import createBillingRecord from '@salesforce/apex/BillingRecordLwcController.createBillingRecord';
import fetchContactEmailList from '@salesforce/apex/BillingRecordLwcController.fetchContactEmailList';
import fetchAccountConEmailList from '@salesforce/apex/BillingRecordLwcController.fetchAccountConEmailList';
import fetchOppConEmailList from '@salesforce/apex/BillingRecordLwcController.fetchOppConEmailList';
import getUser from '@salesforce/apex/BillingRecordLwcController.getUser';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { customlabel  } from 'c/customLabelUtilityLwc';
import { customINVBILLlabel  } from 'c/customLabelUtilityLwc';

export default class invoiceBillingLwc extends NavigationMixin(LightningElement) {
    @track customLabel = customlabel;
    @track customINVBILLlabel = customINVBILLlabel;
    @api isShowModal;
    billingOptionsValue;
    invoicingOptionsValue;
    invoiceOptionsValue;
    ownerName;
    templateReady = false;
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
    _selectedAccountEmails = [];
    _selectedContactEmails = [];
    _selectedOppEmails = [];
    _selectedAllEmails = [];
    selectedAccountId;
    selectedContactId;
    selectedOppId;
    billingName = '';
    billingDescription = '';
    invoiceCounter = '';
    invoiceTypeValue = '';
    invoiceDate = new Date().toJSON().slice(0, 10);

    connectedCallback() {
        getUser()
        .then(result=>{
           
            this.ownerName = result.user.Name;
            this.invoiceCounterReceived = true;
            this.maxInvoiceNumber = result.maxInvoiceNumber;
            this.invoiceCounter = result.maxInvoiceNumber.toString();
           
        }).catch(error=>{
        });
    }

     generatePicklist(data) {
        return data.map(item => ({ "label": item.Name, "value": item.Name}))
    }

    generateEmailOptions(data) {
        return data.map(item => ({"label": item.Email, "value": item.Email}))
    }

    billinghandleChange(e) {
        this.billingOptionsValue = e.detail.value;
    }
   
    get selected() {
        return this._selectedContactEmails.length ? this._selectedContactEmails : 'none';
    }

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
    if(this.selectedTemplateValue != null && this.selectedTemplateValue != '' && this.selectedTemplateValue != undefined){
        this.showSpinner = true;
        var billingRecordData = { 
            billingName: this.billingName,
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
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: result,
                    objectApiName: 'Billing_Record__c', 
                    actionName: 'view'
                }
            });
             
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
                objectApiName: 'Billing_Record__c',
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
   
     lookupAccountRecord(event){
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

    lookupInvoiceTemplateRecord(event){
        if(event.detail.selectedRecord != null){
            this.selectedTemplateValue = event.detail.selectedRecord.Id;
         }else {
            this.selectedTemplateValue = null;
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
         this._selectedAccountEmails = [...event.detail.value];
        // this._selectedAllEmails = this._selectedAllEmails.concat(this._selectedAccountEmails);
     }

     handleContactEmailChange(event){
        this._selectedContactEmails = [...event.detail.value];
      //   this._selectedAllEmails = this._selectedAllEmails.concat(this._selectedContactEmails);
     }

     handleOppEmailChange(event){
        this._selectedOppEmails = [...event.detail.value];
       // this._selectedAllEmails = this._selectedAllEmails.concat(this._selectedOppEmails);
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
      this.handleSaveRecord();
    }
}

}