@isTest
public class CustomLookupLwcControllerTest {
    
    @testSetup
    public static void setupMethod(){
        
        Account theAcc = TestDataUtil.createAccount('Test Account');
        insert theAcc;
    }
    
    @isTest
    public static void fetchLookupDataTest(){
        
        test.starttest();
        list<sObject> objList = CustomLookupLwcController.fetchLookupData('Test','Account');
        test.stoptest();
        System.assertEquals(1,objList.size());
    }
    
    @isTest
    public static void fetchDefaultRecord(){
        Account theAcc = [select Id from Account];
        test.starttest();
        sObject theObj = CustomLookupLwcController.fetchDefaultRecord( theAcc.Id, 'Account');
        test.stoptest();
        System.assertEquals(theAcc.Id,theObj.Id);
    }
}