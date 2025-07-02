@isTest
public class LeadTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test users
        User user1 = new User(
            Alias = 'tstuser',
            Email = 'tstuser72324@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'tstuser72324@example.com'
        );
        insert user1;
        
        User user2 = new User(
            Alias = 'tstusr2',
            Email = 'tstuser272324@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'tstuser272324@example.com'
        );
        insert user2;
    }
    
    @isTest
    static void testBeforeInsert() {
        // Fetch a test user
        User user = [SELECT Id, email, Name FROM User LIMIT 1];
        
        // Create test leads
        Lead lead1 = new Lead(
            FirstName = 'Test',
            LastName = 'Lead1',
            Company = 'Test Company',
            OwnerId = user.Id,
            email = 'tstuser272324@example.com',
            LeadSource = 'Business Development',
            Lead_Source_Other__c = 'test',
            Lead_Type__c = 'Mobile',
            Status = 'Open'
        );
        
        Lead lead2 = new Lead(
            FirstName = 'Test',
            LastName = 'Lead2',
            Company = 'Test Company',
            OwnerId = user.Id,
            email = 'tstuser272324@example.com',
            LeadSource = 'Business Development',
            Lead_Source_Other__c = 'test',
            Lead_Type__c = 'Mobile',
            Status = 'Open'
        );
        
        Test.startTest();
        insert new List<Lead>{lead1, lead2};
        Test.stopTest();
        
        // Verify that the custom field is set correctly
        List<Lead> insertedLeads = [SELECT Id, SF_Owner_For_HubSpot__c FROM Lead WHERE Id IN :new List<Id>{lead1.Id, lead2.Id}];
        
        for (Lead lead : insertedLeads) {
            System.assertEquals(user.Name, lead.SF_Owner_For_HubSpot__c);
        }
    }
    
    @isTest
    static void testBeforeUpdate() {
        // Fetch test users
        User user1 = [SELECT Id, Name FROM User WHERE UserName = 'tstuser72324@example.com' LIMIT 1];
        User user2 = [SELECT Id, Name FROM User WHERE UserName = 'tstuser272324@example.com' LIMIT 1];
        
        // Create test lead
        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            OwnerId = user1.Id,
            email = 'tstuser272324@example.com'
        );
        insert lead;
        
        // Update lead owner
        lead.OwnerId = user2.Id;
        
        Test.startTest();
        update lead;
        Test.stopTest();
        
        // Verify that the custom field is updated correctly
        Lead updatedLead = [SELECT Id, SF_Owner_For_HubSpot__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(user2.Name, updatedLead.SF_Owner_For_HubSpot__c);
    }
}