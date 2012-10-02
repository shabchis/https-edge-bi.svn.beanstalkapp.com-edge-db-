CREATE PROCEDURE [dbo].[CLR_SP_Delivery_Commit_BO_Generic]
@DeliveryID NVARCHAR (4000), @DeliveryTablePrefix NVARCHAR (4000), @MeasuresNamesSQL NVARCHAR (4000), @MeasuresFieldNamesSQL NVARCHAR (4000), @CommitTableName NVARCHAR (4000) OUTPUT
AS EXTERNAL NAME [Deliveries].[StoredProcedures].[CLR_SP_Delivery_Commit_BO_Generic]


GO
EXECUTE sp_addextendedproperty @name = N'SqlAssemblyFile', @value = N'CLR_SP_Delivery_Commit_BO_Generic.cs', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'CLR_SP_Delivery_Commit_BO_Generic';


GO
EXECUTE sp_addextendedproperty @name = N'SqlAssemblyFileLine', @value = N'12', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'CLR_SP_Delivery_Commit_BO_Generic';

