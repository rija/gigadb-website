<?php

/**
 * Service to manage JSON Web Token used to authenticate
 * to File Upload Wizard API
 *
 *
 * @property string $jwtKey private key for signing JSON Web Tokens
 * @property string $jwtTTL time validity for the JSON Web Tokens
 * @property \Lcobucci\JWT\Builder $jwtBuilder JSON Web Token builder library
 * @property UserDAO $users finders for acessing User data
 * @property DateTime $dt DateTime object for time calculation
 *
 * @author Rija Menage <rija+git@cinecinetique.com>
 * @license GPL-3.0
 */
class TokenService extends yii\base\Component
{

	public $jwtKey;
	public $jwtTTL;
	public $jwtBuilder;
	public $jwtSigner;
	public $users;
	public $dt;

	/**
	 * Initializes the application component.
	 * This method overrides the parent implementation by setting default cache key prefix.
	 */
	public function init()
	{
		parent::init();

	}

	/**
	 * Generate JWT token for a user
	 *
	 * @param string $email the email of the user to lookup and generate a token for
	 * @return \Lcobucci\JWT\Token the signed token
	 */
	public function generateTokenForUser(string $email): \Lcobucci\JWT\Token
	{
		$user = $this->users->findByEmail($email);
		$signer = $this->jwtSigner;
		$startTime = $this->dt->modify("+60 seconds")->format('U');
		$expiryTime = $this->dt->modify("+{$this->jwtTTL} seconds")->format('U');
		$client_token = $this->jwtBuilder
            ->setIssuer('www.gigadb.org') // Configures the issuer (iss claim)
            ->setAudience('fuw.gigadb.org') // Configures the audience (aud claim)
            ->setSubject('Access to FUW API') // Configures the subject
            ->setId('4f1g23a12aa', true) // Configures the id (jti claim), replicating as a header item
            ->set('email', $email)
            ->set('name', $user->getFullName())
            ->set('role', $user->getRole())
            ->setIssuedAt(time()) // Configures the time that the token was issue (iat claim)
            ->setNotBefore($startTime) // Configures the time before which the token cannot be accepted (nbf claim)
            ->setExpiration($expiryTime) // Configures the expiration time of the token (exp claim) 1 year
            ->sign($signer, Yii::$app->jwt->key)// creates a signature using [[Jwt::$key]]
            ->getToken(); // Retrieves the generated token

		return $client_token;
	}

}
?>