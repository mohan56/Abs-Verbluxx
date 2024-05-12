import { LightningElement, track, api, wire } from 'lwc';
import getObjectFieldsLabel from '@salesforce/apex/BillingRuleLwcController.getObjectFieldsLabel';
import createBillingRule from '@salesforce/apex/BillingRuleLwcController.createBillingRule';
import getBillingRuleRecords from '@salesforce/apex/BillingRuleLwcController.getBillingRuleRecords';
import getPicklistValues from '@salesforce/apex/BillingRuleLwcController.getPicklistValues';
import deleteBillingRule from '@salesforce/apex/BillingRuleLwcController.deleteBillingRule';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { customlabel  } from 'c/customLabelUtilityLwc';

export default class BillingRuleLwc extends LightningElement {
 
    @api recordId;
    @track customLabel = customlabel;
    fixedWidth = "width:auto";
    ruleCount = 0;
    isOppProductRule = false;
    isOppRule = false;
    OppProductRuleFieldList = [];
    OppRuleFieldList = [];
    labels = [];
    @track billRuledata = [];
    isModalOpen = false;
    isEditRuleShowModal = false;
    rowToEdit;
    recordToSaveAfterEdit = {};
    operatorEditOptions = [];
    openOpportunityRule = false;
    billingRuleType;
    _selected = [];
    showSpinner = false;
    isLookup = false;
    is2ndLookup = false;
    lookupOptions = [];
    isNotLookup = false;
    isNot2ndLookup = false;
    isNot3rdLookup = false;
    selectedField;
    selectedObject = '';
    showSelectedFormula = false;
    inputFieldValue;
    selectedOperatorValue;
    duallistoptions = [];
    operatorOptions = [];
    addSelectedField = '';
    formulaFieldToAdd = [];
    @track index = 0;
    otherfieldDataType;
    inputDataListToSave = [];
    operatorValue;
    isVariable = false;
    isDuplicateField = false;
    lookup2ndOptions = [];
    inputOppDataListToSave = [];
    inputOppProdDataListToSave = [];
    billRuleSaveError;
    labelValueList = [];

    fieldDataType;
    fieldDataTypeOther = false;
    fieldDataTypeBoolean = false;
    fieldDateTypePicklist = false;
    fieldDataTypeDate = false;
    disablePickOptions = false;
    fieldDataTypeDateTime = false;
    fieldDataTypeURL = false;

    //pickValueOptions = [];
    editPickValueOptions = [];
    selectedPickValue;

    connectedCallback() {
        getBillingRuleRecords({ parentBillRuleId: this.recordId })
            .then(result => {
                this.billRuledata = result;
                this.ruleCount = result.length;
            }).catch(error => {
                console.log('error:::' + JSON.stringify(error));
            });
    }

    get selected() {
        return this._selected.length ? this._selected : 'none';
    }

    handleChange(e) {
        this._selected = e.detail.value;
    }

    get options() {
        return [
            { label: 'Opportunity Trigger', value: this.customLabel.Opportunity_Rule },
            { label: 'Opportunity Product Trigger', value: this.customLabel.Opportunity_Product_Rule}
        ];
    }

    handleNewButton(event) {
        this.isModalOpen = true;
    }
    closeModal(event) {
        this.selectedObject= null;
        this.selectedField= null;
        this.index = 0;
        this.formulaFieldToAdd = [];
        this.duallistoptions = [];
        this.OppRuleFieldList = [];
        this.OppProductRuleFieldList = [];
        this.isModalOpen = false;
        this.openOpportunityRule = false;
        this.showSelectedFormula = false;
        this.billingRuleType = '';
        this.inputDataListToSave = [];
        this.isLookup = false;
        this.is2ndLookup = false;
        this.isNotLookup = false;
        this.isNot2ndLookup = false;
        this.addSelectedField = null;

    }

