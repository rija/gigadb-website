<?php

use Yii;
use yii\console\ExitCode;
use \app\models\DatasetFiles;

class DatasetFilesCest {

    public function setUp() {
        # load database schema in test database
        DatasetFiles::reloadDb("20210608", true);
    }

    public function tearDown() {

    }

    public function tryDownloadRestoreBackup(\FunctionalTester $I) {
        $dateStamp = date('Ymd') - 1;

        $I->runShellCommand("./yii dataset-files/download-restore-backup --date $dateStamp");
        $I->canSeeInShellOutput("Downloading production backup for $dateStamp");
        $I->canSeeInShellOutput("Restoring the backup for $dateStamp");
        $I->seeResultCodeIs(Exitcode::OK);

    }

    public function tryUpdateFtpUrlNextAfter(\FunctionalTester $I) {
        $command = Yii::$app->createControllerByID('dataset-files');
        $outcome = $command->run('update-ftp-urls',[
            "next" => 5,
            "after" => 10,
            "dryrun" => true,
        ]);
        $I->assertEquals(Exitcode::OK, $outcome);
    }

    public function tryUsageWhenNoOptions(\FunctionalTester $I)
    {
        $I->runShellCommand("./yii dataset-files/update-ftp-urls", false);
        $I->canSeeInShellOutput("Usage:");
        $I->canSeeInShellOutput("./yii dataset-files/update-ftp-url --next <batch size> [--after <dataset id>][--dryrun][--verbose]");
        $I->canSeeResultCodeIs(Exitcode::USAGE);
    }

    public function tryCommandWithPendingDatasetsProceed(\FunctionalTester $I)
    {
        $I->runShellCommand("echo yes | ./yii dataset-files/update-ftp-urls --next 5");
        $I->canSeeInShellOutput("Warning! This command will alter 5 datasets in the database, are you sure you want to proceed?");
        $I->canSeeInShellOutput("Executing command...");

    }

    public function tryCommandWithPendingDatasetsAbort(\FunctionalTester $I)
    {
        $I->runShellCommand("echo no | ./yii dataset-files/update-ftp-urls --next 5");
        $I->canSeeInShellOutput("Warning! This command will alter 5 datasets in the database, are you sure you want to proceed?");
        $I->canSeeInShellOutput("Aborting.");

    }

    public function tryCommandNoPendingDatasets(\FunctionalTester $I)
    {
        $I->runShellCommand("./yii dataset-files/update-ftp-urls --next 5 --after 99999");
        $I->canSeeInShellOutput("There are no pending datasets with url to replace.");
    }

}