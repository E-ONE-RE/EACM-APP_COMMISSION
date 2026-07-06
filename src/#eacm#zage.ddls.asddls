@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Help per estrazione codice agente'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/ZAGE as select from /eacm/zpraa
{
  key zcdaz as Zcdaz,
      name1
}
