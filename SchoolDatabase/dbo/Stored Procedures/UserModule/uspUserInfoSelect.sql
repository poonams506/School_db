-- =============================================
-- Author:		Deepak Walunj
-- Create date: 02/04/2023
-- Description:	This stored procedure is used to get user info detail by Id
-- =============================================
CREATE PROC dbo.uspUserInfoSelect(@Id INT, @RoleId INT = null)
AS
Begin
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;                              
	SET NOCOUNT ON;  

	BEGIN TRY 

		SELECT usr.UserId, u.Fname + ' ' + u.Lname AS Uname,usr.RoleId,r.Name as RoleName, r.RoleKey, usr.RefId FROM dbo.[UserRole] usr 
		       JOIN dbo.[User] u ON u.UserId=usr.UserId
               JOIN dbo.[Role] r ON r.RoleId=usr.RoleId
			   WHERE u.UserId=@Id AND u.IsDeleted<>1 AND usr.RoleId = ISNULL(@RoleId, usr.RoleId);

        SELECT  usr.RoleId as RoleId,p.PermissionId as PermissionId,p.Name as PermissionName, p.PermissionKey,
				m.ModuleId as ModuleId, m.Name as ModuleName,m.ParentId as ParentId, m.ModuleKey,
				m.MenuTypeId,m.MenuUrl,m.MenuIcon,m.MenuSort, usr.RefId

		FROM dbo.[User] u 
		JOIN dbo.[UserRole] usr ON u.UserId=usr.UserId
		JOIN dbo.[RolePermission] rp ON rp.RoleId=usr.RoleId
		JOIN dbo.[Permission] p ON p.PermissionId=rp.PermissionId
		JOIN dbo.[Module] m ON m.ModuleId=rp.ModuleId
		
		WHERE u.UserId=@Id AND u.IsDeleted<>1
		AND p.IsDeleted<>1 AND m.IsDeleted<>1
		AND usr.IsDeleted<>1 AND rp.IsDeleted<>1
		AND usr.RoleId = ISNULL(@RoleId, usr.RoleId)
		ORDER BY m.MenuSort ASC;

		SELECT TOP (1) AcademicYearId,SchoolCode,SchoolId,LogoUrl,SchoolName
			FROM dbo.[School] ORDER BY SchoolId DESC;

		SELECT CASE WHEN p.ParentId IS NOT NULL THEN p.ParentId 
			        WHEN a.AdminId IS NOT NULL THEN a.AdminId
				    WHEN t.TeacherId IS NOT NULL THEN t.TeacherId
					WHEN c.ClerkId IS NOT NULL THEN c.ClerkId
					WHEN cb.CabDriverId IS NOT NULL THEN cb.CabDriverId
		ELSE u.UserId END AS UserIdByRole,
		CASE WHEN p.ParentId IS NOT NULL THEN CONCAT(p.FirstName,' ',p.MiddleName,' ',p.LastName)
			        WHEN a.AdminId IS NOT NULL THEN CONCAT(a.FirstName,' ',a.MiddleName,' ',a.LastName)
				    WHEN t.TeacherId IS NOT NULL THEN CONCAT(t.FirstName,' ',t.MiddleName,' ',t.LastName)
					WHEN c.ClerkId IS NOT NULL THEN CONCAT(c.FirstName,' ',c.MiddleName,' ',c.LastName)
					WHEN cb.CabDriverId IS NOT NULL THEN CONCAT(cb.FirstName,' ',cb.MiddleName,' ',cb.LastName)
		ELSE CONCAT(u.FName,' ',u.MName,' ',u.LName) END AS UserFullNameByRole,
		CASE WHEN p.ParentId IS NOT NULL THEN p.ProfileImageURL
			        WHEN a.AdminId IS NOT NULL THEN a.ProfileImageURL
				    WHEN t.TeacherId IS NOT NULL THEN t.ProfileImageURL
					WHEN c.ClerkId IS NOT NULL THEN c.ProfileImageURL
					WHEN cb.CabDriverId IS NOT NULL THEN cb.ProfileImageURL
		ELSE '' END AS ProfileImageURL

		FROM dbo.[UserRole] usr 
		       JOIN dbo.[User] u ON u.UserId=usr.UserId
               JOIN dbo.[Role] r ON r.RoleId=usr.RoleId
			   LEFT JOIN dbo.[Admin] a ON a.IsAppAccess=1 AND a.AppAccessMobileNo=u.Uname AND  r.RoleKey='Admin' AND a.IsDeleted<>1
			   LEFT JOIN dbo.[Teacher] t ON t.IsAppAccess=1 AND t.AppAccessMobileNo=u.Uname AND  r.RoleKey='Teacher' AND t.IsDeleted<>1
			   LEFT JOIN dbo.[Clerk] c ON c.IsAppAccess=1 AND c.AppAccessMobileNo=u.Uname AND  r.RoleKey='Clerk' AND c.IsDeleted<>1
			   LEFT JOIN dbo.[CabDriver] cb ON cb.IsAppAccess=1 AND cb.AppAccessMobileNo=u.Uname AND  r.RoleKey='Cab_Driver' AND cb.IsDeleted<>1
			   LEFT JOIN dbo.[Parent] p ON  r.RoleKey='Parent' AND p.IsDeleted<>1
			   WHERE u.UserId=@Id AND u.IsDeleted<>1 AND usr.RoleId = @RoleId
			   AND (r.RoleKey<>'Parent' OR  EXISTS
			   (SELECT TOP (1) ps.ParentId FROM dbo.[ParentStudentMapping] ps 
			   JOIN dbo.[Student] s ON ps.ParentId=p.ParentId AND s.IsAppAccess=1 AND ps.StudentId=s.StudentId AND 
			   s.AppAccessMobileNo=u.Uname AND s.IsDeleted<>1 AND s.IsArchive <> 1 ORDER BY ps.ParentId DESC));

	 END TRY                                                    
 BEGIN CATCH                         
                                                  
   DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();                                                    
   DECLARE @ErrorSeverity INT = ERROR_SEVERITY();                                                   
   DECLARE @ErrorState INT = ERROR_STATE();                                                       
   DECLARE @ErrorNumber INT = ERROR_NUMBER();                                                  
   DECLARE @ErrorLine INT = ERROR_LINE();                                                 
   DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();                                               
  
   EXEC uspExceptionLogInsert @ErrorLine,@ErrorMessage,@ErrorNumber,@ErrorProcedure,@ErrorSeverity,@ErrorState                                                  
            
 END CATCH   


End

GO
