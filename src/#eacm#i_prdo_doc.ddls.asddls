@EndUserText.label: 'NPRDO - Documento'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity /EACM/I_PRDO_DOC
  as select from /eacm/prdo as z
  composition [0..*] of /EACM/I_PRDO_POS as _Positions
{
  key z.zclpr as Zclpr,
  key z.bukrs as Bukrs,
  key z.vkorg as Vkorg,
  key z.vtweg as Vtweg,
  key z.vbeln as Vbeln,
  key z.gjahr as Gjahr,


min( z.kunrg ) as kunrg,
max( z.fkdat ) as fkdat,
z.waerk as Waerk,

  max( z.local_last_changed_at ) as LocalLastChangedAt,

  _Positions
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
//  z.kunrg,
//  z.fkdat,
   z.waerk




