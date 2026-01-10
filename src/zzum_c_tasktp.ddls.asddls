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
      @ObjectModel.text.element: [ 'StatusDescription' ]
      OverallStatus,
      StatusCriticality,
      StatusDescription,
      Locallastchangedat, -- Needed for ETag

      /* Associations */
      _Subtask : redirected to composition child zzum_c_subtaskTP
}
