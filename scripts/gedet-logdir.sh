#!/bin/bash

# $Id$

# Copyright (C) 2008-2011 Oliver Schulz <oliver.schulz@tu-dortmund.de>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


usage() {
echo >&2 "Usage: ${0} COMMAND OPTIONS"
cat >&2 <<EOF
Create or query a log directory

COMMANDS:
  help / -?                   Show help
  create                      create a log directory
  info                        get info about a log directory
EOF
} # usage()



usage_create() {
echo >&2 "Usage: ${0} create [OPTIONS] TYPE NAME"
cat >&2 <<EOF
Create a directory for a new measurement or simulation.

Options:
  -?                          Show help
  -y TYPE                     Meas./Sim. type (Lab-Test, Physics-Run, ...)
  -n NAME                     Short name (filename-compatible, no whitespace)
  -u USER                     Add system user-id to people involved
  -t TITLE                    Measurement/Simulation title
  -l LOCATION                 Location (Uni-Somewhere, ...)
  -s DATE                     Force start/end date (YYYY-MM-DD/YYYY-MM-DD)
  -p PATH                     Parent path for new directory
  -b                          Batch-mode, non-interactive

TYPE and NAME must be specified as argument or via -c -n option. Everything
else is optional.

TYPE Values:
  - lt: Lab-Test (Experimental stuff, quick tests, test runs, ...)
  - lm: Lab-Measurement (Serious measurements: Research, qualification, ...)
  - lr: Lab-Run (Runs under non physics-grade conditions)
  - lp: Lab-Production (Production / assembly of equipment, ...)
  - la: Lab-Activity (Anything that doesn't fit the other types)
  - lf: Lab-Result (Lab Results (plots, etc.), if kept separate from data)
  - pr: Physics-Run (Physics runs under physics-grade conditions)
  - pp: Physics-Result, preliminary (Preliminary results under physics-grade conditions)
  - pf: Physics-Result, final (Results under physics-grade conditions)
  - st: Simulation-Test (Test simulations, experimental runs, ...)
  - sr: Simulation-Run (Analysis-grade simulations)
  - sf: Simulation-Result (Simulation results)

EOF
echo >&2 "Example: ${0} create -u user_a -u user_b test-measurement"
} # usage_create()



usage_info() {
echo >&2 "Usage: ${0} info [OPTIONS] LOGDIR"
cat >&2 <<EOF
Create a directory for a new measurement or simulation.

Options:
  -?                          Show help
  -d LOGDIR                   Target directory
  -f FORMAT                   Valid formats: xml (default: xml).
EOF
echo >&2 "Example: ${0} info -d somedir -f xml"
} # usage_create()



# == main =============================================================

COMMAND="$1"
shift 1

# UTF-8 Byte-Order-Mark (BOM):
BOM=`echo -n -e '\0357\0273\0277'`


# == command help =====================================================

if [ "${COMMAND}" = "help" -o "${COMMAND}" = "-?" ] ; then
	usage
	exit 1
fi # command help



# == command create ===================================================

if [ "${COMMAND}" = "create" ] ; then

NAME=
TITLE="Measurement/Simulation Title"
TYPE=""
LOCATION="Unknown"
USERS=
DATE=`date -uI`"/"
LOGPATH="."
BATCHMODE="false"

DOMAINNAME=`dnsdomainname`
if (echo "${DOMAINNAME}" | grep -q '\(^\|\.\)mpp\.mpg\.de$') ; then LOCATION="MPP" ; fi
if (echo "${DOMAINNAME}" | grep -q '\(^\|\.\)mppmu\.mpg\.de$') ; then LOCATION="MPP" ; fi
if (echo "${DOMAINNAME}" | grep -q '\(^\|\.\)lngs\.infn\.it$') ; then LOCATION="LNGS" ; fi

# Get options:

while getopts ?u:y:n:t:l:s:p:b opt
do
	case "$opt" in
		\?)	usage_create; exit 1 ;;
		u) USERS="$USERS $OPTARG" ;;
		y) TYPE="$OPTARG" ;;
		n) NAME="$OPTARG" ;;
		t) TITLE="$OPTARG" ;;
		l) LOCATION="$OPTARG" ;;
		s) DATE="$OPTARG" ;;
		p) LOGPATH="$OPTARG" ;;
		b) BATCHMODE="true" ;;
	esac
