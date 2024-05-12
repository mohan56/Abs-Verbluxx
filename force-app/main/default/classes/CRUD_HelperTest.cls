/**********************************************************
Class: CRUD_HelperTest
Description: This is controller class of Lwc CRUD_Helper
***********************************************************/
@istest
public class CRUD_HelperTest {
    
/**********************************************************
Method: testcleanseFields
Description: Test Method of method CRUD_Helper.cleanseFields
***********************************************************/
  @istest
    public static void testcleanseFields(){
       
        List<Account> acclist = new List<Account>();
          for (Integer i = 0; i < 5; i++) {
            Account acc = new Account(Name = 'Test Account ' + i);
            acclist.add(acc);
    }
        system.AccessType accesstype = system.AccessType.READABLE;

        test.starttest();
        List<SObject> cleansedRecords = CRUD_Helper.cleanseFields(acclist, accesstype);
        test.stoptest();
        // Assertion
        System.assertEquals(acclist.size(), cleansedRecords.size(), 'Number of records should remain the same');
    }
/**********************************************************
Method: testCheckDeleteList
Description: Test Method of method CRUD_Helper.checkDeleteList
***********************************************************/
    
     @istest
    public static void testCheckDeleteList(){
        
        List<Billing_Trigger__c> testBilllist = new List<Billing_Trigger__c>();
          for (Integer i = 0; i < 5; i++) {
            Billing_Trigger__c theBill = new Billing_Trigger__c(Name = 'Test Account ' + i);
            testBilllist.add(theBill);
    }
        test.starttest();
        Boolean testDelete = CRUD_Helper.checkDeleteList(testBilllist, 'Billing_Trigger__c');
        test.stoptest();
        // Assertion
        System.assert(testDelete);
    }
}