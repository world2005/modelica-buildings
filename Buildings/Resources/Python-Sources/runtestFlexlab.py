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
import testFlexlab

testFlexlab.init([], ["u1", "u2"],"")