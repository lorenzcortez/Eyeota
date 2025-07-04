global class SalesDBSegmentRevenueAssignmentInvokable {
    
    @InvocableMethod(label='Sales Database to Process' )
    public static List<SupplyDBResult> processSalesDataBase(List<ID> ids) {
        List<SupplyDBResult> results = new List<SupplyDBResult>();
        SupplyDBResult result = new SupplyDBResult();
        
        SalesDBSegmentRevenueAssignment b = new SalesDBSegmentRevenueAssignment(ids); 
        b.salesDBIds = ids;
        Id batchProcessId = Database.executeBatch(b, 1);
        result.isSucceeded = TRUE;
        
        results.add(result);
        
        return results;
    }
    
    global class SupplyDBResult {
        @InvocableVariable(label='True if succeeded')
        global boolean isSucceeded;
        
    }


}