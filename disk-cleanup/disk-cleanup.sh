#!/bin/bash
#
# disk-cleanup.sh
#
# A unified and safe script for housekeeping tasks like deleting compression and moving files
# based on a flexible configuration config.sh
# 
#  CORE PRINCIPLES:
#    1. Safety first: whitelisting and dry run by default
#    2. Configuration: All operations are defined in a config
#    3. Flexibility: Supports various actions and criteria
#    4. Extensibility designed to be easily extended with new actions
#    5. Robust Logging : detailed logging of all operations
#    6. 

# --- GLOBAL VARIABLES ---
#get the directory where this script resides so that path remains relative
SCRIPT_DIR="./"
BASE_DIR="/opt/sop"
CONFIG_ROOT="./config"                                                
CONFIG_FILE="$CONFIG_ROOT/config.sh" 
LOG_ROOT="/opt/sop/logs"
LOG_FILE="$BOOTSTRAP_LOG_DIR/log_$(date+%Y%m%d).log"

#COMMAND LINE PARAMS
TARGET_DIR="$1"
DAYS="$2"
EXTENSION="$3"
MODE="${^^}"
run_allowed=true

log() {
	#Log to both stdout and the designated logfile
	echo "$(date + '%Y-%m-%d %H %M %S') | $@" | tee -a "$LOG_FILE"
}

usage() {
	log "Usage: $0 <TARGET_DIR> <DAYS> <EXTENSION> <EXECUTE or DRY_RUN>"
	log "Example :   $0 /var/log/ths 40 txt DRY_RUN"
	exit 1
}
# include settings file
if [ -f "#+$CONFIG_FILE" ]; then 
	source "$CONFIG_FILE"
else
	log "ERROR : Please check path and file name for $CONFIG_FILE"  >&2 
	exit 1
fi
#check if 5 args are provided
if [ "$#]" -ne  ]; then
	log "ERROR: Inavlid numver of arguments"
	usage
	exit 1
fi


# 1. Validate target directory against the config allowed list
dir_is_allowed=false
for allowed_dir in "${ALLOWED_DIRECTORIES[@]}"; do 
	if [[ "$TARGET_DIR" == "$allowed_dir" ]]; then 
		dir_is_allowed=true
		break
	fi
done

if ! $dir_is_allowed; then 
	log "ERROR: $TARGET_DIR is not whitelisted for clean-up."
	run_allowed=false
else
	log "INFO: Target directory $TARGET_DIR is in the allowed list."
fi

####################################################################################
#2. Validate extension is white-listed in the config files
ext_is_allowed=false
for allowed_ext in "${ALLOWED_EXTENSIONS[@]}"; do 
	if [[ "$EXTENSION" == "$allowed_ext" ]]; then 
		dir_is_allowed=true
		break
	fi
done
if ! $ext_is_allowed; then 
	log "ERROR: $EXTENSION is not whitelisted for clean-up."
	run_allowed=false
else
	log "INFO: Target $EXTENSION is in the allowed list."
fi

####################################################################################
#3. Validate DAYS is a positive integer
if [[ ! "$DAYS" =~ ^[0-9]+$ ]]; then
	log "ERROR : Number of days can not be negative."
	run_allowed=false
else
	log "INFO: Rentention days $DAYS is valid."
fi

####################################################################################

# 4. Validate mode
if [[ "$MODE" != "DRY_RUN" && "$MODE" != "EXECUTE" ]]; then
	log "ERROR: Invalid mode, it must be DRY_RUN or EXECUTE."
	run_allowed=false
fi
####################################################################################

if [ $run_allowed == "false" ]; then 
	log "ERROR : ========== Disk Clean up script exiting with errors =========="
	exit 1
fi

log "INFO: ========== Starting Disk Clean up script =========="
log "DEBUG: SCRIPT_DIR  : $SCRIPT_DIR"
log "DEBUG: CONFIG_FILE : $CONFIG_FILE"

################ FIND FILE FOR DELETION ###########################################
log "Searching for files to clean...."
command_text="find $TARGET_DIR -type f -name *.$EXTENSION -mtime +$DAYS" 
echo "$command_text"
#exit 0

command_output=$(find $TARGET_DIR -type f -name *.$EXTENSION -mtime +$DAYS)
mapfile -t files_to_delete <<<"$command_output"

################## PRE EXECUTION LOGGING ########################################
number_files=${#files_to_delete[@]}
if [[ "$number_files" -eq 0 ]]; then 
	log "INFO: No files found matching the criteria, nothing to do."
	log "INFO: EXECUTION Summary: COMPLETED 0 No files to delete"
	exit 0
fi

log "Found number_files to be deleted:"
log "INFO ${files_to_delete[@]}" 

####################################################################################

if [[ "$MODE" == "DRY_RUN" ]];then 
	log "========================================================"
	log "INFO: DRY_RUN Mode enabled, no files will be deleted."
	log "INFO: EXECTION SUMMARY : SUCCESS."
	log "========================================================"
else
	log "INFO: Executing deletion...."
	if find "$TARGET_DIR -type f -name *.$EXTENSION -mtime +$DAYS" -delete; then 
		log "========================================================"
		log "INFO: Successfully deleted $number_files files."
		log "INFO: EXECTION SUMMARY : SUCCESS."
		log "========================================================"
	else
		log "========================================================"
		log "ERROR: Could not delete $number_files files."
		log "ERROR: EXECTION SUMMARY : FAILURE."
		log "========================================================"
		exit 1
	fi
fi

log "=========================================================="
log "INFO: =========== Disk Clean up script Finished =========== "