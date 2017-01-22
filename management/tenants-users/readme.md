# Summary

The 'projects.sh' script does the following:

- creates a tenant
- creates two users per tenant
- [ creates bastion VM ]
- sends info per mail

The creation of the bastion VM is optionnal. Everything depends on the users.csv file as following:

```
groupe1;user11;passwd11;user12;passwd12;user11@example.fr;yes
groupe2;user21;passwd21;user22;passwd22;user21@example.fr;no

```
**Note: ** the last line must have a new line otherwise the script won't parse it


If the last element is set to 'yes' a bastion VM will be created and its ssh key as well as its floating ip will
be added to the project's directory.

This directory is zipped and send to the user's email through [mailgun](https://www.mailgun.com/) API. 


# Mailgun

Several elements has to be set in the environment.

```
	export INFRA_MAILGUN_API_KEY="key-XXXXXXXXXXXXXXXXXXXXX"
	export INFRA_MAILGUN_MAIL="equipe-infra@XXXXXXXXXXXXXXXXXXXX.mailgun.org"
	export INFRA_MAILGUN_API_END_POINT="https://api.mailgun.net/v3/XXXXXXXXX.mailgun.org/messages"
```

## Important
If no domain name was set in the mailgun account, you won't be able to send email to somebody else than your account
(as well as a few other you would have previously add). So the email in the users.csv file **won't work**.



# Openstack

For the tenant and user creation, the keysonerc_admin must be sourced **before** calling the script.
You must also set this value : 
```
	export INFRA_OPENSTACK_AUTH_URL="http://XX.XX.XX.XXX:5000/v2.0"
```

**WARNING:** After this script, you must **source again** the keystonerc_admin file !



