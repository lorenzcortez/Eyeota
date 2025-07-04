@isTest
public class Invoke_CongaDateFilterClassTest {
    @isTest
    static void testRunBatch() {
        // Step 1: Create test data for FlowInput
        Invoke_CongaDateFilterClass.FlowInput testInput = new Invoke_CongaDateFilterClass.FlowInput();
        testInput.startDate = Date.today().addDays(-10);
        testInput.endDate = Date.today();

        // Step 2: Create a list of FlowInput to simulate Flow behavior
        List<Invoke_CongaDateFilterClass.FlowInput> inputList = new List<Invoke_CongaDateFilterClass.FlowInput>();
        inputList.add(testInput);

        // Step 3: Call the Invocable Method
        Test.startTest();
        List<Invoke_CongaDateFilterClass.FlowOutput> result = Invoke_CongaDateFilterClass.runBatch(inputList);
        Test.stopTest();
    }

    @isTest
    static void testInvalidDateRange() {
        // Step 1: Create invalid FlowInput data (startDate after endDate)
        Invoke_CongaDateFilterClass.FlowInput testInput = new Invoke_CongaDateFilterClass.FlowInput();
        testInput.startDate = Date.today();
        testInput.endDate = Date.today().addDays(-10);

        // Step 2: Create a list of FlowInput
        List<Invoke_CongaDateFilterClass.FlowInput> inputList = new List<Invoke_CongaDateFilterClass.FlowInput>();
        inputList.add(testInput);

        // Step 3: Call the Invocable Method and handle exceptions
        Test.startTest();
        try {
            List<Invoke_CongaDateFilterClass.FlowOutput> result = Invoke_CongaDateFilterClass.runBatch(inputList);
        } catch (Exception e) {
        }
        Test.stopTest();
    }
}