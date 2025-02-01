public class LeadTriggerHandler {
    public static void beforeInsert(List<Lead> newLeads) {
        hubSpotSalesforceOwnerLead(newLeads, NULL);
    }
    
    public static void beforeUpdate(List<Lead> newLeads, Map<Id, Lead> oldLeadMap) {
        hubSpotSalesforceOwnerLead(newLeads, oldLeadMap);
    }
    
    private static void hubSpotSalesforceOwnerLead(List<Lead> newLeads, Map<Id, Lead> oldLeadMap) {
        Set<Id> ownerIdSet = new Set<Id>();
        List<Lead> leadToProcess = new List<Lead>();
        Map<Id, User> hubspotUserMap = New Map<Id, User>();
        
        for (Lead leadRec : newLeads) {
            if(Trigger.isInsert){
                ownerIdSet.add(leadRec.OwnerId);
                leadToProcess.add(leadRec);
            } else if(Trigger.isUpdate && leadRec.OwnerId != oldLeadMap.get(leadRec.Id).OwnerId){
                ownerIdSet.add(leadRec.OwnerId);
                leadToProcess.add(leadRec);
            }
        }
        
        hubspotUserMap = getSFOwnersHubspotMap(ownerIdSet);
        
        for (Lead leadRec : leadToProcess) {
            leadRec.SF_Owner_For_HubSpot__c = getSFOwnerHubspotName(hubspotUserMap.get(leadRec.ownerId));
        }
    }
    
    private static Map<Id, User> getSFOwnersHubspotMap(Set<Id> ownerIdSet) {
       return new Map<Id, User>([SELECT Id, Name, isActive FROM User WHERE Id IN: ownerIdSet]);
    }
    
    private static String getSFOwnerHubspotName(User hubspotUser) {
        if(Label.Eunice_Machine_Id.contains(hubspotUser.Id)){
            return NULL;
        } else{
            if(hubspotUser.isActive){
                return hubspotUser.Name;
            }
        }
        return null;
    }
    
}