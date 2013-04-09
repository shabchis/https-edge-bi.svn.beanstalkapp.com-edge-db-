/****** Object:  StoredProcedure [dbo].[ResetUnendedServices] Script Date: 08/09/2011 ******/
CREATE PROCEDURE [dbo].[ResetUnendedServices] 
AS
BEGIN

  UPDATE EdgeSystem.[dbo].[ServiceInstance]
  SET [TimeEnded] = SYSDATETIME ( ),
	  [State] = 6,
	  [Outcome] = 4
  WHERE[TimeEnded] is NULL
       and datediff(HOUR,[TimeStarted],SYSDATETIME ( ))<24
 
END