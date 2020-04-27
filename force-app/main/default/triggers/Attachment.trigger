trigger Attachment on Attachment (after insert, after update, before delete, before insert, before update) {
	GenerateAttachmentsPlusAction.runHandler();
}