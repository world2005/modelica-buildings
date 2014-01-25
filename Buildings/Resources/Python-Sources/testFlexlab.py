# Python module functions used to interface with the CalBay adapter from Modelica.
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
# Step 3: Move into the different folders and run python setup.py install
# 
#===============================================================================

import sys
import os

## ssh query@flexq '{"cmd":"GETDAQ","sys":"WattStopper","chn":"HS1--4126F--Occupancy Sensor-1-LMPX-100","user":"'${FLUSER}'","pass":"'${FLPASS}'"}'
## ssh query@flexq '{"cmd":"GETDAQ","sys":"WattStopper","chn":"HS3--4126R--Light Level-1","user":"'${FLUSER}'","pass":"'${FLPASS}'"}'

## ssh query@flexq '{"cmd":"GETCONFIG","sys":"WattStopper","chn":"HS1--4126F--Occupancy Sensor-1-LMPX-100","user":"'${FLUSER}'","pass":"'${FLPASS}'"}'
## ssh query@flexq '{"cmd":"LOGIN","user":"'${FLUSER}'","pass":"'${FLPASS}'"}'
## ssh query@flexq '{"cmd":"REQCHAN","user":"'${FLUSER}'","pass":"'${FLPASS}'"}'

## ssh query@flexq '{"cmd":"GETUSERDATA","user":"'${FLUSER}'","pass":"'${FLPASS}'","cmdslp":5.0,"rcvsz":61234}'

## ssh query@flexq '{"cmd":"GETWSALLCHANNEL","user":"'${FLUSER}'","pass":"'${FLPASS}'","cmdslp":5.0,"rcvsz":65536}'
## ssh query@flexq '{"cmd":"GETWSALLVALUE","user":"'${FLUSER}'","pass":"'${FLPASS}'","cmdslp":0.1,"rcvsz":2048}'


# Note: This hostname might changed in the future
#HOSTNAME = "128.3.20.130"
# FOR TESTING
HOSTNAME = "flexq.lbl.gov"
#usrName = "querydev"
#HOSTNAME = "128.3.22.128"

# Note: This port might not be needed if SSH is used
PORT = 3500

# Configuration file
CFG_FILE = ".flexlab.cfg"

#public key file
ID_RSA = "id_rsa"

# Global variables
# Length of double to write
lenDlbWri = 0
# Length of strings to write
lenStrWri = 0
# Length of strings to read
lenStrRea = 0
# username
usrName = ""
# user password
usrPwd = ""

# List that contains json for strings written
jsonStrWri = []
# List that contains json for strings read
jsonStrRea = []
# Return value of SSH
#sshCli = 0

#===============================================================================
# Json string generated from http://www.jsoneditoronline.org/
#===============================================================================
# FOR TESTING
testJson = {
    "systype":"WattStopper",
    "sensname":"HS1--4126F--Dimmer Level-2",
    "sensvalue":10,
    "logger":{
        "msg":"Success!",
        "level":"INFO"
    }
}

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
#    Any "id_rsa" or "id_dsa" key discoverable in ~/.sshCli/
#    Plain username/password auth, if a password was given
# 
# If a private key requires a password to unlock it, and a password is passed in, 
# that password will be used to attempt to unlock the key.

#===============================================================================
# Example of script that gets private keyfile 
# privatekeyfile = os.path.expanduser('~/.sshCli/id_rsa')
# mykey = paramiko.RSAKey.from_private_key_file(privatekeyfile)
# sshCli.connect(IP[0], username = user[0], pkey = mykey)
#===============================================================================

#===============================================================================

def jsonValidator(str):
    '''Validates the JSON retrieved from SSH.

    :param str: String.

    '''
    try:
         from jsonschema import validate
    except ImportError:
        raise ImportError('Module ``jsonschema`` is required!')
   
    # Json Schema
    schema = {
        "type":"object",
        "properties":{
        "systype":{"type":"string"},
        "sensname":{"type":"string"},
        "sensvalue":{"type":"number"},
        "logger":{
            "msg":{"type":"string"},
            "level":{"type":"string"}
        }
      }
    }
    # If no exception is raised by validate(), the instance is valid.
    validate(str, schema)


