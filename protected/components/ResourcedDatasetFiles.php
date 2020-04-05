<?php
/**
 * DAO class to retrieve the files associated to a dataset from a REST API
 *
 *
 * @param int $id of the dataset for which to retrieve the information
 * @param CDbConnection $dbConnection The database connection object to interact with the database storage
 * @author Rija Menage <rija+git@cinecinetique.com>
 * @license GPL-3.0
 */
class ResourcedDatasetFiles extends DatasetComponents implements DatasetFilesInterface
{
	/** @var DB id of the dataset record for wich to retrieve files */
	private $_id;
	/** @var $_db database connnection handler for resolving DOI<->ID */
	private $_db;
	/** @var $_fuwClient GigaDB client to connect to FUW REST API to get the files */
	private $_fuwClient;

	public function __construct (int $dataset_id, CDbConnection $dbConnection, FileUploadService $fuwClient)
	{
		parent::__construct();
		$this->_id = $dataset_id;
		$this->_db = $dbConnection;
		$this->_fuwClient = $fuwClient;
	}

	/**
	 * return the dataset id
	 *
	 * @return int
	 */
	public function getDatasetId(): int
	{
		return $this->_id;
	}

	/**
	 * return the dataset identifier (DOI)
	 *
	 * @return string
	 */
	public function getDatasetDOI(): string
	{
		return $this->getDOIfromId($this->_db, $this->_id);
	}

	/**
	 * retrieve files from REST API
	 *
	 * @return array of files array maps
	 */
	public function getDatasetFiles(): array
	{
		// convert the FUW upload record to a GigaDB record
		$uploadToFile = function ($upload) {
			$file=[];
			$file["id"] = null;
			$file["dataset_id"] = $this->_id;
			$file["name"] = $upload["name"];
			$file["location"] = $upload["location"];
			$file["extension"] = strtolower(pathinfo($upload["name"], PATHINFO_EXTENSION));
			$file["size"] = $upload["size"];
			$file["description"] = $upload["description"];
			$file["format"] = $upload["extension"];
			$file["type"] = $upload["datatype"];
			$file["date_stamp"] = $upload["updated_at"];
			$file["file_attributes"] = []; //TODO
			return $file;
		};

        // Fetch list of uploaded files
        $uploadedFiles = $this->_fuwClient->getUploads($this->getDatasetDOI());

        $datasetFiles = array_map($uploadToFile, $uploadedFiles);
		return $datasetFiles;
		
	}

	public function getDatasetFilesSamples(): array
	{
		return [];
	}


}

?>