done
shift `expr $OPTIND - 1`

# Check arguments:

if [ "${TYPE}" == "" ] ; then TYPE="$1" ; fi
if [ "${TYPE}" == "" ] ; then
	usage_create; echo -e >&2 "\nError: Argument TYPE is mandatory"; exit 1
fi
case "${TYPE}" in
	lt) TYPESPEC="Lab-Test" ;;
	lm) TYPESPEC="Lab-Measurement" ;;
	lr) TYPESPEC="Lab-Run" ;;
	lp) TYPESPEC="Lab-Production" ;;
	la) TYPESPEC="Lab-Activity" ;;
	lf) TYPESPEC="Lab-Result" ;;
	pr) TYPESPEC="Physics-Run" ;;
	pp) TYPESPEC="Physics-Result, preliminary" ;;
	pf) TYPESPEC="Physics-Result" ;;
	st) TYPESPEC="Simulation-Test" ;;
	sr) TYPESPEC="Simulation-Run" ;;
	sf) TYPESPEC="Simulation-Result" ;;
	*)  echo -e >&2 "\nError: TYPE ${TYPE} unknown."; exit 1 ;;
esac

if [ "${NAME}" == "" ] ; then NAME="$2" ; fi
if [ "${NAME}" == "" ] ; then
	usage_create; echo -e >&2 "\nError: Argument NAME is mandatory"; exit 1
fi

if [ "$USERS" == "" ] ; then USERS="${USER}" ; fi

if [ ! -d "${LOGPATH}" ] ; then
	echo -e >&2 "\nError: \"${LOGPATH}\" it not a valid directory."; exit 1
fi

# Convert whitespace in title to dashes:
NAME=`echo "${NAME}" | sed 's/[[:space:]]\+/-/g'`

# Run:

if [ "$EDITOR" == "" ] ; then EDITOR="pico" ; fi

UUID=`uuidgen -v4`
UUID_SHORT=`echo "${UUID}" | grep -o '^[^-]\+'`
DATE_START=`echo "${DATE}" | grep -o '^[^/]*'`
LOGDIR="${DATE_START}_${UUID_SHORT}_${TYPE}_${NAME}"
ABOUTFILE="about.txt"
TITLE_UNDERLINE=`echo "${TITLE}" | sed 's/./=/g'`

if [ "${LOGPATH}" != "." ] ; then
	LOGDIR="${LOGPATH}/${LOGDIR}"
fi

PEOPLE=
for u in $USERS; do
	PEOPLE="${PEOPLE}, `getent passwd $u | cut -d ':' -f 5`"
done
PEOPLE=`echo $PEOPLE | sed 's/^, //'`

mkdir "${LOGDIR}"
echo "$UUID" > "${LOGDIR}/.uuid"

echo "${LOGDIR}"

# Create UTF-8 BOM:
echo -n -e "${BOM}" > "${LOGDIR}/${ABOUTFILE}"

cat >> "${LOGDIR}/${ABOUTFILE}" <<EOF
${TITLE}
${TITLE_UNDERLINE}

Metadata
--------

  * UUID:     ${UUID}
  * Type:     ${TYPESPEC}
  * Location: ${LOCATION}
  * People:   ${PEOPLE}
  * Date:     ${DATE}

Description
-----------

Describe what and how you're going to do, measure or simulate and how it
turned out ...
EOF

echo >&2
echo >&2 "Please edit \"${LOGDIR}/${ABOUTFILE}\" (keep contents Markdown compatible)."

if [ "${BATCHMODE}" == "false" ] ; then
	${EDITOR} "${LOGDIR}/${ABOUTFILE}"
fi
	
exit 0
fi # command create


# == command info ===================================================

if [ "${COMMAND}" = "info" ] ; then

LOGDIR=
FORMAT="xml"

DOMAINNAME=`dnsdomainname`
if (echo "${DOMAINNAME}" | grep -q '\(^\|\.\)mpp\.mpg\.de$') ; then LOCATION="MPP" ; fi
if (echo "${DOMAINNAME}" | grep -q '\(^\|\.\)mppmu\.mpg\.de$') ; then LOCATION="MPP" ; fi
if (echo "${DOMAINNAME}" | grep -q '\(^\|\.\)lngs\.infn\.it$') ; then LOCATION="LNGS" ; fi

