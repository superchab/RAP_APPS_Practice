@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Task Header Projection'

@Metadata.allowExtensions: true

define root view entity zzum_c_tasktp
  provider contract transactional_query
  as projection on zzum_r_tasktp

{
  key TaskUuid,

      TaskId,
      Title,
      Description,
      OverallStatus,

      Locallastchangedat, -- Needed for ETag

      /* Associations */
      _Subtask : redirected to composition child zzum_c_subtaskTP
}
