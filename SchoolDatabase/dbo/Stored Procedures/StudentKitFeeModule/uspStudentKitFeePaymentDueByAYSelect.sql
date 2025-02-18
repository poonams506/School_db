-- =============================================
-- Author:    DW
-- Create date: 02/05/2024
-- Description:  get due amount by AY
-- =============================================
CREATE  PROCEDURE [dbo].[uspStudentKitFeePaymentDueByAYSelect]
	@StudentId INT,
    @CurrentAcademicYearInclude BIT
AS
BEGIN
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY

 DECLARE @currentAyId SMALLINT;
 SET @currentAyId = (SELECT TOP 1 AcademicYearId FROM School)
 
 DECLARE  @studentTemp TABLE(
 StudentId INT,
 AcademicYearId INT,
 GradeId INT,
 DivisionId INT
 )
 INSERT INTO @studentTemp
 SELECT DISTINCT S.StudentId, M.AcademicYearId, M.GradeId, M.DivisionId
  FROM StudentGradeDivisionMapping M
       INNER JOIN Student S
       ON M.StudentId = S.StudentId
	   INNER JOIN FeeParticular FP
	   ON M.GradeId = FP.GradeId AND M.DivisionId = FP.DivisionId AND FP.IsPublished = 1
       WHERE
   M.IsDeleted <> 1
   AND S.IsDeleted <> 1
   AND FP.IsDeleted <> 1
   AND s.StudentId = @StudentId
   -- note  : don't use academic year here

   IF @CurrentAcademicYearInclude = 1
   BEGIN
           DECLARE  @temp3withAY TABLE(
             TotalFee MONEY,
             DiscountedFee MONEY,
             PaidAmount MONEY,
             OtherPaidAmount MONEY,
             DueAmount MONEY,
             ChequeClearedAmount MONEY,
             ChequeUnclearAmount MONEY,
             GradeId INT,
             DivisionId INT,
             AcademicYearId INT,
             StudentId INT
             )
             INSERT INTO @temp3withAY
           SELECT dbo.udfStudentKitStudentTotalFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'TotalFee',
             dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'DiscountedFee',
             dbo.udfStudentKitStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'PaidAmount',
             dbo.udfStudentKitStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'OtherPaidAmount',
             dbo.udfStudentKitStudentDueAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'DueAmount',
             dbo.udfStudentKitStudentChequeClearedAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'ChequeClearedAmount',
             dbo.udfStudentKitStudentChequeUnClearAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'ChequeUnclearAmount',
	         M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId
          FROM StudentGradeDivisionMapping M
               INNER JOIN Student S
               ON M.StudentId = S.StudentId
	            INNER JOIN @studentTemp t ON
	           S.StudentId = t.StudentId
          WHERE
           M.IsDeleted <> 1
           AND S.IsDeleted <> 1
           AND s.StudentId = @StudentId
           -- note  : inclide current academic year here
 
         SELECT 
             s.StudentId,
             G.GradeName + ' - ' + D.DivisionName AS GradeName,
             G.GradeId,
             D.DivisionId,
             M.AcademicYearId,
             A.AcademicYearKey,
             S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName AS 'FullName',
             M.IsRTEStudent,
             temp.TotalFee AS 'TotalFee',
             temp.DiscountedFee AS 'DiscountedFee',
             temp.PaidAmount AS 'PaidAmount',
             temp.OtherPaidAmount AS 'OtherPaidAmount',
             temp.DueAmount AS 'DueAmount',
             temp.ChequeClearedAmount AS 'ChequeClearedAmount',
             temp.ChequeUnclearAmount AS 'ChequeUnclearAmount'
         FROM StudentGradeDivisionMapping M
               INNER JOIN Student S
               ON M.StudentId = S.StudentId
               INNER JOIN Grade G
               ON G.GradeId = M.GradeId
               INNER JOIN Division D
               ON D.DivisionId = M.DivisionId
               INNER JOIN AcademicYear A
               ON A.AcademicYearId = M.AcademicYearId
	           INNER JOIN @temp3withAY temp
	           ON M.GradeId = temp.GradeId AND M.DivisionId = temp.DivisionId AND M.AcademicYearId = temp.AcademicYearId AND M.StudentId = temp.StudentId
	            INNER JOIN @studentTemp t ON
	           S.StudentId = t.StudentId

         WHERE
           M.IsDeleted <> 1
           AND S.IsDeleted <> 1
           AND s.StudentId = @StudentId
           AND (temp.DueAmount > 0
           or temp.ChequeUnclearAmount > 0)
           -- note  : inclide current academic year here
   END
   ELSE
   BEGIN

               DECLARE  @temp3 TABLE(
             TotalFee MONEY,
             DiscountedFee MONEY,
             PaidAmount MONEY,
             OtherPaidAmount MONEY,
             DueAmount MONEY,
             ChequeClearedAmount MONEY,
             ChequeUnclearAmount MONEY,
             GradeId INT,
             DivisionId INT,
             AcademicYearId INT,
             StudentId INT
             )
        INSERT INTO @temp3
        SELECT dbo.udfStudentKitStudentTotalFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'TotalFee',
             dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'DiscountedFee',
             dbo.udfStudentKitStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'PaidAmount',
             dbo.udfStudentKitStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'OtherPaidAmount',
             dbo.udfStudentKitStudentDueAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'DueAmount',
             dbo.udfStudentKitStudentChequeClearedAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'ChequeClearedAmount',
             dbo.udfStudentKitStudentChequeUnClearAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'ChequeUnclearAmount',
	         M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId
          FROM StudentGradeDivisionMapping M
               INNER JOIN Student S
               ON M.StudentId = S.StudentId
	            INNER JOIN @studentTemp t ON
	           S.StudentId = t.StudentId
          WHERE
           M.IsDeleted <> 1
           AND S.IsDeleted <> 1
           AND s.StudentId = @StudentId
           AND M.AcademicYearId <> @currentAyId
           -- note  : don't use academic year here
 
         SELECT 
             s.StudentId,
             G.GradeName + ' - ' + D.DivisionName AS GradeName,
             G.GradeId,
             D.DivisionId,
             M.AcademicYearId,
             A.AcademicYearKey,
             S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName AS 'FullName',
             M.IsRTEStudent,
             temp.TotalFee AS 'TotalFee',
             temp.DiscountedFee AS 'DiscountedFee',
             temp.PaidAmount AS 'PaidAmount',
             temp.OtherPaidAmount AS 'OtherPaidAmount',
             temp.DueAmount AS 'DueAmount',
             temp.ChequeClearedAmount AS 'ChequeClearedAmount',
             temp.ChequeUnclearAmount AS 'ChequeUnclearAmount'
         FROM StudentGradeDivisionMapping M
               INNER JOIN Student S
               ON M.StudentId = S.StudentId
               INNER JOIN Grade G
               ON G.GradeId = M.GradeId
               INNER JOIN Division D
               ON D.DivisionId = M.DivisionId
               INNER JOIN AcademicYear A
               ON A.AcademicYearId = M.AcademicYearId
	           INNER JOIN @temp3 temp
	           ON M.GradeId = temp.GradeId AND M.DivisionId = temp.DivisionId AND M.AcademicYearId = temp.AcademicYearId AND M.StudentId = temp.StudentId
	            INNER JOIN @studentTemp t ON
	           S.StudentId = t.StudentId

         WHERE
           M.IsDeleted <> 1
           AND S.IsDeleted <> 1
           AND s.StudentId = @StudentId
           AND M.AcademicYearId <> @currentAyId
           AND (temp.DueAmount > 0
           or temp.ChequeUnclearAmount > 0)
           -- note  : don't use academic year here
   END

  
 
END TRY BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
@ErrorState END CATCH
END