@EndUserText.label: 'File ENASARCO online'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /EACM/I_EON_FILE
  as select from /eacm/eon_file
{
  key file_uuid as FileUuid,

      created_by as CreatedBy,
      created_at as CreatedAt,

      file_name as FileName,

      @Semantics.mimeType: true
      mime_type as MimeType,

      file_size as FileSize,

      @Semantics.largeObject: {
        mimeType: 'MimeType',
        fileName: 'FileName',
        contentDispositionPreference: #ATTACHMENT
      }
      file_content as FileContent
}
