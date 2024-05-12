public with sharing class CustomLookupLwcController {
      @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {    
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        string sQuery = 'Select Id,Name From ' + String.escapeSingleQuotes(sObjectApiName) + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        string sRecId = recordId;    
        string sQuery = 'Select Id,Name From ' + String.escapeSingleQuotes(sObjectApiName) + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            System.debug('obj::: '+obj);
            return obj;
        }
        return null;
    }
}