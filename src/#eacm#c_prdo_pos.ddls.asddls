@EndUserText.label: 'NPRDO - Posizioni Consumption'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity /EACM/C_PRDO_POS
  as projection on /EACM/I_PRDO_POS
{
  key Zclpr,
  key Bukrs,
  key Vkorg,
  key Vtweg,
  key Vbeln,
  key Gjahr,
  key Posnr,

  Material,
  MaterialDescription,
  Waerk,
  Quantity,
  LocalLastChangedAt,

  @ObjectModel.virtualElementCalculatedBy: 'ABAP:/EACM/CL_PRDO_AGT_HIDE'
  virtual HideAgentsAnticipi : abap_boolean,

  @ObjectModel.virtualElementCalculatedBy: 'ABAP:/EACM/CL_PRDO_AGT_HIDE'
  virtual HideAgentsProvvigioni : abap_boolean,

  _Document : redirected to parent /EACM/C_PRDO_DOC,
  _Agents   : redirected to composition child /EACM/C_PRDO_AGT
}
