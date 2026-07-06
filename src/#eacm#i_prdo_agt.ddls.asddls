//@EndUserText.label: 'NPRDO - Agenti'
//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@Metadata.allowExtensions: true
//define view entity /EACM/I_PRDO_AGT
//  as select from /eacm/prdo as z
//  association to /EACM/I_PRDO_DOC as _Document
//    on  $projection.Zclpr = _Document.Zclpr
//    and $projection.Bukrs = _Document.Bukrs
//    and $projection.Vkorg = _Document.Vkorg
//    and $projection.Vtweg = _Document.Vtweg
//    and $projection.Vbeln = _Document.Vbeln
//    and $projection.Gjahr = _Document.Gjahr
// 
//  association to parent /EACM/I_PRDO_POS as _Position
//    on  $projection.Zclpr = _Position.Zclpr
//    and $projection.Bukrs = _Position.Bukrs
//    and $projection.Vkorg = _Position.Vkorg
//    and $projection.Vtweg = _Position.Vtweg
//    and $projection.Vbeln = _Position.Vbeln
//    and $projection.Gjahr = _Position.Gjahr
//    and $projection.Posnr = _Position.Posnr
//{
//  key z.zclpr as Zclpr,
//  key z.bukrs as Bukrs,
//  key z.vkorg as Vkorg,
//  key z.vtweg as Vtweg,
////  key cast( lpad( z.vbeln, 10, '0' ) as vbeln_va ) as Vbeln,
//  key z.vbeln as Vbeln,
//  key z.gjahr as Gjahr,
//  key z.posnr as Posnr,
//  key z.zidag as Zidag,
//  key z.zcdaz as Zcdaz,
//
//  z.zutmx as UnitMeasure,
//  z.fkdat as DocumentDate,
//  z.kunrg as Kunrg,
// 
//case
//  when z.zclpr = 'ANTICIPI'
//    then cast( ' ' as abap_boolean )
//  else cast( 'X' as abap_boolean )
//end as HideAnticipo,
//
//case
//  when z.zclpr = 'ANTICIPI'
//    then cast( 'X' as abap_boolean )
//  else cast( ' ' as abap_boolean )
//end as HideAltriCampi,
//
//
// @EndUserText.label: 'Importo recuper'
//  cast( z.zimar as abap.dec( 15, 2 ) ) as Zimar,
//  @EndUserText.label: 'Importo anticipato'
//  cast( z.ziman as abap.dec( 15, 2 ) ) as Ziman,
//  
//  cast( z.zpcpr as abap.dec( 8, 5 ) ) as Zpcpr,
////  z.zpcpr as Zpcpr,
//  @EndUserText.label: 'Base di Calcolo'
//  cast( z.zimpp as abap.dec( 15, 2 ) ) as Zimpp,
//  @EndUserText.label: 'Importo Provvigione'
//  cast( z.zimco as abap.dec( 15, 2 ) ) as Zimco,
//  @EndUserText.label: 'Provvigione a valore'
//  cast( z.zimpu as abap.dec( 15, 2 ) ) as Zimpu,  
//  
//  z.zdest as Zdest,
//  z.local_last_changed_at as LocalLastChangedAt,
//  
//  _Document,
//  _Position
//}
//where z.posnr <> '000000'
@EndUserText.label: 'NPRDO - Agenti'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity /EACM/I_PRDO_AGT
  as select from /eacm/prdo as z
  association to /EACM/I_PRDO_DOC as _Document
    on  $projection.Zclpr = _Document.Zclpr
    and $projection.Bukrs = _Document.Bukrs
    and $projection.Vkorg = _Document.Vkorg
    and $projection.Vtweg = _Document.Vtweg
    and $projection.Vbeln = _Document.Vbeln
    and $projection.Gjahr = _Document.Gjahr
 
  association to parent /EACM/I_PRDO_POS as _Position
    on  $projection.Zclpr = _Position.Zclpr
    and $projection.Bukrs = _Position.Bukrs
    and $projection.Vkorg = _Position.Vkorg
    and $projection.Vtweg = _Position.Vtweg
    and $projection.Vbeln = _Position.Vbeln
    and $projection.Gjahr = _Position.Gjahr
    and $projection.Posnr = _Position.Posnr
{
  key z.zclpr as Zclpr,
  key z.bukrs as Bukrs,
  key z.vkorg as Vkorg,
  key z.vtweg as Vtweg,
//  key cast( lpad( z.vbeln, 10, '0' ) as vbeln_va ) as Vbeln,
  key z.vbeln as Vbeln,
  key z.gjahr as Gjahr,
  key z.posnr as Posnr,
  key z.zidag as Zidag,
  key z.zcdaz as Zcdaz,

  z.zutmx as UnitMeasure,
  z.fkdat as DocumentDate,
  z.kunrg as Kunrg,
  z.budat as Budat,
  z.zwaer as Zwaer,
  z.kurrf as Kurrf,
  z.ztpag as Ztpag,
  z.zstre as Zstre,
  z.zmodi as Zmodi,
  z.zcamd as Zcamd,
  z.zdtmd as Zdtmd,
  z.zormd as Zormd,
 
case
  when z.zclpr = 'ANTICIPI'
    then cast( ' ' as abap_boolean )
  else cast( 'X' as abap_boolean )
end as HideAnticipo,

case
  when z.zclpr = 'ANTICIPI'
    then cast( 'X' as abap_boolean )
  else cast( ' ' as abap_boolean )
end as HideAltriCampi,


 @EndUserText.label: 'Importo recuper'
  cast( z.zimar as abap.dec( 15, 2 ) ) as Zimar,
  @EndUserText.label: 'Importo anticipato'
  cast( z.ziman as abap.dec( 15, 2 ) ) as Ziman,
  
  cast( z.zpcpr as abap.dec( 8, 5 ) ) as Zpcpr,
//  z.zpcpr as Zpcpr,
  @EndUserText.label: 'Base di Calcolo'
  cast( z.zimpp as abap.dec( 15, 2 ) ) as Zimpp,
  @EndUserText.label: 'Importo Provvigione'
  cast( z.zimco as abap.dec( 15, 2 ) ) as Zimco,
  @EndUserText.label: 'Provvigione a valore'
  cast( z.zimpu as abap.dec( 15, 2 ) ) as Zimpu,  
  
  z.zdest as Zdest,
  z.local_last_changed_at as LocalLastChangedAt,
  
  _Document,
  _Position
}
where z.posnr <> '000000'
  and z.zstre <> 'D'
  and z.zmodi <> 'D'
