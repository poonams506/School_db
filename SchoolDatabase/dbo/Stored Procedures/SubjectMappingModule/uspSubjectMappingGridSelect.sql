-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 04/03/2024
-- Description:  This stored procedure is used to get subject mapping info
-- =============================================
CREATE PROC [dbo].[uspSubjectMappingGridSelect]
    @RequestModel NVARCHAR(MAX)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @AcademicYearId SMALLINT = JSON_VALUE(@RequestModel, '$.academicYearId');
        DECLARE @GradeId SMALLINT = JSON_VALUE(@RequestModel, '$.gradeId');
        DECLARE @DivisionId SMALLINT = JSON_VALUE(@RequestModel, '$.divisionId'); 
        DECLARE @PageSize INT = JSON_VALUE(@RequestModel, '$.getListModel.length');
        DECLARE @PageNumber INT = JSON_VALUE(@RequestModel, '$.getListModel.start');
        DECLARE @SearchText NVARCHAR(150) = JSON_VALUE(@RequestModel, '$.getListModel.search.value');
        DECLARE @OrderBy INT = JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
        DECLARE @OrderBy_ASC_DESC NVARCHAR(20) = JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');

        
        SELECT COUNT(sgdm.SchoolGradeDivisionMatrixId)
        FROM SchoolGradeDivisionMatrix sgdm
        INNER JOIN Grade g ON sgdm.GradeId = g.GradeId
        INNER JOIN Division d ON sgdm.DivisionId = d.DivisionId
        WHERE
            ISNULL(sgdm.IsDeleted, 0) <> 1 
            AND sgdm.AcademicYearId = @AcademicYearId
            AND (LEN(@SearchText) = 0 
                 OR CONCAT(g.GradeName, '-', d.DivisionName) LIKE '%' + @SearchText + '%');

        
        IF (@OrderBy_ASC_DESC = 'desc')
        BEGIN
            SELECT 
                sgdm.SchoolGradeDivisionMatrixId AS 'ClassId',
                sgdm.GradeId,
                sgdm.DivisionId,
                g.GradeName + ' - ' + d.DivisionName AS ClassName,
                (SELECT 
                    CAST(b.SubjectMasterId AS NVARCHAR(50)) + ',' 
                 FROM 
                    SubjectMapping b 
                 WHERE 
                    b.GradeId = g.GradeId 
                    AND b.DivisionId = d.DivisionId 
                    AND b.AcademicYearId = @AcademicYearId 
                    AND b.IsDeleted <> 1
                 FOR XML PATH('')) AS SubjectMasterIds,
                CASE 
                    WHEN EXISTS (
                        SELECT 1 
                        FROM SubjectMapping b 
                        WHERE b.GradeId = g.GradeId 
                        AND b.DivisionId = d.DivisionId 
                        AND b.AcademicYearId = @AcademicYearId 
                        AND (b.IndexNumber IS NULL OR b.IndexNumber = '')

                    ) THEN 0
                    ELSE 1
                END AS Status
            FROM SchoolGradeDivisionMatrix sgdm
            INNER JOIN Grade g ON sgdm.GradeId = g.GradeId
            INNER JOIN Division d ON sgdm.DivisionId = d.DivisionId
            WHERE
                ISNULL(sgdm.IsDeleted, 0) <> 1 
                AND sgdm.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 
                     OR CONCAT(g.GradeName, '-', d.DivisionName) LIKE '%' + @SearchText + '%')
            ORDER BY
                CASE WHEN @OrderBy = 0 THEN LEN(g.GradeName + '-' + d.DivisionName) END DESC,
                g.GradeName + '-' + d.DivisionName DESC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
        END
        ELSE
        BEGIN
            SELECT 
                sgdm.SchoolGradeDivisionMatrixId AS 'ClassId',
                sgdm.GradeId,
                sgdm.DivisionId,
                g.GradeName + ' - ' + d.DivisionName AS ClassName,
                (SELECT 
                    CAST(b.SubjectMasterId AS NVARCHAR(50)) + ',' 
                 FROM 
                    SubjectMapping b 
                 WHERE 
                    b.GradeId = g.GradeId 
                    AND b.DivisionId = d.DivisionId 
                    AND b.AcademicYearId = @AcademicYearId 
                    AND b.IsDeleted <> 1
                 FOR XML PATH('')) AS SubjectMasterIds,
				CASE 
					WHEN EXISTS (
						SELECT 1 
						FROM SubjectMapping b 
						WHERE b.GradeId = g.GradeId 
						AND b.DivisionId = d.DivisionId 
						AND b.AcademicYearId = @AcademicYearId 
						AND (b.IndexNumber IS NULL OR b.IndexNumber = '')
					) THEN 0
					ELSE 1
				END AS Status

            FROM SchoolGradeDivisionMatrix sgdm
            INNER JOIN Grade g ON sgdm.GradeId = g.GradeId
            INNER JOIN Division d ON sgdm.DivisionId = d.DivisionId
            WHERE
                ISNULL(sgdm.IsDeleted, 0) <> 1 
                AND sgdm.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 
                     OR CONCAT(g.GradeName, '-', d.DivisionName) LIKE '%' + @SearchText + '%')
            ORDER BY
                CASE WHEN @OrderBy = 0 THEN LEN(g.GradeName + '-' + d.DivisionName) END ASC,
                g.GradeName + '-' + d.DivisionName ASC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
        EXEC uspExceptionLogInsert 
            @ErrorLine,
            @ErrorMessage,
            @ErrorNumber,
            @ErrorProcedure,
            @ErrorSeverity,
            @ErrorState;
    END CATCH
END