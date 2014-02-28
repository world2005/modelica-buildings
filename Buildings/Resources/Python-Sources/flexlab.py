# This Python module contains functions used to interface with the CalBay adapter.
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

# Note: This hostname might changed in the future
# HOSTNAME = "128.3.20.130"
# FOR TESTING
HOSTNAME = "flexq.lbl.gov"
# usrName = "querydev"
# HOSTNAME = "128.3.22.128"

# Configuration file
CFG_FILE = ".flexlab.cfg"

# User at flexq.lbl.gov
FLEXQUSR = "query"

# public key file
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

# class Query:

def getLen(u):
    '''Get length of the input parameter which is a scalar or a vector.

    :param u: Scalar or vector.
    :return: 1 for scalar or vector's length.

    '''  
    if(isinstance(u, list)):
        return len(u)
    else:
        return 1   

def init(dblWri, strWri, strRea):
    '''Validate input parameters and retrieve the user credentials 
    from input parameter (``strWri``), configuration file or from the system.
    
    .. note::
    
      - The first two strings of ``strWri`` (optionally) contain the user name and the user password. They cannot be left blank but can be empty strings.    
      - The configuration file (``.flexlab.cfg``) must be located in the home directory. 
    
    To determine the user credentials, following search is executed:
    
    For the user name, the function checks if the user name provided in ``strWri`` differs from the word ``user``,
    
    - if ``true`` then it uses it as user name,
    - if ``false`` then it uses the user name specified in the configuration file,
    - ``otherwise``, it uses the login name of the user.
       
    For the password,  the function checks if the user password provided in ``strWri`` differs from the empty string ``""``,
    
    - if ``true`` then it uses it as user password,
    - if ``false`` then it uses the user password specified in the configuration file.
      This is done only if the user name previously retrieved is consistent with the user name in the configuration file,
    - ``otherwise``, it assumes that a user password is not required and set the user password to an empty string.

    :param dblWri: Doubles to be written.
    :param strWri: Strings to be written.
    :param strRea: Strings to be read.

    '''  
    # Redefine global variables.
    global flaIni
    global lenDblWri
    global lenStrWri
    global lenStrRea
    global usrName
    global usrPwd
    
    # Define temporary variables. 
    tmpUsrName = ""
    tmpUsrPwd = ""
    
    # Get length of doubles and strings to read and write.
    lenDblWri = getLen(dblWri)
    lenStrWri = getLen(strWri)
    lenStrRea = getLen(strRea) 
        
    # Check if number of doubles to write match with number of strings to write -2.
    # Note that the number of strings to write contain the user name and the password.
    if(lenDblWri != lenStrWri - 2):
        raise ValueError("Number of doubles to write: " 
                         + str(lenDblWri) + " is not equal to number " 
                         + "of strings to write: " + str(lenStrWri - 2) 
                         + ". Please correct!")   
        
    # Check the configuration file and parsed if existent.
    from os.path import expanduser
    home = expanduser("~")
    cfg_file = os.path.join(home, CFG_FILE) 
    if(os.path.exists(cfg_file)):
        # Parse the file and retrieve user properties.
        usrProp = []
        f = open(cfg_file, 'r')
        prop = f.read()
        f.close
        for t in prop.split(";"):
            for u in t.split("="):
                usrProp.append(u)
        if((''.join(usrProp[0].lower().split()) == "user") 
            & (''.join(usrProp[2].lower().split()) == "password")):
                # sys.exit(usrProp[0]+usrProp[2] + usrProp[1] + usrProp[3])
                tmpUsrName = usrProp[1]
                tmpUsrPwd = usrProp[3]  
        else:
            raise IOError("Configuration file in " 
                          + cfg_file + " does not contain a " 
                          + "valid user name and a valid password. "
                          + "Please check the configuration file!")

    # Determine the user name.
    if(len(strWri[0].lower()) != 0):
        # Get user name from strWri.
        usrName = strWri[0]
    elif(os.path.exists(cfg_file)):
        # Get user name from configuration file.
        usrName = tmpUsrName
    else:
        raise IOError("A user name could not be retrieved!" 
                      + " Please provide a valid user name!")
        # Use getpass to retrieve the user name.
        # import getpass
        # usrName = getpass.getuser()
            
    # Determine the password.
    if(len(strWri[1].lower()) != 0):
        # Get the password from strWri
        usrPwd = strWri[1]
    elif(os.path.exists(cfg_file)):
        # Get password from configuration file
        if(usrName == tmpUsrName):
            usrPwd = tmpUsrPwd
        else:
            raise IOError("The user name: " + usrName + " does not " 
                          + "match the user password found in: " + cfg_file  
                          + " Please correct!.")
    else:
        raise IOError("A user password could not be retrieved!" 
                      + " Please provide a valid user password!")

