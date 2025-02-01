@isTest
public class ExecuteSegmentRevenueTransactionTest {
	@isTest
    static void scenario(){
        Test.startTest();
        ExecuteSegmentRevenueTransaction.execute(50);
        ExecuteSegmentRevenueTransaction.executeSupplyDatabase(50);
        Test.stopTest();
    }
}