@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Transactional view for Task header'

@Metadata.ignorePropagatedAnnotations: true

define root view entity zzum_r_tasktp
  as select from zzum_i_task_head

  composition [1..*] of zzum_r_subtasktp as _Subtask

{
  key TaskUuid,

      TaskId,
      Title,
      Description,
      OverallStatus,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      Locallastchangedat,

      _Subtask // Make association public
}
