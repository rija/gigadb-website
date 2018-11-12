<?php

namespace GigaDB\Tests\UnitTests;


/**
 * Unit tests for UserIdentity class
 *
 * @author Rija Menage <rija+git@cinecinetique.com>
 * @license GPL-3.0
 */
class UserIdentityTest extends \PHPUnit_Framework_TestCase
{


	public function testAuthenticateStrongHashedValidPasswordAndActiveUser()
	{
		$visiting_user = new \User();
		$visiting_user->username = "author@gigadb.org";
		$visiting_user->password = "correct horse battery staple";
		$userIdentity = new \UserIdentity($visiting_user->username,$visiting_user->password);
		$this->assertTrue($userIdentity->authenticate());
		$this->assertEquals(\UserIdentity::ERROR_NONE, $userIdentity->errorCode);
	}



}
?>
