
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================


/* Base64 decoder fot T-SQL */
CREATE PROCEDURE [dbo].[Base64ToString]
(
	@Base64 VARCHAR(4000),
	@String VARCHAR(4000) OUTPUT
) AS

DECLARE 
@ByteArray INT,
@OLEResult INT


EXECUTE @OLEResult = sp_OACreate 'ScriptUtils.ByteArray', @ByteArray OUT
IF @OLEResult <> 0 PRINT 'ScriptUtils.ByteArray problem'

--Set a charset if needed.
execute @OLEResult = sp_OASetProperty @ByteArray, 'CharSet', "UTF-8"
IF @OLEResult <> 0 PRINT 'CharSet problem'

--Set the base64 string
EXECUTE @OLEResult = sp_OASetProperty @ByteArray, 'Base64', @Base64
IF @OLEResult <> 0 PRINT 'Base64 problem'

--Get a string data.
EXECUTE @OLEResult = sp_OAGetProperty @ByteArray, 'String', @String OUTPUT
IF @OLEResult <> 0 PRINT 'String problem'

--Or you can get the data as binary/image.
--Declare @Binary varbinary(4000)
--Declare @Binary image
--execute @OLEResult = sp_OAGetProperty @ByteArray, 'ByteArray', @Binary OUTPUT
--IF @OLEResult <> 0 PRINT 'ByteArray problem'