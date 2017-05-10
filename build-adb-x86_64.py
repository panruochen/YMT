#!/usr/bin/env python

_help_msg = '''
Before running me, please:
1. cd adb-x86_64 && make -B -n > clean-all.txt && make -B -n > build-all.txt
2. Add PyZ to the environ variable of PYTHONPATH
3. Run this script in adb-x86_64 directory
'''

import os, sys
import platform, re, shlex, subprocess, threadpool, time, datetime

def runCmd(args) :
    cl, shell = args
    print "Begin  " + datetime.datetime.now().strftime("%H:%M:%S.%f") + " -> " + cl
    if shell :
        sp = subprocess.Popen(cl, True)
    else :
        sp = subprocess.Popen(shlex.split(cl))
    sp.wait()
    print "Finish " + datetime.datetime.now().strftime("%H:%M:%S.%f") + " -> " + cl
    if sp.returncode :
        print >>sys.stderr, "Command fails: %s" % cl
    return sp.returncode

def show_help_and_exit(exitcode) :
    print >>sys.stderr, _help_msg
    exit(exitcode)

#===============================================================================
#  The main function starts here
#===============================================================================
if len(sys.argv) >= 2 :
    fh = open(sys.argv[1], "r")
if len(sys.argv) <= 1 or not fh :
    print "Usage: %s BUILD-SCRIPT" % sys.argv[0]
    show_help_and_exit(2)

gcc_path = None
gxx_path = None
ar_path = None

sp = subprocess.Popen(['make', 'print-GCC', 'print-G++', 'print-AR'], stdout=subprocess.PIPE)
outs,errs = sp.communicate()
if sp.returncode :
    show_help_and_exit(1)

for line in outs.split('\n') :
    fx = line.rstrip('\r\n').split()
    if len(fx) == 0 :
        continue
    if fx[0] == 'GCC' :
        gcc_path = fx[2]
    elif fx[0] == 'G++' :
        gxx_path = fx[2]
    elif fx[0] == 'AR' :
        ar_path = fx[2]

ar_cmds = []
echo_cmds  = []
mkdir_cmds = []
rm_cmds = []
gcc_cmds = []
link_cmd = None

for x in fh :
    for line in x.rstrip('\r\n').replace('&&',';').split(';') :
        if not line :
            continue
        m = re.match("echo\\s+'(.*)'$", line)
        if m :
            echo_cmds.append(m.group(1))
            continue

        m = re.match("rm\s+-f\s+(.*)$", line)
        if m :
            rm_cmds.append(line)
            continue

        m = re.match("mkdir\s+-p\s+(.*)$", line)
        if m :
            mkdir_cmds.append(line)
            continue

        if line.find(gcc_path) == 0 or line.find(gxx_path) == 0:
            gcc_cmds.append(line)
            continue
        if line.find('yasm') == 0 :
            gcc_cmds.append(line)
            continue

        if re.match('^\s*' + ar_path, line) :
            ar_cmds.append(line)
            continue

fh.close()

if len(gcc_cmds) > 0 :
    link_cmd = gcc_cmds.pop()

start_tm = time.time()

pool = threadpool.ThreadPool.create(4, runCmd)

for x in rm_cmds :
    pool.add_task(x, False)
pool.wait()

for x in mkdir_cmds :
    pool.add_task(x, False)
pool.wait()

i = 0
for x in gcc_cmds :
    pool.add_task(x, False)
    i += 1
    if i % 32 == 0 :
        pool.wait()
#        time.sleep(2)
pool.wait()

for x in ar_cmds :
    pool.add_task(x, False)
pool.wait()

if link_cmd is not None:
    pool.add_task(link_cmd, False)

pool.wait()
pool.wait()
pool.wait()

now = time.time()
print "%d seconds past" % (now - start_tm)

time.sleep(3)

pool.add_task(gcc_path + " --version", False)
pool.add_task(gxx_path + " --version", False)
pool.add_task(ar_path + " --version", False)

pool.close()

