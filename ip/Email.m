% %==================================================================% +-------+
% % Utility                                                          % | | | * |
% %                                                                  % | |/    |
% % /utility/ip/Email.m                                              % | |_| * |
% %==================================================================% +-------+
% Email() sends email notifications. Email initializes and calls sendmail().
%
% USAGE:
%   [] = Email(to, subject, message?, attachments?)
%
% INPUT:
%   char [1,?] to          % Email recipient(s) (may be cell of strings)
%   char [1,?] subject     % Email subject
%   char [1,?] message     % Email body (may be cell of strings)
%   char [1,?] attachments % Email attachment file(s) (may be cell of strings)
%   
% OUTPUT:
%   ~
%
% NOTES:
%   A lab-wide email account at 'matlab_daemon@outlook.com' has been created to
% send experimental email notifications.  The password is the lab password.
%   To send mail, you need to set up a Simple Mail Transfer Protocol (SMTP) mail
% server. For Outlook users associate the daemon email address with Outlook and
% point the 'SMTP_Server' field inside Email() to 'smtp-mail.outlook.com'.

function [] = Email(to, subject, message, attachments)
    % Set login
    setpref('Internet','E_mail','matlab_daemon@outlook.com');
    setpref('Internet','SMTP_Server','smtp-mail.outlook.com');
    setpref('Internet','SMTP_Username','matlab_daemon@outlook.com');
    setpref('Internet','SMTP_Password','12Plasmons');
    % Set protocol (SSL)
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.starttls.enable','true');
    props.setProperty('mail.smtp.socketFactory.class','javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    % Send mail
    switch nargin()
    case 2
        sendmail(to, subject);
    case 3
        sendmail(to, subject, message);
    case 4
        sendmail(to, subject, message, attachments);
    end
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
