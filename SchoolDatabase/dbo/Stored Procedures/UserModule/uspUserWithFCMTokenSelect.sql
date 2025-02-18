CREATE PROC dbo.uspUserWithFCMTokenSelect(@RoleId INT,
@ClassId INT,
@GradeId INT,
@DivisionId INT,
@StudentIds VARCHAR(MAX)=NULL,
@TeacherIds VARCHAR(MAX)=NULL,
@ClerkIds VARCHAR(MAX)=NULL,
@CabDriverIds VARCHAR(MAX)=NULL
)
AS
Begin
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;                              
	SET NOCOUNT ON;  

	BEGIN TRY 
	    

		DECLARE @AcademicYearId INT = (SELECT AcademicYearId FROM School)
	    
	    IF @RoleId = 5 AND @ClassId > 0
		BEGIN
		    DECLARE @_GradeId INT = (SELECT GradeId FROM dbo.SchoolGradeDivisionMatrix WHERE SchoolGradeDivisionMatrixId = @ClassId AND AcademicYearId = @AcademicYearId)
			DECLARE @_DivisionId INT = (SELECT DivisionId FROM dbo.SchoolGradeDivisionMatrix WHERE SchoolGradeDivisionMatrixId = @ClassId AND AcademicYearId = @AcademicYearId)
		    SELECT  DISTINCT 
			u.FCMToken
			FROM 
			dbo.[UserRole] usr 
					JOIN dbo.[User] u ON u.UserId=usr.UserId
					JOIN dbo.[Role] r ON r.RoleId=usr.RoleId
					JOIN dbo.[Student] s ON u.Uname = s.AppAccessMobileNo AND s.IsAppAccess = 1 AND s.IsDeleted <> 1
					JOIN dbo.[StudentGradeDivisionMapping] m ON m.GradeId = @_GradeId AND m.DivisionId = @_DivisionId AND
					m.StudentId = s.StudentId AND m.AcademicYearId = @AcademicYearId AND m.IsDeleted <> 1
					WHERE  u.IsDeleted<>1 AND u.FCMToken IS NOT NULL AND r.RoleId = 5 
		END
		ELSE IF @RoleId = 5 AND @GradeId > 0 AND @DivisionId > 0
		BEGIN
		    SELECT  DISTINCT 
			u.FCMToken
			FROM 
			dbo.[UserRole] usr 
					JOIN dbo.[User] u ON u.UserId=usr.UserId
					JOIN dbo.[Role] r ON r.RoleId=usr.RoleId
					JOIN dbo.[Student] s ON u.Uname = s.AppAccessMobileNo AND s.IsAppAccess = 1 AND s.IsDeleted <> 1
					JOIN dbo.[StudentGradeDivisionMapping] m ON m.GradeId = @GradeId AND m.DivisionId = @DivisionId AND
					m.StudentId = s.StudentId AND m.AcademicYearId = @AcademicYearId AND m.IsDeleted <> 1
					WHERE  u.IsDeleted<>1 AND u.FCMToken IS NOT NULL AND r.RoleId = 5 
		END
		ELSE IF @RoleId = 5 AND @StudentIds IS NOT NULL AND @StudentIds != ''
		BEGIN
		    SELECT DISTINCT 
			u.FCMToken
			FROM 
			dbo.[UserRole] usr 
					JOIN dbo.[User] u ON u.UserId=usr.UserId
					JOIN dbo.[Role] r ON r.RoleId=usr.RoleId
					JOIN dbo.[Student] s ON u.Uname = s.AppAccessMobileNo AND s.IsAppAccess = 1 AND s.IsDeleted <> 1 
					        AND s.StudentId IN (SELECT value FROM STRING_SPLIT(@StudentIds, ','))
					JOIN dbo.[StudentGradeDivisionMapping] m ON
					m.StudentId = s.StudentId AND m.AcademicYearId = @AcademicYearId AND m.IsDeleted <> 1
					WHERE  u.IsDeleted<>1 AND u.FCMToken IS NOT NULL AND r.RoleId = 5 
		END
		ELSE IF @RoleId = 3 AND (@TeacherIds IS NOT NULL OR @TeacherIds != '')
		BEGIN
		    SELECT DISTINCT 
			u.FCMToken
			FROM 
			dbo.[UserRole] usr 
					JOIN dbo.[User] u ON u.UserId=usr.UserId
					JOIN dbo.[Role] r ON r.RoleId=usr.RoleId
					JOIN dbo.[Teacher] s ON u.Uname = s.AppAccessMobileNo AND s.IsAppAccess = 1 AND s.IsDeleted <> 1 
					        AND s.TeacherId IN (SELECT value FROM STRING_SPLIT(@TeacherIds, ','))
					WHERE  u.IsDeleted<>1 AND u.FCMToken IS NOT NULL AND r.RoleId = 3 
		END
		ELSE IF @RoleId = 4 AND (@ClerkIds IS NOT NULL OR @ClerkIds != '')
		BEGIN
		    SELECT DISTINCT 
			u.FCMToken
			FROM 
			dbo.[UserRole] usr 
					JOIN dbo.[User] u ON u.UserId=usr.UserId
					JOIN dbo.[Role] r ON r.RoleId=usr.RoleId
					JOIN dbo.[Clerk] s ON u.Uname = s.AppAccessMobileNo AND s.IsAppAccess = 1 AND s.IsDeleted <> 1 
					        AND s.ClerkId IN (SELECT value FROM STRING_SPLIT(@ClerkIds, ','))
					WHERE  u.IsDeleted<>1 AND u.FCMToken IS NOT NULL AND r.RoleId = 4 
		END
		ELSE IF @RoleId = 6 AND (@CabDriverIds IS NOT NULL OR @CabDriverIds != '')
		BEGIN
		    SELECT DISTINCT 
			u.FCMToken
			FROM 
			dbo.[UserRole] usr 
					JOIN dbo.[User] u ON u.UserId=usr.UserId
					JOIN dbo.[Role] r ON r.RoleId=usr.RoleId
					JOIN dbo.CabDriver s ON u.Uname = s.AppAccessMobileNo AND s.IsAppAccess = 1 AND s.IsDeleted <> 1 
					        AND s.CabDriverId IN (SELECT value FROM STRING_SPLIT(@CabDriverIds, ','))
					WHERE  u.IsDeleted<>1 AND u.FCMToken IS NOT NULL AND r.RoleId = 6 
		END
		ELSE
		BEGIN
		     SELECT  DISTINCT 
			u.FCMToken
			FROM 
			dbo.[UserRole] usr 
					JOIN dbo.[User] u ON u.UserId=usr.UserId
					JOIN dbo.[Role] r ON r.RoleId=usr.RoleId
					WHERE  u.IsDeleted<>1 AND u.FCMToken IS NOT NULL AND r.RoleId = @RoleId 
		END
	
        

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
