//@EndUserText.label: 'NPRDO - Agenti Consumption'
//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@Metadata.allowExtensions: true
//define view entity /EACM/C_PRDO_AGT
//  as projection on /EACM/I_PRDO_AGT
//{
//  key Zclpr,
//  key Bukrs,
//  key Vkorg,
//  key Vtweg,
//  key Vbeln,
//  key Gjahr,
//  key Posnr,
//  key Zidag,
//  
//        @Consumption.valueHelpDefinition: [
//        {
//          entity: {
//            name: '/EACM/ZAGE',
//            element: 'Zcdaz'
//          },
//          useForValidation: true
//        }
//      ]
//  key Zcdaz,
//
//
//  UnitMeasure,
//  Kunrg,
//   
//  Zimar,
//  Ziman,
//  Zpcpr,
//  Zimpp,
//  Zimco,
//  Zimpu,  
//  Zdest,
//
//  LocalLastChangedAt,
//
//// serve per visualizzare dei campi diversi, in AGENTS, in base
//// al valore di ZCPLR ( che è solo di testata).
//// Classe /EACM/CL_PRDO_AGT_HIDE
//@ObjectModel.virtualElementCalculatedBy: 'ABAP:/EACM/CL_PRDO_AGT_HIDE'
//virtual HideAnticipo : abap_boolean,
//
//@ObjectModel.virtualElementCalculatedBy: 'ABAP:/EACM/CL_PRDO_AGT_HIDE'
//virtual HideAltriCampi : abap_boolean,
//
//  _Document : redirected to /EACM/C_PRDO_DOC,
//  _Position : redirected to parent /EACM/C_PRDO_POS
//}
@EndUserText.label: 'NPRDO - Agenti Consumption'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity /EACM/C_PRDO_AGT
  as projection on /EACM/I_PRDO_AGT
{
  key Zclpr,
  key Bukrs,
  key Vkorg,
  key Vtweg,
  key Vbeln,
  key Gjahr,
  key Posnr,
  key Zidag,
  
        @Consumption.valueHelpDefinition: [
        {
          entity: {
            name: '/EACM/ZAGE',
            element: 'Zcdaz'
          },
          useForValidation: true
        }
      ]
  key Zcdaz,


  UnitMeasure,
  Kunrg,
  Budat,
  Zwaer,
  Kurrf,
  Ztpag,
  Zstre,
  Zmodi,
  Zcamd,
  Zdtmd,
  Zormd,
    
  Zimar,
  Ziman,
  Zpcpr,
  Zimpp,
  Zimco,
  Zimpu,  
  Zdest,

  LocalLastChangedAt,

// serve per visualizzare dei campi diversi, in AGENTS, in base
// al valore di ZCPLR ( che è solo di testata).
// Classe /EACM/CL_PRDO_AGT_HIDE
@ObjectModel.virtualElementCalculatedBy: 'ABAP:/EACM/CL_PRDO_AGT_HIDE'
virtual HideAnticipo : abap_boolean,

@ObjectModel.virtualElementCalculatedBy: 'ABAP:/EACM/CL_PRDO_AGT_HIDE'
virtual HideAltriCampi : abap_boolean,

  _Document : redirected to /EACM/C_PRDO_DOC,
  _Position : redirected to parent /EACM/C_PRDO_POS
}
