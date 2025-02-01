@isTest
public class CongaDateFilterBatchTest {

    @isTest
    static void testCongaDateFilterBatch() {
        // Step 1: Create test data
        // Insert a sample Account record with the required RecordType and default dates
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Data_Supplier_Parent_Accout' AND SObjectType = 'Account' LIMIT 1];
        Account testAccount = new Account(
            Name = 'Test Account',
            RecordTypeId = rt.Id
        );
        insert testAccount;

        // Verify test data was inserted
        System.assertNotEquals(null, testAccount.Id, 'Account record should be created successfully.');

        // Step 2: Define batch parameters
        Date testStartDate = Date.today().addDays(-7);
        Date testEndDate = Date.today().addDays(7);

        // Step 3: Instantiate the batch class
        CongaDateFilterBatch batch = new CongaDateFilterBatch(testStartDate, testEndDate);

        // Step 4: Execute the batch
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        // Step 5: Verify the batch results
        Account updatedAccount = [SELECT Start_Date__c, End_Date__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(testStartDate, updatedAccount.Start_Date__c, 'Start_Date__c should be updated correctly.');
        System.assertEquals(testEndDate, updatedAccount.End_Date__c, 'End_Date__c should be updated correctly.');
    }
}