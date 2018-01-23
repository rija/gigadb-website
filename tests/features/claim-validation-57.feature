Feature: Upon receiving email with dataset claim, a submitter to validate the claim
	As a submitter of dataset "/dataset/100002"
	I want to receive an notification when another gigadb user claim authorship on that dataset
	So that I can validate or invalidate the claim

Background:
	Given the Gigadb database is loaded with data from  "gigadb_testdata.sql"
	And the credentials for "default" test users are loaded

Scenario: a dataset submitter to validate a claim to reconcile a dataset author to a gigadb account
	Given I am a submitter of dataset "/dataset/100002"
	And I have received an email asking to validate the reconciliation of author "Zhang, G" with user "user@gigadb.org"
	When I click on the validation link
	Then then an email is sent to the curators notifying of claim validation and requesting approval
	And an email is sent to the claimant notifying of validation of the claim and waiting for approval


Scenario: a dataset submitter to invalidate a claim to reconcile a dataset author to a gigadb account
	Given I am a submitter of dataset "/dataset/100002"
	And I have received an email asking to validate the reconciliation of author "Zhang, G" with user "user@gigadb.org"
	When I click on the invalidation link
	Then then an email is sent to the curators notifying them that the claim is invalid
	And an email is sent to the claimant notifying of invalidation of the claim


