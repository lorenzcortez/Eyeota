@isTest
private class MockDataTest{ 
    private static testMethod void test() {
        MockData btcb = new MockData();
        System.assert(btcb.getNumber()>0);
    }
}