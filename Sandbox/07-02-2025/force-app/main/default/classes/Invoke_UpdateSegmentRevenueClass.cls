public with sharing class Invoke_UpdateSegmentRevenueClass {

    @InvocableMethod
    public static List<FlowOutput> runBatch(List<FlowInput> input) {
        List<FlowOutput> outputList = new List<FlowOutput>();
        Database.executeBatch(new UpdateSegmentRevenueBatch(input[0].objectName, input[0].dateField, input[0].startDate, input[0].endDate), 200);
        return outputList;
    }

    public class FlowInput {
        @InvocableVariable(required=true)
        public String objectName;
        @InvocableVariable(required=true)
        public String dateField;
        @InvocableVariable
        public Date startDate;
        @InvocableVariable
        public Date endDate;
    }

    public class FlowOutput {
        @InvocableVariable
        public String errorMsg;
    }
}