def query(usr, pwd, sys_chan, fla):
    '''Establish an SSH connection using username and password and do a query.

    :param usr: Username.
    :param pwd: Password.
    :param sys_chan: channel.
    :param fla: flag for read.

    '''
 
    try:
        import paramiko
    except ImportError:
        raise ImportError('Module ``paramiko`` is required!')
    sshCli = paramiko.SSHClient()
    sshCli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    # Check if a non-empty password has been provided.
    if(pwd != ""):
        try:
            sshCli.connect(HOSTNAME, username=usr, password=pwd)
        except IOError, e:
            raise IOError(str(e) + ". Connection cannot be established with" 
                            + " username: " + usr + " and"
                            + " password: " + pwd + "!")
    # Try to connect without password
    else:
        try:
            print "I am here"
            privatekeyfile = os.path.expanduser('~/'+ ID_RSA)
            usrkey = paramiko.RSAKey.from_private_key_file(privatekeyfile)
            sshCli.connect(HOSTNAME, username=usr
                    , pkey=usrkey)
        except IOError, e:
            raise IOError(str(e) + ". Connection cannot be established with"
                                 + " username: "  + usr + "!")
            
    # extract the system and the channel
    sensor=sys_chan.split(".")
    # save the system
    system = sensor[0]
    #save the channel name
    channel = sensor[1]
    
    # Write command to execute. On the server side testbed.py is called.
    # FIXME parse the string and extract sys and channel
    if (fla==1):
        # Add command to get values   
        cmd = '{"cmd":"GETDAQ","sys":"'+ system + '","chn":"' + channel + '","user":"ws_all","pass":"lblflexws"}'
        #cmd='{"cmd":"GETDAQ","sys":"WattStopper","chn":"HS1--4126F--Occupancy Sensor-1-LMPX-100","user":"ws_all","pass":"lblflexws"}'
    else:
        # Add command to get values
         cmd = '{"cmd":"GETDAQ","sys":"'+ system + '","chn":"' + channel + '","user":"ws_all","pass":"lblflexws"}'
    # Send command to server 
    try:
        stdin, stdout, stderr = sshCli.exec_command(cmd)
        if(len(stderr.read())!=0):
            raise IOError(" An error occurs when trying to get data for "
                          + sys_chan 
                          + ". The error message returns is: "
                          # FIXME: Check the string returned.
                          + str(stderr)
                          +"!") 
        return stdout.read()
        # FOR TESTING
        # return testJson
    except IOError, e :
        raise IOError(str(e) + ". Command: " + cmd + " cannot be executed!")

