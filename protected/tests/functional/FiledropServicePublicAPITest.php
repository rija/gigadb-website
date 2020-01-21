<?php
 /**
 * Test FiledropService to interact with FUW's public REST API
 *
 *
 * @author Rija Menage <rija+git@cinecinetique.com>
 * @license GPL-3.0
*/

use GuzzleHttp\Client;
use GuzzleHttp\HandlerStack;
use GuzzleHttp\Middleware;

class FiledropServicePublicAPITest extends FunctionalTesting
{

    use BrowserSignInSteps;
    use BrowserPageSteps;
    use CommonDataProviders;
    use DatabaseSteps;

    /** @var PDO $dbhf DB handle to FUW database connection */
    private $dbhf;

    /** @var array $uploads list of uploaded files */
    private $uploads;

    /** @var Object $account file drop account */
    private $account;

    /**
     *
     * @uses \BrowserSignInSteps::loginToWebSiteWithSessionAndCredentialsThenAssert()
     */
    public function setUp()
    {
        parent::setUp();

        //admin user is logged to gigadb
        $this->loginToWebSiteWithSessionAndCredentialsThenAssert("admin@gigadb.org","gigadb","Admin");

        //test filedrop account doesn't exist in db
        $filedrop_id = 435342;
        $db_name = getenv("FUW_DB_NAME");
        $db_user = getenv("FUW_DB_USER");
        $db_password = getenv("FUW_DB_PASSWORD");
        $this->dbhf=new CDbConnection("pgsql:host=database;dbname=$db_name",$db_user,$db_password);
        $this->dbhf->active=true;
        $delete_account = $this->dbhf->createCommand("delete from filedrop_account where id=$filedrop_id");
        $delete_account->execute();

    }

    public function tearDown()
    {
        $datasetDAO = new DatasetDAO(["identifier" => '100004']) ;
        $this->tearDownUserIdentity(
            $this->dbhf->pdoInstance,
            $datasetDAO->getSubmitter()->email
        );
        $this->dbhf->active=false;
        $this->dbhf = null;
        $datasetDAO = null;
        parent::tearDown();
    }

    /**
     * Test retrieving existing uploaded files from the API
     *
     * Happy path
     */
    public function testGetUploads()
    {

        // create a filedrop acccount
        $doi = "100004";
        $this->account = $this->setUpFiledropAccount(
            $this->dbhf->getPdoInstance(), $doi
        );

        // create file uploads associated with that account
        $files =  [
                ["doi" => "$doi", "name" =>"somefile.txt", "size" => 325352, "status"=> 0, "location" => "ftp://foobar", "description" => "", "extension" => "TEXT", "datatype"=>"Text"],
                ["doi" => "$doi", "name" =>"anotherfile.png", "size" => 5463434, "status"=> 0, "location" => "ftp://barfoo", "description" => "", "extension" => "PNG", "datatype"=>"Image"],
            ];
        $this->uploads = $this->setUpFileUploads(
            $this->dbhf->getPdoInstance(), $files
        );

        // Prepare the http client to be traceable for testing

        $container = [];
        $history = Middleware::history($container);

        $stack = HandlerStack::create();
        // Add the history middleware to the handler stack.
        $stack->push($history);

        $webClient = new Client(['handler' => $stack]);

        // Instantiate FiledropService
        $filedropSrv = new FiledropService([
            "tokenSrv" => new TokenService([
                                  'jwtTTL' => 31104000,
                                  'jwtBuilder' => Yii::$app->jwt->getBuilder(),
                                  'jwtSigner' => new \Lcobucci\JWT\Signer\Hmac\Sha256(),
                                  'users' => new UserDAO(),
                                  'dt' => new DateTime(),
                                ]),
            "webClient" => $webClient,
            "requester" => \User::model()->findByPk(344), //admin user
            "identifier"=> $doi,
            "dataset" => new DatasetDAO(["identifier" => $doi]),
            "dryRunMode"=> false,
            ]);

        // invoke the Filedrop Service
        $response = $filedropSrv->getUploads($doi);

        // test the response from the API is successful
        $this->assertEquals(200, $container[0]['response']->getStatusCode());

        // test that getUploads return a value
        $this->assertNotNull($response);

        // and that it's an array of files
        // $this->assertEquals(2, count($response));

        // remove the account and the files from database
        $this->tearDownFiledropAccount(
            $this->dbhf->getPdoInstance(),
            $this->account
        );

        $this->tearDownFileUploads(
            $this->dbhf->getPdoInstance(),
            $this->uploads
        );

    }

}

?>