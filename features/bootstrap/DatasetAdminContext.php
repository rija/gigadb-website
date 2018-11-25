<?php

use Behat\Behat\Context\Context;
use Behat\Behat\Hook\Scope\BeforeScenarioScope;
use Behat\Gherkin\Node\TableNode;

/**
 * Contains the steps definitions used in dataset-admin.feature
 *
 *
 * @author Rija Menage <rija+git@cinecinetique.com>
 * @license GPL-3.0
 * @see http://docs.behat.org/en/latest/quick_start.html#defining-steps
 *
 * @uses GigadbWebsiteContext For loading production like data
 */
class DatasetAdminContext implements Context
{
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
     * @Then I should see a form element labelled :arg1
     */
    public function iShouldSeeAFormElementLabelled2($arg1)
    {

        // $this->minkContext->assertSession()->fieldExists($arg1);
        PHPUnit_Framework_Assert::assertTrue(
            $this->minkContext->getSession()->getPage()->hasField($arg1)
        );
    }

    /**
     * @Then I should see a button input :arg1
     */
    public function iShouldSeeAButtonInput($arg1)
    {
        PHPUnit_Framework_Assert::assertTrue(
            $this->minkContext->getSession()->getPage()->hasButton($arg1)
        );
    }

    /**
     * @Then I should see element :arg1's content changing from :arg2 to :arg3
     */
    public function iShouldSeeElementSContentChangingFromTo($arg1, $arg2, $arg3)
    {
        $this->minkContext->getSession()->wait(10000, "($('$arg1').html() != '$arg2' )");
        PHPUnit_Framework_Assert::assertTrue(
            $this->minkContext->getSession()->getPage()->hasContent($arg3)
        );
    }

}
