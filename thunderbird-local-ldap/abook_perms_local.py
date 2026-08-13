#!/usr/bin/python3

import sqlite3
import time
import subprocess
import tempfile
from pathlib import Path

# Update these to the address book file and the permissions file in your Thunderbird directory
# The script will write the email directory entries directly into the address book file and
# add a permission to load images from that email address in the permissions file
abook_file = '/home/msheermo/.thunderbird/kd8x6x8m.default-esr/abook.sqlite'                                                                                                                                                                                                                
perms_file = '/home/msheermo/.thunderbird/kd8x6x8m.default-esr/permissions.sqlite'

# Required LDAP fields needed to create an address book entry
fields = {'rhatUUID', 'uidNumber', 'cn', 'displayName', 'rhatPreferredLastName', 'rhatPrimaryMail'}

# Contact class that holds all the information for a contact and formats the
# data for insertion into the address book and permissions databases
class Contact:
# Initialize the contact object to defaults or data passed to it
    def __init__(self, ldapentry):
        self.card = ldapentry['rhatUUID']
        self.uid = int(ldapentry['uidNumber'])
        self.DisplayName = ldapentry['cn']
        self.PopularityIndex = 0
        # If the contact has a preferred alias, use that as their primary email
        # and move their primary email to second email
        if ('rhatPreferredAlias' in ldapentry and 
            ldapentry['rhatPreferredAlias'] != ldapentry['rhatPrimaryMail']):
            self.PrimaryEmail = ldapentry['rhatPreferredAlias']
            self.SecondEmail = ldapentry['rhatPrimaryMail']
        else:
            self.PrimaryEmail = ldapentry['rhatPrimaryMail']
            self.SecondEmail = None
        self.FirstName = ldapentry['displayName']
        self.PreferDisplayName = 1
        self.LastName = ldapentry['rhatPreferredLastName']
        self.LastModifiedDate = int(time.time())

    def __str__(self):
        return f'UUID: {self.card}, DisplayName: {self.DisplayName}, ' \
               f'PrimaryEmail: {self.PrimaryEmail}, FirstName: {self.FirstName}, ' \
               f'LastName: {self.LastName}'

    def __repr__(self):
        return f'UUID: {self.card}, DisplayName: {self.DisplayName}, ' \
               f'PrimaryEmail: {self.PrimaryEmail}, FirstName: {self.FirstName}, ' \
               f'LastName: {self.LastName}'

    def abookrecords(self):
        records = ["DisplayName", "PopularityIndex", "PrimaryEmail", "SecondEmail",
                  "FirstName", "PreferDisplayName", "LastName", "LastModifiedDate"]
        return [(self.card, x, getattr(self, x)) for x in records if getattr(self, x, None)]

    def permsrecord(self, pid, email):
        return f'INSERT OR REPLACE INTO moz_perms (id, origin, type, ' + \
               f'permission, expireType, expireTime, modificationTime) ' + \
               f'VALUES ({pid}, ' + \
               f'"chrome://messenger/content/email={email}", ' + \
               f'"image", 1, 0, 0, ' + \
               f'{int(time.time())});'

    def primarypermsrecord(self):
        return self.permsrecord(self.uid, self.PrimaryEmail)

    def secondpermsrecord(self):
        return self.permsrecord(-self.uid, self.SecondEmail)

# Check that we can connect to the address book and permission sqlite databases
# before we download all the LDAP data so we don't waste time with multiple
# downloads. The main reason this will fail is if Thunderbird is running which
# will cause the address book and permission files to be locked.
print('Connecting to Thunderbird address book...')
try:
    # Confirm that the address book and permissions files exist
    if not (Path(abook_file).is_file() and Path(perms_file).is_file()):
        print('Address book or permissions files do not exist')
        print('Open Thunderbird to automatically recreate them')
        exit()

    # Connect to the address book and permissions sqlite databases
    abookdb = sqlite3.connect(abook_file)
    permsdb = sqlite3.connect(perms_file)
    abookcur = abookdb.cursor()
    permscur = permsdb.cursor()

    # Turn off Synchronous to improve performance (not reliable if power or disk failure)
    abookcur.execute('''PRAGMA synchronous = OFF''')
    permscur.execute('''PRAGMA synchronous = OFF''')

    # Turn off journaling and atomic commit to improve performance (no rollback)
    abookcur.execute('''PRAGMA journal_mode = OFF''')
    permscur.execute('''PRAGMA journal_mode = OFF''')

except Exception as sqlite_error:
    print('Error connecting to address book or permissions files\n', sqlite_error)
    print('Make sure that Thunderbird is not running.') 
    exit()

# Check that a kerberos ticket exists as it is required for authenticating
# to LDAP
print('Checking for kerberos authentication...')
try:
    # If the command succeeds, a kerberos ticket is present
    subprocess.check_call(['klist', '-s'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    # If the command fails (exit code 1 or other), no valid ticket is present
except subprocess.CalledProcessError:
    print('No kerberos ticket found. Run kinit first and login')
    exit()
except FileNotFoundError:
    # Handle cases where klist is not found
    print('klist command not found. Check that kerberos tools are installed.')
    exit()

try:
    print('Downloading LDAP data...')
    # Temporary file for LDAP download
    # Temporary file will be cleaned when the process exits
    with tempfile.NamedTemporaryFile(delete_on_close=False) as temp:
        try:
            # Connect to LDAP server and download relevant users and fields to a local temporary file
            subprocess.run(['/usr/bin/ldapsearch',
                            '-Y', 'GSSAPI', # Equivalent to SASL_MECH GSSAPI
                            '-N', # Equivalent to SASL_NOCANON on
                            '-LLL', # LDIF format without comments or version
                            '-o', 'ldif-wrap=no', # Don't wrap output
                            '-H', 'ldap:///dc%3Dipa%2Cdc%3Dredhat%2Cdc%3Dcom', # Server URL
                            '-b', 'cn=users,cn=accounts,dc=ipa,dc=redhat,dc=com', # Search base
                            'employeeType', 'rhatUUID', 'uidNumber', 'cn', 'displayName',
                            'rhatPreferredLastName', 'rhatPrimaryMail', 'rhatPreferredAlias'], # Requested fields
                            stdout=temp)
        except Exception as ldap_error:
            print('Error getting LDAP data\n', ldap_error)
            exit()

        # Open a connection to the LDAP download data
        conn = open(temp.name, 'r')

        print('Updating Thunderbird address book...')
        entry = {}
        for line in conn:
        # dn indicates the start of a record, skip the first line
            if line[0:1] == 'dn':
                continue
        # Blank line indicates the end of a record
            elif line == '\n':
        # Check that we have all the relevant fields
                if fields <= set(entry):
                    card = Contact(entry)
        # Not catching errors at this point because we turned off rollbacks for speed, so the address
        # book or permissions database is not in a good state. If this happens, you will just have to
        # delete the sqlite databases and Thunderbird will re-create them automatically.
                    abookcur.executemany('INSERT OR REPLACE INTO properties VALUES(?,?,?);',
                        card.abookrecords());
                    permscur.execute(card.primarypermsrecord())
                    if card.SecondEmail:
                        permscur.execute(card.secondpermsrecord())
                    entry.clear()
        # Any other line is an attribute. Add it to the dictionary
            else:
                k, v = line.split(':', 1)
                entry[k] = v.strip(': \n')

except Exception as tempfile_error:
    print('Error creating or reading temporary file\n', tempfile_error)
    exit()

# Commit all the updates and close the databases
abookdb.commit()
permsdb.commit()

abookdb.close()
permsdb.close()
