Feature: a user can claim his/her datasets
	As a gigadb user,
	I want to mark as my own datasets that I've authored
	So I can manage them

Scenario: Give users a button to claim an author from the author search link
	Given I am logged in as "user@gigadb.org"
	And I have searched for a dataset I have authored
	And I clicked on the author link for my name
	When I am on the result page
	Then I should see a "Is this you? link your account" button


Scenario: a user creates a claim on an author



Scenario: provide submitters a way to validate a user's claim on an author