#===============================================================================
# def connect(usr, pwd):
#     '''Establish an SSH connection using username and password.
# 
#     :param usr: Username.
#     :param pwd: Password.
# 
#     '''
#     #global sshCli
#  
#     try:
#         import paramiko
#     except ImportError:
#         raise ImportError('Module ``paramiko`` is required!')
#     sshCli = paramiko.SSHClient()
#     sshCli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
#     
#     # Check if a non-empty password has been provided.
#     if(pwd != ""):
#         try:
#             sshCli.connect(HOSTNAME, username=usr, password=pwd)
#         except IOError, e:
#             raise IOError(str(e) + ". Connection cannot be established with" 
#                             + " username: " + usr + " and"
#                             + " password: " + pwd + "!")
#     # Try to connect without password
#     else:
#         try:
#             privatekeyfile = os.path.expanduser('~/'+ ID_RSA)
#             usrkey = paramiko.RSAKey.from_private_key_file(privatekeyfile)
#             sshCli.connect(HOSTNAME, username=usr
#                     , pkey=usrkey)
#         except IOError, e:
#             raise IOError(str(e) + ". Connection cannot be established with"
#                                  + " username: "  + usr + "!")
#     return sshCli
# 
# def get(usr, pwd, sys_chan, sshCli):
#     '''Connect to server and retrieve value of control point.
# 
#     :param usr: Username.
#     :param pwd: Password.
#     :param sys_chan: Channel name.
#     :return: JSON string.
# 
#     '''    
#     # extract the system and the channel
#     sensor=sys_chan.split(".")
#     
#     # save the system
#     system = sensor[0]
#     
#     #save the channel name
#     channel = sensor[1]
#     
#     # Write command to execute. On the server side testbed.py is called.
#     # FIXME parse the string and extract sys and channel
#     #cmd = '{"cmd":"GETDAQ","sys":"'+ system + '","chn":"' + channel + '","user":"ws_all","pass":"lblflexws"}'
#     cmd='{"cmd":"GETDAQ","sys":"WattStopper","chn":"HS1--4126F--Occupancy Sensor-1-LMPX-100","user":"ws_all","pass":"lblflexws"}'
#     
#     # Send command to server 
#     try:
#         stdin, stdout, stderr = sshCli.exec_command(cmd)
#         sshCli.close()
#         return stdout.read()
#         #=======================================================================
#         # if(len(stderr.read())!=0):
#         #    raise IOError(" An error occurs when trying to get data for "
#         #                  + sys_chan 
#         #                  + ". The error message returns is: "
#         #                  # FIXME: Check the string returned.
#         #                  + str(stderr)
#         #                  +"!") 
#         # return stdout.read()
#         #=======================================================================
#         #return stdout.read()
#         # FOR TESTING
#         # return testJson
#     except IOError, e :
#         raise IOError(str(e) + ". Command: " + cmd + " cannot be executed!")
# 
# def set(usr, pwd, sys_chan, sys_chan_val):
#     '''Connect to server and retrieve value of control point.
# 
#     :param usr: Username.
#     :param pwd: Password.
#     :param sys_chan: Channel name.
#     :param sys_chan_val: Channel value.
#     :return: JSON string.
# 
#     '''
#     # Connect to server
#     connect(usr, pwd)
#     
#      # extract the system and the channel
#     sensor=sys_chan.split(".")
#     
#     # save the system
#     system = sensor[0]
#     
#     #save the channel name
#     channel = sensor[1]
#     
#     # Write command to execute. On the server side testbed.py is called.
#     # FIXME parse the string and exctract sys and channel
#     cmd = '{"cmd":"GETDAQ","sys":"'+ system + '","chn":"' + channel + '","user":"ws_all","pass":"lblflexws"}'
#     # FOR TESTING
#     #cmd = 'echo test >> file1.txt'
#     
#     # Send command to server 
#     try:
#         stdin, stdout, stderr = sshCli.exec_command(cmd)
#         sshCli.close()
#         if(len(stderr.read())!=0):
#            raise IOError(" An error occurs when trying to set data for "
#                          + sys_chan 
#                          + ". The error message returns is: "
#                           # FIXME: Check the string returned.
#                          + str(stderr) 
#                          +"!") 
#         return stdout.read()
#         # FOR TESTING
#         #return testJson
#     except IOError, e :
#         raise IOError(str(e) + ". Command: " + cmd + " cannot be executed!")
#===============================================================================
    
def jsonParser(json_data):
    '''Parse the JSON retrieved from SSH.

    :param str: String.
    :return: Vectors with name, value, msg and level

    '''

    #Validate json
    jsonValidator(json_data)
    #Retrieve properties of data strings
    # Get the system type
    sysType=json_data["systype"]
    # Get the sensorname
    sensName=json_data["sensname"]
    # Concatenate sensorname and systype
    sensTypeName = sysType + "." + sensName
    # Get the sensValue
    # FIXME: Server should put dummy value in String when writing
    sensValue=json_data["sensvalue"]
    #Get the logger message
    logMsg = json_data["logger"]["msg"]
    #Get the logger level
    logLevel = json_data["logger"]["level"]
    #return properties
    return(sensTypeName, sensValue, logMsg, logLevel)

def getlen(u):
    '''Get length of scalar or vector.

    :param u: Scalar or vector.
    :return: Length.

    '''  
    if(isinstance(u, list)):
        return len(u)
    else:
        return 1    


#===============================================================================
# Logging Levels in Python
# 
# Level     Numeric value
# CRITICAL     50
# ERROR        40
# WARNING      30
# INFO         20
# DEBUG        10
# NOTSET        0
#===============================================================================
def getlog(name, level, msg):
    '''Get length of scalar or vector.

    :param name: Name of string.
    :param level: Logging level.
    :param msg: Logging message.

    '''  

    if(level.lower() == "error"):
        raise IOError("ERROR: An error occurs when trying to retrieve data for " 
                       + name + ". The logging message is: " + msg)
