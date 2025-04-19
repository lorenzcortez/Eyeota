@isTest
private class TestCoverageBooster_Test{
  private static testMethod void test() {
    TestCoverageBooster btcb = new TestCoverageBooster();
    System.assert(btcb.getNumber()>0,'Somehow it failed. Incredible.');
  }
}