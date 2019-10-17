<?php

	require 'lib/db.php';

    $appconfig = parse_ini_file("/app/proto/appconfig.ini");
    $web_endpoint = $appconfig["web_endpoint"];
    $api_endpoint = $appconfig["api_endpoint"];
    $jwt_token = $appconfig["dummy_jwt_token"];


	$thisurl = parse_url($_SERVER['REQUEST_URI']);
	parse_str($thisurl["query"], $params);

	// pass the JWT token
	$headers = [ "Authorization: Bearer $jwt_token"];

	//
	// A very simple PHP example that sends a HTTP POST to a remote site
	//

	$ch = curl_init();

	curl_setopt($ch, CURLOPT_URL, $api_endpoint);
	curl_setopt($ch, CURLOPT_POST, true);
	curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
	curl_setopt($ch, CURLOPT_POSTFIELDS,
	            "doi=${params['d']}");

	// In real life you should use something like:
	// curl_setopt($ch, CURLOPT_POSTFIELDS, 
	//          http_build_query(array('postvar1' => 'value1')));

	// Receive server response ...
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

	$server_output = curl_exec($ch);
	$server_errno = curl_errno($ch);

	if($server_errno)
	{
	    $server_error = curl_error($ch);
	    error_log("Error communicating with the REST API: $server_error");
	    error_log($server_output);
	}
	else {
		error_log($server_output);
	}
	curl_close ($ch);

	// var_dump($server_output);
?>
<!DOCTYPE html>
<html>
<head>
	<title>Prototype of File Upload Wizard (Create drop box)</title>
</head>
<body>
	<nav><a href="<?= $web_endpoint ?>">[Go back to Dashboard]</a></nav>
	<?
		if (false === $server_output) {
			echo "<p><b>Failed: <b> $server_error ($server_errno)</p>";
		}
		else {
			echo "<p><b>Success<b></p>";
		}
	 ?>
</body>
</html>