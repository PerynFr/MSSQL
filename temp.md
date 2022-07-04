SELECT [name] FROM [sys].[database_mirroring_endpoints]
Then, using the name returned from that simple query, issue the following two commands back-to-back (replacing the endpoint name with your own):

ALTER ENDPOINT YourEndPointName STATE=STOPPED
ALTER ENDPOINT YourEndPointName STATE=STARTED
