@EndUserText.label: 'Download file ENASARCO online'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@UI.headerInfo: {
  typeName: 'File ENASARCO',
  typeNamePlural: 'File ENASARCO'
}
define root view entity /EACM/C_EON_FILE
  as projection on /EACM/I_EON_FILE
{
  @UI.lineItem: [{ position: 10 }]
  key FileUuid,

  @UI.lineItem: [{ position: 20 }]
  FileName,

  @UI.lineItem: [{ position: 30 }]
  CreatedAt,

  @UI.hidden: true
  CreatedBy,

  @UI.hidden: true
  MimeType,

  @UI.lineItem: [{ position: 40 }]
  FileSize,

  @UI.lineItem: [{ position: 50, label: 'Download' }]
  @UI.identification: [{ position: 50, label: 'Download' }]
  FileContent
}
