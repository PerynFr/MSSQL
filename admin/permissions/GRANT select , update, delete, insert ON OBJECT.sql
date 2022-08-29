GRANT select ON OBJECT::[ITOps_automation].[APPA].[WPBS_Users]  to [CORP\svc_RTKWPBS]
GRANT update ON OBJECT::[ITOps_automation].[APPA].[WPBS_Users]  to [CORP\svc_RTKWPBS]
GRANT insert ON OBJECT::[ITOps_automation].[APPA].[WPBS_Users]  to [CORP\svc_RTKWPBS]
GRANT delete ON OBJECT::[ITOps_automation].[APPA].[WPBS_Users]  to [CORP\svc_RTKWPBS]
go
sp_helprotect NULL, [CORP\svc_RTKWPBS]


GRANT select,update,delete,insert  ON OBJECT::[ITOps_automation].[APPA].[Application_Owners]  to [CORP\adm_VAleksandrov]
go
sp_helprotect NULL, [CORP\adm_VAleksandrov]