    handleRuleChange(event) {

        this.billingRuleType = event.detail.value;
        this.showSpinner = true;
        if (this.billingRuleType == this.customLabel.Opportunity_Rule) {
            this.isNot3rdLookup = false;
            this.isLookup = false;
            this.is2ndLookup = false;
            this.isNotLookup = false;
            this.isNot2ndLookup = false;
            this.selectedObject = 'Opportunity';

            var inputDataObjectApi = {
                objectName: 'Opportunity',
                apiName: '',
                isLookup: false
            }

            getObjectFieldsLabel({ theInputData: inputDataObjectApi })
                .then(result => {
                    let dataDraft = JSON.parse(JSON.stringify(result));
                    dataDraft.forEach(item => {
                        if (item.type == 'REFERENCE') {
                            item.label = item.label + ' >';
                        }
                    });
                    this.duallistoptions = [...dataDraft];
                    this.openOpportunityRule = true;
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.log('error:::' + JSON.stringify(error));
                    this.duallistoptions = undefined;
                    this.showSpinner = false;
                })
        } else {
            this.isNot3rdLookup = false;
            this.isLookup = false;
            this.is2ndLookup = false;
            this.isNotLookup = false;
            this.isNot2ndLookup = false;
            this.selectedObject = 'OpportunityLineItem';
            this.showSpinner = true;

            var inputDataObjectApi = {
                objectName: 'OpportunityLineItem',
                apiName: '',
                isLookup: false
            }
            getObjectFieldsLabel({ theInputData: inputDataObjectApi })
                .then(result => {
                    let dataDraft = JSON.parse(JSON.stringify(result));
                    dataDraft.forEach(item => {
                        if (item.type == 'REFERENCE') {
                            item.label = item.label + ' >';
                        }
                    });
                    this.duallistoptions = [...dataDraft];

                    this.openOpportunityRule = true;
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.log('error:::' + JSON.stringify(error));
                    this.duallistoptions = undefined;
                    this.showSpinner = false;
                })
        }
    }
    
