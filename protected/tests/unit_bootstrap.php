<?php

// change the following paths if necessary
$yiit=__DIR__.'/../yiit.php';
$config=dirname(__FILE__).'/../config/test.php';
$composer=dirname(__FILE__)."/../../vendor/autoload.php";

require_once($yiit);
require_once($composer);

# Load the modified root class for Yii1.1/Yii2.0
$yii=dirname(__FILE__).'/../components/Yii.php';
require_once($yii);

# load Yii 2 (but don't run the web application)
$yii2Config = require(__DIR__ . '/../config/yii2/web.php');
new yii\web\Application($yii2Config);

Yii::$enableIncludePath = false;
Yii::createWebApplication($config);
