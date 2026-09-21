@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cold-Chain Excursion Interface View'
define root view entity ZI_CC_EXCURSION
  as select from zdt_cc_exc_hdr

  association [1..1] to ZI_CC_ZONE      as _Zone  on $projection.ZoneId = _Zone.ZoneId

  association [0..*] to zi_cc_exc_batch as _Batch on $projection.ExcursionID = _Batch.ExcursionId
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
      @Semantics.user.createdBy: true
      created_by     as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at     as CreatedAt,
      @Semantics.user.lastChangedBy: true
      changed_by     as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at     as ChangedAt,

      _Zone,
      _Batch
}