    handleOnMenuSelect(event) {

        const operatorValueMap = new Map([
            ['Equals', '= Equals'],
            ['Not Equals', '<> Not Equals'],
            ['Less Than', '< Less Than'],
            ['Less Than or Equal', '<= Less Than or Equal'],
            ['Greater Than', '> Greater Than'],
            ['Greater Than or Equal', '>= Greater Than or Equal']
        ]);

        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        var recordToEdit = {};
        if (event.detail.value == 'editRecord') {

            recordToEdit = this.billRuledata[key];
            this.recordToSaveAfterEdit = this.billRuledata[key];

            if (recordToEdit.Field_Data_Type__c == 'STRING' || recordToEdit.Field_Data_Type__c == 'PICKLIST' || recordToEdit.Field_Data_Type__c == 'ID' || recordToEdit.Field_Data_Type__c == 'URL') {

                this.operatorEditOptions = [
                    { label: '= Equals', value: 'Equals' },
                    { label: '<> Not Equals', value: 'Not Equals' },
                ]
            } else if (recordToEdit.Field_Data_Type__c == 'CURRENCY' || recordToEdit.Field_Data_Type__c == 'DOUBLE' || recordToEdit.Field_Data_Type__c == 'PERCENT' || recordToEdit.Field_Data_Type__c == 'DATE' || recordToEdit.Field_Data_Type__c == 'INTEGER' || recordToEdit.Field_Data_Type__c == 'DATETIME') {
                this.operatorEditOptions = [
                    { label: '= Equals', value: 'Equals' },
                    { label: '<> Not Equals', value: 'Not Equals' },
                    { label: '< Less Than', value: 'Less Than' },
                    { label: '<= Less Than or Equal', value: 'Less Than or Equal' },
                    { label: '> Greater Than', value: 'Greater Than' },
                    { label: '>= Greater Than or Equal', value: 'Greater Than or Equal' },
                ]
            }
            else if (recordToEdit.Field_Data_Type__c == 'BOOLEAN') {
                this.operatorEditOptions = [
                    { label: '= Equals', value: 'Equals' },
                ]
            }
          
            if (recordToEdit.Field_Data_Type__c == 'DATE') {
                recordToEdit = Object.assign({ isDateType: true }, recordToEdit);

            } else if (recordToEdit.Field_Data_Type__c != 'PICKLIST' && recordToEdit.Field_Data_Type__c != 'REFERENCE' && recordToEdit.Field_Data_Type__c != 'BOOLEAN' && recordToEdit.Field_Data_Type__c != 'DATE' && recordToEdit.Field_Data_Type__c != 'DATETIME') {
                recordToEdit = Object.assign({ isOtherType: true }, recordToEdit);

            } else if (recordToEdit.Field_Data_Type__c == 'DATETIME') {
                recordToEdit = Object.assign({ isDateTimeType: true }, recordToEdit);

            } else if (recordToEdit.Field_Data_Type__c == 'BOOLEAN') {
                recordToEdit = Object.assign({ isBooleanType: true }, recordToEdit);
               if(recordToEdit.Value__c == 'True'){
                setTimeout(() =>
               this.template.querySelector('[name="optionSelectEdit"]').selectedIndex = 0
             );
               }else{
                console.log('recordToEdit false::: '+JSON.stringify(recordToEdit));
                setTimeout(() =>
                this.template.querySelector('[name="optionSelectEdit"]').selectedIndex = 1
              );
               }
            } else if (recordToEdit.Field_Data_Type__c == 'PICKLIST') {
                recordToEdit = Object.assign({ isPickListType: true }, recordToEdit);
            }

            if (recordToEdit.Field_Data_Type__c == 'PICKLIST') {
                var objectName;

                /*  if (recordToEdit.Field_Label__c.includes('.')) {
                      objectName = recordToEdit.Field_Label__c.substring(0, recordToEdit.Field_Label__c.indexOf('.'));
                  } else {
                      objectName = (recordToEdit.RuleType__c == 'Opportunity') ? "Opportunity" : "OpportunityLineItem";
                  }*/

                let objArray = recordToEdit.Field_Label__c.split('.');
                let parentObjApiName;
                if (objArray.length > 2) {                   
                    parentObjApiName = objArray[0];
                    objectName = (objArray[1].endsWith('__c')) ? objArray[1] : objArray[1]+'Id';
                    parentObjApiName = parentObjApiName.includes('Id') ? parentObjApiName.substring(0, parentObjApiName.length - 2) : parentObjApiName;
                } 
                    else if (objArray.length == 2) {
                        parentObjApiName = (recordToEdit.Rule_Type__c == 'Opportunity') ? "Opportunity" : "OpportunityLineItem";
                        objectName = (objArray[0].endsWith('__c')) ? objArray[0] : objArray[0]+'Id';
                    } 
                else {
                    parentObjApiName = ' ';
                    objectName = (recordToEdit.Rule_Type__c == 'Opportunity') ? "Opportunity" : "OpportunityLineItem";
                }

                const fieldName = recordToEdit.Field_Label__c.split('.').pop();

                getPicklistValues({ parentObjApiName: parentObjApiName, ObjectApiName: objectName, FieldApiName: fieldName })
                    .then(result => {
                        this.editPickValueOptions = result;
                    }).catch(error => {
                        console.log('error:::' + JSON.stringify(error));
                    });
            }

            this.rowToEdit = recordToEdit;
            this.isEditRuleShowModal = true;

        } else {

            var arrNew1 = [...this.billRuledata];
            var recToDelete = arrNew1[key];
            if (arrNew1.length > 1) {
                arrNew1.splice(key, 1);
            } else if (arrNew1.length == 1) {
                arrNew1 = [];
            }

            this.billRuledata = [...arrNew1];
            this.ruleCount = this.billRuledata.length;

            deleteBillingRule({ billId: recToDelete.Id })
                .then(result => {
                    const evt = new ShowToastEvent({
                        title: 'Deleted!',
                        message: 'Billing rule deleted successfully',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                })
                .catch(error => {
                    const evt = new ShowToastEvent({
                        title: 'Error!',
                        message: error,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    console.log('billing Rule Deletion Error');
                })
        }

    }

    handleEditRuleOperatorChange(event) {
        var editObject = { ...this.recordToSaveAfterEdit };
        editObject.Operator__c = event.target.value;
        this.recordToSaveAfterEdit = { ...editObject }
    }

    handleEditInputChange(event) {
        var editObject = { ...this.recordToSaveAfterEdit };
        editObject.Value__c = event.target.value;
        this.recordToSaveAfterEdit = { ...editObject }
    }

    handleEditRuleInputVariable(event) {

        this.template.querySelector('[data-edit="editInput"]').disabled = event.target.checked;
        var editObject = { ...this.recordToSaveAfterEdit };
        editObject.Variable__c = event.target.checked;

        if (event.target.checked == true) {
            editObject.Value__c = '';
            this.template.querySelector('[data-edit="editInput"]').value = '';
        }
        this.recordToSaveAfterEdit = { ...editObject }

    }

    CloseEditModalBox(event) {
        this.isEditRuleShowModal = false;
    }

    handleEditCheckValidation() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.mandatoryEditfield');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    handleEditValidation(event) {
        if (this.handleEditCheckValidation()) {
            this.SaveEditModalBoxValue();
        }
    }

    SaveEditModalBoxValue() {

        var objToUpdateList = [];
        var objToUpdate = {
            billRuleId: this.recordToSaveAfterEdit.Id,
            rullType: this.recordToSaveAfterEdit.Rule_Type__c,
            fieldName: this.recordToSaveAfterEdit.Field_Label__c,
            value: this.recordToSaveAfterEdit.Value__c,
            operate: this.recordToSaveAfterEdit.Operator__c,
            parentBillRecord: this.recordId,
            isVariable: this.recordToSaveAfterEdit.Variable__c,
            fieldDataType: this.recordToSaveAfterEdit.Field_Data_Type__c
        }

        objToUpdateList.push(objToUpdate);

        createBillingRule({ billingRuleDetails: objToUpdateList })
            .then(result => {
                this.isEditRuleShowModal = false;
                const evt = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Billing rule have been updated successfully',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                window.location.reload();
            })
            .catch(error => {
                this.billRuleSaveError = true
                this.billRuleError = error.body.message;
                console.log('billRuleError::: ' + JSON.stringify(this.billRuleError));
            })
    }

    // Billing Rule Edit/Delete Table Function above
    handleTextSelect(event) {

       let selectedCSSClass = this.template.querySelector('.textButtonSelected1');
       if(selectedCSSClass){
        selectedCSSClass.classList.remove('textButtonSelected1');
        selectedCSSClass.classList.add('textButton');
       }
        this.template.querySelector('[data-id1="' +event.target.value+ '"]').className = 'textButtonSelected1';

        this.isNotLookup = false;
        this.is2ndLookup = false;
        this.isNot2ndLookup = false;
        this.isNot3rdLookup = false;
        if (this.selectedObject.includes(".")) {
            this.selectedObject = this.selectedObject.substring(0, this.selectedObject.indexOf('.'));
        }

        var apiName = '';
        var isReference = false;
        this.duallistoptions.forEach(item => {
            if (item.value == event.target.value && item.type == 'REFERENCE' && item.value.substring(0, item.value.length - 2).endsWith('Id')) {
                isReference = true;
                // apiName = item.value.substring(0, item.value.length - 4)
                apiName = item.value;
            } else if (item.value == event.target.value && item.type == 'REFERENCE' && !item.value.substring(0, item.value.length - 2).endsWith('Id')) {
                isReference = true;
                apiName = item.value
            }
        })

        if (isReference) {
            this.showSpinner = true;
            const objectName = this.selectedObject.split('.').pop();

            this.selectedObject = this.selectedObject + '.' + apiName;
            var inputDataObjectApi = {
                objectName: objectName,
                apiName: apiName,
                isLookup: true
            }
            getObjectFieldsLabel({ theInputData: inputDataObjectApi })
                .then(result => {
                    let dataDraft = JSON.parse(JSON.stringify(result));
                    this.labelValueList = result;
                    dataDraft.forEach(item => {
                        if (item.type == 'REFERENCE') {
                            item.label = item.label + ' >';
                        }
                    });
                    this.lookupOptions = [...dataDraft];
                    console.log('this.lookup2ndOptions::: '+JSON.stringify(this.lookupOptions));
                    this.showSpinner = false;
                    this.isLookup = true;
                })
                .catch(error => {
                    console.log('error:::' + JSON.stringify(error));
                    this.lookupOptions = undefined;
                    this.showSpinner = false;
                    this.isLookup = true;
                    this.isNotLookup = false;
                    this.isNot3rdLookup = false;
                })
        } else {
            this.isLookup = false;
            this.is2ndLookup = false;
            this.isNot2ndLookup = false;
            this.isNot3rdLookup = false;
            this.isNotLookup = true;
            this.selectedField = event.target.value;
        }
    }

    handleTextSelect2(event) {
       console.log("handleTextSelect2");
       let selectedCSSClass = this.template.querySelector('.textButtonSelected2');

       if(selectedCSSClass){
        selectedCSSClass.classList.remove('textButtonSelected2');
        selectedCSSClass.classList.add('textButton');
       }
      this.template.querySelector('[data-id2="' +event.target.value+ '"]').className = 'textButtonSelected2';

        var occur = this.selectedObject.split(".").length - 1;

        if (this.selectedObject.includes(".") && occur >= 2) {
            this.selectedObject = this.selectedObject.substring(0, this.selectedObject.lastIndexOf('.'));       
        }

        var apiName = '';
        var isReference = false;
        this.lookupOptions.forEach(item => {
            if (item.value == event.target.value && item.type == 'REFERENCE') {
                isReference = true;
                //apiName= item.value.substring(0, item.value.length - 4);
                apiName = item.value;
            }
        })
        if (isReference) {
            this.showSpinner = true;
            let objectName = this.selectedObject.split('.').pop();
            objectName = objectName.includes('Id') ? objectName.substring(0, objectName.length - 2) : objectName;
            this.selectedObject = this.selectedObject + '.' + apiName;

            var inputDataObjectApi = {
                objectName: objectName,
                apiName: apiName,
                isLookup: true
            }
            getObjectFieldsLabel({ theInputData: inputDataObjectApi })
                .then(result => {
                    this.isNot3rdLookup = false;
                    this.isNotLookup = false;
                    this.isNot2ndLookup = false;
                    let dataDraft = JSON.parse(JSON.stringify(result));

                    dataDraft = dataDraft.filter(object => {
                        return object.type != 'REFERENCE';
                      });


                    // dataDraft.forEach(item => {
                    //     if (item.type == 'REFERENCE') {
                    //         item.label = item.label + ' >';
                    //     }
                    // });
                  
                    this.lookup2ndOptions = [...dataDraft];
                    console.log('this.lookup2ndOptions::: '+JSON.stringify(this.lookup2ndOptions));
                    this.showSpinner = false;
                    this.is2ndLookup = true;

                })
                .catch(error => {
                    console.log('error:::' + JSON.stringify(error));
                    this.lookupOptions = undefined;
                    this.showSpinner = false;
                    this.is2ndLookup = true;
                    this.isNot2ndLookup = false;
                })

        } else {
            this.is2ndLookup = false;
            this.isNot2ndLookup = true;
            this.isNot3rdLookup = false;
            this.selectedField = event.target.value;
        }
    }

    handleTextSelect3(event) {
        console.log("handleTextSelect3");
       let selectedCSSClass = this.template.querySelector('.textButtonSelected3');
       if(selectedCSSClass){
        selectedCSSClass.classList.remove('textButtonSelected3');
        selectedCSSClass.classList.add('textButton');
       }
        this.template.querySelector('[data-id3="' +event.target.value+ '"]').className = 'textButtonSelected3';

        this.isNot3rdLookup = true;
        this.selectedField = event.target.value;
    }

    handleOppOperatorChange(event) {
        var selectedRow = event.currentTarget;
        var currindex = selectedRow.dataset.oppkey;
        this.inputOppDataListToSave[currindex].operate = event.target.value;
    }

    handleProdOperatorChange(event) {
        var selectedRow = event.currentTarget;
        var currindex = selectedRow.dataset.prodkey;
        this.inputOppProdDataListToSave[currindex].operate = event.target.value;
    }

    handleOppInputVariable(event) {
        var selectedRow = event.currentTarget;
        var currindex = selectedRow.dataset.opp;
        this.template.querySelector(`[data-opp="${currindex}"]`).disabled = event.target.checked;  // Disable input if variable is true
        this.inputOppDataListToSave[currindex].isVariable = event.target.checked;

        if (event.target.checked) {
            this.inputOppDataListToSave[currindex].value = '';
            this.template.querySelector(`[data-opp="${currindex}"]`).value = '';
        }
    }

    handleOppProdInputVariable(event) {
        var selectedRow = event.currentTarget;
        var currindex = selectedRow.dataset.prod;
        this.template.querySelector(`[data-prod="${currindex}"]`).disabled = event.target.checked;  // Disable input if variable is true
        this.inputOppProdDataListToSave[currindex].isVariable = event.target.checked;

        if (event.target.checked) {
            this.template.querySelector(`[data-prod="${currindex}"]`).value = ''; // UI null if variable
            this.inputOppProdDataListToSave[currindex].value = '';
        }
    }

    handleFormulaOppInput(event) {
        var selectedRow = event.currentTarget;
        var currindex = selectedRow.dataset.opp;
        this.inputOppDataListToSave[currindex].value = event.target.value;
    }

    handleFormulaOppProdInput(event) {
        var selectedRow = event.currentTarget;
        var currindex = selectedRow.dataset.prod;
        this.inputOppProdDataListToSave[currindex].value = event.target.value;
    }

    removeOppRow(event) {

        var selectedRow = event.currentTarget;
        var currindex = selectedRow.dataset.opp;
        var arrObjRemove = this.OppRuleFieldList[currindex];

        this.isOppRule = false;

        if (this.OppRuleFieldList.length > 1) {
            this.formulaFieldToAdd.splice(currindex, 1);
            this.OppRuleFieldList.splice(currindex, 1);
            this.inputDataListToSave.splice(currindex, 1);
            this.inputOppDataListToSave.splice(currindex, 1);
           
            /*      this.OppRuleFieldList.forEach((item, index) =>{
                      item.key = index;
                  })
      
                  this.inputOppDataListToSave.splice(key, 1);
                  this.inputOppDataListToSave.forEach((item, index) =>{
                      item.index = index;
                  }) */
            this.isOppRule = true;
        } else if (this.OppRuleFieldList.length == 1) {
            this.OppRuleFieldList = [];
            this.inputOppDataListToSave = [];

            this.inputDataListToSave = this.inputDataListToSave.filter(object => {
                return object.rullType != this.customLabel.Opportunity_Rule;
              });

            this.formulaFieldToAdd = this.formulaFieldToAdd.filter(object => {
                return object.billRuleType != this.customLabel.Opportunity_Rule;
              });
            this.isOppRule = false;
        }
    }


    removeOppProdRow(event) {

        var selectedRow = event.currentTarget;
        var currindex = selectedRow.dataset.prod;
        var arrObjRemove = this.OppProductRuleFieldList[currindex];

        this.isOppProductRule = false;

        if (this.OppProductRuleFieldList.length > 1) {
            this.formulaFieldToAdd.splice(currindex, 1);
            this.OppProductRuleFieldList.splice(currindex, 1);
            this.inputDataListToSave.splice(currindex, 1);
            this.inputOppProdDataListToSave.splice(currindex, 1);

            /*    this.OppProductRuleFieldList.forEach((item, index) =>{
                    item.key = index;
                })
    
                this.inputOppProdDataListToSave.splice(key, 1);
                this.inputOppProdDataListToSave.forEach((item, index) =>{
                    item.index = index;
                })*/
            this.isOppProductRule = true;
        } else if (this.OppProductRuleFieldList.length == 1) {
            this.OppProductRuleFieldList = [];
            this.inputOppProdDataListToSave = [];

            this.inputDataListToSave = this.inputDataListToSave.filter(object => {
                return object.rullType != this.customLabel.Opportunity_Product_Rule;
              });

            this.formulaFieldToAdd = this.formulaFieldToAdd.filter(object => {
                return object.billRuleType != this.customLabel.Opportunity_Product_Rule;
              });

            this.isOppProductRule = false;
        }
    }

    handleAddField(event) {
        var listFieldLabelList = [];
        var pickValueOptions;
        this.showSpinner = true;
        this.index++;
        var i = this.index;
        if (this.selectedObject.includes(".")) {
            let replacedId = this.selectedObject.replace('Id','');
            let lookupObjName = replacedId.slice(replacedId.indexOf('.') + 1);
            lookupObjName = lookupObjName.endsWith('Id') ? lookupObjName.substring(0, lookupObjName.length - 2) : lookupObjName;
            this.addSelectedField = lookupObjName + '.' + this.selectedField;
        } else {
            this.addSelectedField = this.selectedField;
        }
        if (this.isLookup) {
            listFieldLabelList = this.lookupOptions;
        } else {
            listFieldLabelList = this.duallistoptions
        }
        listFieldLabelList.forEach(item => {
            // Input Type
            if (item.type == 'PICKLIST' && item.value == this.selectedField) {
                this.showSpinner = true;
                this.fieldDataType = item.type;
                this.fieldDateTypePicklist = true;
                this.fieldDataTypeBoolean = false;
                this.fieldDataTypeOther = false;
                this.fieldDataTypeDateTime = false;
                this.fieldDataTypeDate = false;
                this.fieldDataTypeURL = false;

                let sObjectApiName;
                let parentObjApiName;

                if (this.selectedObject.includes('.')) {
                    sObjectApiName = this.selectedObject.split('.').pop();
                    let objectArray = this.selectedObject.split('.');
                    parentObjApiName = objectArray[objectArray.length - 2];
                    parentObjApiName = parentObjApiName.includes('Id') ? parentObjApiName.substring(0, parentObjApiName.length - 2) : parentObjApiName;
                } else {
                    sObjectApiName = this.selectedObject;
                    parentObjApiName = ' ';
                }

                getPicklistValues({ parentObjApiName: parentObjApiName, ObjectApiName: sObjectApiName, FieldApiName: this.selectedField })
                    .then(result => {
                        pickValueOptions = result;

                        console.log('picklistOptions::: '+JSON.stringify(result));
                       // this.showSpinner = false;
                    }).catch(error => {
                        console.log('error:::' + JSON.stringify(error));
                    });

            } else if (item.type != 'PICKLIST' && item.type != 'REFERENCE' && item.type != 'BOOLEAN' && item.type != 'DATE' && item.type != 'DATETIME' && item.value == this.selectedField) {
                this.fieldDataType = item.type;
                this.otherfieldDataType = item.type;
                this.fieldDataTypeOther = true;
                this.fieldDataTypeBoolean = false;
            } else if (item.type == 'BOOLEAN' && item.value == this.selectedField) {
                this.fieldDataType = item.type;
                this.fieldDataTypeBoolean = true;
                this.fieldDataTypeOther = false;
                this.fieldDateTypePicklist = false;
                this.fieldDataTypeDate = false;
                this.fieldDataTypeDateTime = false;
            } else if (item.type == 'DATE' && item.value == this.selectedField) {
                this.fieldDataType = item.type;
                this.fieldDataTypeDate = true;
                this.fieldDataTypeOther = false;
                this.fieldDataTypeBoolean = false;
            } else if (item.type == 'DATETIME' && item.value == this.selectedField) {
                this.fieldDataType = item.type;
                this.fieldDataTypeDate = false;
                this.fieldDataTypeOther = false;
                this.fieldDataTypeBoolean = false;
                this.fieldDataTypeDateTime = true;
            } else if ((item.type == 'URL' || item.type == 'PHONE') && item.value == this.selectedField) {
                this.fieldDataType = item.type;
                this.fieldDataTypeDate = false;
                this.fieldDataTypeOther = true;
                this.fieldDataTypeBoolean = false;
                this.fieldDataTypeDateTime = false;
              
            }


            // Operator Option Creation
            if (item.value == this.selectedField && (item.type == 'STRING' || item.type == 'PICKLIST' || item.type == 'ID' || item.type == 'URL' || item.type == 'PHONE')) {
                this.operatorOptions = [
                    { label: '= Equals', value: 'Equals' },
                    { label: '<> Not Equals', value: 'Not Equals' },
                ]
            } else if (item.value == this.selectedField && (item.type == 'CURRENCY' || item.type == 'DOUBLE' || item.type == 'PERCENT' || item.type == 'DATE' || item.type == 'INTEGER' || item.type == 'DATETIME')) {
                this.fieldDataTypeDecimal = true;
                this.operatorOptions = [
                    { label: '= Equals', value: 'Equals' },
                    { label: '<> Not Equals', value: 'Not Equals' },
                    { label: '< Less Than', value: 'Less Than' },
                    { label: '<= Less Than or Equal', value: 'Less Than or Equal' },
                    { label: '> Greater Than', value: 'Greater Than' },
                    { label: '>= Greater Than or Equal', value: 'Greater Than or Equal' },
                ]
            }
            else if (item.value == this.selectedField && item.type == 'BOOLEAN') {
                this.operatorOptions = [
                    { label: '= Equals', value: 'Equals' },
                ]
            }
           // this.showSpinner = false;
        })
        
        setTimeout(() => {
        var fieldDTPicklist = this.fieldDateTypePicklist == true ? true : false
        var fieldDTOther = this.fieldDataTypeOther == true ? true : false
        var fieldDTBoolean = this.fieldDataTypeBoolean == true ? true : false
        var fieldDTDate = this.fieldDataTypeDate == true ? true : false
        var fieldDTDateTime = this.fieldDataTypeDateTime == true ? true : false
        var fieldDTUrl = this.fieldDataTypeURL == true ? true : false
     
        // Formula Fields to show on UI
        var formulaField = {
            billRuleType: this.billingRuleType,
            fieldName: this.addSelectedField,
            operator: this.operatorOptions,
            fieldDTPicklist: fieldDTPicklist,
            fieldDTOther: fieldDTOther,
            fieldDTBoolean: fieldDTBoolean,
            fieldDTDate: fieldDTDate,
            fieldDTDateTime: fieldDTDateTime,
            picklistOptions:pickValueOptions,
            key: i - 1
        };
        this.formulaFieldToAdd.push(formulaField);
     
        console.log('this.formulaFieldToAdd::: '+JSON.stringify(this.formulaFieldToAdd));
        // Fields to Save to database
        var inputDateToSave = {
            index: i - 1,
            rullType: this.billingRuleType,
            fieldName: this.addSelectedField,
            value: this.fieldDataType == 'BOOLEAN' ? 'false': '',
            operate: '',
            parentBillRecord: this.recordId,
            isVariable: false,
            fieldDataType: this.fieldDataType
        };
        this.inputDataListToSave.push(inputDateToSave);


        if (this.billingRuleType != this.customLabel.Opportunity_Rule) {
            this.isOppProductRule = true;
            this.formulaFieldToAdd.forEach(item => {
                if (item.billRuleType == this.customLabel.Opportunity_Product_Rule) {
                    this.OppProductRuleFieldList.push(item);
                    // Remove Duplicate
                    this.OppProductRuleFieldList = this.OppProductRuleFieldList.filter((obj, index) => {
                        return index === this.OppProductRuleFieldList.findIndex(o => obj.key === o.key);
                    });
                }
            })
            this.inputDataListToSave.forEach(item => {
                if (item.rullType ==  this.customLabel.Opportunity_Product_Rule) {
                    this.inputOppProdDataListToSave.push(item);
                    // Remove Duplicate
                    this.inputOppProdDataListToSave = this.inputOppProdDataListToSave.filter((obj, index) => {
                        return index === this.inputOppProdDataListToSave.findIndex(o => obj.index === o.index);
                    });
                }
            })

        } else {
            this.isOppRule = true;
            this.formulaFieldToAdd.forEach(item => {
                if (item.billRuleType == this.customLabel.Opportunity_Rule) {
                    this.OppRuleFieldList.push(item);
                    this.OppRuleFieldList = this.OppRuleFieldList.filter((obj, index) => {
                        return index === this.OppRuleFieldList.findIndex(o => obj.key === o.key);
                    });
                }
            })

            this.inputDataListToSave.forEach(item => {
                if (item.rullType == this.customLabel.Opportunity_Rule) {
                    this.inputOppDataListToSave.push(item);
                    this.inputOppDataListToSave = this.inputOppDataListToSave.filter((obj, index) => {
                        return index === this.inputOppDataListToSave.findIndex(o => obj.index === o.index);
                    });
                }
            })
        }
        
            this.showSelectedFormula = true;
            this.showSpinner = false;
          }, 2500);
      
    }

    handleCancelField1(event) {
        this.isNotLookup = false;
        this.isNot3rdLookup = false;
    }

    handleCancelField2(event) {
        //this.is2ndLookup = false;
        this.isNot2ndLookup = false;
    }

    handleCancelField3(event) {
        this.isNot3rdLookup = false;
    }

    submitAndSaveDetails(event) {
        this.showSpinner = true;
        var allInputDataToSave = [...this.inputOppDataListToSave, ...this.inputOppProdDataListToSave];

        allInputDataToSave.forEach(object => {
            object.billId = '';
            delete object['index'];
        });


        createBillingRule({ billingRuleDetails: allInputDataToSave })
            .then(result => {
                this.isModalOpen = false;
                const evt = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Billing rules have been created successfully',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                window.location.reload(); // Reload the whole page
                this.showSpinner = false;
            })
            .catch(error => {
                this.billRuleSaveError = true
                this.billRuleError = error.body.message;
                console.log('billRuleError::: ' + JSON.stringify(this.billRuleError));
                this.showSpinner = false;
            })
    }

    /*   removeRow(event){ 
           console.log('Remove row');
           var selectedRow = event.currentTarget;
           var currindex = selectedRow.dataset.key;
           console.log('currindexOP::'+JSON.stringify(currindex));
           var arrObjSave = this.inputDataListToSave[currindex];
           console.log('arrObjToSaveOP::'+JSON.stringify(arrObjSave));



           this.showSelectedFormula = false;
           var selectedRow = event.currentTarget;
           var key = selectedRow.dataset.id;
           console.log('Index to remove:::'+JSON.stringify(key));

           if(this.formulaFieldToAdd.length>1){
               this.formulaFieldToAdd.splice(key, 1);
               this.formulaFieldToAdd.forEach((item, index) =>{
                   item.key = index;
               })

               this.inputDataListToSave.splice(key, 1);
               this.inputDataListToSave.forEach((item, index) =>{
                   item.index = index;
               })
               this.index--;
               this.showSelectedFormula = true;
           }else if(this.accountList.length == 1){
               this.formulaFieldToAdd = [];
               this.inputDataListToSave = [];
               this.index--;
               this.showSelectedFormula = false;
           }
           
           console.log('formulaList After Remove:::'+JSON.stringify(this.formulaFieldToAdd));
           console.log('SaveList After Remove:::'+JSON.stringify(this.inputDataListToSave));
       }*/

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
            this.submitAndSaveDetails();
        }
    }

    getObjectKey(obj, value) {
        return Object.keys(obj).find(key => obj[key] === value);
    }
}