def calBay(_usr, _pwd, sys_chan, val, fla):
    '''Establish an SSH connection using the user name and password and do a query.
    This module requires ``paramiko``, ``pycrypto`` and ``ecdsa`` to be installed.
    Below are instructions on how to get ``paramiko``, ``pycrypto``, and ``acdsa``.
    
    Step 1: Go to 
    
    - https://github.com/paramiko/paramiko,   
    - https://github.com/dlitz/pycrypto,  
    - https://pypi.python.org/pypi/ecdsa/
     
    Step 2: Download the zip-files, and extract them
 
    Step 3: Move into the different folders and run python setup.py install

    :param _usr: User name.
    :param _pwd: User password.
    :param sys_chan: ``Systemname.Channelname``.
    :param val: Value to write.
    :param fla: 0 for read, 1 for write.
    
    
    Usage: Type
           >>> import flexlab.daq.query as q
           >>> q.calBay("ws", "lbl", "WattStopper.HS1--4126F--Dimmer Level-2", 0, 0)

    This will return the following message ``["USER AUTHENTICATION ERROR"]`` which is to expect since the credentials are incorrect.
     

    '''
 
    try:
        import paramiko
    except ImportError:
        raise ImportError('Module ``paramiko`` is required!')
    
    # Extract the system and the channel names from sys_chan.
    _str = sys_chan.split(".")
    # Check whether sys_chan has exactly two strings concatenated.
    nstr = len(_str);
    if(nstr!= 2):
        raise ValueError("Length of " + _str + " split is: " 
                          + str(nstr) + " which is not equal to 2!" 
                          + " Please check and correct!") 
    # save the system name
    _sys = _str[0]
    # save the channel name
    _chan = _str[1]
    # The assumption is that each user needs to have a provate key to connect to flexq.lbl.gov
    sshCli = paramiko.SSHClient()
    sshCli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        privatekeyfile = os.path.expanduser('~/' + ID_RSA)
        if not(os.path.exists(privatekeyfile)):
            raise IOError("A private key file could not be found in: "
                          + privatekeyfile + "!")
        else:
            usrkey = paramiko.RSAKey.from_private_key_file(privatekeyfile)
            sshCli.connect(HOSTNAME, username=FLEXQUSR, pkey=usrkey)
    except IOError, e:
        raise IOError(str(e) + ". Connection cannot be established to flexq.lbl.gov"
                             + " with the username: " + FLEXQUSR 
                             + " and the private key located in "
                             + privatekeyfile + "!")
    
#         # Check if a non-empty password has been provided.
#     if(_pwd != ""):
#         try:
#             sshCli.connect(HOSTNAME, username=_usr, password=_pwd)
#         except IOError, e:
#             raise IOError(str(e) + ". Connection cannot be established with" 
#                             + " username: " + _usr + " and"
#                             + " password: " + _pwd + "!")
#     # Try to connect without password using private key.
#     else:
#         try:
#             privatekeyfile = os.path.expanduser('~/' + ID_RSA)
#             usrkey = paramiko.RSAKey.from_private_key_file(privatekeyfile)
#             sshCli.connect(HOSTNAME, username=FLEXQUSR
#                     , pkey=usrkey)
#         except IOError, e:
#             raise IOError(str(e) + ". Connection cannot be established with"
#                                  + " username: " + FLEXQUSR + "!")
            

    # Write command to get or set data.
    if(fla == 0):
        # Add command to get values   
        _cmd = '{"cmd":"GETDAQ","sys":"' + _sys + '","chn":"' + _chan + '","user":"' + _usr + '","pass":"' + _pwd + '"}'
    if(fla == 1):
        # Add command to set values
        # FIXME: We do not sent any command to set values yet. The placeholder is currently the get command.
        _cmd = '{"cmd":"GETDAQ","sys":"' + _sys + '","chn":"' + _chan + '","user":"' + _usr + '","pass":"' + _pwd + '"}'
    # Send command to server 
    try:
        stdin, stdout, stderr = sshCli.exec_command(_cmd)
        if(len(stderr.read())!= 0):
            raise IOError(" An error occurs when trying to get data for "
                          + sys_chan 
                          + ". The error message returns is: "
                          # FIXME: Check the string returned.
                          + str(stderr)
                          + "!") 
        return stdout.read()
        # FOR TESTING
        # return testJson
    except IOError, e :
        raise IOError(str(e) + ". Command: " + _cmd + " cannot be executed!")

