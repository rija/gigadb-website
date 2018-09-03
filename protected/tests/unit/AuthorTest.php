<?php


class AuthorTest extends CDbTestCase
{
    protected $fixtures=array(
        'authors'=>'Author',
        'relationship'=>'Relationship',
        'author_rel'=>'AuthorRel',
    );

	function testOK() {
		$this->assertEquals(true,true,"true is always true");
	}
	


}

?>
