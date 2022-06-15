SELECT @@VERSION, 
  SERVERPROPERTY('ProductMajorVersion'), 
  DATABASEPROPERTYEX(N'master', 'Version');

/*
Internal Version	Major Version	Notes
539	SQL Server 2000	 
611	SQL Server 2005	 
612	SQL Server 2005 SP2	The file format changed when VARDECIMAL was added. This meant you couldn't restore a 2005 SP2 backup to 2005 SP1, even if you weren't using the feature.
655	SQL Server 2008	 
661	SQL Server 2008 R2	I've seen reports of 660 and 662, but haven't observed directly. And I've seen at least one thread that talks about 665 but I think this was just a typo (they meant 655).
706	SQL Server 2012	 
782	SQL Server 2014	 
852	SQL Server 2016	 
869	SQL Server 2017	I don't have any evidence, but I believe when SQL Server 2017 was first released it had an internal version of 868. RTM from current media shows 869.
904	SQL Server 2019	The latest Cumulative Update (#16) still has the same internal version as RTM.
> 904	SQL Server 2022	This version isn't released yet but assume for now that any version higher than 904 is from a pre-release version.
*/