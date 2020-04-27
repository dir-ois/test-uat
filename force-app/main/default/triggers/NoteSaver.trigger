trigger NoteSaver on Note (after update, after delete) {
    // Get the current user's profile name
    Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];
    
    // If current user is not a System Administrator, do not allow Notes to be deleted
    if(Trigger.isDelete){
        if (!prof.Name.contains('System Administrator'))
        {
            for (Note a : Trigger.old) {
                a.addError('You do not have permission to delete notes. Please create a new note to supersede this one');
            }   
        }
    }
    else{
        if (!prof.Name.contains('System Administrator'))
        {
            for (Note a : Trigger.new) {
                //note actualNote = Trigger.oldMap.get(a.Id);
                a.addError('Unable to edit notes. Please create a new note to supersede this one.');
            }   
        }
    }

    
}