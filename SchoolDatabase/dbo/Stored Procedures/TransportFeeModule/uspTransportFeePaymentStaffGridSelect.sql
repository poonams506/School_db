-- =============================================
-- Author:    Deepa Walunj
-- Create date: 31/08/2023
-- Description:  This stored procedure is used to get Fee payment deatils for grid
-- =============================================
CREATE  PROCEDURE [dbo].[uspTransportFeePaymentStaffGridSelect]
	@RequestModel NVARCHAR(MAX)
AS
BEGIN
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY
 DECLARE @AcademicYearId SMALLINT = JSON_VALUE(@RequestModel, '$.academicYearId');
 DECLARE @PageSize INT=JSON_VALUE(@RequestModel, '$.getListModel.length');
 DECLARE @PageNumber INT=JSON_VALUE(@RequestModel, '$.getListModel.start');
 DECLARE @SearchText NVARCHAR(150)=JSON_VALUE(@RequestModel, '$.getListModel.search.value');
 DECLARE @OrderBy INT=JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
 DECLARE @OrderBy_ASC_DESC NVARCHAR(20)=JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');

  DECLARE @TransportConsumerTable TABLE(
    TotalFee MONEY,
    DiscountedFee MONEY,
    PaidAmount MONEY,
    OtherPaidAmount MONEY,
    DueAmount MONEY,
    ChequeClearedAmount MONEY,
    ChequeUnclearAmount MONEY,
    AcademicYearId SMALLINT,
    RoleId INT,
    RoleName NVARCHAR(50),
    FirstName NVARCHAR(100),
    MiddleName NVARCHAR(100),
    LastName NVARCHAR(100),
    ConsumerId INT
  )
 
  INSERT INTO @TransportConsumerTable 
  -- Teacher
  SELECT dbo.udfConsumerTransportTotalFee(@AcademicYearId, T.TeacherId, 3) AS 'TotalFee',
     dbo.udfConsumerTransportDiscountedFee(@AcademicYearId, T.TeacherId, 3) AS 'DiscountedFee',
     dbo.udfConsumerTransportPaidAmount(@AcademicYearId, T.TeacherId, 3) AS 'PaidAmount',
     dbo.udfConsumerTransportOtherPaidAmount(@AcademicYearId, T.TeacherId, 3) AS 'OtherPaidAmount',
     dbo.udfConsumerTransportDueAmount(@AcademicYearId, T.TeacherId, 3) AS 'DueAmount',
     dbo.udfConsumerTransportChequeClearedAmount(@AcademicYearId, T.TeacherId, 3) AS 'ChequeClearedAmount',
     dbo.udfConsumerTransportChequeUnClearAmount(@AcademicYearId, T.TeacherId, 3) AS 'ChequeUnclearAmount',
	  @AcademicYearId AS AcademicYearId, 3 AS RoleId, 'Teacher' AS RoleName,
      T.FirstName, T.MiddleName, T.LastName, T.TeacherId
  FROM TransportConsumerStoppageMapping M
  INNER JOIN Teacher T
       ON M.ConsumerId = T.TeacherId AND M.RoleId = 3
  WHERE
   M.IsDeleted <> 1
   AND T.IsDeleted <> 1
   AND M.AcademicYearId = @AcademicYearId
   AND M.RoleId = 3

   UNION
   -- Clerk
  SELECT dbo.udfConsumerTransportTotalFee(@AcademicYearId, T.ClerkId, 4) AS 'TotalFee',
     dbo.udfConsumerTransportDiscountedFee(@AcademicYearId, T.ClerkId, 4) AS 'DiscountedFee',
     dbo.udfConsumerTransportPaidAmount(@AcademicYearId, T.ClerkId, 4) AS 'PaidAmount',
     dbo.udfConsumerTransportOtherPaidAmount(@AcademicYearId, T.ClerkId, 4) AS 'OtherPaidAmount',
     dbo.udfConsumerTransportDueAmount(@AcademicYearId, T.ClerkId, 4) AS 'DueAmount',
     dbo.udfConsumerTransportChequeClearedAmount(@AcademicYearId, T.ClerkId, 4) AS 'ChequeClearedAmount',
     dbo.udfConsumerTransportChequeUnClearAmount(@AcademicYearId, T.ClerkId, 4) AS 'ChequeUnclearAmount',
	  @AcademicYearId AS AcademicYearId, 4 AS RoleId, 'Clerk' AS RoleName,
      T.FirstName, T.MiddleName, T.LastName, T.ClerkId
  FROM TransportConsumerStoppageMapping M
  INNER JOIN Clerk T
       ON M.ConsumerId = T.ClerkId AND M.RoleId = 4
  WHERE
   M.IsDeleted <> 1
   AND T.IsDeleted <> 1
   AND M.AcademicYearId = @AcademicYearId
   AND M.RoleId = 4

   UNION
   -- Cab Driver
  SELECT dbo.udfConsumerTransportTotalFee(@AcademicYearId, T.CabDriverId, 6) AS 'TotalFee',
     dbo.udfConsumerTransportDiscountedFee(@AcademicYearId, T.CabDriverId, 6) AS 'DiscountedFee',
     dbo.udfConsumerTransportPaidAmount(@AcademicYearId, T.CabDriverId, 6) AS 'PaidAmount',
     dbo.udfConsumerTransportOtherPaidAmount(@AcademicYearId, T.CabDriverId, 6) AS 'OtherPaidAmount',
     dbo.udfConsumerTransportDueAmount(@AcademicYearId, T.CabDriverId, 6) AS 'DueAmount',
     dbo.udfConsumerTransportChequeClearedAmount(@AcademicYearId, T.CabDriverId, 6) AS 'ChequeClearedAmount',
     dbo.udfConsumerTransportChequeUnClearAmount(@AcademicYearId, T.CabDriverId, 6) AS 'ChequeUnclearAmount',
	  @AcademicYearId AS AcademicYearId, 6 AS RoleId, 'Cab Driver' AS RoleName,
      T.FirstName, T.MiddleName, T.LastName, T.CabDriverId
  FROM TransportConsumerStoppageMapping M
  INNER JOIN CabDriver T
       ON M.ConsumerId = T.CabDriverId AND M.RoleId = 6
  WHERE
   M.IsDeleted <> 1
   AND T.IsDeleted <> 1
   AND M.AcademicYearId = @AcademicYearId
   AND M.RoleId = 6


   SELECT COUNT(*) FROM @TransportConsumerTable S
   WHERE  (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName  LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (S.FirstName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.MiddleName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.LastName LIKE '%'+@SearchText+'%')
   ))


  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
 SELECT 
     S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName AS 'FullName',
     S.ConsumerId,
     S.RoleId,
     S.RoleName,
     S.TotalFee AS 'TotalFee',
     S.DiscountedFee AS 'DiscountedFee',
     S.PaidAmount AS 'PaidAmount',
     S.DueAmount AS 'DueAmount',
     S.ChequeUnclearAmount AS 'ChequeUnclearAmount'
 FROM @TransportConsumerTable S

 WHERE
   (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName  LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (S.FirstName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.MiddleName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.LastName LIKE '%'+@SearchText+'%')
   ))

 ORDER BY
 CASE WHEN @OrderBy=1 THEN S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName END DESC,
 CASE WHEN @OrderBy=2 THEN S.RoleName END DESC,
 CASE WHEN @OrderBy=3 THEN S.TotalFee END DESC,
 CASE WHEN @OrderBy=4 THEN S.DiscountedFee END DESC,
 CASE WHEN @OrderBy=5 THEN S.PaidAmount END DESC,
 CASE WHEN @OrderBy=6 THEN S.DueAmount END DESC,
 CASE WHEN @OrderBy=7 THEN S.ChequeUnclearAmount END DESC
 OFFSET @PageNumber ROWS
 FETCH NEXT @PageSize ROWS ONLY
 
