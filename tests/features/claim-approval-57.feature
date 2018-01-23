Feature: admin to manage claims from users to datasets
	As a admin,
	I want to manage claims from gigadb users on dataset authors
	So that legitimate authors can access and manage their datasets on gigadb


Scenario: admins to approve a claim to reconcile a dataset author to a gigadb account
	Given I sign in as an admin
	And I have received an email asking to confirm reconciliation of author "Zhang, G" with user "user@gigadb.org"
	And I have received an email from a dataset submitter validating the claim
	When I click on the approval link from the submitter validation email
	Then the author "Zhang, G" of dataset "/dataset/100002" is associated with Gigadb account of email "user@gigadb.org"



Scenario: admins reject a claim on a dataset author after receiving email from claimant
	Given I sign in as an admin
	And I have received an email asking to confirm reconciliation of author "Zhang, G" with user "user@gigadb.org"
	When I click on the claim rejection link from the reconciliation request email
	Then an email is sent to claimant notifying or rejection of claim
	And an email is sent to submitter notifiying of rejectino of claim

Scenario: admins reject a claim on a dataset author after receiving an validation email from submitter
	Given I sign in as an admin
	And I have received an email asking to confirm reconciliation of author "Zhang, G" with user "user@gigadb.org"
	And I have received an email from a dataset submitter validating the claim
	When I click on the claim rejection link from the submitter validation email
	Then an email is sent to claimant notifying or rejection of claim
	And an email is sent to submitter notifiying of rejectino of claim


Scenario: admins reject a claim on a dataset author after receiving an invalidation email from submitter
	Given I sign in as an admin
	And I have received an email asking to confirm reconciliation of author "Zhang, G" with user "user@gigadb.org"
	And I have received an email from a dataset submitter invalidating the claim
	When I click on the claim rejection link from the submitter invalidation email
	Then an email is sent to claimant notifying or rejection of claim
	And an email is sent to submitter notifiying of rejectino of claim
