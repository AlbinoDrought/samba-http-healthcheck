[![logo](https://raw.githubusercontent.com/albinodrought/samba-with-http-healthcheck/master/logo.jpg)](https://www.samba.org)

# Samba

Samba docker container

# What is Samba?

Since 1992, Samba has provided secure, stable and fast file and print services
for all clients using the SMB/CIFS protocol, such as all versions of DOS and
Windows, OS/2, Linux and many others.

# How to use this image

By default there are no shares configured, additional ones can be added.

## Hosting a Samba instance

    sudo docker run -it -p 139:139 -p 445:445 -d albinodrought/samba-with-http-healthcheck

OR set local storage:

    sudo docker run -it --name samba -p 139:139 -p 445:445 \
                -v /path/to/directory:/mount \
                -d albinodrought/samba-with-http-healthcheck

## Configuration

    sudo docker run -it --rm albinodrought/samba-with-http-healthcheck -h
    Usage: samba.sh [-opt] [command]
    Options (fields in '[]' are optional, '<>' are required):
        -h          This help
        -c "<from:to>" setup character mapping for file/directory names
                    required arg: "<from:to>" character mappings separated by ','
        -g "<parameter>" Provide global option for smb.conf
                    required arg: "<parameter>" - IE: -g "log level = 2"
        -i "<path>" Import smbpassword
                    required arg: "<path>" - full file path in container
        -n          Start the 'nmbd' daemon to advertise the shares
        -p          Set ownership and permissions on the shares
        -r          Disable recycle bin for shares
        -S          Disable SMB2 minimum version
        -s "<name;/path>[;browse;readonly;guest;users;admins;writelist;comment]"
                    Configure a share
                    required arg: "<name>;</path>"
                    <name> is how it's called for clients
                    <path> path to share
                    NOTE: for the default values, just leave blank
                    [browsable] default:'yes' or 'no'
                    [readonly] default:'yes' or 'no'
                    [guest] allowed default:'yes' or 'no'
                    [users] allowed default:'all' or list of allowed users
                    [admins] allowed default:'none' or list of admin users
                    [writelist] list of users that can write to a RO share
                    [comment] description of share
        -u "<username;password>[;ID;group]"       Add a user
                    required arg: "<username>;<passwd>"
                    <username> for user
                    <password> for user
                    [ID] for user
                    [group] for user
        -w "<workgroup>"       Configure the workgroup (domain) samba should use
                    required arg: "<workgroup>"
                    <workgroup> for samba
        -W          Allow access wide symbolic links
        -I          Add an include option at the end of the smb.conf
                    required arg: "<include file path>"
                    <include file path> in the container, e.g. a bind mount

    The 'command' (if provided and valid) will be run instead of samba

ENVIRONMENT VARIABLES

 * `CHARMAP` - As above, configure character mapping
 * `GLOBAL` - As above, configure a global option
 * `IMPORT` - As above, import a smbpassword file
 * `NMBD` - As above, enable nmbd
 * `PERMISSIONS` - As above, set file permissions on all shares
 * `RECYCLE` - As above, disable recycle bin
 * `SHARE` - As above, setup a share
 * `SMB` - As above, disable SMB2 minimum version
 * `TZ` - Set a timezone, IE `EST5EDT`
 * `USER` - As above, setup a user
 * `WIDELINKS` - As above, allow access wide symbolic links
 * `WORKGROUP` - As above, set workgroup
 * `USERID` - Set the UID for the samba server
 * `GROUPID` - Set the GID for the samba server
 * `INCLUDE` - As above, add a smb.conf include
 * `HEALTHCHECK_SHARE` - Name of the share to perform IO checks on. Healthcheck results will be available on port 8080, returning 200 if OK and 500 if not ok.

**NOTE**: if you enable nmbd (via `-n` or the `NMBD` environment variable), you
will also want to expose port 137 and 138 with `-p 137:137/udp -p 138:138/udp`.

**NOTE2**: there are reports that `-n` and `NMBD` only work if you have the
container configured to use the hosts network stack.

## Examples

Any of the commands can be run at creation with `docker run` or later with
`docker exec -it samba samba.sh` (as of version 1.3 of docker).

### Setting the Timezone

    sudo docker run -it -e TZ=EST5EDT -p 139:139 -p 445:445 -d albinodrought/samba-with-http-healthcheck

### Start an instance creating users and shares:

    sudo docker run -it -p 139:139 -p 445:445 -d albinodrought/samba-with-http-healthcheck \
                -u "example1;badpass" \
                -u "example2;badpass" \
                -s "public;/share" \
                -s "users;/srv;no;no;no;example1,example2" \
                -s "example1 private share;/example1;no;no;no;example1" \
                -s "example2 private share;/example2;no;no;no;example2"

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/albinodrought/samba-with-http-healthcheck/issues).