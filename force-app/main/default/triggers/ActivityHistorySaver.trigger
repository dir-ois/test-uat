trigger ActivityHistorySaver on Task (after delete) 
{
// Get the current user's profile name
  Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];
  
  // If current user is not a System Administrator, do not allow Activity History events to be deleted
  if (!prof.Name.contains('System Administrator')) 
  {
    for (task t : Trigger.old) 
    {
      t.addError('You do not have permission to delete tasks from the Activity History');
    }  
  }

}