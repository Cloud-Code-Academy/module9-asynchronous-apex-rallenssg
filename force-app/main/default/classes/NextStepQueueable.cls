/*
 * NextStepQueueable Class Description:
 * 
 * Implement the Queueable interface to process records asynchronously.
 * This example processes up to 10 accounts at a time.
 * It removes the Next Step from the accounts and related opportunities.
 * Note: The class below contains placeholders for implementing a queueable job to update accounts and opportunities.
 */
public with sharing class NextStepQueueable implements Queueable {
    // Member variable to store the accounts
    private Map<Id,Account> accounts;

    // Constructor to accept the accounts
    public NextStepQueueable(Map<Id,Account> accounts) {
        // Store the accounts in a member variable
        this.accounts = accounts;
    }

    // Method to queue the job
    public static void enqueueJob() {
        // Get 10 accounts with Next Step populated
        List<Account> accts = [SELECT Id, Next_Step__c FROM Account WHERE Next_Step__c != null LIMIT 10];

        // If there are any accounts, queue the job using
        if (!accts.isEmpty())
            Id jobId = System.enqueueJob(new NextStepQueueable(new Map<Id,Account>(accts)));
    }

    /*
     * Update/Uncomment the template code to create a method
     * Method to execute the queueable job
     */
    public void execute(QueueableContext context) {
        // Get the accounts from the member variable
        List<Account> accts = accounts.values();
            // Remove the Next Step using the helper method
        for (Account acct : accts) {
            removeNextStep(acct);
        }
        // Update the accounts
        update accts;

        // Get the opportunities related to the accounts
        List<Opportunity> opps = [SELECT Id, NextStep, AccountId FROM Opportunity WHERE AccountId IN :accounts.keySet() AND NextStep != null];

            // Remove the Next Step using the helper method
        for (Opportunity opp : opps) {
            removeNextStep(opp);
        }

        // Update the opportunities
        update opps;

        // Call the enqueueJob method to queue another job to process more records.
        enqueueJob();
    }

    // Helper method to remove the Next Step
    // Overloaded method to accept an opportunity
    private static void removeNextStep(Opportunity opp) {
        opp.NextStep = null;
    }

    // Helper method to remove the Next Step
    // Overloaded method to accept an account
    private static void removeNextStep(Account acc) {
        acc.Next_Step__c = null;
    }
}