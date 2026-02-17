#!/bin/bash

#1. cmd line arg  quoting
if [ "$#" -ne 3 ]
then
    echo "Usage: $0 <src_dir> <backup_dir> <ext>"
    exit 1
fi
SOURCE_DIR="$1"
BACKUP_DIR="$2"
EXT="$3"

#2. globbing
FILES=("$SOURCE_DIR"/*"$EXT")

#3. export statements
export  BACKUP_COUNT=0

#4. array operations
for file in "${FILES[@]}"
do
    size=$(stat -c "%s" "$file")
    echo "$(basename "$file") --> $size bytes"
done

#4. conditional execution
if [ ! -d "$BACKUP_DIR" ]
then    
    mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ]
    then 
        echo "Error: Could not create backup directory!"
        exit 1
    fi
fi
if [ ${#FILES[@]} -eq 0 ]
then 
    echo "No files with extension $EXT found in $SOURCE_DIR."
    exit 1
fi
TOTAL_SIZE=0
for file in "${FILES[@]}" 
do
    filename=$(basename "$file")
    destFile="$BACKUP_DIR/$filename"
    size=$(stat -c "%s" "$file")
    if [ -e "destFile" ]
    then
        if [ "$file" -nt "$destFile" ]
        then
            cp "$file" "$destFile"
            BACKUP_COUNT=$((BACKUP_COUNT + 1))
            TOTAL_SIZE=$((TOTAL_SIZE + size))
        fi
    else
        cp "$file" "$destFile"
        BACKUP_COUNT=$((BACKUP_COUNT + 1))
        TOTAL_SIZE=$((TOTAL_SIZE + size))
    fi
done

#6. output reporting
REPORT_FILE="$BACKUP_DIR/backup_report.log"

{
    echo "Backup Summary Report"
    echo "-------------------------"
    echo "Total files processed: ${#FILES[@]}"
    echo "Total files backed up: $BACKUP_COUNT"
    echo "Total size of files backed up: $TOTAL_SIZE bytes"
    echo "Backup directory: $BACKUP_DIR"
} > "$REPORT_FILE"

echo "Backup completed successfully"
echo "Report saved to $REPORT_FILE"
