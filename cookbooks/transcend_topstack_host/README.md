# transcend\_topstack\_host

## Description

The default recipe in this cookbook is currently empty, but will
presumably be filled in with the Chef code necessary to install and
configure software for a TopStack host.

## Recipes

### available.rb

The transcend\_topstack\_host::available recipe will search out and
determine what versions are available of particular particular
binary software packages that we care about for TopStack, currently
only mysql-server and memcached.  This information will be stored
in a data bag named "versions" on the Chef server.  Inside of the
"versions" data bag, there will be ids for each of the software
packages of interest, and for each of the software packages of
interest we will list Semantic versioning style Major.Minor.Patch
versions for each program in a single space-delimited string.  If
the version string for a given package includes a dash character,
and optionally more characters after the dash, then the dash and
everything after it will be trimmed off before the version information
is stored.

This recipe is only expected to be run periodically on the Chef
server, or elsewhere on TopStack infrastructure resources, and the
only purpose is to populate the "versions" data bag with the current
information.  This data bag will get over-written every time this
recipe is run, with whatever information is currently available.

One of the first things this recipe does is refresh the information
available from the upstream binary software repositories as to which
versions of which software is available.  You will need to make
sure that the repositories are properly configured so that they can
be updated as needed -- either directly connected to the Internet
and using the standard repos, or connected to the servers where
your internal repos are hosted.

This recipe tries to be judicious about logging only minimal but
useful information at the "info" level, and more internal information
at the "debug" level.  Make sure that you're running chef-client
at the right logging level for the amount of logging output you
expect to see.

As of this writing, if everything goes well, then this recipe should
execute in about fifteen seconds or less, including updating the
local cache of the upstream repo information, finding all available
versions of the programs of particular interest, and storing that
data in the data bag on the Chef server.  If it takes longer than
that, you probably have screwed up repository configurations, Chef
server/data bag configurations, or something else.

### install.rb

The transcend\_topstack\_host::install recipe will take a specified
version as requested by the customer (Major.Minor.Patch) and then,
based on the information in the "versions" cookbook, find the closest
matching full version string that is actually currently available
to be installed.  It will then install the version based on the
full version string, if possible.  We do this because the "package"
resource has worked fine when fed a "Major.Minor" number as the
version to be installed, but failed when we gave it "Major.Minor.Patch".
Thus, we work around the bug in the package resource.

One of the first things this recipe does is refresh the information
available from the upstream binary software repositories as to which
versions of which software is available.  You will need to make
sure that the repositories are properly configured so that they can
be updated as needed -- either directly connected to the Internet
and using the standard repos, or connected to the servers where
your internal repos are hosted.

This list must be in sync with the list that was available to the
corresponding transcend\_topstack\_host::available recipe, otherwise
the behaviour is unlikely to match what the customer desires.

This recipe is expected to be executed on each node that is performing
TopStack functions for the end users, as opposed to operating on
the TopStack infrastructure machines.

If the programs of interest have not yet been installed on this
node, it may take a little while for this recipe to execute, even
if all it does is install mysql-server or memcached.  These can
be large programs and it can take a while to install them from
binary packages, do the initial configuration as specified in the
packaging instructions, etc....

For mysql-server and memcached, this recipe pulls the desired version
information out of the data bag node[:\_\_TRANSCEND\_\_DATABAG\_\_],
and if that data bag does not exist or is empty, then it logs a
fatal error and the run will be aborted very quickly.  The recipe
is smart enough to detect what type of package to install, based
on the name of the data bag -- if it has "rds" in the name then
mysql-server will be installed, and if it has "ecache" in the name
then memcached will be installed.

If the version as specified in this data bag is not available, then
the installation will fail.  It is the responsibility of the calling
routine(s) to ensure that they only provide options to the user
that are actually available on the target systems.

## Platforms

These recipes were developed on Ubuntu 12.04 LTS, and currently do
not support any other versions of Ubuntu, or any other platform.

If you need to add support for other platforms, then it should be
relatively easy to add appropriate "if platform?" method checks in
the Chef recipes, and put in corresponding code to handle RPMs for
RHEL, or whatever other package management methods are appropriate
for specific platforms.

In that case, see
http://docs.opscode.com/dsl\_recipe\_method\_platform.html for more
information.

## License and Author

Copyright 2012-2013 by Transcend Computing & Momentum Software, Inc.
All rights reserved.

Author:: John Gardner(<jgardner@transcendcomputing.com>)
Contributor:: Brad Knowles (<bknowles@momentumsi.com>)
