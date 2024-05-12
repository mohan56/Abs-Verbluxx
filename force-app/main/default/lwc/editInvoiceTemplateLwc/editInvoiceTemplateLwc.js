import { LightningElement,api, wire, track } from 'lwc';
import fetchInvoiceTemplateToEdit from '@salesforce/apex/InvoiceTemplateLwcController.fetchInvoiceTemplateToEdit';
import getObjectFieldsLabel from '@salesforce/apex/InvoiceTemplateLwcController.getObjectFieldsLabel';
import saveData from'@salesforce/apex/InvoiceTemplateLwcController.saveData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { customlabel  } from 'c/customLabelUtilityLwc';
import { customINVTemplabel  } from 'c/customLabelUtilityLwc';
export default class EditInvoiceTemplateLwc extends NavigationMixin(LightningElement) {
    @track customLabel = customlabel;
    @track customINVTemplabel = customINVTemplabel;
    @api invTempId;
    showSpinner= false;
    areDetailsVisible = false;
    areOLIDetailsReady = false;
    data={};
    descriptionFieldOptions=[];
    unitPriceFieldOptions=[];
    amountFieldOptions=[];
    quantityFieldOptions=[];

    billingStreetOptions=[];
    billingCityOptions=[];
    billingStateOptions=[];
    billingCountryOptions=[];
    billingPincodeOptions=[];
    businessNameOptions=[];
    businessPhoneOptions=[];
    
  contactStreetOptions = [];
  contactCityOptions = [];
  contactStateOptions = [];
  contactCountryOptions = [];   //this.businessNameOptions.push(item);
  contactPincodeOptions = [];
   
    templateNameValue;
    businessNameValue;
    businessPhoneValue;
    businessStreetValue;
    businessCityValue;
    businessCountryValue;
    businessStateValue;
    businessPinCodeValue;
    imageUrl;
    
  contactStreetValue;
  contactCityValue;
  contactCountryValue;
  contactStateValue;
  contactPinCodeValue;
  imageUploaded = false;

    //Product
    quantityValue;
    prodDescriptionValue;
    unitPriceValue;
    totalAmountValue;

    connectedCallback() {

        getObjectFieldsLabel({sObjectName:'OpportunityLineItem'})
        .then(result=>{
          console.log('result => '+JSON.stringify(result));
          result.forEach(item=>{
            if(item.label.includes('Description')){
              this.descriptionFieldOptions.push(item)
            }else if(item.type == 'CURRENCY' && (item.label.includes('Unit') || item.value.includes('Unit'))){
             this.unitPriceFieldOptions.push(item);
            }else if(item.type == 'CURRENCY' && (item.label.includes('Amount') || item.label.includes('Total'))){
              this.amountFieldOptions.push(item);
            }else if(item.type == 'DOUBLE'){
             this.quantityFieldOptions.push(item);
            }
          })
          this.areOLIDetailsReady = true;
          console.log(' this.amountFieldOptions::: '+ JSON.stringify(this.amountFieldOptions));
          console.log(' this.unitPriceFieldOptions::: '+ JSON.stringify(this.unitPriceFieldOptions));

        }).catch(error=>{
            console.log('error:::'+JSON.stringify(error));
        });


        fetchInvoiceTemplateToEdit({invTempId:this.invTempId})
        .then(result=>{
         this.data = result; 
         console.log('result::: '+JSON.stringify(result));
        
         this.imageUrl = result.contVerUrl;
         if( result.contVerUrl) {
          this.imageUploaded = true;
         }
         this.templateNameValue = result.tempObj.Name;
         this.businessNameValue = result.tempObj.Buisness_Name_Field__c;
         this.businessPhoneValue = result.tempObj.Business_Phone_Field__c;
         this.businessStreetValue = result.tempObj.Street_Field__c;
         this.businessCityValue = result.tempObj.City_Field__c;
         this.businessCountryValue = result.tempObj.Country_Field__c;
         this.businessStateValue = result.tempObj.State_Field__c;
         this.businessPinCodeValue = result.tempObj.ZipCode_Field__c;

         this.contactStreetValue = result.tempObj.Contact_Street_Field__c;
         this.contactCityValue = result.tempObj.Contact_City_Field__c;
         this.contactCountryValue = result.tempObj.Contact_Country_Field__c;
         this.contactStateValue = result.tempObj.Contact_State_Field__c;
         this.contactPinCodeValue = result.tempObj.Contact_ZipCode_Field__c;

         this.quantityValue = result.tempObj.Product_Quantity_Field__c;
         this.prodDescriptionValue= result.tempObj.Product_Description_Field__c;
         this.unitPriceValue = result.tempObj.Product_Unit_Price_Field__c;
         this.totalAmountValue = result.tempObj.Product_Total_Amount_Field__c;
        })
        .catch(error =>{
            console.log('error::: '+JSON.stringify(error));
        })
    }