# Get options:

while getopts ?d:f: opt
do
	case "$opt" in
		\?)	usage_info; exit 1 ;;
		d) LOGDIR="$OPTARG" ;;
		f) FORMAT="$OPTARG" ;;
	esac
done
shift `expr $OPTIND - 1`

# Check arguments:

if [ "${LOGDIR}" == "" ] ; then LOGDIR="$1" ; fi
if [ "${LOGDIR}" == "" ] ; then
	usage_info; echo -e >&2 "\nError: Argument LOGDIR is mandatory"; exit 1
fi

# Check format:

if [ "${FORMAT}" = "xml" ] ; then
	ABOUTFILE="${LOGDIR}/about.txt"

	if [ -f "${ABOUTFILE}" ] ; then
		RDF_ABOUT=`echo "${LOGDIR}/" \
			| sed "s/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/\"/\&quot;/g; s/'/\&apos;/g" \
			| sed -s "s/^\//file:\/\/\//" `
		echo '	<rdf:Description xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'
		echo '	             xmlns:dc="http://purl.org/dc/elements/1.1/"'
		echo "	             rdf:about=\"${RDF_ABOUT}\">"

		INFO=`cat "${ABOUTFILE}" \
			| grep '^[[:space:]]\+\*[[:space:]]\+\(UUID\|Type\|Location\|People\|Date\):[[:space:]]\+.*$' \
			| sed "s/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g" \
			| sed 's/^[[:space:]]\+\*[[:space:]]\+\([[:alnum:]]\+\):[[:space:]]\+\(.*\)$/|\1:\2/' \
			| sed ':loop /^.*$/N;s/\n//g;tloop'`"|"
		DC_TITLE=`cat "${ABOUTFILE}" | head -n 1 | sed "s/^${BOM}//" | sed "s/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g"`
		DC_IDENTIFIER="urn:uuid:"`echo "${INFO}" | grep -o '|UUID:\([^|]\+\)|' | sed 's/|\([[:alnum:]]\+\):\([^|]\+\)|/\2/'`
		DC_TYPE=`echo "${INFO}" | grep -o '|Type:\([^|]\+\)|' | sed 's/|\([[:alnum:]]\+\):\([^|]\+\)|/\2/'`
		DC_COVERAGE=`echo "${INFO}" | grep -o '|Location:\([^|]\+\)|' | sed 's/|\([[:alnum:]]\+\):\([^|]\+\)|/\2/'`
		DC_CREATOR=`echo "${INFO}" | grep -o '|People:\([^|]\+\)|' | sed 's/|\([[:alnum:]]\+\):\([^|]\+\)|/\2/'`
		DC_DATE=`echo "${INFO}" | grep -o '|Date:\([^|]\+\)|' | sed 's/|\([[:alnum:]]\+\):\([^|]\+\)|/\2/'`
		
		if [ "${DC_TITLE}" != "" ] ; then
			echo "		<dc:title>${DC_TITLE}</dc:title>"
		fi
		if [ "${DC_IDENTIFIER}" != "" ] ; then
			echo "		<dc:identifier>${DC_IDENTIFIER}</dc:identifier>"
		fi
		if [ "${DC_TYPE}" != "" ] ; then
			echo "		<dc:type>${DC_TYPE}</dc:type>"
		fi
		if [ "${DC_COVERAGE}" != "" ] ; then
			echo "		<dc:coverage>${DC_COVERAGE}</dc:coverage>"
		fi
		if [ "${DC_CREATOR}" != "" ] ; then
			echo "		<dc:creator>${DC_CREATOR}</dc:creator>"
		fi
		if [ "${DC_DATE}" != "" ] ; then
			echo "		<dc:date>${DC_DATE}</dc:date>"
		fi

		echo "		<dc:language>en</dc:language>"
		echo '	</rdf:Description>'
	fi

	exit 0;
fi

usage_info; echo -e >&2 "\nError: Unknown format \"${FORMAT}\"."; exit 1
fi # command info



# == unknown command ==================================================

usage; echo -e >&2 "\nError: Unknown command \"${COMMAND}\"."; exit 1
