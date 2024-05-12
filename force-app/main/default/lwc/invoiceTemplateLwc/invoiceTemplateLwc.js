import { LightningElement, wire, track } from 'lwc';
import getObjectFieldsLabel from '@salesforce/apex/InvoiceTemplateLwcController.getObjectFieldsLabel';
import saveData from '@salesforce/apex/InvoiceTemplateLwcController.saveData';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { customlabel } from 'c/customLabelUtilityLwc';
import { customINVTemplabel } from 'c/customLabelUtilityLwc';
export default class InvoiceTemplateLwc extends NavigationMixin(LightningElement) {
  @track customLabel = customlabel;
  @track customINVTemplabel = customINVTemplabel;
  showSpinner = false;
  businessNameOptions = [];
  businessPhoneOptions = [];
  billingStreetOptions = [];
  billingCityOptions = [];
  billingStateOptions = [];
  billingCountryOptions = [];   //this.businessNameOptions.push(item);
  billingPincodeOptions = [];
  businessNameValue;
  businessPhoneValue;
  businessStreetValue;
  businessCityValue;
  businessCountryValue;
  businessStateValue;
  businessPinCodeValue;
  templateNameValue;
  uploadLogoName;
  fileInformation = {};
  imageUploaded = false;

  contactStreetValue;
  contactCityValue;
  contactCountryValue;
  contactStateValue;
  contactPinCodeValue;

  //Product Fields
  descriptionFieldOptions = [];
  unitPriceFieldOptions = [];
  amountFieldOptions = [];
  quantityFieldOptions = [];
  quantityValue;
  prodDescriptionValue;
  unitPriceValue;
  totalAmountValue;
  error;
  areDetailsVisible = false;

  contactStreetOptions = [];
  contactCityOptions = [];
  contactStateOptions = [];
  contactCountryOptions = [];   //this.businessNameOptions.push(item);
  contactPincodeOptions = [];


  @wire(getObjectFieldsLabel, { sObjectName: 'OpportunityLineItem' })
  wiredOliSchema({ error, data }) {
    if (data) {
      console.log('data::: ' + JSON.stringify(data));
      data.forEach(item => {
        if (item.label.includes('Description')) {
          this.descriptionFieldOptions.push(item)
        } else if (item.type == 'CURRENCY' && (item.label.includes('Unit') || item.value.includes('Unit'))) {
          this.unitPriceFieldOptions.push(item);
        } else if (item.type == 'CURRENCY' && (item.label.includes('Total') || item.label.includes('Amount'))) {
          this.amountFieldOptions.push(item);
        } else if (item.type == 'DOUBLE') {
          this.quantityFieldOptions.push(item);
        }
      })
    }
    console.log(' this.amountFieldOptions::: ' + JSON.stringify(this.amountFieldOptions));
  }

  @wire(getObjectFieldsLabel, { sObjectName: 'Account' })
  wiredAccountSchema({ error, data }) {
    if (data) {
      data.forEach(item => {
        if (item.type == 'TEXTAREA' && item.label.includes('Street')) {
          this.billingStreetOptions.push(item)
        } else if (item.type == 'STRING' && item.label.includes('City')) {
          this.billingCityOptions.push(item);
        } else if (item.type == 'STRING' && item.label.includes('State')) {
          this.billingStateOptions.push(item);
        } else if (item.type == 'STRING' && item.label.includes('Country')) {
          this.billingCountryOptions.push(item)
        } else if (item.type == 'STRING' && item.label.includes('Zip')) {
          this.billingPincodeOptions.push(item);
        } else if (item.type == 'STRING' && item.label.includes('Name')) {
          this.businessNameOptions.push(item);
        } else if (item.type == 'PHONE') {
          this.businessPhoneOptions.push(item);
        }
      })
      this.areDetailsVisible = true;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.businessNameOptions = undefined;
    }
  }

  @wire(getObjectFieldsLabel, { sObjectName: 'Contact' })
  wiredContactSchema({ error, data }) {
    if (data) {
      data.forEach(item => {
        if (item.type == 'TEXTAREA' && item.label.includes('Street')) {
          this.contactStreetOptions.push(item)
        } else if (item.type == 'STRING' && item.label.includes('City')) {
          this.contactCityOptions.push(item);
        } else if (item.type == 'STRING' && item.label.includes('State')) {
          this.contactStateOptions.push(item);
        } else if (item.type == 'STRING' && item.label.includes('Country')) {
          this.contactCountryOptions.push(item)
        } else if (item.type == 'STRING' && item.label.includes('Zip')) {
          this.contactPincodeOptions.push(item);
        }
      })
    } else if (error) {
      console.log('error on Contact::: ' + JSON.stringify(error));
    }
  }

