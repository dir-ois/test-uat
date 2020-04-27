@isTest private class EmailToSupportRequest_Test{
   static testMethod void TestinBoundEmailServiceNow()
   {
       // create a new email and envelope object
       Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
       // setup the data for the email
      email.subject = 'Helpdesk to SR';
      email.fromAddress = 'dirhelp@service-now.com';
      email.plainTextBody = 'email body\n2225256325\nTitle';
      
      // add an Binary attachment
      Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
      attachment.body = blob.valueOf('my attachment text');
      attachment.fileName = 'textfileone.txt';
      attachment.mimeTypeSubType = 'text/plain';
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
      
      
  
      // add an Text atatchment
  
      Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
      attachmenttext.body = 'my attachment text';
      attachmenttext.fileName = 'textfiletwo3.txt';
      attachmenttext.mimeTypeSubType = 'texttwo/plain';
      email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
      
      
      // call the email service class and test it with the data in the testMethod
      EmailToSupportRequest testInbound=new EmailToSupportRequest();
      testInbound.handleInboundEmail(email, env);
    
     
   
   }
   
   static testMethod void TestinBoundEmailNotServiceNow()
   {
       // create a new email and envelope object
       Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
       // setup the data for the email
      email.subject = 'Helpdesk to SR';
      email.fromAddress = 'dirhelp@yahoo.com';
      email.plainTextBody = 'email body\n2225256325\nTitle';
      
      // add an Binary attachment
      Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
      attachment.body = blob.valueOf('my attachment text');
      attachment.fileName = 'textfileone.txt';
      attachment.mimeTypeSubType = 'text/plain';
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
      
      
  
      // add an Text atatchment
  
      Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
      attachmenttext.body = 'my attachment text';
      attachmenttext.fileName = 'textfiletwo3.txt';
      attachmenttext.mimeTypeSubType = 'texttwo/plain';
      email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
      
      
      // call the email service class and test it with the data in the testMethod
      EmailToSupportRequest testInbound=new EmailToSupportRequest();
      testInbound.handleInboundEmail(email, env);
    
     
   }
}