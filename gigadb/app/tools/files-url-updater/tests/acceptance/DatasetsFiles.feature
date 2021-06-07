Feature: Want to download dataset files from the website
  As a website user
  I want to download from GigaDB website the files associated with a dataset
  So that I can do my work

  Scenario: basic configuration
    Given the tool is configured
    When I run the command "./yii dataset-files/download-restore-backup" with options "--help"
    Then I should see "--date: string"

  Scenario: Default path
    Given there are files attached to datasets:
      | dataset.identifier | file.location | dataset.ftp_site |
      | 100373 | ftp://ftp.cngb.org/pub/gigadb/pub/10.5524/100001_101000/100373/vcf/bb_snp.vcf.gz | ftp://parrot.genomics.cn/gigadb/pub/10.5524/100001_101000/100373/ |
      | 100373 | ftp://ftp.cngb.org/pub/gigadb/pub/10.5524/100001_101000/100373/readme.txt | ftp://parrot.genomics.cn/gigadb/pub/10.5524/100001_101000/100373/ |
      | 100891 | ftp://parrot.genomics.cn/gigadb/pub/10.5524/100001_101000/100891/readme_100891.txt | ftp://parrot.genomics.cn/gigadb/pub/10.5524/100001_101000/100891/ |
      | 100891 | ftp://parrot.genomics.cn/gigadb/pub/10.5524/100001_101000/100891/MesKit-master.zip | ftp://parrot.genomics.cn/gigadb/pub/10.5524/100001_101000/100891/ |
      | 100633 | ftp://ftp.ebi.ac.uk/pub/databases/reference_proteomes/previous_releases/qfo_release-2011_04/2011_04_reference_proteomes.tar.gz | ftp://parrot.genomics.cn/gigadb/pub/10.5524/100001_101000/100633/ |
      | 100633 | https://figshare.com/s/19a006d6fea9c2494ab8 | ftp://parrot.genomics.cn/gigadb/pub/10.5524/100001_101000/100633/ |
      | 100633 | ftp://parrot.genomics.cn/gigadb/pub/10.5524/100001_101000/100633/readme_100633.txt | ftp://parrot.genomics.cn/gigadb/pub/10.5524/100001_101000/100633/ |
    When I run the update script on datasets:
      | dataset.identifier |
      | 100373 |
      | 100891 |
      | 100633 |
    And I navigate to the dataset pages:
      | dataset.identifier |
      | 100373 |
      | 100891 |
      | 100633 |
    Then I see in the respective files tab:
      | dataset.identifier | file.location | dataset.ftp_site |
      | 100373 | https://ftp.cngb.org/pub/gigadb/pub/10.5524/100001_101000/100373/vcf/bb_snp.vcf.gz |  https://ftp.cngb.org/pub/gigadb/pub/10.5524/100001_101000/100373/ |
      | 100373 | https://ftp.cngb.org/pub/gigadb/pub/10.5524/100001_101000/100373/readme.txt | https://ftp.cngb.org/pub/gigadb/pub/10.5524/100001_101000/100373/ |
      | 100891 | https://ftp.cngb.org/pub/gigadb/pub/10.5524/100001_101000/100891/readme_100891.txt | https://ftp.cngb.org/pub/gigadb/pub/10.5524/100001_101000/100891/ |
      | 100891 | https://ftp.cngb.org/pub/gigadb/pub/10.5524/100001_101000/100891/MesKit-master.zip | https://ftp.cngb.org/pub/gigadb/pub/10.5524/100001_101000/100891/ |
      | 100633 | ftp://ftp.ebi.ac.uk/pub/databases/reference_proteomes/previous_releases/qfo_release-2011_04/2011_04_reference_proteomes.tar.gz | https://ftp.cngb.org/pub/gigadb/pub/10.5524/100001_101000/100633/ |
      | 100633 | https://figshare.com/s/19a006d6fea9c2494ab8 | https://ftp.cngb.org/pub/gigadb/pub/10.5524/100001_101000/100633/ |
      | 100633 | https://ftp.cngb.org/pub/gigadb/pub/10.5524/100001_101000/100633/readme_100633.txt | https://ftp.cngb.org/pub/gigadb/pub/10.5524/100001_101000/100633/ |