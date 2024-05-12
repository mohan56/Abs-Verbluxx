import { LightningElement, wire, track } from 'lwc';
import invoiceProvider from '@salesforce/apex/InvoiceViewLwcController.invoiceProvider';
import fetchBillingRecords from '@salesforce/apex/InvoiceViewLwcController.fetchBillingRecords';
import invoiceProviderFromBilling from '@salesforce/apex/InvoiceViewLwcController.invoiceProviderFromBilling';
import saveInvoiceAttachment from '@salesforce/apex/InvoiceViewLwcController.saveInvoiceAttachment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import jsPDF from '@salesforce/resourceUrl/jsPDF';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import { customlabel } from 'c/customLabelUtilityLwc';
import { customINVVIEWlabel } from 'c/customLabelUtilityLwc';

export default class invoiceViewLwc extends NavigationMixin(LightningElement) {
    @track customLabel = customlabel;
    @track customINVVIEWlabel = customINVVIEWlabel;
    objBilling = { 'sObjectType': 'Billing_Record__c' };
    recordId;
    invoiceList = [];
    invoiceCount;
    billingInvoiceCount;
    showSpinner = false;
    billingInvoiceList;
    invoicesToEmail = [];
    invoicesToPrint = [];
    docBlobListForInvoice = [];
    @track billingRecordOptions = [];
    showBillingRecord = false;
    showInvoiceList = false;
    @track selectedBillingRecordId;
    @track validationError = '';
    selectedOpportunityRecord;
    showPDF = false;
    shownewBillingButton = true;//New Button
    rowsToProcess = [];
    invoiceLogo;
    noOppTriggerError;
    invoiceProviderFromBillingError;

    isAsc = false;
    isDsc = false;
    isCustomerSort = false;
    isOpportunitySort = false;
    isAccountSort = false;
    isStatusSort = false;
    isAmountSort = false;
    isInvoiceDateSort=false;

    isCustomerSortPreInv = false;
    isOpportunitySortPreInv = false;
    isAccountSortPreInv = false;
    isStatusSortPreInv = false;
    isAmountSortPreInv = false;
    isInvoiceDateSortPreInv=false;
    sortedDirection = 'asc';
    sortedColumn;

