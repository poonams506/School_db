-- =============================================
-- Author:    DW
-- Create date: 02/05/2024
-- Description:  get due amount by AY
-- =============================================
CREATE  PROCEDURE [dbo].[uspTransportFeePaymentDueByAYSelect]
	@ConsumerId INT,
    @RoleId INT,
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
             RoleId INT,
             AcademicYearId INT,
             ConsumerId INT
             )
             INSERT INTO @temp3withAY
           SELECT dbo.udfConsumerTransportTotalFee(a.AcademicYearId,@ConsumerId, @RoleId) AS 'TotalFee',
             dbo.udfConsumerTransportDiscountedFee(a.AcademicYearId,@ConsumerId, @RoleId) AS 'DiscountedFee',
             dbo.udfConsumerTransportPaidAmount(a.AcademicYearId,@ConsumerId, @RoleId) AS 'PaidAmount',
             dbo.udfConsumerTransportOtherPaidAmount(a.AcademicYearId,@ConsumerId, @RoleId) AS 'OtherPaidAmount',
             dbo.udfConsumerTransportDueAmount(a.AcademicYearId,@ConsumerId, @RoleId) AS 'DueAmount',
             dbo.udfConsumerTransportChequeClearedAmount(a.AcademicYearId,@ConsumerId, @RoleId) AS 'ChequeClearedAmount',
             dbo.udfConsumerTransportChequeUnClearAmount(a.AcademicYearId,@ConsumerId, @RoleId) AS 'ChequeUnclearAmount',
	         @RoleId AS RoleId, a.AcademicYearId AS AcademicYearId, @ConsumerId AS ConsumerId
           FROM AcademicYear a 
           -- note  : inclide current academic year here
         IF @RoleId = 5
         BEGIN
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
	           ON M.AcademicYearId = temp.AcademicYearId AND M.StudentId = temp.ConsumerId AND temp.RoleId = 5

         WHERE
           M.IsDeleted <> 1
           AND S.IsDeleted <> 1
           AND s.StudentId = @ConsumerId
           AND (temp.DueAmount > 0
           or temp.ChequeUnclearAmount > 0)
        END
        IF @RoleId = 3 -- teacher
        BEGIN
            SELECT 
             A.AcademicYearKey,
             t.FirstName + ' ' + t.MiddleName + ' ' + t.LastName AS 'FullName',
             temp.TotalFee AS 'TotalFee',
             temp.DiscountedFee AS 'DiscountedFee',
             temp.PaidAmount AS 'PaidAmount',
             temp.OtherPaidAmount AS 'OtherPaidAmount',
             temp.DueAmount AS 'DueAmount',
             temp.ChequeClearedAmount AS 'ChequeClearedAmount',
             temp.ChequeUnclearAmount AS 'ChequeUnclearAmount'
         FROM 
               AcademicYear A
	           INNER JOIN @temp3withAY temp
	           ON A.AcademicYearId = temp.AcademicYearId AND temp.ConsumerId = @ConsumerId AND temp.RoleId = @RoleId
	            INNER JOIN Teacher t ON
	           t.TeacherId = temp.ConsumerId

         WHERE
           t.IsDeleted <> 1
           AND t.TeacherId = @ConsumerId
           AND (temp.DueAmount > 0
           or temp.ChequeUnclearAmount > 0)
        END
        IF @RoleId = 4 -- clerk
        BEGIN
            SELECT 
             A.AcademicYearKey,
             t.FirstName + ' ' + t.MiddleName + ' ' + t.LastName AS 'FullName',
             temp.TotalFee AS 'TotalFee',
             temp.DiscountedFee AS 'DiscountedFee',
             temp.PaidAmount AS 'PaidAmount',
             temp.OtherPaidAmount AS 'OtherPaidAmount',
             temp.DueAmount AS 'DueAmount',
             temp.ChequeClearedAmount AS 'ChequeClearedAmount',
             temp.ChequeUnclearAmount AS 'ChequeUnclearAmount'
         FROM 
               AcademicYear A
	           INNER JOIN @temp3withAY temp
	           ON A.AcademicYearId = temp.AcademicYearId AND temp.ConsumerId = @ConsumerId AND temp.RoleId = @RoleId
	            INNER JOIN Clerk t ON
	           t.ClerkId = temp.ConsumerId

         WHERE
           t.IsDeleted <> 1
           AND t.ClerkId = @ConsumerId
           AND (temp.DueAmount > 0
           or temp.ChequeUnclearAmount > 0)
        END
        IF @RoleId = 6 -- Cab Driver
        BEGIN
            SELECT 
             A.AcademicYearKey,
             t.FirstName + ' ' + t.MiddleName + ' ' + t.LastName AS 'FullName',
             temp.TotalFee AS 'TotalFee',
             temp.DiscountedFee AS 'DiscountedFee',
             temp.PaidAmount AS 'PaidAmount',
             temp.OtherPaidAmount AS 'OtherPaidAmount',
             temp.DueAmount AS 'DueAmount',
             temp.ChequeClearedAmount AS 'ChequeClearedAmount',
             temp.ChequeUnclearAmount AS 'ChequeUnclearAmount'
         FROM 
               AcademicYear A
	           INNER JOIN @temp3withAY temp
	           ON A.AcademicYearId = temp.AcademicYearId AND temp.ConsumerId = @ConsumerId AND temp.RoleId = @RoleId
	            INNER JOIN CabDriver t ON
	           t.CabDriverId = temp.ConsumerId

         WHERE
           t.IsDeleted <> 1
           AND t.CabDriverId = @ConsumerId
           AND (temp.DueAmount > 0
           or temp.ChequeUnclearAmount > 0)
        END

           -- note  : inclide current academic year here
   END
   ELSE
   BEGIN
           DECLARE  @temp3withoutAY TABLE(
                     TotalFee MONEY,
                     DiscountedFee MONEY,
                     PaidAmount MONEY,
                     OtherPaidAmount MONEY,
                     DueAmount MONEY,
                     ChequeClearedAmount MONEY,
                     ChequeUnclearAmount MONEY,
                     RoleId INT,
                     AcademicYearId INT,
                     ConsumerId INT
                     )
        INSERT INTO @temp3withoutAY
        SELECT dbo.udfConsumerTransportTotalFee(a.AcademicYearId,@ConsumerId, @RoleId) AS 'TotalFee',
             dbo.udfConsumerTransportDiscountedFee(a.AcademicYearId,@ConsumerId, @RoleId) AS 'DiscountedFee',
             dbo.udfConsumerTransportPaidAmount(a.AcademicYearId,@ConsumerId, @RoleId) AS 'PaidAmount',
             dbo.udfConsumerTransportOtherPaidAmount(a.AcademicYearId,@ConsumerId, @RoleId) AS 'OtherPaidAmount',
             dbo.udfConsumerTransportDueAmount(a.AcademicYearId,@ConsumerId, @RoleId) AS 'DueAmount',
             dbo.udfConsumerTransportChequeClearedAmount(a.AcademicYearId,@ConsumerId, @RoleId) AS 'ChequeClearedAmount',
             dbo.udfConsumerTransportChequeUnClearAmount(a.AcademicYearId,@ConsumerId, @RoleId) AS 'ChequeUnclearAmount',
	         @RoleId AS RoleId, a.AcademicYearId AS AcademicYearId, @ConsumerId AS ConsumerId
           FROM AcademicYear a 
           WHERE a.AcademicYearId <> @currentAyId

         IF @RoleId = 5
         BEGIN
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
	           INNER JOIN @temp3withoutAY temp
	           ON M.AcademicYearId = temp.AcademicYearId AND M.StudentId = temp.ConsumerId AND temp.RoleId = 5

         WHERE
           M.IsDeleted <> 1
           AND S.IsDeleted <> 1
           AND s.StudentId = @ConsumerId
           AND M.AcademicYearId <> @currentAyId
           AND temp.AcademicYearId  <> @currentAyId
           AND (temp.DueAmount > 0
           or temp.ChequeUnclearAmount > 0)
        END
        IF @RoleId = 3 -- teacher
        BEGIN
            SELECT 
             A.AcademicYearKey,
             t.FirstName + ' ' + t.MiddleName + ' ' + t.LastName AS 'FullName',
             temp.TotalFee AS 'TotalFee',
             temp.DiscountedFee AS 'DiscountedFee',
             temp.PaidAmount AS 'PaidAmount',
             temp.OtherPaidAmount AS 'OtherPaidAmount',
             temp.DueAmount AS 'DueAmount',
             temp.ChequeClearedAmount AS 'ChequeClearedAmount',
             temp.ChequeUnclearAmount AS 'ChequeUnclearAmount'
         FROM 
               AcademicYear A
	           INNER JOIN @temp3withoutAY temp
	           ON A.AcademicYearId = temp.AcademicYearId AND temp.ConsumerId = @ConsumerId AND temp.RoleId = @RoleId
	            INNER JOIN Teacher t ON
	           t.TeacherId = temp.ConsumerId

         WHERE
           t.IsDeleted <> 1
           AND t.TeacherId = @ConsumerId
           AND A.AcademicYearId <> @currentAyId
           AND temp.AcademicYearId  <> @currentAyId
           AND (temp.DueAmount > 0
           or temp.ChequeUnclearAmount > 0)
        END
        IF @RoleId = 4 -- clerk
        BEGIN
            SELECT 
             A.AcademicYearKey,
             t.FirstName + ' ' + t.MiddleName + ' ' + t.LastName AS 'FullName',
             temp.TotalFee AS 'TotalFee',
             temp.DiscountedFee AS 'DiscountedFee',
             temp.PaidAmount AS 'PaidAmount',
             temp.OtherPaidAmount AS 'OtherPaidAmount',
             temp.DueAmount AS 'DueAmount',
             temp.ChequeClearedAmount AS 'ChequeClearedAmount',
             temp.ChequeUnclearAmount AS 'ChequeUnclearAmount'
         FROM 
               AcademicYear A
	           INNER JOIN @temp3withoutAY temp
	           ON A.AcademicYearId = temp.AcademicYearId AND temp.ConsumerId = @ConsumerId AND temp.RoleId = @RoleId
	            INNER JOIN Clerk t ON
	           t.ClerkId = temp.ConsumerId

         WHERE
           t.IsDeleted <> 1
           AND t.ClerkId = @ConsumerId
           AND A.AcademicYearId <> @currentAyId
           AND temp.AcademicYearId  <> @currentAyId
           AND (temp.DueAmount > 0
           or temp.ChequeUnclearAmount > 0)
        END
        IF @RoleId = 6 -- Cab Driver
        BEGIN
            SELECT 
             A.AcademicYearKey,
             t.FirstName + ' ' + t.MiddleName + ' ' + t.LastName AS 'FullName',
             temp.TotalFee AS 'TotalFee',
             temp.DiscountedFee AS 'DiscountedFee',
             temp.PaidAmount AS 'PaidAmount',
             temp.OtherPaidAmount AS 'OtherPaidAmount',
             temp.DueAmount AS 'DueAmount',
             temp.ChequeClearedAmount AS 'ChequeClearedAmount',
             temp.ChequeUnclearAmount AS 'ChequeUnclearAmount'
         FROM 
               AcademicYear A
	           INNER JOIN @temp3withoutAY temp
	           ON A.AcademicYearId = temp.AcademicYearId AND temp.ConsumerId = @ConsumerId AND temp.RoleId = @RoleId
	            INNER JOIN CabDriver t ON
	           t.CabDriverId = temp.ConsumerId

         WHERE
           t.IsDeleted <> 1
           AND t.CabDriverId = @ConsumerId
           AND A.AcademicYearId <> @currentAyId
           AND temp.AcademicYearId  <> @currentAyId
           AND (temp.DueAmount > 0
           or temp.ChequeUnclearAmount > 0)
        END
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