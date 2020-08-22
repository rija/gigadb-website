@view-mockup @mockup
Feature:
	As a Reviewer
	I want to access the privately uploaded files of a submitted dataset
	So that I can download and audit the files and their metadata

Background:
	Given there is a user "Artie" "Dodger"
	And a dataset with DOI "000007" owned by user "Artie" "Dodger" has status "Submitted"
	And filedrop account for DOI "000007" does exist

@ok
Scenario: Can access unique and time-limed url of dataset page showing uploaded files
	Given a mockup url has been created for reviewer "artie_dodger@foobar.com" and dataset with DOI "000007"
	When I browse to the mockup url
	Then I should see "Mockup created for artie_dodger@foobar.com, valid for 1 month"


@ok
Scenario: The page at the unique and time-limed url show dataset info
	Given a mockup url has been created for reviewer "artie_dodger@foobar.com" and dataset with DOI "000007"
	When I browse to the mockup url
	Then I should see "Dataset Fantastic"
	And I should see "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo"


@ok
Scenario: The page at the unique and time-limed url show uploaded files (no sample, attributes)
	Given file uploads have been uploaded for DOI "000007"
	And a mockup url has been created for reviewer "artie_dodger@foobar.com" and dataset with DOI "000007"
	When I browse to the mockup url
	Then I should see the files
	| File Name | Data Type | File Format | Size |
	| seq1.fa | Sequence assembly | FASTA | 23.43 MiB |
	| Specimen.pdf | Annotation | PDF | 19.11 KiB |


@ok
Scenario: The page at the unique and time-limed url show uploaded files and attributes (no sample)
	Given file uploads have been uploaded for DOI "000007"
	And there are file attributes associated with those files
	And a mockup url has been created for reviewer "artie_dodger@foobar.com" and dataset with DOI "000007"
	When I browse to the mockup url
	Then I should see the files
	| File Name | Data Type | File Format | Size | File Attributes (1st) | File Attributes (2nd) |
	| seq1.fa | Sequence assembly | FASTA | 23.43 MiB | Temperature: 45 Celsius | Humidity: 75 |
	| Specimen.pdf | Annotation | PDF | 19.11 KiB | Temperature: 51 Celsius | Humidity: 90 |

@ok
Scenario: The page at the unique and time-limed url show uploaded files with sample column data
	Given file uploads with samples have been uploaded for DOI "000007"
	And a mockup url has been created for reviewer "artie_dodger@foobar.com" and dataset with DOI "000007"
	When I browse to the mockup url
	Then I should see the files
	| File Name | Sample ID | Data Type | File Format | Size |
	| seq1.fa | Sample A, Sample Z | Sequence assembly | FASTA | 23.43 MiB |
	| Specimen.pdf | Sample E | Annotation | PDF | 19.11 KiB |

# Scenario: I can download the drop box file locations from the private mockup dataset page
# 	Given I have a received a link "/dataset/mockup/6ba41e9f81baf4ba2bb6d5ecc3e858b0"
# 	And a set of files has been uploaded to the drop box
# 	And user has filled in metadata for all the files
# 	And the uploaded dataset has status "Submitted"
# 	And I am on "/dataset/mockup/6ba41e9f81baf4ba2bb6d5ecc3e858b0"
# 	When I follow "file1.txt"
# 	Then The "file1.txt" file should be downloaded