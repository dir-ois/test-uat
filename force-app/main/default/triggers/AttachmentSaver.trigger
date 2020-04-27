trigger AttachmentSaver on Attachment (after delete) {
    // Get the current user's profile name
    Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];
    
    // If current user is not a System Administrator or HR Personnel Specialist User, do not allow Attachments to be deleted
    if (!(prof.Name.contains('System Administrator') ||
          prof.Name.contains('HR Personnel Specialist User')
         )
       ) {
        for (Attachment a : Trigger.old) {
            a.addError('Unable to delete attachments.');
        }   
    }
}