END
ELSE
  BEGIN
        
  
  SELECT 
     S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName AS 'FullName',
     S.ConsumerId,
     S.RoleId,
     S.RoleName,
     S.TotalFee AS 'TotalFee',
     S.DiscountedFee AS 'DiscountedFee',
     S.PaidAmount AS 'PaidAmount',
     S.DueAmount AS 'DueAmount',
     S.ChequeUnclearAmount AS 'ChequeUnclearAmount'
 FROM @TransportConsumerTable S

 WHERE
   (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName  LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (S.FirstName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.MiddleName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.LastName LIKE '%'+@SearchText+'%')
   ))

 ORDER BY
 CASE WHEN @OrderBy=1 THEN S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName END ASC,
 CASE WHEN @OrderBy=2 THEN S.RoleName END ASC,
 CASE WHEN @OrderBy=3 THEN S.TotalFee END ASC,
 CASE WHEN @OrderBy=4 THEN S.DiscountedFee END ASC,
 CASE WHEN @OrderBy=5 THEN S.PaidAmount END ASC,
 CASE WHEN @OrderBy=6 THEN S.DueAmount END ASC,
 CASE WHEN @OrderBy=7 THEN S.ChequeUnclearAmount END ASC
 OFFSET @PageNumber ROWS
 FETCH NEXT @PageSize ROWS ONLY
  
  
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