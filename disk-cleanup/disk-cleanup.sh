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
#get the directotry where this script resides so that path remains relative
