public with sharing class Invoke_CongaDateFilterClass {

    @InvocableMethod
    public static List<FlowOutput> runBatch(List<FlowInput> input) {
        List<FlowOutput> outputList = new List<FlowOutput>();
        Database.executeBatch(new CongaDateFilterBatch(input[0].startDate, input[0].endDate), 200);
        return outputList;
    }

    public class FlowInput {
        @InvocableVariable(required=true)
        public Date startDate;
        @InvocableVariable(required=true)
        public Date endDate;
    }

    public class FlowOutput {
        @InvocableVariable
        public String errorMsg;
    }
}