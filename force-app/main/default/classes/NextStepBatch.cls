/*
 * NextStepBatch Class Description:
 * 
 * Implementing the 'Database.Batchable' interface allows you to define a job that can be broken into smaller batches.
 * Update the Next Step field on all accounts and opportunities in the org to 'Batching the next meetings together.' 
 * Send an email to all active users
 */
public with sharing class NextStepBatch implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext bc){
        // Query for all accounts and return the query locator.
        return Database.getQueryLocator('SELECT Id, Next_Step__c FROM Account'); // Update null with the query locator
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope){
        final String BATCH_NEXT_STEP = 'Batching the next meetings together.';

        // Update the Next Step field on each record in the batch scope.

        // Loop through the scope account records
        for (Account acc : scope) {
            acc.Next_Step__c = BATCH_NEXT_STEP; // Set the Next Step field to 'Batching the next meetings together.'
        }

        update scope; // Update the account records in this batch scope
        
        // Query for all opportunities related to the accounts in this batch scope
        List<Opportunity> opps = [SELECT Id, NextStep FROM Opportunity WHERE AccountId IN :scope];

        // Loop through the opportunity records
        for (Opportunity opp : opps) {
            opp.NextStep = BATCH_NEXT_STEP;  // Set the Next Step field to 'Batching the next meetings together.'
        }

        update opps; // Update the opportunity records

    }
    
    public void finish(Database.BatchableContext bc){
        final List<User> USERS = [SELECT Id, Name, Email FROM User WHERE IsActive = true AND (NOT Email LIKE 'autoproc%')]; // DO NOT CHANGE

        // Create a set of email addresses
        Set<String> emailAddresses = new Set<String>();
        
        // Get the email addresses of all active users
        for (User u : USERS) {
            emailAddresses.add(u.Email);
        }

        sendEmailToActiveUsers(emailAddresses); // Pass the set of active user emails to the sendEmailToActiveUsers method
    }

    // Helper method to send an email to all emails in the set
    private void sendEmailToActiveUsers(Set<String> emails){
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>(emails));
            mail.setSubject('Next Step Batch Complete');
            mail.setPlainTextBody('The next step batch has completed.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
            System.debug('Error sending email: ' + e.getMessage());
        }
        
    }
}