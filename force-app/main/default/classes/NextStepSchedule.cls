/*
 * NextStepSchedule Class Description:
 * 
 * The NextStepSchedule class is tailored to schedule the execution of the NextStepBatch class in Salesforce.
 * By implementing the Schedulable interface, it allows administrators or developers to define specific intervals at which the batch job should run, automating the process of updating the Next Step field for Account and Opportunity objects.
 * 
 */
public with sharing class NextStepSchedule implements Schedulable {

    /*
     * Update/Uncomment the template code to create a method
     * Execute the batch job NextStepBatch using the Database.executeBatch method
     * Configure and schedule the job using the Apex Scheduler in Salesforce Setup
     * Code to execute the batch job should not need to change other than uncommenting the code
     */
    public void execute(SchedulableContext sc) {
        // Create an instance of the NextStepBatch class
        NextStepBatch batchJob = new NextStepBatch();
        // Execute the batch job
        Database.executeBatch(batchJob);
    }
}