<?php

use Behat\Behat\Context\Context;
use Behat\Behat\Hook\Scope\BeforeScenarioScope;
use Behat\Gherkin\Node\TableNode;

/**
 * Contains the steps definitions used in author-names.feature and name-preview.feature
 *
 *
 * @author Rija Menage <rija+git@cinecinetique.com>
 * @license GPL-3.0
 * @see http://docs.behat.org/en/latest/quick_start.html#defining-steps
 *
 * @uses GigadbWebsiteContext For loading production like data
 */
class DatasetViewContext implements Context
{
    private $surname = null;
    private $first_name = null;
    private $middle_name =  null;


    /**
     * @var GigadbWebsiteContext
     */
    private $gigadbWebsiteContext;
    private $minkContext;

    /**
     * The method to retrieve needed contexts from the Behat environment
     *
     * @param BeforeScenarioScope $scope parameter needed to retrieve contexts from the environment
     *
     * @BeforeScenario
     *
    */
    public function gatherContexts(BeforeScenarioScope $scope)
    {
        $environment = $scope->getEnvironment();

        $this->gigadbWebsiteContext = $environment->getContext('GigadbWebsiteContext');
        $this->minkContext = $environment->getContext('Behat\MinkExtension\Context\MinkContext');
    }

    /**
     * @Given /^Gigadb web site is loaded with production-like data$/
     */
    public function gigadbWebSiteIsLoadedWithProductionLikeData()
    {
        $sqlfile = "production_like.pgdmp";
        // return array(
        //     new Step\Given("Gigadb web site is loaded with \"${sqlfile}\" data"),
        // );
        $this->gigadbWebsiteContext->gigadbWebSiteIsLoadedWithData($sqlfile);
    }

    /**
     * @Given /^author has surname "([^"]*)"$/
     */
    public function authorHasSurname($arg1)
    {
        $this->surname = $arg1 ;
    }

    /**
     * @Given /^author has first name "([^"]*)"$/
     */
    public function authorHasFirstName($arg1)
    {
        $this->first_name = $arg1 ;
    }

    /**
     * @Given /^author has middle name "([^"]*)"$/
     */
    public function authorHasMiddleName($arg1)
    {
        $this->middle_name = $arg1 ;
    }



    /**
     * Ensure name fields are reset before scenario run for author-names.feature and name-preview.feature
     *
     * @BeforeScenario @author-names-display&&@edit-display-name
     */
    public function reset()
    {
        $this->surname = null;
        $this->first_name = null;
        $this->middle_name = null;
    }


    /**
     * @Then I should see all the authors with links
     */
    public function iShouldSeeAllTheAuthorsWithLinks(TableNode $table)
    {
        foreach($table as $row) {
            $this->minkContext->getSession()->getPage()->findLink($row['Author']);
        }
    }

    /**
     * @Then I should see links to all associated peer-reviewed publications
     */
    public function iShouldSeeLinksToAllAssociatedPeerReviewedPublications(TableNode $table)
    {
        foreach($table as $row) {
            $this->minkContext->getSession()->getPage()->findLink($row['Publications']);
        }
    }

    /**
     * @Then I should see links to all the projects
     */
    public function iShouldSeeLinksToAllTheProjects(TableNode $table)
    {
        foreach($table as $row) {
            $this->minkContext->getSession()->getPage()->findLink($row['Projects']);
        }
    }




}
