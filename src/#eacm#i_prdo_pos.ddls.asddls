//@EndUserText.label: 'NPRDO - Posizioni'
//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@Metadata.allowExtensions: true
//define view entity /EACM/I_PRDO_POS
//  as select from /eacm/prdo as z
//  association to parent /EACM/I_PRDO_DOC as _Document
//    on  $projection.Zclpr = _Document.Zclpr
//    and $projection.Bukrs = _Document.Bukrs
//    and $projection.Vkorg = _Document.Vkorg
//    and $projection.Vtweg = _Document.Vtweg
//    and $projection.Vbeln = _Document.Vbeln
//    and $projection.Gjahr = _Document.Gjahr
//  composition [0..*] of /EACM/I_PRDO_AGT as _Agents
//{
//  key z.zclpr as Zclpr,
//  key z.bukrs as Bukrs,
//  key z.vkorg as Vkorg,
//  key z.vtweg as Vtweg,
//  key z.vbeln as Vbeln,
//  key z.gjahr as Gjahr,
//  key z.posnr as Posnr,
//
//  min( z.matnr ) as Material,
//  min( z.maktx ) as MaterialDescription,
//  z.waerk as Waerk,
//  max( z.menge ) as Quantity,
//  
//  max( z.local_last_changed_at ) as LocalLastChangedAt,
//
//
//  _Document,
//  _Agents
//}
//where z.posnr <> '000000'
//group by
//  z.zclpr,
//  z.bukrs,
//  z.vkorg,
//  z.vtweg,
//  z.vbeln,
//  z.gjahr,
//  z.posnr,
//  z.waerk

@EndUserText.label: 'NPRDO - Posizioni'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity /EACM/I_PRDO_POS
  as select from /eacm/prdo as z
  association to parent /EACM/I_PRDO_DOC as _Document
    on  $projection.Zclpr = _Document.Zclpr
    and $projection.Bukrs = _Document.Bukrs
    and $projection.Vkorg = _Document.Vkorg
    and $projection.Vtweg = _Document.Vtweg
    and $projection.Vbeln = _Document.Vbeln
    and $projection.Gjahr = _Document.Gjahr
  composition [0..*] of /EACM/I_PRDO_AGT as _Agents
{
  key z.zclpr as Zclpr,
  key z.bukrs as Bukrs,
  key z.vkorg as Vkorg,
  key z.vtweg as Vtweg,
  key z.vbeln as Vbeln,
  key z.gjahr as Gjahr,
  key z.posnr as Posnr,

  min( z.matnr ) as Material,
  min( z.maktx ) as MaterialDescription,
  z.waerk as Waerk,
  max( z.menge ) as Quantity,
  
  max( z.local_last_changed_at ) as LocalLastChangedAt,


  _Document,
  _Agents
}
where z.posnr <> '000000'
  and z.zstre <> 'D'
  and z.zmodi <> 'D'
group by
  z.zclpr,
  z.bukrs,
  z.vkorg,
  z.vtweg,
  z.vbeln,
  z.gjahr,
  z.posnr,
  z.waerk