    // Invoice Pagination Starts
    totalRecords = 0; //Total no.of records
    pageSize = 10; //No.of records to be displayed per page
    totalPages; //Total no.of pages
    pageNumber = 1; //Page number    
    recordsToDisplay = []; //Records to be displayed on the page
    totalBillingRecords = 0; //Total no.of records
    pageBillingRecordSize = 10; //No.of records to be displayed per page
    totalBillingPages; //Total no.of pages
    billingPageNumber = 1; //Page number    
    billingRecordsToDisplay = []; //Records to be displayed on the page

    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }
    get bDisablePrevious() {
        return this.pageNumber == 1;
    }
    get bDisableNext() {
        return this.pageNumber == this.totalPages;
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
    // JS function to handel pagination logic 
    paginationHelper() {
        this.recordsToDisplay = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.invoiceList[i]);
        }
    }
    // -------------------Invoice Pagination Ends------------------------------------//

    // Billing Record Pagination Starts

    get bilingDisableFirst() {
        return this.billingPageNumber == 1;
    }
    get billingDisableLast() {
        return this.billingPageNumber == this.totalBillingPages;
    }
    get bilingDisablePrevious() {
        return this.billingPageNumber == 1;
    }
    get billingDisableNext() {
        return this.billingPageNumber == this.totalBillingPages;
    }
    previousBillingPage() {
        this.billingPageNumber = this.billingPageNumber - 1;
        this.paginationBillingHelper();
    }
    nextBillingPage() {
        this.billingPageNumber = this.billingPageNumber + 1;
        this.paginationBillingHelper();
    }
    firstBillingPage() {
        this.billingPageNumber = 1;
        this.paginationBillingHelper();
    }
    lastBillingPage() {
        this.billingPageNumber = this.totalBillingPages;
        this.paginationBillingHelper();
    }
    // JS function to handel pagination logic 
    paginationBillingHelper() {
        this.billingRecordsToDisplay = [];
        // calculate total pages
        this.totalBillingPages = Math.ceil(this.totalBillingRecords / this.pageBillingRecordSize);
        // set page number 
        if (this.billingPageNumber <= 1) {
            this.billingPageNumber = 1;
        } else if (this.billingPageNumber >= this.totalBillingPages) {
            this.billingPageNumber = this.totalBillingPages;
        }
        // set records to display on current page 
        for (let i = (this.billingPageNumber - 1) * this.pageBillingRecordSize; i < this.billingPageNumber * this.pageBillingRecordSize; i++) {
            if (i === this.totalBillingRecords) {
                break;
            }
            this.billingRecordsToDisplay.push(this.billingInvoiceList[i]);
        }
    }
    // Billing Record Pagination Ends

    a_Record_URL;

    connectedCallback() {
        this.a_Record_URL = window.location.origin;
    }

    @wire(invoiceProvider)
    wireddata({ data, error }) {
        this.shownewBillingButton = true;//new Button
        if (data) {
            this.invoiceList = data;
            this.invoiceList = this.invoiceList.map((item, i) => {
                let indx = i;
                let pdfUrl;
                if (item.invContentDocId != null) pdfUrl = `/sfc/servlet.shepherd/document/download/${item.invContentDocId}`
                let oppHref = this.a_Record_URL + '/' + item.oppId;
                let accHref = this.a_Record_URL + '/' + item.accId;
                let conHref = this.a_Record_URL + '/' + item.conId;

                return { ...item, indx: indx, oppHref: oppHref, accHref: accHref, conHref: conHref, pdfUrl: pdfUrl };
            })
            this.invoiceCount = data.length;
            this.totalRecords = data.length;
            this.showInvoiceList = true;
            this.paginationHelper();
        }
        else if (error) {
            const evt = new ShowToastEvent({
                title: 'Error !',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    newBillingRecordHandler() {
        this.showBillingRecord = true;
        this.showInvoiceList = false;
        this.shownewBillingButton = false;//new Button 
        fetchBillingRecords()
            .then(result => {
                this.billingRecordOptions = result.map(record => ({
                    label: record.Name,
                    value: record.Id
                }));
                this.billingRecords = JSON.stringify(result);

            })
            .catch(error => {
            });
    }

    //Any bILL Record is Seleceted from the Table
    selectedbillingRecordsHandler(event) {
        this.noOppTriggerError = null;
        this.invoiceProviderFromBillingError = null;
        this.shownewBillingButton = false;//New Button 
        this.showSpinner = true;
        this.selectedBillingRecordId = event.target.value;
        invoiceProviderFromBilling({ billId: this.selectedBillingRecordId })
            .then((result) => {

                if(result.errMessage != null && result.errMessage != undefined){
                 this.showSpinner = false;
                 this.noOppTriggerError = result.errMessage;
                 this.billingInvoiceList = null;
                }else{
                    
                this.noOppTriggerError= null;
                this.billingInvoiceList = result.wrapperClassList;
                this.invoiceLogo = result.invoiceLogo;
                this.billingInvoiceList = this.billingInvoiceList.map((item, i) => {
                    let indx = i;
                    let oppHref = this.a_Record_URL + '/' + item.oppId;
                    let accHref = this.a_Record_URL + '/' + item.accId;
                    return { ...item, indx: indx, oppHref: oppHref, accHref: accHref };
                })
                this.billingInvoiceCount = result.wrapperClassList.length;
                this.totalBillingRecords = result.wrapperClassList.length;
                this.showSpinner = false;
                this.paginationBillingHelper();
                 }
            })
            .catch((error) => {
                this.invoiceProviderFromBillingError = error.body.message;
                this.showSpinner = false;
                this.billingInvoiceList = null;
                console.log('Error=>' + JSON.stringify(error));
            });
    }

    //Process Invoice Button Is Clicked
    processInvoiceButtonHandler() {
        this.showSpinner = true;
        var rowsToProcessUnique = Object.values(this.rowsToProcess.reduce((a, item) => {
            a[item.oppId] = item;
            return a;
        }, {}));

        var rowsToProcessFinal = [];

        rowsToProcessUnique.forEach(item => {
            if (item.emailChecked || item.printChecked) {
                rowsToProcessFinal.push(item)
            }
        })

        if (rowsToProcessFinal.length < 1) {
            this.showSpinner = false;
            const evt = new ShowToastEvent({
                title: 'Warning !',
                message: 'You did not select any items. Set one of the billing actions: EMAIL or PRINT for each item you wish to process an invoice',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.rowsToProcess = [];
            rowsToProcessUnique = [];
        } else {
            rowsToProcessFinal.forEach(item => {
                this.docBlobListForInvoice.push(this.generatePdf(item));
            })

            //Saving the Attachements
            saveInvoiceAttachment({ invBlobData: this.docBlobListForInvoice })
                .then(result => {

                    this.docBlobListForInvoice = [];
                    this.showSpinner = false;

                    const evt = new ShowToastEvent({
                        title: 'Success !',
                        message: 'Invoices generated successfully for selected records',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);

                    this.billingInvoiceList = this.billingInvoiceList.map(item => {

                        if (result[item.oppId] != undefined) {
                            let pdfUrl = `/sfc/servlet.shepherd/document/download/${result[item.oppId]}`
                            return { ...item, pdfUrl: pdfUrl }
                        } else {
                            return { ...item }
                        }
                    })
                    this.paginationBillingHelper();
                })
                .catch(error => {
                    const evt = new ShowToastEvent({
                        title: 'Error !',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.showSpinner = false;
                })
        }
    }

    //Opportunity Table Email Button is Clicked
    opportunityEmailHandler(event) {

        if (event.target.checked) {
            var selectedRow = event.currentTarget;
            var currindex = selectedRow.dataset.id;

            var billingObjOppId = this.billingInvoiceList[currindex].oppId;// it is returning the current Index when selected

            this.billingInvoiceList = this.billingInvoiceList.map(element => {
                if (element.oppId === billingObjOppId) {
                    let emailChecked = true;
                    return { ...element, emailChecked: emailChecked }
                } else {
                    return { ...element }
                }
            });
            this.rowsToProcess.push(this.billingInvoiceList[currindex]);
        }
        else {
            var selectedRow = event.currentTarget;
            var currindexRm = selectedRow.dataset.id;

            var billingObjOppId = this.billingInvoiceList[currindexRm].oppId;

            this.billingInvoiceList = this.billingInvoiceList.map(element => {
                if (element.oppId === billingObjOppId) {
                    let emailChecked = false;
                    return { ...element, emailChecked: emailChecked }
                } else {
                    return { ...element }
                }
            });

            this.rowsToProcess.push(this.billingInvoiceList[currindexRm]);
        }
    }

    //When Opportunity Table Print Button is Clicked
    opportunityPrintHandler(event) {

        if (event.target.checked) {
            var selectedRow = event.currentTarget;
            var currindex = selectedRow.dataset.id;

            var billingObjOppId = this.billingInvoiceList[currindex].oppId;// it is returning the current Index when selected

            this.billingInvoiceList = this.billingInvoiceList.map(element => {

                if (element.oppId === billingObjOppId) {
                    let printChecked = true;
                    return { ...element, printChecked: printChecked }
                } else {
                    return { ...element }
                }
            });
            this.rowsToProcess.push(this.billingInvoiceList[currindex]);
        }
        else {
            var selectedRow = event.currentTarget;
            var currindexRm = selectedRow.dataset.id;
            var billingObjOppId = this.billingInvoiceList[currindexRm].oppId;

            this.billingInvoiceList = this.billingInvoiceList.map(element => {
                if (element.oppId === billingObjOppId) {
                    let printChecked = false;
                    return { ...element, printChecked: printChecked }
                } else {
                    return { ...element }
                }
            });

            this.rowsToProcess.push(this.billingInvoiceList[currindexRm]);
        }
    }

    // Generating Pdf invoice Start
    jsPdfInitialized = false;
    renderedCallback() {
        loadScript(this, jsPDF).then(() => { });
        if (this.jsPdfInitialized) {
            return;
        }
        this.jsPdfInitialized = true;
    }

    generatePdf(dataToInv) {

        let oliArrayList = [];
        if (dataToInv.oliList != null) {
            dataToInv.oliList.forEach(item => {

                let oliData = {
                    'Quantity': item.Quantity,
                    'Description': item.Description ? item.Description : '',
                    'UnitPrice': 'USD ' + new Intl.NumberFormat('en-US').format(item.UnitPrice),
                    'TotalPrice': 'USD ' + new Intl.NumberFormat('en-US').format(item.TotalPrice)
                }
                var array = Object.keys(oliData)
                    .map(function (key) {
                        return oliData[key].toString();
                    });
                oliArrayList.push(array);
            })
        }

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        let pageHeight = doc.internal.pageSize.height;

        if (this.invoiceLogo != null) doc.addImage(this.invoiceLogo, 'PNG', 140, 30, 40, 30);
        doc.setFont('helvetica')
        doc.text(this.customINVVIEWlabel.INVVIEW_PDF_Invoice_Heading, 90, 20,)
        doc.setFontSize(10).setFont('helvetica', 'bold');
        if (dataToInv.accName != null) doc.text(dataToInv.accName, 20, 40).setFontSize(10).setFont('helvetica', 'bold');
        if (dataToInv.billTo != null) doc.text(dataToInv.billTo, 20, 45).setFontSize(11).setFont("helvetica", 'bold');
        doc.text("Phone: ", 20, 60).setFontSize(11).setFont("helvetica", 'bold');
        if (dataToInv.conPhone != null) doc.text(dataToInv.conPhone, 33, 60)

        doc.setDrawColor(0);
        doc.setFillColor(0, 51, 102);
        doc.rect(20, 63, 175, 10, 'F');
        doc.setTextColor("#ffffff");
        doc.text(this.customINVVIEWlabel.INVVIEW_PDF_Invoice_No, 21, 70).setFontSize(11).setFont('helvetica', 'bold');
        if (dataToInv.invoiceNumber != null) doc.text(dataToInv.invoiceNumber, 47, 70).setFontSize(11).setFont('helvetica', 'bold');
        doc.setTextColor("#ffffff");
        doc.text(this.customINVVIEWlabel.INVVIEW_PDF_Date, 150, 70).setFontSize(11).setFont('helvetica', 'bold');
        if (dataToInv.invoiceDate != null) doc.text(dataToInv.invoiceDate, 165, 70).setFontSize(11).setFont('helvetica', 'bold');
        doc.setTextColor("#003366");
        doc.text(this.customINVVIEWlabel.INVVIEW_PDF_Bill_To + ' ', 20, 80).setFontSize(10).setFont('helvetica', 'normal');
        doc.line(20, 81, 194, 81);
        doc.setTextColor("#000000");
        if (dataToInv.conName != null) doc.text(dataToInv.conName, 20, 85).setFontSize(10).setFont('helvetica', 'normal');

        if (dataToInv.shipTo != null) doc.text(dataToInv.shipTo, 20, 90).setFontSize(10).setFont('helvetica', 'normal');

        // Define the table headers and data
        const headers = [this.customINVVIEWlabel.INVVIEW_PDF_Table_Header_1, this.customINVVIEWlabel.INVVIEW_PDF_Table_Header_2, this.customINVVIEWlabel.INVVIEW_PDF_Table_Header_3, this.customINVVIEWlabel.INVVIEW_PDF_Table_Header_4];

        // Set the table starting position
        let y = 20;

        // Set the column widths
        const columnWidths = [35, 60, 40, 40];

        // Set the table styles
        const headerStyle = { fillColor: "#003366", textColor: "#ffffff" };
        const rowStyle = { fillColor: "#f2f2f2" };

        // Draw the table headers
        headers.forEach((header, index) => {
            doc.setFillColor(headerStyle.fillColor);
            doc.setTextColor(headerStyle.textColor);
            doc.rect(y, 100, columnWidths[index], 8, "F");


            if (header.includes('UNIT') || header.includes('TOTAL')) {
                doc.text(header, y + columnWidths[index] - 2, 105, { align: 'right' });
            } else {
                doc.text(header, y + 2, 105);
            }
            y += columnWidths[index];
        });

        y = 20;
        let x = 110;

        // Draw the table rows
        oliArrayList.forEach((row) => {
            row.forEach((cell, index) => {
                doc.setFillColor(rowStyle.fillColor);
                doc.setTextColor(0, 0, 0);
                doc.rect(y, x, columnWidths[index], 8, "F");           

               if ((cell.includes('USD') && index == 2) || (cell.includes('USD') && index == 3)) {
                    doc.text(cell, y + columnWidths[index] - 2, x + 5, { align: 'right'});
                } else {
                    doc.text(cell, y + 2, x + 5);
               } 

                y += columnWidths[index];
            });
            x = x + 9;
            y = 20;
            if (pageHeight - 20 <= x) {
                doc.addPage();
                x = 20
                y = 20
            }
        });

        x = x + 5;

        doc.setTextColor("#003366");
        doc.text(this.customINVVIEWlabel.INVVIEW_PDF_Subtotal, 105, x + 5).setTextColor("#003366");
        doc.line(105, x + 6, 194, x + 6)       
        doc.text(this.customINVVIEWlabel.INVVIEW_PDF_SALES_TAX, 105, x + 10).setTextColor("#003366");
        doc.line(105, x + 11, 194, x + 11)     
        doc.text(this.customINVVIEWlabel.INVVIEW_PDF_SHIPPING_HANDLING, 105, x + 15).setTextColor("#003366");
        doc.line(105, x + 16, 194, x + 16)       
        doc.text(this.customINVVIEWlabel.INVVIEW_PDF_TOTAL_DUE_BY_DATE + ' ', 105, x + 20).setTextColor("#003366");
        doc.line(105, x + 21, 194, x + 21)
     
        if (dataToInv.invoiceAmount != null) doc.text('USD ' + new Intl.NumberFormat('en-US').format(dataToInv.invoiceAmount), 192, x + 5, { align: 'right' }).setTextColor("#003366");
        if (dataToInv.shippinghandling != null) doc.text('USD ' + new Intl.NumberFormat('en-US').format(dataToInv.shippinghandling), 192, x + 10,{ align: 'right' }).setTextColor("#003366");
        if (dataToInv.salesTax != null) doc.text('USD ' + new Intl.NumberFormat('en-US').format(dataToInv.salesTax), 192, x + 15,{ align: 'right' }).setTextColor("#003366");      
        let totalAmount = parseFloat(dataToInv.invoiceAmount || 0) + parseFloat(dataToInv.shippinghandling || 0) + parseFloat(dataToInv.salesTax || 0);
      
        if (totalAmount != isNaN) {
            doc.text('USD ' + new Intl.NumberFormat('en-US').format(totalAmount), 192, x + 20,{ align: 'right' }).setTextColor("#003366");
           
        } else {
           
            console.log("Converstion Error");
        }
        var blobData = btoa(doc.output());
        var blobDataObj = { ...dataToInv, blobData: blobData };
        return blobDataObj;
    }

    //When PDF IS SELECTED
    showPreviewPDF(event) {
        var pdfUrlStr = event.target.value.toString();
        const after_ = pdfUrlStr.split('/').pop();

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: after_
            }
        })
    }

    // Sorting of Columns After Invoice Generation Start
    sortByCustomerInv(event){
        this.isCustomerSort = true;
        this.isOpportunitySort = false;
        this.isAccountSort = false;
        this.isStatusSort = false;
        this.isAmountSort = false;
        this.isInvoiceDateSort=false;
        this.sortData( this.recordsToDisplay,event.currentTarget.dataset.id);
    }

    sortByOpportunityInv(event) {
        this.isCustomerSort = false;
        this.isOpportunitySort = true;
        this.isAccountSort = false;
        this.isStatusSort = false;
        this.isAmountSort = false;
        this.isInvoiceDateSort=false;
        this.sortData( this.recordsToDisplay,event.currentTarget.dataset.id);
    }

    sortByAccountInv(event) {
        this.isCustomerSort = false;
        this.isOpportunitySort = false;
        this.isAccountSort = true;
        this.isStatusSort = false;
        this.isAmountSort = false;
        this.isInvoiceDateSort=false;
        this.sortData( this.recordsToDisplay, event.currentTarget.dataset.id);
    }
    sortByStatusInv(event) {
        this.isCustomerSort = false;
        this.isOpportunitySort = false;
        this.isAccountSort = false;
        this.isStatusSort = true;
        this.isAmountSort = false;
        this.isInvoiceDateSort=false;
        this.sortData(this.recordsToDisplay, event.currentTarget.dataset.id);
    }
    sortByAmountInv(event) {
        this.isCustomerSort = false;
        this.isOpportunitySort = false;
        this.isAccountSort = false;
        this.isStatusSort = false;
        this.isAmountSort = true;
        this.isInvoiceDateSort=false;
        this.sortData( this.recordsToDisplay,event.currentTarget.dataset.id);
    }
    sortByInvoiceDateInv(event) {
        this.isCustomerSort = false;
        this.isOpportunitySort = false;
        this.isAccountSort = false;
        this.isStatusSort = false;
        this.isAmountSort = false;
        this.isInvoiceDateSort=true;
        this.sortData( this.recordsToDisplay,event.currentTarget.dataset.id);
    }
   // Sorting of Columns After Invoice Generation End

   // Sorting of Columns Pre Invoice Generation Start
    sortByCustomerPreInv(event) {
        this.isCustomerSortPreInv = true;
        this.isOpportunitySortPreInv = false;
        this.isAccountSortPreInv = false;
        this.isStatusSortPreInv = false;
        this.isAmountSortPreInv = false;
        this.isInvoiceDateSortPreInv=false;
        console.log('this.billingRecordsToDisplay::: '+JSON.stringify(this.billingRecordsToDisplay));
        this.sortData(this.billingRecordsToDisplay, event.currentTarget.dataset.id);
    }
  
    sortByOpportunityPreInv(event) {
        this.isCustomerSortPreInv = false;
        this.isOpportunitySortPreInv = true;
        this.isAccountSortPreInv = false;
        this.isStatusSortPreInv = false;
        this.isAmountSortPreInv = false;
        this.isInvoiceDateSortPreInv=false;
        this.sortData(this.billingRecordsToDisplay, event.currentTarget.dataset.id);
    }

    sortByAccountPreInv(event) {
        this.isCustomerSortPreInv = false;
        this.isOpportunitySortPreInv = false;
        this.isAccountSortPreInv = true;
        this.isStatusSortPreInv = false;
        this.isAmountSortPreInv = false;
        this.isInvoiceDateSortPreInv=false;
        this.sortData(this.billingRecordsToDisplay, event.currentTarget.dataset.id);
    }

    sortByStatusPreInv(event){
        this.isCustomerSortPreInv = false;
        this.isOpportunitySortPreInv = false;
        this.isAccountSortPreInv = false;
        this.isStatusSortPreInv = true;
        this.isAmountSortPreInv = false;
        this.isInvoiceDateSortPreInv=false;
        this.sortData(this.billingRecordsToDisplay, event.currentTarget.dataset.id);
    }
    sortByAmountPreInv(event){
        this.isCustomerSortPreInv = false;
        this.isOpportunitySortPreInv = false;
        this.isAccountSortPreInv = false;
        this.isStatusSortPreInv = false;
        this.isAmountSortPreInv = true;
        this.isInvoiceDateSortPreInv=false;
        this.sortData(this.billingRecordsToDisplay, event.currentTarget.dataset.id);
    }

    sortByInvoiceDatePreInv(event){
        this.isCustomerSortPreInv = false;
        this.isOpportunitySortPreInv = false;
        this.isAccountSortPreInv = false;
        this.isStatusSortPreInv = false;
        this.isAmountSortPreInv = false;
        this.isInvoiceDateSortPreInv=true;
        this.sortData(this.billingRecordsToDisplay, event.currentTarget.dataset.id);
    }

    
    sortData(listToSort, sortColumnName) {
        // check previous column and direction
        if (this.sortedColumn === sortColumnName) {
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        } 
        else {
            this.sortedDirection = 'asc';
        }

        // check arrow direction
        if (this.sortedDirection === 'asc') {
            this.isAsc = true;
            this.isDsc = false;
        } 
        else {
            this.isAsc = false;
            this.isDsc = true;
        }
        // check reverse direction
        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;

        this.sortedColumn = sortColumnName;

        // sort the data
        if(listToSort[0].printChecked || listToSort[0].emailChecked){
            this.recordsToDisplay = JSON.parse(JSON.stringify(listToSort)).sort((a, b) => {
                if(sortColumnName == 'invoiceAmount'){
                    a = +a[sortColumnName] ? +a[sortColumnName] : ''; // Handle null values
                    b = +b[sortColumnName] ? +b[sortColumnName] : '';
                }else{
                    a = a[sortColumnName] ? a[sortColumnName].toLowerCase() : ''; // Handle null values
                    b = b[sortColumnName] ? b[sortColumnName].toLowerCase() : '';    
                }
                return a > b ? 1 * isReverse : -1 * isReverse;
            });
        }else{
            this.billingRecordsToDisplay = JSON.parse(JSON.stringify(listToSort)).sort((a, b) => {
                if(sortColumnName == 'invoiceAmount'){
                    a = +a[sortColumnName] ? +a[sortColumnName] : ''; // Handle null values
                    b = +b[sortColumnName] ? +b[sortColumnName] : '';
                }else{
                    a = a[sortColumnName] ? a[sortColumnName].toLowerCase() : ''; // Handle null values
                    b = b[sortColumnName] ? b[sortColumnName].toLowerCase() : '';
                }
                return a > b ? 1 * isReverse : -1 * isReverse;
            });
        }
    }
}