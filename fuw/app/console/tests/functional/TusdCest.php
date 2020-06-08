<?php 

namespace console\tests;

use console\tests\FunctionalTester;
use Yii;
use console\controllers\TusdController;
use common\models\Upload;
use backend\models\FiledropAccount;
use backend\fixtures\FiledropAccountFixture;
use yii\console\ExitCode;

class TusdCest
{
    public function _before(FunctionalTester $I)
    {
    }

    // tests
    public function tryWithSuccessToCreateUploadForFile(FunctionalTester $I)
    {
    	$doi = "300001";

    	$tusdFileManifest = file_get_contents(codecept_data_dir()."tusd.info");

    	$accountId = $I->haveInDatabase('filedrop_account',	[
	        'doi' => $doi,
	        'status' => FiledropAccount::STATUS_ACTIVE,
	    ]);

    	$outcome = Yii::$app->createControllerByID('tusd')->run('upload',[
    		"doi" => $doi, 
    		"json" => $tusdFileManifest,
    		"datafeed_path" => "/app/console/tests/_data",
    		"token_path" => "/app/console/tests/_data",
    	]);

    	$I->assertEquals(Exitcode::OK, $outcome);

		$I->assertEquals(1, Upload::find([
    		"doi" => $doi,
    		"name" => "seq1.fa", 
    		"status" => Upload::STATUS_UPLOADING, 
    		"extension" =>"FASTA",
    		"size" => "117",
    		"initial_md5" => "58e51b8d263ca3e89712c65c4485a8c9",
    		"filedrop_account_id" => $accountId,
    	])->count());

    }

    public function tryCreateUploadForFileFromJSONFile(FunctionalTester $I)
    {
    	$doi = "300001";

    	$accountId = $I->haveInDatabase('filedrop_account',	[
	        'doi' => $doi,
	        'status' => FiledropAccount::STATUS_ACTIVE,
	    ]);

    	$outcome = Yii::$app->createControllerByID('tusd')->run('upload',[
    		"doi" => $doi, 
    		"jsonfile" => codecept_data_dir()."tusd.info",
    		"datafeed_path" => "/app/console/tests/_data",
    		"token_path" => "/app/console/tests/_data",
    	]);

    	$I->assertEquals(Exitcode::OK, $outcome);

		$I->assertEquals(1, Upload::find([
    		"doi" => $doi,
    		"name" => "seq1.fa", 
    		"status" => Upload::STATUS_UPLOADING, 
    		"extension" =>"FASTA",
    		"size" => "117",
    		"initial_md5" => "58e51b8d263ca3e89712c65c4485a8c9",
    		"filedrop_account_id" => $accountId,
    	])->count());    	
    }

    public function tryWithDefaultOptions(FunctionalTester $I)
    {
    	$controller = Yii::$app->createControllerByID('tusd');
    	$I->assertEquals("/var/www/files/data/", $controller->datafeed_path);
    	$I->assertEquals("/var/private", $controller->token_path);
    	$I->assertNull($controller->doi);
    	$I->assertNull($controller->json);

    }
}
