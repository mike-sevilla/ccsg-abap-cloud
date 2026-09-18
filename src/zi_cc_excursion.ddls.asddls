@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cold-Chain Excursion Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CC_EXCURSION
  as select from zdt_cc_exc_hdr
{
  key exc_id         as ExcursionID,
      zone_id        as ZoneId,
      plant          as Plant,
      start_ts       as StartTimestamp,
      end_ts         as EndTimestamp,
      max_temp_c     as MaxTemperature,
      degree_minutes as DegreeMinutes,
      exc_status     as Status,
      disposition    as Disposition,
      created_by     as CreatedBy,
      created_at     as CreatedAt,
      changed_by     as ChangedBy,
      changed_at     as ChangedAt
}
