    -- =============================================
    -- Author: prathamesh ghule
    -- Create date: 14/05/2024
    -- Description: This stored procedure is used to get for parent app dashboard data
    -- =============================================
    CREATE PROCEDURE [dbo].[uspStudentGradeDivisionParentAppSelect] 
    (@AcademicYearId INT, @ParentId INT) AS 
    BEGIN 
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        SET NOCOUNT ON;

        BEGIN TRY 

       SELECT 
       CONCAT(s.FirstName,' ',s.MiddleName,' ',s.LastName) AS FullName,
	       sm.AcademicYearId,sm.StudentId,pm.ParentId,
           sm.GradeId,g.GradeName,sm.DivisionId,d.DivisionName
     FROM dbo.student s
     INNER JOIN  dbo.ParentStudentMapping pm on s.StudentId=pm.StudentId
	 INNER JOIN  dbo.StudentGradeDivisionMapping sm on s.StudentId=sm.StudentId
     INNER JOIN dbo.Grade g on sm.GradeId = g.GradeId
     INNER JOIN dbo.Division d on sm.DivisionId = d.DivisionId 
	    WHERE 
        pm.ParentId=@ParentId
    AND sm.academicYearId =@AcademicYearId
    AND sm.IsDeleted<>1
    AND s.IsDeleted<>1
    AND s.IsArchive<>1
    AND g.IsDeleted<>1
    AND d.IsDeleted<>1

        END TRY 
        BEGIN CATCH 
            DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
            DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
            DECLARE @ErrorState INT = ERROR_STATE();
            DECLARE @ErrorNumber INT = ERROR_NUMBER();
            DECLARE @ErrorLine INT = ERROR_LINE();
            DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
            EXEC uspExceptionLogInsert @ErrorLine, 
                @ErrorMessage, 
                @ErrorNumber, 
                @ErrorProcedure, 
                @ErrorSeverity, 
                @ErrorState;
        END CATCH 
    END;
    GO
