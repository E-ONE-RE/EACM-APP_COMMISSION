@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help Classifica Provvigioni'
@ObjectModel.dataCategory: #VALUE_HELP
define view entity /EACM/H_ZCLPR
  as select from /eacm/zpr08
{
  key zclpr as Zclpr,
      bukrs,
      zdesc
}
