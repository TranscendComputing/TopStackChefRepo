#!/usr/bin/env python

import shutil
from subprocess import Popen, PIPE, STDOUT, call

cookbooks = Popen("knife cookbook list", 
                   stdout=PIPE, shell=True).stdout.read()
cookbooks = cookbooks.splitlines()
for cookbook in cookbooks:
	cookbook, version = cookbook.split()
	print "Download cookbook %s, %s" % (cookbook, version)
	if cookbook == "transcend_mysql":
		return_code = call("knife cookbook download %s 1.2.3" % cookbook, shell=True)
	else:
		return_code = call("knife cookbook download %s" % cookbook, shell=True)
    	if return_code != 0:
        	print >>sys.stderr, "Download failed on %s: " % cookbook, return_code
	shutil.move("%s-%s" % (cookbook, version), "%s" % cookbook)	