    @wire(getObjectFieldsLabel,{sObjectName:'Account'})
   wiredAccountSchema({ error, data }) {
     if (data) {
      console.log('Accountdata::: '+JSON.stringify(data));
      data.forEach(item=>{
        if(item.type == 'TEXTAREA' && item.label.includes('Street')){
          this.billingStreetOptions.push(item)
        }else if(item.type == 'STRING' && item.label.includes('City')){
          this.billingCityOptions.push(item);
        }else if(item.type == 'STRING' && item.label.includes('State')){
          this.billingStateOptions.push(item);
        }else if(item.type == 'STRING' && item.label.includes('Country')){
          this.billingCountryOptions.push(item)
        }else if(item.type == 'STRING' && item.label.includes('Zip')){
         this.billingPincodeOptions.push(item);
        }else if(item.type == 'STRING' && item.label.includes('Name')){
          this.businessNameOptions.push(item);
        }else if(item.type == 'PHONE'){
         this.businessPhoneOptions.push(item);
        }
        this.areDetailsVisible = true;
      })
     }
     console.log('billingPincodeOptions::: '+JSON.stringify(this.billingPincodeOptions));
     console.log('billingCountryOptions::: '+JSON.stringify(this.billingCountryOptions));
     console.log('billingStateOptions::: '+JSON.stringify(this.billingStateOptions));
   }

   @wire(getObjectFieldsLabel,{sObjectName:'Contact'})
  wiredContactSchema({ error, data }) {
    if (data) {
      console.log('Contactdata::: '+JSON.stringify(data));
      data.forEach(item=>{
        if(item.type == 'TEXTAREA' && item.label.includes('Street')){
          this.contactStreetOptions.push(item)
        }else if(item.type == 'STRING' && item.label.includes('City')){
          this.contactCityOptions.push(item);
        }else if(item.type == 'STRING' && item.label.includes('State')){
          this.contactStateOptions.push(item);
        }else if(item.type == 'STRING' && item.label.includes('Country')){
          this.contactCountryOptions.push(item)
        }else if(item.type == 'STRING' && item.label.includes('Zip')){
         this.contactPincodeOptions.push(item);
        }
      })
    }else if(error){
        console.log('error on Contact::: '+JSON.stringify(error));
    }
  }

   handleTemplateName(event){
    this.templateNameValue = event.target.value;
    }
    
    openfileUpload(event){
      const file = event.target.files[0];
      var image = this.template.querySelector('.outputLogo');
      image.src = URL.createObjectURL(file);
      this.imageUploaded = true;
      this.uploadLogoName = file.name;
    
      let reader = new FileReader();
      reader.onload = () => {
          let fileContent = reader.result.split(',')[1];
    
          this.fileInformation = {
              'fileName': file.name,
              'fileContent': fileContent
          }
    
      }
      reader.readAsDataURL(file);
    }
   
    removeLogoHandle(){
      this.template.querySelector('.outputLogo').src = null;
      this.fileInformation = {};
      this.imageUploaded = false;
      this.imageUrl='';
    }
     
    businessNameHandleChange(event){
    this.businessNameValue = event.target.value;
    }
    
    businessPhoneHandleChange(event){
    this.businessPhoneValue = event.target.value;
    }
    
