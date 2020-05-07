<?php

namespace common\tests\Helper;

use \Codeception\Module\Db;

/**
 * Before/After test hooks for the Db module goes here.
 *
 * Don't put any kind of before/after test hooks here.
 * Instead, subclass the module for which you want to create hooks
 * like here.
 *
 *
 * @author Rija Menage <rija+git@cinecinetique.com>
 * @license GPL-3.0
 */
class DbExtendedWithHooks extends \Codeception\Module\Db
{


    // public function _before(\Codeception\TestInterface $test)
    // {
    //     parent::_before($test);
    //     echo var_dump( $this->_getDbh() );
    //     echo var_dump( $this->getDatabases() );
    // }

    /**
     * HOOK: after each test scenario
     * make sure the fuw database's tables are cleaned of
     * record created during the tests
     * This is made necessary as default send email scenario
     * has now a side effect of adding a new user which
     * the Db module doesn't know how to remote after test run
     * TODO: figure out to have it run only for the scenario in question
    */
    public function _after(\Codeception\TestInterface $test)
    {
    	$this->amConnectedToDatabase('fuwdb');
    	$userCriteria = ['username' => 'joyfox'] ;
        $this->_getDriver()->deleteQueryByCriteria('public.user', $userCriteria);

        $uploadCriteria = ['doi' => '000007'];

        $this->_getDriver()->deleteQueryByCriteria('public.upload', $uploadCriteria);

        $this->_getDriver()->deleteQueryByCriteria('public.user', ["email" => "artie_dodger@gigadb.org"]);

        $this->amConnectedToDatabase(self::DEFAULT_DATABASE);

        $this->_getDriver()->deleteQueryByCriteria('dataset', ["identifier" => "000007"]);
        $this->_getDriver()->deleteQueryByCriteria('dataset', ["identifier" => "000008"]);
        $this->_getDriver()->deleteQueryByCriteria('dataset', ["identifier" => "100006"]);
        $this->_getDriver()->deleteQueryByCriteria('gigadb_user', ["email" => "artie_dodger@gigadb.org"]);
        $this->_getDriver()->deleteQueryByCriteria('gigadb_user', ["email" => "joy_fox@gigadb.org"]);

        parent::_after($test);
    }
}

 ?>