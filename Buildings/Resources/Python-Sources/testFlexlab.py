# Python module functions used to interface with the CalBay adapter from Modelica.
# Make sure that the python path is set, such as by running
# @author: Thierry Nouidui  2013-12-20

#===============================================================================
# This script requires paramiko, pycrypto and ecdsa to be installed.
# 
# Below are instructions on how to get paramiko, pycrypto, and acdsa.
# 
# Step 1: Go to 
#     https://github.com/paramiko/paramiko, 
#     https://github.com/dlitz/pycrypto
#     https://pypi.python.org/pypi/ecdsa/
# Step 2: Download the zip files, and extract them
# 
# Step 3: Move into the differentfolder and run python setup.py install
# 
#===============================================================================

import sys
import os

# Note: This hostname might changed in the future
HOSTNAME = "128.3.20.130"

# Note: This port might change in the future
#PORT = 3500

# Configuration file
CFG_FILE = ".flexlab.cfg"

# Global variables
# length of double to write
lenDlbWri = 0
#length of strings to write
lenStrWri = 0
# length of strings to read
lenStrRea = 0
# username
usrName = ""
# user password
usrPwd = ""

# list that contains json for strings written
jsonWri = []

# list that contains json for strings read
jsonRea = []

#===============================================================================
# connect(self, hostname, port=22, username=None, password=None, pkey=None, key_filename=None, 
# timeout=None, allow_agent=True, look_for_keys=True, compress=False)
#    source code 
# 
# Connect to an SSH server and authenticate to it. The server's host key is 
# checked against the system host keys (see load_system_host_keys) and any local host keys 
# (load_host_keys). If the server's hostname is not found in either set of host keys, 
# the missing host key policy is used (see set_missing_host_key_policy). 
# The default policy is to reject the key and raise an SSHException.
# 
# Authentication is attempted in the following order of priority:
# 
#    The pkey or key_filename passed in (if any)
#    Any key we can find through an SSH agent
#    Any "id_rsa" or "id_dsa" key discoverable in ~/.ssh/
#    Plain username/password auth, if a password was given
# 
# If a private key requires a password to unlock it, and a password is passed in, 
# that password will be used to attempt to unlock the key.

#===============================================================================
# Example of script that gets private keyfile 
# privatekeyfile = os.path.expanduser('~/.ssh/id_rsa')
# mykey = paramiko.RSAKey.from_private_key_file(privatekeyfile)
# ssh.connect(IP[0], username = user[0], pkey = mykey)
#===============================================================================

#===============================================================================

def connect (usr, pwd):
    '''Establish an SSH connection using username and password.

    :param usr: Username.
    :param pwd: Password.

    '''
    try:
        import paramiko
    except ImportError:
        raise ImportError('Module ``paramiko`` is required!')
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    # Check if a non-empty password has been provided.
    if(pwd != ""):
        try:
            ssh.connect(HOSTNAME, username=usr, password=pwd)
        except IOError, e:
            raise IOError(str(e) + ". Connection cannot be established with" 
                            + " username: " + usr + " and"
                            + " password: " + pwd + "!")
    # Try to connect without password
    else:
        try:
            ssh.connect(HOSTNAME, username=usr
                    , pkey='<key-file>')
        except IOError, e:
            raise IOError(str(e) + ". Connection cannot be established with"
                                 + " username: "  + usr + "!")
     
def get(usr, pwd, sys_chan):
    '''Connect to server and retrieve value of control point.

    :param usr: Username.
    :param pwd: Password.
    :param sys_chan: Channel name.
    :return: JSON string.

    '''
    # Connect to server
    connect (usr, pwd)
    
    # Write command to execute
    cmd = 'GETDAQ:' + sys_chan
    
    # Send command to server 
    try:
        stdin, stdout, stderr = ssh.exec_command(cmd)
        ssh.close()
        return stdout
    except paramiko.SSHException, e :
        raise IOError(str(e) + ". Command: " + cmd + " cannot be executed!")

 
