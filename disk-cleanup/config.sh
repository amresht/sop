#config.sh 
#
# COnfiguration file for the housekeeping disk-cleanup.sh
#
# Each section defines a clean up rule
#
# Supported actions: Delete, archival
#
#
#[settings]
#TODO change this as per your own business unit requirements
APP_CODE="BDFST"
LOG_ROOT="/apps/bodyfast/logs"
LOG_LEVEL="INFO"

#WHITELISTED EXTESIONS
# List of extensions the disk clean up script is allowed to operate on.
# THis is a critical safety feature to prevent accidental data loss
# List of file extensions, for a new addition add on a new line within the parentheses
ALLOWED_EXTENSIONS=(
	"tgz"
	"tar.gz"
)


# List of directories the disk clean up script is allowed to operate on.
#
# Add each new path on a new line within the parentheses
#

ALLOWED_DIRECTORIES=(
	"/var/log/tdm"
	"/opt/app/nginx/"
	"/apps/trs/log"
	"/tmp/amresh/log"
)