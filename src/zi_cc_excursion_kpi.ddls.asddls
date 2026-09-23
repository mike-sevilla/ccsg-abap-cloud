@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Excursion Analytical View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CC_EXCURSION_KPI
  as select from ZI_CC_EXCURSION
{
  key ZoneId,

      count( * )                              as ExcursionCount,
      avg( DegreeMinutes  as abap.dec(15,2) ) as AvgDegreeMinutes,
      max( MaxTemperature )                   as PeakTemperature

}

group by
  ZoneId
