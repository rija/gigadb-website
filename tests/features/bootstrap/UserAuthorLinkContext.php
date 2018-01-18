<?php

use Behat\Behat\Context\BehatContext;

class UserAuthorLinkContext extends BehatContext
{
    public function __construct(array $parameters)
    {

    }


    /**
     * @BeforeSuite
     */
    public static function initialize_databaes()
    {
        print_r("Recreating the database... ");
        exec("vagrant ssh -c \"sudo -Hiu postgres /usr/bin/psql < /vagrant/sql/kill_drop_recreate.sql\"",$kill_output);
        // var_dump($kill_output);
        print_r("Loading test data... ");
        exec("vagrant ssh -c \"sudo -Hiu postgres /usr/bin/psql gigadb < /vagrant/sql/gigadb_testdata.sql\"",$load_output);
        // var_dump($load_output);
    }

}
