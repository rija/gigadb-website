<?php
 /**
 * Test FiledropService to invoke on FUW REST APU the creation of filedrop account
 *
 *
 * @author Rija Menage <rija+git@cinecinetique.com>
 * @license GPL-3.0
*/

use GuzzleHttp\Client;
use GuzzleHttp\HandlerStack;
use GuzzleHttp\Middleware;

class FiledropServiceTest extends FunctionalTesting
{

    use BrowserSignInSteps;
    use BrowserPageSteps;
    use CommonDataProviders;

    /**
     *
     * @uses \BrowserSignInSteps::loginToWebSiteWithSessionAndCredentialsThenAssert()
     */
    public function setUp()
    {
        parent::setUp();

        //admin user is logged to gigadb
        $this->loginToWebSiteWithSessionAndCredentialsThenAssert("admin@gigadb.org","gigadb","Admin");

    }

    public function testCreateAccountMakeAuthenticatedCall()
    {
        $api_endpoint = "http://fuw-admin-api/filedrop-accounts";
        $doi = "101001";
        $jwt_ttl = 31104000 ;

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
                                  'jwtTTL' => $jwt_ttl,
                                  'jwtBuilder' => Yii::$app->jwt->getBuilder(),
                                  'jwtSigner' => new \Lcobucci\JWT\Signer\Hmac\Sha256(),
                                  'users' => new UserDAO(),
                                  'dt' => new DateTime(),
                                ]),
            "webClient" => $webClient,
            "requester" => \User::model()->findByPk(344), //admin user
            "identifier"=> $doi,
            "dryRunMode"=>false,
            ]);

        // set the right status on the dataset
        Dataset::model()->updateAll(["upload_status" => "AssigningFTPbox"], "identifier = :doi", [":doi" => $doi]);

        // invoke the Filedrop Service
        $filedropSrv->createAccount();

        // test an authenticated HTTP call was actually made to the API
        $this->assertTrue(1 == count($container));
        $this->assertTrue("POST" == $container[0]['request']->getMethod());
        $this->assertTrue($api_endpoint == $container[0]['request']->getUri());
        $this->assertFalse(401 == $container[0]['response']->getStatusCode());
        $this->assertFalse(403 == $container[0]['response']->getStatusCode());

        // test the response is successful
        $this->assertEquals(201, $container[0]['response']->getStatusCode());

        // test that we are on the admin page after invocation of the action
        // $this->assertEquals( "http://gigadb.dev/adminDataset/admin", $this->getCurrentUrl() );

        // restore original upload status
        Dataset::model()->updateAll(["upload_status" => "Published"], "identifier = :doi", [":doi" => $doi]);
    }

    public function testCreateAccountWithNonAdminUser()
    {
        $api_endpoint = "http://fuw-admin-api/filedrop-accounts";
        $doi = "000009";
        $jwt_ttl = 31104000 ;

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
                                  'jwtTTL' => $jwt_ttl,
                                  'jwtBuilder' => Yii::$app->jwt->getBuilder(),
                                  'jwtSigner' => new \Lcobucci\JWT\Signer\Hmac\Sha256(),
                                  'users' => new UserDAO(),
                                  'dt' => new DateTime(),
                                ]),
            "webClient" => $webClient,
            "requester" => \User::model()->findByPk(345),
            "identifier"=> $doi,
            "dryRunMode"=>true,
            ]);

        // invoke the Filedrop Service
        try {

            $success = $filedropSrv->createAccount();
        }
        catch(Exception $e) {
            // echo \GuzzleHttp\Psr7\str($e->getRequest());
        }

        // test an authenticated HTTP call was not actually made to the API
        $this->assertTrue(0 == count($container));
        $this->assertFalse($success);

    }

    public function testCreateAccountWithWrongStatus()
    {
        $api_endpoint = "http://fuw-admin-api/filedrop-accounts";
        $doi = "100004";
        $jwt_ttl = 31104000 ;

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
                                  'jwtTTL' => $jwt_ttl,
                                  'jwtBuilder' => Yii::$app->jwt->getBuilder(),
                                  'jwtSigner' => new \Lcobucci\JWT\Signer\Hmac\Sha256(),
                                  'users' => new UserDAO(),
                                  'dt' => new DateTime(),
                                ]),
            "webClient" => $webClient,
            "requester" => \User::model()->findByPk(344),
            "identifier"=> $doi,
            "dryRunMode"=>true,
            ]);

        // invoke the Filedrop Service
        $success = $filedropSrv->createAccount();

        // test an authenticated HTTP call was not actually made to the API
        $this->assertTrue(0 == count($container));
        $this->assertFalse($success);

    }

}

?>