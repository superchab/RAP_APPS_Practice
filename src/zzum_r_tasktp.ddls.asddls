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
      /* 1. Logic for Color (Criticality) */
      case OverallStatus
        when 'I' then 2  -- Yellow (In Progress)
        when 'C' then 3  -- Green  (Completed)
        when 'E' then 1  -- Red    (Error)
        when 'P' then 0  -- Grey   (Pending)
        else 0           -- Grey   (Initial/Empty)
      end as StatusCriticality,
      /* 2. Logic for Text (Description) */
      case OverallStatus
        when 'I' then 'In Progress'
        when 'C' then 'Completed'
        when 'E' then 'Error'
        when 'P' then 'Pending'
        else 'Initial'
      end as StatusDescription,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      Locallastchangedat,

      _Subtask // Make association public
}