#    if(level.lower() == "warning"):
#        errmsg = "WARNING: An error occurs when trying to retrieve data for " + name + ". The logging message is: " + msg   

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
    lenDblWri = getlen(dblWri)
    lenStrWri = getlen(strWri)
    lenStrRea = getlen(strRea) 
        
    # Check if number of doubles to write match with number of strings to write
    print lenStrWri
    if(lenDblWri != lenStrWri - 2):
        raise ValueError("Number of doubles to write: " 
                          + str(lenDblWri) + " is not equal to number " 
                          + " of strings to write: " + str(lenStrWri - 2) 
                          + ". Please check and correct!")   
        
    # Check configuration file and parsed if existant
    from os.path import expanduser
    home = expanduser("~")
    cfg_file = os.path.join(home, CFG_FILE) 
    if(os.path.exists(cfg_file)):
        # Parse the file and retrieve user properties
        usrProp = []
        f = open(cfg_file, 'r')
        prop = f.read()
        f.close
        for t in prop.split(";"):
            for u in t.split("="):
                usrProp.append(u)
        if((''.join(usrProp[0].lower().split()) == "user") 
            & (''.join(usrProp[2].lower().split()) == "password")):
                #sys.exit(usrProp[0]+usrProp[2] + usrProp[1] + usrProp[3])
                tmpUsrName = usrProp[1]
                tmpUsrPwd  = usrProp[3]  
        else:
            raise IOError("Configuration file in " 
                                + cfg_file + " does not contain a " 
                                + " valid user and a valid password."
                                + " Please check the configuration file!")

    # Determine the username
    if(strWri[0].lower() != "user"):
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
    if(strWri[1].lower() != ""):
        # Get the password from strWri
        usrPwd = strWri[1]
    elif(os.path.exists(cfg_file)):
        # Get password from configuration file
        if(usrName == tmpUsrName):
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
    :return: Vectors or scalar values of strings read.
    
    Usage: Type
           >>> import testFlexlab
           >>>testFlexlab.flexlab([1,2], ["usr", "pwd", "u1", "u2"], ["y1", "y2"])

    This will return the following exception which is to expect since the credentials are incorrect.
        ``IOError: [Errno 10060] A connection attempt failed because the connected party 
        did not properly respond after a period of time, or established connection failed
        because connected host has failed to respond. Connection cannot be established
        with username: usr and password: pwd!``

    '''    
    # Multiple delimiters
    import re
    # Redefine global variables
    global jsonStrRea
    global jsonStrWri
    
    # List with values for strings written
    resMatWri = [[], [], [], []]
    # List with values for strings read
    resMatRea = [[], [], [], []]
    
    # List with double values of sensor read
    sensValarr = []
    
    # Initialize the simulation
    init(dblWri, strWri, strRea)
    
    # FIXME: Are the name of sensors in Calbay and Database harmonized? If not and a 
    # user sends "WattStopper:TRoom" and it happens that this is not existing in Calbay, 
    # should the server do a mapping between names to make sure the testbed.py is searching for the 
    # correct data in the database? 
    # Note: On the server side, the script should always try to retrieve data in Calbay first, if they do not 
    # exist, it should go to the database.
    
    # Set doubles and strings to be written
    # Note: Need to substract 2 from the length of strWri
    # for the username and the passwords strings
    #===========================================================================
    # if(lenDblWri == 1):
    #    name, value, msg, level = jsonParser(set(usrName, usrPwd, strWri[2], dblWri))
    #    # Check logging
    #    getlog(name, level, msg)
    # else:
    #    for i in range(0, lenStrWri - 2):
    #        name, value, msg, level =  jsonParser(set(usrName, usrPwd, strWri[i + 2], dblWri[i]))
    #        # Check logging
    #        getlog(name, level, msg)
    #        # Save data
    #        resMatWri[0].append(name)
    #        resMatWri[1].append(value)
    #        resMatWri[2].append(msg)
    #        resMatWri[3].append(level)
    #===========================================================================
          
    # Get doubles values from strings to be read
    
    if(lenStrRea == 1):
        #name, value, msg, level = jsonParser(get(usrName, usrPwd, strRea))
        #sensVal = 10
        sensVal = re.split('[] []',query(usrName, usrPwd, strRea, 1))
        # Check logging
        #getlog(name, level, msg)
        return float(sensVal[1])
    else:
        for i in range(0, lenStrRea):
            #name, value, msg, level = jsonParser(get(usrName, usrPwd, strRea[i]))
            sensVal = re.split('[] []',query(usrName, usrPwd, strRea, 1))
            # Check logging
            #getlog(name, level, msg)
            # Save data
            #resMatRea[0].append(name)
            #resMatRea[1].append(value)
            #resMatRea[2].append(msg)
            #resMatRea[3].append(level)
            sensValarr.append(float(sensVal[1]))
        return sensValarr           
        

