@issue-49 @merging-two-authors @javascript
Feature: Merging duplicate authors
	In order to reduce data duplication and to increase datasets interlinking
	As an admin user
	I want to merge author records that are identical

Background:
	Given Gigadb web site is loaded with "gigadb_testdata.sql" data
	And default admin user exists
	When I go to "/dataset/100002"
	Then I should see "Genomic data from Adelie penguin (Pygoscelis adeliae)"

Scenario: On author edit form, there is a button to start the merging with another author
	Given I sign in as an admin
	When I go to "/adminAuthor/update/id/3791"
	Then I should see "Merge with an author"

Scenario: Presssing the merge an author button leads to author table and then merging of an author
	Given I sign in as an admin
	And I am on "/adminAuthor/update/id/3791"
	When I follow "Merge with an author"
	And I wait "2" seconds
	And I click on the row for author id "3794"
	And I wait "1" seconds
	And A dialog box reads "Confirm merging these two authors?"
	And I should see "Zhang Guojieuojie"
	And I should see "Lambert David M"
	And I should see "ORCID: n/a"
	And I should see "ORCID: 0000-0002-5486-853Z"
	And I follow "Yes, merge with selected author"
	And I wait "1" seconds
	Then I should be on "/admin/Author/view/id/3791"
	And I should see "this author is merged with author(s)"
	And I should see "Pan S (3794)"

Scenario: Abort a merge from the popup confirmation box
	Given I sign in as an admin
	And I am on "/adminAuthor/update/id/3791"
	When I follow "Merge with an author"
	And I wait "2" seconds
	And I click on the row for author id "3794"
	And I wait "1" seconds
	And A dialog box reads "Confirm merging Zhang Guojie with Pan S ?"
	And I follow "No, abort merging"
	And I wait "1" seconds
	Then I should be on "/admin/Author/view/id/3791"
	And I should not see "this author is merged with author(s)"


Scenario: There is an unmerge button to disconnect two authors from an author edit form
	Given author "3791" is merged with author "3794"
	And I sign in as an admin
	When I go to "/adminAuthor/update/id/3791"
	Then I should see "this author is merged with author(s):"
	And I should see "3794"
	And I should see "Unmerge"

Scenario: Cannot merge an author with himself
	Given I sign in as an admin
	And I am on "/adminAuthor/update/id/3791"
	When I follow "Merge with an author"
	And I wait "2" seconds
	And I click on the row for author id "3791"
	And I wait "1" seconds
	And A dialog box reads "Confirm merging Zhang Guojie with Pan S ?"
	And I follow "Yes, merge with selected author"
	Then I should see "Cannot merge with self. Choose another author to merge with"

Scenario: If exists (A1 identical_to A4), A4 view shows link to A1
	Given author "3791" is merged with author "3794"
	And I sign in as an admin
	When I go to "/adminAuthor/view/id/3794"
	Then I should see "this author is merged with author(s):"
	Then I should see "Zhang Guojie (3791)"

Scenario: If exists (A1 identical_to A4), attempt to merge A4 with A1 should not be possible
	Given author "3791" is merged with author "3794"
	And I sign in as an admin
	When I go to "/adminAuthor/update/id/3794"
	When I follow "Merge with an author"
	And I wait "2" seconds
	And I click on the row for author id "3791"
	And I wait "1" seconds
	Then A dialog box reads "Confirm merging Zhang Guojie with Pan S ?"
	And I follow "Yes, merge with selected author"
	Then I should see "Authors already merged. Choose another author to merge with"


Scenario: If exists (A1 identical_to A4), on A4 edit form: shows link to A1 and unmerge button
	Given author "3791" is merged with author "3794"
	And I sign in as an admin
	When I go to "/adminAuthor/update/id/3794"
	Then I should see "this author is merged with author(s):"
	Then I should see "Zhang Guojie (3791)"
	And I should see "Unmerge"


Scenario: If exists (A1 i_t A2), (A1 i_t A3) and (A2 i_t A5), on A1 view: a graph of merged authors is shown properly
	Given author "3791" is merged with author "3792"
	And author "3791" is merged with author "3793"
	And author "3792" is merged with author "3795"
	And I sign in as an admin
	When I go to "/adminAuthor/view/id/3791"
	Then I should see "this author is merged with author(s):"
	Then I should see "3792"
	Then I should see "3793"
	Then I should see "3795"

Scenario: If exists (A1 i_t A2), (A1 i_t A3) and (A2 i_t A5), a graph of merged authors is shown properly on A5
	Given author "3791" is merged with author "3792"
	And author "3791" is merged with author "3793"
	And author "3792" is merged with author "3795"
	And I sign in as an admin
	When I go to "/adminAuthor/view/id/3795"
	Then I should see "this author is merged with author(s):"
	Then I should see "3791"
	Then I should see "3792"
	Then I should see "3793"

Scenario: If exists (A1 i_t A2), (A1 i_t A3) and (A2 i_t A5), on A1 edit form: shows links and an unmerge button
	Given author "3791" is merged with author "3792"
	And author "3791" is merged with author "3793"
	And author "3792" is merged with author "3795"
	And I sign in as an admin
	When I go to "/adminAuthor/update/id/3791"
	Then I should see "this author is merged with author(s):"
	And I should see "3792"
	And I should see "3793"
	And I should see "3795"
	And I should see "Unmerge"


Scenario: If exists (A1 i_t A2), (A1 i_t A3) and (A2 i_t A5), on A5 edit form: shows links and an unmerge button
	Given author "3791" is merged with author "3792"
	And author "3791" is merged with author "3793"
	And author "3792" is merged with author "3795"
	And I sign in as an admin
	When I go to "/adminAuthor/update/id/3795"
	Then I should see "this author is merged with author(s):"
	And I should see "3791"
	And I should see "3792"
	And I should see "3793"
	And I should see "Unmerge"


Scenario: If exists (A1 i_t A2), (A1 i_t A3) and (A2 i_t A5), on A3 edit form, pressing unmerge removes A3 from graph
	Given author "3791" is merged with author "3792"
	And author "3791" is merged with author "3793"
	And author "3792" is merged with author "3795"
	And I sign in as an admin
	When I go to "/adminAuthor/update/id/3793"
	And I follow "Unmerge"
	And I wait "2" seconds
	Then I should be on "/adminAuthor/view/id/3793"
	And I should not see "3791"
	And I should not see "3792"
	And I should not see "3795"
	And I should not see "Unmerge"