def set(usr, pwd, sys_chan, sys_chan_val):
    '''Connect to server and retrieve value of control point.

    :param usr: Username.
    :param pwd: Password.
    :param sys_chan: Channel name.
    :param sys_chan_val: Channel value.
    :return: JSON string.

    '''
    # Connect to server
    connect (usr, pwd)
    
    # Write command to execute
    cmd = 'SETDAQ:' + sys_chan + ':' + str(sys_chan_val)
    
    # Send command to server 
    try:
        stdin, stdout, stderr = ssh.exec_command(cmd)
        ssh.close()
        return stdout
    except paramiko.SSHException, e :
        raise IOError(str(e) + ". Command: " + cmd + " cannot be executed!")

def getlen(u):
    '''Get length of scalar or vector.

    :param u: Scalar or vector.
    :return: Length.

    '''  
    if (isinstance(u, list)):
        return len (u)
    else:
        return 1    

def init(dblWri, strWri, strRea):
    '''Initialize variables for simulation.

    :param dblWri: List of doubles to be written.
    :param strWri: List of strings to be written.
    :param strRea: List of strings to be read.

    '''  
    # Redefine global variables
    global flaIni
    global lenDblWri
    global lenStrWri
    global lenStrRea
    global usrName
    global usrPwd
    
    # Define temporary variables 
    tmpUsrName = ""
    tmpUsrPwd = ""
    
    # Get length of inputs variables
    lenDblWri = getlen (dblWri)
    lenStrWri = getlen (strWri)
    lenStrRea = getlen (strRea) 
        
    # Check if number of doubles to write match with number of strings to write
    if (lenDblWri != lenStrWri - 2):
        raise ValueError ("Number of doubles to write: " 
                          + str(lenDblWri) + " is not equal to number " 
                          + " of strings to write: " + str(lenStrWri - 2) 
                          + ". Please check and correct!")   
        
    # Check configuration file and parsed if existant
    from os.path import expanduser
    home = expanduser("~")
    cfg_file = os.path.join(home, CFG_FILE) 
    if (os.path.exists(cfg_file)):
        # Parse the file and retrieve user properties
        usrProp = []
        f = open(cfg_file, 'r')
        prop = f.read()
        f.close
        for t in prop.split(";"):
            for u in t.split("="):
                usrProp.append(u)
            if ((''.join(usrProp[0].lower().split()) == "user") 
                & (''.join(usrProp[2].lower().split()) == "password")):
                tmpUsrName = usrProp[1]
                tmpUsrPwd  = usrProp[3]
            else:
                raise IOError ("Configuration file in " 
                                + cfg_file + " does not contain a " 
                                + " valid user and a valid password."
                                + " Please check the configuration file!")

    # Determine the username
    if (strWri[0].lower() != "user"):
        # Get username from strWri
        usrName = strWri[0]
    elif(os.path.exists(cfg_file)):
        # Get username from configuration file
        usrName = tmpUsrName
    else:
        # Use getpass to retrieve the username
        import getpass
        usrName = getpass.getuser()
            
    # Determine the password
    if (strWri[1].lower() != ""):
        # Get the password from strWri
        usrPwd = strWri[1]
    elif(os.path.exists(cfg_file)):
        # Get password from configuration file
        if (usrName == tmpUsrName):
            usrPwd = tmpUsrPwd
        else:
            usrPwd = ""
    else:
        # Password is assumed to not be required and
        # will be set to an empty string.
        usrPwd = ""

def flexlab(dblWri, strWri, strRea):
    '''Main function to interface with Calbay.

    :param dblWri: List of doubles to be written.
    :param strWri: List of strings to be written.
    :param strRea: List of strings to be read.

    '''    
    # Redefine global variables
    global jsonRea
    global jsonWri
    
    # Initialize the simulation
    init (dblWri, strWri, strRea)
    
    # Set doubles and strings to be written
    # Note: Need to substract 2 from the length of strWri
    # for the username and the passords strings
    if (lenDblWri == 1):
        jsonWri.append (set (usrName, usrPwd, strWri[2], dblWri))
    else:
        for i in range(0, lenStrWri - 2):
            jsonWri.append (set (usrName, usrPwd, strWri[i + 2], dblWri[i]))
            
     # Get doubles values from strings to be read
    for i in range(0, lenStrRea):
        jsonRea.append (set (usrName, usrPwd, strRea[i]))       
    
    return 2

