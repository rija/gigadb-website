<?php
/**
 * This action will load the metadata form
 *
 * URL: /authorisedDataset/filesAnnotate/100006
 *
 *
 * @author Rija Menage <rija+git@cinecinetique.com>
 * @license GPL-3.0
 */
class FilesAnnotateAction extends CAction
{

    public function run($id)
    {
        $this->getController()->layout='uploader_layout';
        $webClient = new \GuzzleHttp\Client();

        // Instantiate FileUploadService
        $filedropSrv = new FileUploadService([
            "tokenSrv" => new TokenService([
                                  'jwtTTL' => 3600,
                                  'jwtBuilder' => Yii::$app->jwt->getBuilder(),
                                  'jwtSigner' => new \Lcobucci\JWT\Signer\Hmac\Sha256(),
                                  'users' => new UserDAO(),
                                  'dt' => new DateTime(),
                                ]),
            "webClient" => $webClient,
            "requester" => Yii::app()->user,
            "identifier"=> $id,
            "dataset" => new DatasetDAO(["identifier" => $id]),
            "dryRunMode"=>false,
            ]);

        // Fetch list of uploaded files
        $uploadedFiles = $filedropSrv->getUploads($id);
        // Yii::log("uploadedFiles count: ".count($uploadedFiles),'info');

        $completeSuccess = true;
        if(isset($_POST['Upload']))
        {
            foreach($uploadedFiles as $upload)
            {
                if(isset($_POST['Upload'][$upload['id']])) {
                    $completeSuccess = $completeSuccess && $filedropSrv->updateUpload($upload['id'], $_POST['Upload'][$upload['id']] );
                }
            }
            if ($completeSuccess) {
                Yii::app()->user->setFlash('fileUpload','File uploading complete');
            }
            else {
                Yii::app()->user->setFlash('error','Error with some files');
            }
            $this->getController()->redirect("/user/view_profile#submitted");
        }
        $this->getController()->render("filesAnnotate", array("identifier" => $id, "uploads" => $uploadedFiles));
    }
}

?>