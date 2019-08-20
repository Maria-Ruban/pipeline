
set +x
ln -s /usr/local/lib/node_modules ../common/node_modules
node ../common/findMissingLabels.js mysql://ruser:pass%40123@${ENV_HOST_NAME}/${SERVEREXT_DBNAME}
set -x

if [ -d generated ];then
    rm -r generated
fi
mkdir generated

cd source
bower cache clean irf-elements
bower uninstall irf-elements angular-data-table
bower install
rm -rf node_modules
npm install

if [ "$APK_REQUIRED" = true ] ; then
    gulp clean
    gulp build --siteCode=${SITECODE}
    Client=${CLIENT}
    build_mode=${BUILDMODE}
    Build_Environment=${RELEASE_ENVIRONMENT}

    gulp appManifestUpdate --version-post-fix=${RELEASE_ENVIRONMENT} --version=${VERSION}

    bundleId=com.dvara.perdix_${SITECODE}
    if [ -z $BUNDLE_ID ]
    then
        # bundleId=$BUNDLE_ID
        bundleId=com.dvara.perdix_${SITECODE}
    else
            bundleId=$BUNDLE_ID
            
    fi

    gulp androidManifestUpgrade --version=${VERSION} --bundle-id=$bundleId --app-name="$APP_NAME"
    build_mode="${BUILDMODE}"

    gulp build --siteCode=${SITECODE}
    cp ../../build/env_config/perdix-client__irf-env.js ./www/js/irf-env.js

    rm -rf platforms/
    rm -rf plugins/

    if [ -f build.json ]
    then
            rm build.json
    fi

    if [ ! -d platforms/android ]
    then
            cordova platform add android@${CDV_AND_VERSION}
    fi

    mv ../../build/env_config/build-signing.properties ./platforms/android/${build_mode}-signing.properties
    mv ../../build/env_config/release-key.keystore ./platforms/android/release-key.keystore

    cordova prepare android

    cordova build android --${build_mode}

    cd ..

    if [ -d build_apk ]
    then
            rm -r build_apk/
    fi
    mkdir build_apk
    mv source/platforms/android/build/outputs/apk/${build_mode}/android-${build_mode}.apk generated/$APK_FILE_NAME
    cd source
fi

gulp clean
gulp build --siteCode=${SITECODE} --babelRequired=${BABEL_REQUIRED}

if [ -z "$PERDIX7_INTEGEGRATION_URL" ];
then
    echo "Perdix7 Integration URL not defined. Not changing integation.html"
else
    echo "Perdix7 Integration URL defined. Updating integration.html."
    gulp updateLegacyURLInIndex --legacy-system-url=$PERDIX7_INTEGEGRATION_URL
fi

gulp build --siteCode=${SITECODE} --babelRequired=${BABEL_REQUIRED}
cd ..

if [ $PERDIX7_INTEGEGRATION_STRATEGY = "INDEX_FILE_REPLACEMENT" ]; then
    cp source/www/index.html source/www/index8.html
    cp source/www/integration.html source/www/index.html
fi
cd configuration/management/server-ext
composer install --ignore-platform-reqs
cd ../../../

cp configuration/queries.sql generated/
cp -R source/www generated/
mv generated/www generated/perdix-client
mkdir -p generated/json
cp configuration/"Process Definition JSONs"/Active/${PROCESS_JSON_DIR}/*.json generated/json
cp -R configuration/management generated/
if [ ! -z $SMS_TEMPLATE_DIR ] && [ -d "configuration/smsTemplate/${SMS_TEMPLATE_DIR}" ]; then
    cp -R configuration/smsTemplate/${SMS_TEMPLATE_DIR}/smsTemplate.txt generated/
else
    echo "SMS Templates configuration not given. Hence skipping."
fi

if [ ! -z $PERDIX_GROOVY_DIR ] && [ -d "configuration/perdix-server-scripts/${PERDIX_GROOVY_DIR}" ]; then
    cp -R configuration/perdix-server-scripts/${PERDIX_GROOVY_DIR} generated/perdix-server-scripts
else
    echo "NO perdix-server-scripts DEFINED"
fi

if [ ! -z $ENCORE_GROOVY_DIR ] && [ -d "configuration/encore-server-scripts/${ENCORE_GROOVY_DIR}" ]; then
    cp -R configuration/encore-server-scripts/${ENCORE_GROOVY_DIR} generated/encore-server-scripts
else
    echo "NO encore-server-scripts DEFINED"
fi

if [ ! -z $CONF_DIR_NAME ] && [ -d "configuration/awaazde/${CONF_DIR_NAME}" ]; then
    cp -R configuration/awaazde/${CONF_DIR_NAME} generated/awaazde
else
    echo "NO awaazde DEFINED"
fi

 # Moving environment files
echo "Moving environment config files..."
mv ../build/env_config/perdix-client__irf-env.js generated/perdix-client/js/irf-env.js
mv ../build/env_config/scoring__ConfigureDbs.php generated/management/scoring/includes/ConfigureDbs.php
mv ../build/env_config/scoring__db.php generated/management/scoring/includes/db.php
mv ../build/env_config/user-management__init.php generated/management/user-management/_init.php
mv ../build/env_config/server-ext__env.env generated/management/server-ext/.env

cd generated
tar -czf build.tar.gz *
cd ..
mv generated/build.tar.gz target/
exit 0