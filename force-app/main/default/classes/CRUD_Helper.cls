/************************************************************************************************************
@class:         CRUD_Helper
@description:   This class is used by all classes that retrive data from the database to ensure that FLS
                and encryption rules are respected. This is essential for Lightning Component classes
                it is a requirement for standard Apex classes to pass the AppExchange security review
**************************************************************************************************************/
public Class CRUD_Helper {
       
/**********************************************************************************************
    @method         cleanseFields
    @param          List<SObject> obj
    @param          String dmlType
    @return         SObject
    @description    This method takes the record and processes to enforce standard stripInAccessible
**********************************************************************************************/

    public static List<SObject> cleanseFields(List<SObject> records, System.AccessType dmlType) {
            SObjectAccessDecision securityDecision = Security.stripInaccessible(dmlType,records);
            return securityDecision.getRecords();
    }
    
    public static Boolean areFieldsCreateable(Set<String> fieldSet, String objectApiName) {
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
        
        for (String fieldName : fieldSet) {
            Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
            if(!fieldDescribe.isCreateable()){
                return false;
            }
            
        }
        
        return true;
    }
    
    public static Boolean areFieldsUpsertable(Set<String> fieldSet, String objectApiName) {
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
        
        for (String fieldName : fieldSet) {
            Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
            if(!fieldDescribe.isUpdateable() || !fieldDescribe.isCreateable()){
                return false;
            }
            
        }
        return true;
    }
    
   /* public static List<SObject> cleanseFields(List<SObject> records, System.AccessType dmlType) {
        // Use Security.stripInaccessible to handle CRUD and FLS checks
        SObjectAccessDecision securityDecision = Security.stripInaccessible(dmlType, records);
        
        // Retrieve the SObject Type dynamically
        Schema.SObjectType objectType = records[0].getSObjectType();
        system.debug('objectType=>'+objectType);
        Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        
        // Filter fields based on FLS
        for (SObject record : securityDecision.getRecords()) {
            for (String fieldName : fieldMap.keySet()) {
                system.debug('fieldName=>'+fieldName);
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                if (!fieldDescribe.isAccessible()) {
                    // Field is not accessible, set it to null
                    record.put(fieldName, null);
                }
            }
        }
        system.debug('securityrecords=>'+securityDecision.getRecords());
        return securityDecision.getRecords();
    }*/

    /**********************************************************************************************
    @method         checkDeleteList
    @param          List<SObject> obj
    @param          String dmlType
    @return         SObject
    @description    This method takes the record and processes to enforce standard stripInAccessible
**********************************************************************************************/
     public Static Boolean checkDeleteList(List<Sobject> SobjectRec, String SobjectName) {
        Boolean Success = true;
        Boolean valid = False;
        String Message = '';

        if (SobjectRec.size() == 0) Return true;

        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(SobjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        if (!SObjectTypeObj.getDescribe().isDeletable()) Success = False;

        if (!Success) {
            throw new AuraHandledException( 'No delete access to ~ ' + DescribeSObjectResultObj.getLabel() + ' to perform this operation!');
        }
        System.debug('Success==>' + Success);
        return Success;
    } 
}