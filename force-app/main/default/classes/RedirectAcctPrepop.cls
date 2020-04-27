public class RedirectAcctPrepop {
private Contact con {get; set;}

public RedirectAcctPrepop (ApexPages.StandardController stdController)
{
    this.con = (Contact) stdController.getRecord();
}
public PageReference newContact()
{
    PageReference retVal = new PageReference('/003/e?retURL=%2F003%2Fo&con4=DIR');
    retVal.getParameters().put('nooverride', '1');
    retVal.setRedirect(true); 
    return retVal;
}
}