#     def jsonValidator(str):
#     '''Validates the JSON retrieved from SSH.
# 
#     :param str: String.
# 
#     '''
#     try:
#          from jsonschema import validate
#     except ImportError:
#         raise ImportError('Module ``jsonschema`` is required!')
#    
#     # Json Schema
#     schema = {
#         "type":"object",
#         "properties":{
#         "sensvalue":{"type":"number"},
#         "logger":{
#             "msg":{"type":"string"},
#             "level":{"type":"string"}
#         }
#       }
#     }
#     # If no exception is raised by validate(), the instance is valid.
#     validate(str, schema)

def jsonParser(jsonObj):
    '''Remove square brackets from the JSON string.
     
    :param jsonObj: JSON object to parse.
    :return: JSON object parsed.
     
    '''
  
    # Multiple delimiters
    import re      
    return re.split ('[] []', jsonObj)

#     def jsonParser(json_data):
#     '''Parse the JSON retrieved from SSH.
# 
#     :param str: String.
#     :return: Vectors with name, value, msg and level
# 
#     '''
# 
#     #Validate json
#     jsonValidator(json_data)
#     #Retrieve properties of data strings
#     # Get the sensValue
#     # FIXME: Server should put dummy value in String when writing
#     sensValue=json_data["sensvalue"]
#     #Get the logger message
#     logMsg = json_data["logger"]["msg"]
#     #Get the logger level
#     logLevel = json_data["logger"]["level"]
#     #return properties
#     return(sensTypeName, sensValue, logMsg, logLevel)

# #===============================================================================
# # Logging Levels in Python
# # 
# # Level     Numeric value
# # CRITICAL     50
# # ERROR        40
# # WARNING      30
# # INFO         20
# # DEBUG        10
# # NOTSET        0
# #===============================================================================
# def getlog(name, level, msg):
#     '''Get logging.
# 
#     :param name: Name of string.
#     :param level: Logging level.
#     :param msg: Logging message.
# 
#     '''  
# 
#     if(level.lower() == "error"):
#         raise IOError("ERROR: An error occurs when trying to retrieve data for " 
#                        + name + ". The logging message is: " + msg)
# #    if(level.lower() == "warning"):
# #        errmsg = "WARNING: An error occurs when trying to retrieve data for " + name + ". The logging message is: " + msg  

def execute(dblWri, strWri, strRea):
    '''Main function to interface with FLEXLAB.
    This function calls the following three methods respectively:
    
    1. ``init()`` to validate the input parameters and retrieve the user credentials, 
    2. ``calBay()`` to connect to the Calbay adapter for getting or setting data,
    3. ``jsonParser()`` to parse the JSON string returned from the query into doubles.

    :param dblWri: Doubles to be written.
    :param strWri: Strings to be written.
    :param strRea: Strings to be read.
    :return: Vectors or scalar values of strings read.
    
    Usage: Type
           >>> import flexlab.daq.query as q
           >>> q.execute([1,2], ["ws", "lbl", "sys1.chan1", "sys1.chan2"], ["sys2.chan1", "sys2.chan2"])

    This will return the following message ``ValueError: could not convert string to float: "USER"`` which is to expect since the credentials are incorrect, 
    and the return value of the command execution is a string (``USER AUTHENTIFICATION ERROR``) which cannot be parsed.
    
    '''    
    # Redefine global variables
    # global jsonStrRea
    # global jsonStrWri
    
    # List with values for strings written
    # resMatWri = [[], [], [], []]
    # List with values for strings read
    # resMatRea = [[], [], [], []]
    
    # List with double values of channel read.
    chanValRea = []
    
    # Initialize the simulation.
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
    #===========================================================================
    # Get doubles values from strings to be read
    if(lenStrRea == 1):
        sensVal = jsonParser(calBay(usrName, usrPwd, strRea, 0, 0))
        # getlog(name, level, msg)
        return float(sensVal[1])
    else:
        for i in range(0, lenStrRea):
            sensVal = jsonParser(calBay(usrName, usrPwd, strRea[i], 0, 0))
            # Check logging
            # getlog(name, level, msg)
            chanValRea.append(float(sensVal[1]))
        return chanValRea           