  handleTemplateName(event) {
    this.templateNameValue = event.target.value;
  }

  openfileUpload(event) {
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
    console.log('file::: ' + JSON.stringify(file));
  }

  removeLogoHandle() {
    var image = this.template.querySelector('.outputLogo');
    image.src = '';
    this.imageUploaded = false;
    this.fileInformation = {};
  }

  businessNameHandleChange(event) {
    this.businessNameValue = event.target.value;
  }

  businessPhoneHandleChange(event) {
    this.businessPhoneValue = event.target.value;
  }

  businessStreetHandleChange(event) {
    this.businessStreetValue = event.target.value;
  }

  businessCityHandleChange(event) {
    this.businessCityValue = event.target.value;
  }

  businessCountryHandleChange(event) {
    this.businessCountryValue = event.target.value;
  }

  businessStateHandleChange(event) {
    this.businessStateValue = event.target.value;
  }

  businessZipHandleChange(event) {
    this.businessPinCodeValue = event.target.value;
  }
  // Contact Billing Info Start
  contactStreetHandleChange(event) {
    this.contactStreetValue = event.target.value;
  }

  contactCityHandleChange(event) {
    this.contactCityValue = event.target.value;
  }

  contactCountryHandleChange(event) {
    this.contactCountryValue = event.target.value;
  }

  contactStateHandleChange(event) {
    this.contactStateValue = event.target.value;
  }

  contactZipHandleChange(event) {
    this.contactPinCodeValue = event.target.value;
  }


  // Product Info Start
  quantityHandleChange(event) {
    this.quantityValue = event.target.value;
  }

  descriptionHandleChange(event) {
    this.prodDescriptionValue = event.target.value;
  }

  unitPriceHandleChange(event) {
    this.unitPriceValue = event.target.value;
  }

  amountFieldHandleChange(event) {
    this.totalAmountValue = event.target.value;
  }

  // Product Info End

  handleSaveRecord() {
    this.showSpinner = true;
    let base64Content = '';
    let fileName = '';
    if (this.fileInformation) {
      fileName = this.fileInformation.fileName;
      fileName = this.fileInformation.fileName;
      let fileContent = this.fileInformation.fileContent;
      base64Content = encodeURIComponent(fileContent);
    }

    var dataToSave = {
      removeLogo: false,
      logoname: fileName,
      base64Content: base64Content,
      tempName: this.templateNameValue,
      bizname: this.businessNameValue,
      bizphone: this.businessPhoneValue,
      bizstreet: this.businessStreetValue,
      bizcity: this.businessCityValue,
      bizcountry: this.businessCountryValue,
      bizstate: this.businessStateValue,
      bizzipcode: this.businessPinCodeValue,
      prodquantity: this.quantityValue,
      proddecsp: this.prodDescriptionValue,
      unitprice: this.unitPriceValue,
      totalamount: this.totalAmountValue,
      constreet: this.contactStreetValue,
      concity: this.contactCityValue,
      concountry: this.contactCountryValue,
      constate: this.contactStateValue,
      conzipcode: this.contactPinCodeValue,
    }

    saveData({ thetemplateDetails: dataToSave })
      .then(result => {
        this.showSpinner = false;

        const evt = new ShowToastEvent({
          title: 'Success!',
          message: 'Record Saved Successfully.',
          variant: 'success',
          mode: 'dismissable'
        });
        this.dispatchEvent(evt);

        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
            recordId: result,
            objectApiName: 'Invoice_Template__c',
            actionName: 'view'
          }
        });

      })
      .catch(error => {
        console.log('error:::' + JSON.stringify(error));
      })

  }

  handleCheckValidation() {
    let isValid = true;
    let inputFields = this.template.querySelectorAll('.mandatoryfield');
    inputFields.forEach(inputField => {
      if (!inputField.checkValidity()) {
        inputField.reportValidity();
        isValid = false;
      }
    });
    return isValid;
  }

  handleValidation(event) {
    if (this.handleCheckValidation()) {
      this.showSpinner = true;
      this.handleSaveRecord();
    }
  }

  handleCancel(event) {
    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes: {
        objectApiName: 'Invoice_Template__c',
        actionName: 'list'
      },
      state: {
        filterName: 'Recent'
      },
    });
  }

}