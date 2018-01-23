Feature: a curator can fill in user id in an author record
	As a curator,
	I want to connect a user identity to an author record
	So that I can enable gigadb users direct access to the dataset they have authored

Background:
	Given the Gigadb database is loaded with data from  "gigadb_testdata.sql"
	And the credentials for "default" test users are loaded


Scenario: make the connection on the author' form using user's identifier
	Given I sign in as an admin
	When I am on "/adminAuthor/update/id/3791"
	And I fill in "User identity" with "345"
	And press "Save"
	Then the response should contain "User ID"
	And the response should contain "345"
	And I should be on "/adminAuthor/view/id/3791"


# Scenario: make the connection on the author view using user's email
# 	Given I sign in as an admin
# 	When I am on "/adminAuthor/update/id/3791"
# 	And I fill in "User identity" with "user@gigadb.org"
# 	And press "Save"
# 	Then the response should contain "User ID"
# 	And the response should contain "345"
# 	And I should be on "/adminAuthor/view/id/3791"



# Scenario: make the connection on the author view using author's Orcid id
# 	Given I sign in as an admin
# 	And user has ORCID ID "0000-0002-5486-853X"
# 	And author has ORCID ID "0000-0002-5486-853X"
# 	When I am on "/adminAuthor/update/id/3791"
# 	And I press "Resolve ORCID"
# 	And press "Save"
# 	Then the response should contain "User ID"
# 	And the response should contain "345"
# 	And I should be on "/adminAuthor/view/id/3791"


Scenario: attach an author to a user's profile
	Given I sign in as an admin
	When I am on "/user/update/id/345"
	And I fill in "Author Id" with "3791"
	And press "Save"
	Then the response should contain "Author ID"
	And the response should contain "3791"
	And I should be on "/user/view/id/345"
