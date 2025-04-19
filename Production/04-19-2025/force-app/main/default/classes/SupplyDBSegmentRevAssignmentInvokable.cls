global class SupplyDBSegmentRevAssignmentInvokable {
    
    @InvocableMethod(label='Supply Database to Process' )
    public static List<SupplyDBResult> processSupplyDataBase(List<ID> ids) {
        List<SupplyDBResult> results = new List<SupplyDBResult>();
        SupplyDBResult result = new SupplyDBResult();
        
        SupplyDatabaseSegmentRevenueAssignment b = new SupplyDatabaseSegmentRevenueAssignment(ids); 
        b.supplyDBIds = ids;
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