    businessStreetHandleChange(event){
    this.businessStreetValue = event.target.value;
    }
    
    businessCityHandleChange(event){
    this.businessCityValue = event.target.value;
    }
    
    businessCountryHandleChange(event){
    this.businessCountryValue = event.target.value;
    }
    
    businessStateHandleChange(event){
    this.businessStateValue = event.target.value;
    }
    
    businessZipHandleChange(event){
      this.businessPinCodeValue = event.target.value;
      console.log('this.businessPinCodeValue::: '+ event.target.value);
    }   

    // Contact Billing Info Start
   contactStreetHandleChange(event){
  this.contactStreetValue = event.target.value;
  }
  
  contactCityHandleChange(event){
  this.contactCityValue = event.target.value;
  }
  
  contactCountryHandleChange(event){
  this.contactCountryValue = event.target.value;
  }
  
  contactStateHandleChange(event){
  this.contactStateValue = event.target.value;
  }
  
  contactZipHandleChange(event){
    this.contactPinCodeValue = event.target.value;
  }

    // Product Info Start
   quantityHandleChange(event){
    this.quantityValue = event.target.value;
    }
    
    descriptionHandleChange(event){
    this.prodDescriptionValue = event.target.value;
    }
    
    unitPriceHandleChange(event){
    this.unitPriceValue = event.target.value;
    }
    
    amountFieldHandleChange(event){
      this.totalAmountValue = event.target.value;
    }
  // Product Info End
  
    handleSaveRecord(){
    this.showSpinner = true;
    console.log('dataToSave:::');
    let base64Content = '';
    let fileName = ''; 
    if(this.fileInformation){
        fileName = this.fileInformation.fileName;
        let fileContent = this.fileInformation.fileContent;
        base64Content = encodeURIComponent(fileContent);
    }

    console.log( 'src:: '+!this.template.querySelector('.outputLogo').src);
    console.log('this.imageUrl::: '+!this.imageUrl);
            
      var dataToSave = {
        removeLogo: (!this.template.querySelector('.outputLogo').src && !this.imageUrl) ? true : false,
        invId: this.invTempId,
        logoname:fileName,
        base64Content:base64Content,
        tempName:this.templateNameValue,
        bizname:this.businessNameValue,
        bizphone:this.businessPhoneValue,
        bizstreet:this.businessStreetValue,
        bizcity:this.businessCityValue,
        bizcountry:this.businessCountryValue,
        bizstate:this.businessStateValue,
        bizzipcode:this.businessPinCodeValue,
        prodquantity:this.quantityValue,
        proddecsp:this.prodDescriptionValue,
        unitprice:this.unitPriceValue,
        totalamount:this.totalAmountValue,
        constreet:this.contactStreetValue,
        concity:this.contactCityValue,
        concountry:this.contactCountryValue,
        constate:this.contactStateValue,
        conzipcode:this.contactPinCodeValue
      }
    
      console.log('dataToSave:::' + JSON.stringify(dataToSave));
      saveData({thetemplateDetails:dataToSave})
      .then(result=>{
       console.log('Success:::'+JSON.stringify(result));
       this.showSpinner = false;
   
    window.parent.location =window.location.origin +'/'+result;

    const evt = new ShowToastEvent({
      title: 'Success!',
      message: 'Record Saved Successfully.',
      variant: 'success',
      mode: 'dismissable'
  });
  this.dispatchEvent(evt);

    //    this[NavigationMixin.Navigate]({
    //     type: 'standard__recordPage',
    //     attributes: {
    //         recordId: result,
    //         objectApiName: 'Invoice_Template__c', 
    //         actionName: 'view'
    //     }
    // });
      })
      .catch(error=>{
        this.showSpinner = false;
        console.log('error:::'+JSON.stringify(error));
      })
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
      this.showSpinner = true;
      this.handleSaveRecord();
    }
    }

    handleCancel(){
        console.log('handle cancel');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.invTempId,
                objectApiName: 'Invoice_Template__c', 
                actionName: 'view'
            }
        });
    }

}