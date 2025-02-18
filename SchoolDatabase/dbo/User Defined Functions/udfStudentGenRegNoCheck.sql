CREATE FUNCTION [dbo].[udfStudentGenRegNoCheck] (@Gen_Reg_No NVARCHAR(100),@StudentId BIGINT)
RETURNS BIT AS
BEGIN

     DECLARE @GenRegNoExist INT;
    DECLARE @StudentCount INT;
	SET @GenRegNoExist=0;
    SELECT @StudentCount = COUNT(s.StudentId) 
    FROM Student s
    WHERE  GeneralRegistrationNo = @Gen_Reg_No
                   AND IsDeleted <> 1
				  AND (s.StudentId <> @StudentId OR @StudentId = 0)

    IF @StudentCount > 0
    BEGIN
        SET @GenRegNoExist = 1;  
    END
     RETURN @GenRegNoExist;

END;