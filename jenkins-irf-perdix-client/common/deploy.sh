#!/bin/bash

# Licensed to the Dvara Solutions (ASF) under one or more
# contributor license agreements.  

# -----------------------------------------------------------------------------
# Deploy Script for Perdix Client
#
# Environment Prerequisites
# 
# PERDIX_CLIENT_DIR & MANAGEMENT_BUNDLE_DIR directory should be owned by `jenkins` user, group should be `www-data`
# PROCESS_JSON_DIR should be owned by `jenkins` user, group should be `tomcat`
# QUERIES_DIR and queries.sql file should be owned by `jenkins` user, group should be `tomcat`
# SMS_TEMPLATES_DIR should be owned by `jenkins`, group should be `tomcat`
# 

# Add the validation for file access by changing the permission and checking exit codes.

die() { echo "$*" 1>&2 ; exit 1; }

. setenv.sh

if [[ -z "${PERDIX_CLIENT_DIR// }" ]] || 
    [[ -z "${MANAGEMENT_BUNDLE_DIR// }" ]] ||
    [[ -z "${PROCESS_JSON_DIR// }" ]] ||
    [[ -z "${QUERIES_DIR// }" ]]
then
    die "Environment Variables are not proper!"
fi

find $MANAGEMENT_BUNDLE_DIR -type d -not -path "$MANAGEMENT_BUNDLE_DIR/server-ext/uploads" -exec chmod 755 {} \;
find $MANAGEMENT_BUNDLE_DIR -type f -not -path "$MANAGEMENT_BUNDLE_DIR/server-ext/uploads/*" -exec chmod 644 {} \;

find $PERDIX_CLIENT_DIR -type d -exec chmod 755 {} \;
find $PERDIX_CLIENT_DIR -type f -exec chmod 644 {} \;

find $PROCESS_JSON_DIR -type d -exec chmod 755 {} \;
find $PROCESS_JSON_DIR -type f -exec chmod 644 {} \;

find $QUERIES_DIR -type d -exec chmod 755 {} \;
find $QUERIES_DIR -type f -exec chmod 644 {} \;

tar -xzf build.tar.gz

rsync -av --delete ./perdix-client/ $PERDIX_CLIENT_DIR
rsync -av --delete ./management/ $MANAGEMENT_BUNDLE_DIR
rsync -av --delete ./json/ $PROCESS_JSON_DIR
cp -f queries.sql $QUERIES_DIR
cp *.apk $APK_DIR


# Change permission for folders and files as required.
# find /opt/mount_point/application/nginx/management  -type d -exec chmod 755 {} \; 

# find /opt/mount_point/application/nginx/management -type f -exec chmod 644 {} \;


# Update permissions for uploads folder to 775

if [ -d "$SMS_TEMPLATES_DIR" ]; then
    cp -f smsTemplate.txt $SMS_TEMPLATES_DIR/
else
    echo "SMS Templates not configured for the environment. Hence skipping."
fi

if [ -d "$PERDIX_GROOVY_DIR" ]; then
    find $PERDIX_GROOVY_DIR -type d -exec chmod 755 {} \;
    find $PERDIX_GROOVY_DIR -type f -exec chmod 644 {} \;

    # Not deleting the files in the target directory as these files may not be checked-in properly by developers. It will only overwrite.
    rsync -av ./perdix-server-scripts/ $PERDIX_GROOVY_DIR
else
    echo "Groovy files not configured for the environment. Hence skipping."
fi

if [ -d "$ENCORE_GROOVY_DIR" ]; then
    # Not deleting the files in the target directory as these files may not be checked-in properly by developers. It will only overwrite.
    rsync -av ./encore-server-scripts/ $ENCORE_GROOVY_DIR
else
    echo "Groovy files not configured for the environment. Hence skipping."
fi

if [ -d "$AWAAZDE_DIR" ]; then
    rsync -av --delete ./awaazde/ $AWAAZDE_DIR
else
    echo "Awaazde not configured for the environment. Hence skipping."
fi

echo "Deploy completed sucessfully!" 