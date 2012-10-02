-- =============================================
-- Author:	Shay Barchen
-- Create date: 21.06.2012
-- Description:	Signature migration for Adwords services
-- =============================================
CREATE PROCEDURE [dbo].[Output_Signature_Migration_Adwords_GND]

AS

DECLARE
 @DeliveryID char(32)
,@OutputID  char(32)
,@AccountID int
,@ChannelID int
,@Signature nvarchar(400)
,@Decode_Signature nvarchar(max)
,@Status int
,@PipelineInstanceID bigint
,@TimePeriodStart datetime2(7)
,@TimePeriodEnd datetime2(7)
,@DateCreated datetime
,@DateModified datetime
,@TableName nvarchar(100)
,@NewSignature nvarchar(max)
,@SignaturePrefix nvarchar(100)


	
DECLARE _cursor CURSOR FOR
SELECT
	   DOutput.[DeliveryID]
      ,DOutput.[OutputID]
      ,DOutput.[AccountID]
      ,DOutput.[ChannelID]
      ,DOutput.[Signature]
      ,dbo.ConvertFromBase64CLR(DOutput.[Signature])
      ,DOutput.[Status]
      ,DOutput.[PipelineInstanceID]
      ,DOutput.[TimePeriodStart]
      ,DOutput.[TimePeriodEnd]
      ,DOutput.[DateCreated]
      ,DOutput.[DateModified]
      ,params.Value
FROM  dbo.DeliveryOutput DOutput
inner join [dbo].[DeliveryOutputParameters] as params
  on params.DeliveryID collate Hebrew_CI_AS = DOutput.DeliveryID
where channelid = 1 and [Key] like 'CommitTableName'
and  DOutput.[Signature] = N'R29vZ2xlQWR3b3Jkc1NlYXJjaC1bOTVdLVtlZGdlLmJpLm1jY0BnbWFpbC5jb21dLVs4MjUtMzE4LTQxNzZdLVt7c3RhcnQ6e2FsaWduOidTdGFydCcsZGF0ZTonMjAxMi0wNi0wNlQwMDowMDowMCd9LGVuZDp7YWxpZ246J0VuZCcsZGF0ZTonMjAxMi0wNi0wNlQyMzo1OTo1OS45OTk5OTk5J319XS1bQURfUEVSRk9STUFOQ0VfUkVQT1JUfEtFWVdPUkRTX1BFUkZPUk1BTkNFX1JFUE9SVF0='


OPEN _cursor


/***/--Print 'open cursor'


FETCH NEXT FROM _cursor --FOR UPDATE
INTO @DeliveryID ,@OutputID  ,@AccountID ,@ChannelID ,@Signature ,@Decode_Signature ,@Status ,@PipelineInstanceID ,@TimePeriodStart 
,@TimePeriodEnd ,@DateCreated ,@DateModified, @TableName



WHILE @@FETCH_STATUS = 0
BEGIN

/***/--print 'Table Name= '+ @TableName

 SET @SignaturePrefix = 
    (
		select value
		from dbo.SplitString(@Decode_Signature, '-')
		where zeroBasedOccurance=0
    )
print 'Current Prefix = '+@SignaturePrefix

--Google
print 'checking table name'+ @TableName
If @TableName like '"Paid_API_AllColumns_v29"'
	BEGIN
		--print 'Paid_API_AllColumns_v29:'
		--print REPLACE(@Decode_Signature,@SignaturePrefix,'GoogleSearch')
		
		SET @NewSignature = dbo.ConvertToBase64CLR(REPLACE(@Decode_Signature,@SignaturePrefix,'GoogleSearch'))
		--print 'New Encoded signature:'+ @NewSignature
		--print 'Test: '+ dbo.ConvertFromBase64CLR(@NewSignature);
	END
	
ELSE if @TableName like '"Paid_API_Content_v29"'
	BEGIN
	   -- print 'Paid_API_AllColumns_v29'
	   -- print REPLACE(@Decode_Signature,@SignaturePrefix,'GDN')
	    
		SET @NewSignature = dbo.ConvertToBase64CLR(REPLACE(@Decode_Signature,@SignaturePrefix,'GDN'))
		
	--print 'New Encoded signature:'+ @NewSignature
	--	print 'Test: '+ dbo.ConvertFromBase64CLR(@NewSignature);
	END


UPDATE  dbo.DeliveryOutput
SET
[Signature] = @NewSignature
WHERE
      [DeliveryID] = @DeliveryID
	  AND [OutputID] = @OutputID
	  AND [AccountID] = @AccountID
      AND [ChannelID] = @ChannelID
      AND [Signature] = @Signature
      AND [Status] = @Status
      AND [PipelineInstanceID] = @PipelineInstanceID
      AND [TimePeriodStart] = @TimePeriodStart
      AND [TimePeriodEnd] = @TimePeriodEnd
      AND [DateCreated] = @DateCreated
      AND [DateModified] = @DateModified
 
 FETCH NEXT FROM _cursor --FOR UPDATE
INTO @DeliveryID ,@OutputID  ,@AccountID ,@ChannelID ,@Signature ,@Decode_Signature ,@Status ,@PipelineInstanceID ,@TimePeriodStart 
,@TimePeriodEnd ,@DateCreated ,@DateModified, @TableName     
END

CLOSE _cursor
DEALLOCATE _cursor;  
