<?php

namespace app\controllers;

use \Yii;
use \yii\helpers\Console;
use \yii\console\Controller;
use \yii\console\ExitCode;
use app\models\DatasetFiles;

/**
 * The tool for updating production database's file table to replace ftp urls
 * @package app\commands
 */
class DatasetFilesController extends Controller
{
    /**
     * @var string $date the yyyymmdd for which to retrieve a production backup
     */
    public string $date;

    /**
     * @var int $next get list of next $next pending datasets
     */
    public int $next = 0;
    /**
     * @var int $after dataset id only pending datasets after this one are returned
     */
    public int $after = 0;

    /**
     * @var bool true if dry run mode is activated, false otherwise (default)
     */
    public bool $dryrun = false;

    /**
     * @var bool if true no attempt will be made to download the production database backup
     */
    public bool $nodownload = false;

    /**
     * @var bool true to show the full audit of transformation
     */
    public bool $verbose = false;

    public function options($actionID)
    {
        // $actionId might be used in subclasses to provide options specific to action id
        return ['color', 'interactive', 'help','date','next','after','dryrun','verbose','nodownload'];
    }

    public function init()
    {
        $this->date ??= date('Ymd') - 1 ;
    }


    /**
     * This command will download and load in database production backup for the given date
     *
     * @throws \Throwable
     * @return int Exit code
     */
    public function actionDownloadRestoreBackup()
    {
        try {
            if(!$this->nodownload) {
                $this->stdout("\nDownloading production backup for {$this->date}\n", Console::BOLD);
                $ftpConfig = \Yii::$app->params['ftp'];
                system("ncftpget -u {$ftpConfig['username']} -p {$ftpConfig['password']} {$ftpConfig['host']} /app/sql/ /gigadbv3_{$this->date}.backup", $downloadStatus);
            }
        }
        catch (Throwable $e) {
            $this->stdout($e->getMessage().PHP_EOL, Console::FG_RED);
            Yii::error($e->getMessage());
            return ExitCode::OSERR;
        }

        $this->stdout("\nRestoring the backup for {$this->date}\n", Console::BOLD);
        try {
            DatasetFiles::reloadDb($this->date);
        }
        catch (Throwable $e) {
            $this->stdout($e->getMessage().PHP_EOL, Console::FG_RED);
            Yii::error($e->getMessage());
            return ExitCode::OSERR;
        }
        return ExitCode::OK;
    }


    /**
     * This command will update file table to replace ftp urls for the supplied list of dataset ids
     *
     *  Usage:
     *      ./yii dataset-files/update-ftp-url --next <batch size> [--after <dataset id>][--dryrun][--verbose]
     * TODO: to implement
     * @throws \Throwable
     * @return int Exit code
     */
    public function actionUpdateFtpUrls()
    {
        //Managing input
        $optNext = $this->next ;
        $optAfter = $this->after;
        $optDryRun = $this->dryrun;
        $optVerbose = $this->verbose;

        //Return usage unless mandatory options are passed
        if(!($optNext)) {
            $this->stdout("\nUsage:\n\t ./yii dataset-files/update-ftp-url --next <batch size> [--after <dataset id>][--dryrun][--verbose]\n\n");
            return ExitCode::USAGE;
        }

        // Prepare logging and audit
        $auditLog = [];

         // Instantiating the model class that holds the business logic
        $df = DatasetFiles::build($optDryRun);

        try {
            $rows = $df->getNextPendingDatasets($optAfter, $optNext);

            if(!$optDryRun && count($rows) > 0 ) {
                $this->stdout("\nWarning! ", Console::FG_RED);
                switch($this->confirm("This command will alter ".count($rows)." datasets in the database, are you sure you want to proceed?\n")) {
                    case false:
                        $this->stdout("Aborting.\n", Console::FG_BLUE);
                        return ExitCode::OK;
                    default:
                        $this->stdout("Executing command...\n", Console::FG_BLUE);
                }
            }
            elseif (!$rows || count($rows) ===  0) {
                $this->stdout("\nThere are no pending datasets with url to replace.\n", Console::FG_BLUE);
                return ExitCode::OK;
            }

            foreach ($rows as $key => $value) {
                $this->stdout("[{$value["dataset_id"]}]",Console::BOLD);
                $nbFiles = $df->queryFilesForDataset($value["dataset_id"])->count();
                $auditLog[$value["dataset_id"]] = ["ftp_site" => [], "location" => []];
                $ftpSiteAudit = [];
                $locationAudit = [];

                $db = \Yii::$app->db;
                $transaction = $db->beginTransaction();
                try{
                    $this->stdout("\tTransforming ftp_site... ");
                    $ftpSiteOutcome = $df->replaceDatasetFTPSite($value["dataset_id"],$ftpSiteAudit);
                    $auditLog[$value["dataset_id"]]["ftp_site"] = $ftpSiteAudit ;
                    if ($ftpSiteOutcome)
                        $this->stdout("DONE", Console::BG_GREEN);
                    else
                        $this->stdout("ERROR", Console::BG_RED);


                    $this->stdout("\n\tTransforming file locations ...", Console::BOLD);
                    $locationOutcome = $df->replaceFilesLocationForDataset($value["dataset_id"], $locationAudit);
                    $auditLog[$value["dataset_id"]]["location"] = $locationAudit ;
                    switch($locationOutcome) {
                        case 0:
                            $this->stdout("FAILURE (0/$nbFiles)", Console::BG_RED);
                            break;
                        case $nbFiles:
                            $this->stdout("DONE ($nbFiles/$nbFiles)", Console::BG_GREEN);
                            break;
                        default:
                            $this->stdout("ERROR ($locationOutcome/$nbFiles)", Console::BG_YELLOW);
                            break;
                    }
                    $this->stdout("\n");

                    $transaction->commit();
                }
                catch(\Throwable $e) {
                    $this->stdout(" ftp_site ERROR", Console::BG_RED);
                    $this->stdout(" location FAILURE (0/$nbFiles)", Console::BG_RED);
                    $this->stdout("\n** Rolling back transaction for dataset of id {$value["dataset_id"]}\n", Console::BG_RED);
                    $transaction->rollBack();
                    throw $e; //we stop the whole run
                }


            }

            if ($optVerbose) {
                $this->stdout("\nDetailed audit log:\n\n", Console::BOLD );

                // ftp_site replacement audit
                $this->stdout("\nftp_site replacement: \n");
                $this->stdout("\ndataset id | old value | new value | Updated\n");
                foreach ($auditLog as $datasetAudit) {
                    $this->stdout(implode(" | ",$datasetAudit["ftp_site"])."\n");
                }

                // location replacement audit
                $this->stdout("\nlocation replacement: \n");
                foreach ($auditLog as $datasetAudit) {
                    $this->stdout("\n[{$datasetAudit['ftp_site']['id']}]\n",Console::BOLD);
                    $this->stdout("\nfile id | old value | new value | Updated\n");
                    foreach($datasetAudit['location'] as $file) {
                        $this->stdout(implode(" | ",$file)."\n");
                    }
                }

            }
        }
        catch (Throwable $e) {
            $this->stdout($e->getMessage().PHP_EOL, Console::FG_RED);
            Yii::error($e->getMessage());
            return ExitCode::OSERR;
        }

        return ExitCode::OK;
    }



}
