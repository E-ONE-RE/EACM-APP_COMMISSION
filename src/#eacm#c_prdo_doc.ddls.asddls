@EndUserText.label: 'NPRDO - Documento Consumption'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity /EACM/C_PRDO_DOC
  provider contract transactional_query
  as projection on /EACM/I_PRDO_DOC
{
      @Consumption.valueHelpDefinition: [
        {
          entity: {
            name: '/EACM/H_ZCLPR',
            element: 'Zclpr'
          },
          useForValidation: true
        }
      ]
  
  key Zclpr,
  
      @Consumption.valueHelpDefinition: [
        {
          entity: {
            name: '/EACM/C_T001',
            element: 'Bukrs'
          },
          useForValidation: true
        }
      ]
  key Bukrs,
  
      @Consumption.valueHelpDefinition: [
        {
          entity: {
            name: '/EACM/C_TVKO',
            element: 'Vkorg'
          },
          useForValidation: true
        }
      ]

  key Vkorg,
  
      @Consumption.valueHelpDefinition: [
        {
          entity: {
            name: '/EACM/C_TVTW',
            element: 'Vtweg'
          },
          useForValidation: true
        }
      ]

  key Vtweg,

   @Search.defaultSearchElement: true
  key Vbeln,

  key Gjahr,
  
  kunrg,
  fkdat,
  
     LocalLastChangedAt,

      _Positions : redirected to composition child /EACM/C_PRDO_POS
}
