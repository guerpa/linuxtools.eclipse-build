#!/bin/bash
set -e

baseDir=$(pwd)
workDirectory=
baseBuilder=
eclipseBuilder=

buildID="R3_7_1"
baseBuilderTag="R3_7_1"
eclipseBuilderTag="R3_7_1"
label="3.7.1"
fetchTests="yes"

usage="usage:  <build ID> [-workdir <working directory>] [-baseBuilder <path to org.eclipse.releng.basebuilder checkout>] [-eclipseBuilder <path to org.eclipse.releng.eclipsebuilder checkout>] [-baseBuilderTag <org.eclipse.releng.basebuilder tag to check out>] [-noTests]"

while [ $# -gt 0 ]
do
        case "$1" in
                -workdir) workDirectory="$2"; shift;;
                -workDir) workDirectory="$2"; shift;;
                -baseBuilder) baseBuilder="$2"; shift;;
                -baseBuilderTag) baseBuilderTag="$2"; shift;;
                -eclipseBuilder) eclipseBuilder="$2"; shift;;
                -eclipseBuilderTag) eclipseBuilderTag="$2"; shift;;
                -noTests) fetchTests="no"; shift;;
                -help) echo $usage; exit 0;;
                --help) echo $usage; exit 0;;
                -h) echo $usage; exit 0;;
                *) buildID="$1";
        esac
        shift
done

# Must specify a build ID
if [ "x${buildID}x" = "xx" ]; then
    echo >&2 "Must specify build ID.  Example:  R3_5_1 ."
    echo >&2 "${usage}"
    exit 1
else
  echo "Going to create source tarballs for ${buildID}."
fi

if [ "x${workDirectory}x" = "xx" ]; then
  workDirectory="${baseDir}"
  echo "Working directory not set; using this directory (${baseDir})."
fi

if [ "x${baseBuilder}x" = "xx" ]; then
  baseBuilder="${workDirectory}"/org.eclipse.releng.basebuilder
  echo "Basebuilder checkout not specified; will check out ${baseBuilderTag} into ${baseBuilder}."
fi
if [ "x${eclipseBuilder}x" = "xx" ]; then
  eclipseBuilder="${workDirectory}"/org.eclipse.releng.eclipsebuilder
  echo "Eclipsebuilder checkout not specified; will check out into ${eclipseBuilder}."
fi

fetchDirectory="${workDirectory}"/fetch
mkdir -p "${fetchDirectory}"
homeDirectory="${workDirectory}"/userhome
rm -rf "${homeDirectory}"
mkdir -p "${homeDirectory}"
workspace="${workDirectory}"/workspace
rm -rf "${workspace}"
mkdir -p "${workspace}"
cvsRepo=":pserver:anonymous@dev.eclipse.org:/cvsroot/eclipse"
mapsRoot="org.eclipse.releng/maps"

commonGitRepo="git://git.eclipse.org/gitroot/platform/eclipse.platform.common"

# Fetch basebuilder
if [ ! -e "${baseBuilder}" ]; then
  mkdir -p "${baseBuilder}"
  cd "${baseBuilder}"/..
  cvs -d${cvsRepo} co -r ${baseBuilderTag} org.eclipse.releng.basebuilder
  cd "${baseDir}"
fi

# Fetch eclipsebuilder
if [ ! -e ${eclipseBuilder} ]; then
  mkdir -p "${eclipseBuilder}"
  cd "${eclipseBuilder}"/..
  cvs -d${cvsRepo} co -r ${eclipseBuilderTag} org.eclipse.releng.eclipsebuilder
  cd "${eclipseBuilder}"
  patch -p0 < "${baseDir}"/patches/eclipse-addFetchMasterAndTestsTargets.patch
  patch -p0 < "${baseDir}"/patches/eclipse-removeSkipMapsCheck.patch
  cd "${baseDir}"
fi

if [ -e ${fetchDirectory}/orbitRepo ]; then
  cd "${eclipseBuilder}"
  patch -p0 < "${baseDir}"/patches/eclipse-dontusefullmoonformaster.patch
  cd "${baseDir}"
fi

if [ -e ${fetchDirectory}/ecfBundles ]; then
  cd "${eclipseBuilder}"
  patch -p0 < "${baseDir}"/patches/eclipse-useLocalECFBundles.patch
  cd "${baseDir}"
fi

# Build must be run from within o.e.r.eclipsebuilder checkout
cd "${eclipseBuilder}"

java -jar \
"${baseBuilder}"/plugins/org.eclipse.equinox.launcher_*.jar \
-consolelog \
-data "${workspace}" \
-application org.eclipse.ant.core.antRunner \
-f buildAll.xml \
fetchMasterFeature \
-DbuildDirectory="${fetchDirectory}" \
-DskipBase=true \
-DmapsRepo=${cvsRepo} \
-DmapCvsRoot=${cvsRepo} \
-DmapsCvsRoot=${cvsRepo} \
-DmapsRoot=${mapsRoot} \
-DmapsCheckoutTag=${buildID} \
-DmapVersionTag=${buildID} \
-Dcommonrepo=${commonGitRepo} \
-Duser.home="${homeDirectory}" \
2>&1 | tee ${workDirectory}/sourcesFetch.log

cd "${fetchDirectory}"

# Extract osgi.util src for rebuilding
pushd plugins/org.eclipse.osgi.util
  unzip -q -d src src.zip
  # Remove pre-compiled class files and the source.zip
  rm -r org/ src.zip
popd

# Remove scmCache directory
rm -rf scmCache

git clone git://git.eclipse.org/gitroot/ecf/org.eclipse.ecf.git
cd org.eclipse.ecf
git archive --format=tar --prefix=ecf-3.5.0/ R-Release_HEAD-sdk_feature-19_2011-03-13_18-40-16 | gzip >ecf-3.5.0.tar.gz
cp ecf-3.5.0.tar.gz ../
cd ..
rm -fr org.eclipse.ecf
tar -xf ecf-3.5.0.tar.gz
rm -fr ecf-3.5.0.tar.gz
cd ecf-3.5.0

# Source for ECF bthat aren't part of SDK map files
for f in \
    org.eclipse.ecf \
    org.eclipse.ecf.filetransfer \
    org.eclipse.ecf.identity \
    org.eclipse.ecf.ssl \
; do
mv framework/bundles/$f ../plugins;
done

for f in \
    org.eclipse.ecf.provider.filetransfer \
    org.eclipse.ecf.provider.filetransfer.httpclient \
    org.eclipse.ecf.provider.filetransfer.httpclient.ssl \
    org.eclipse.ecf.provider.filetransfer.ssl \
; do
mv  providers/bundles/$f ../plugins;
done
cd ..
rm -fr ecf-3.5.0

cd "${fetchDirectory}"
# We don't want to re-ship these as those bundles inside will already be
# copied into the right places for the build
rm -rf ecfBundles orbitRepo

# Remove files from the version control system
find -depth -name CVS -exec rm -rf {} \;

# Remove prebuilt binaries
find \( -name '*.exe' -o -name '*.dll' \) -delete
find -type f \( -name '*.so' -o -name '*.so.2' -o -name '*.a' \) -delete
find \( -name '*.sl' -o -name '*.jnilib' \) -delete
find \( -name '*.cvsignore' \) -delete

# Remove unnecessary repo
rm -rf tempSite

# Remove binary JARs
find -type f -name '*.jar' -delete

# Remove fetch logs
rm fetch_*

# Remove unnecessary feature and plugins
rm -rf features/org.eclipse.sdk.examples
rm -rf plugins/*.examples*

# Remove temporary files
find -name '*.orig' -delete

# Remove empty directories
find -type d -empty -delete

cd ..
mv fetch eclipse-${label}-src
tar cjf "${workDirectory}"/eclipse-${label}-src.tar.bz2 \
  eclipse-${label}-src
cd "${eclipseBuilder}"

if [ "${fetchTests}" = "yes" ]; then

rm -rf "${fetchDirectory}"/*

java -jar \
"${baseBuilder}"/plugins/org.eclipse.equinox.launcher_*.jar \
-consolelog \
-data "${workspace}" \
-application org.eclipse.ant.core.antRunner \
-f buildAll.xml \
fetchSdkTestsFeature \
-DbuildDirectory="${fetchDirectory}" \
-DskipBase=true \
-Dhuson=true \
-DmapsRepo=${cvsRepo} \
-DmapCvsRoot=${cvsRepo} \
-DmapsCvsRoot=${cvsRepo} \
-DmapsRoot=${mapsRoot} \
-DmapsCheckoutTag=${buildID} \
-DmapVersionTag=${buildID} \
-Dcommonrepo=${commonGitRepo} \
-Duser.home="${homeDirectory}" \
2>&1 | tee "${workDirectory}"/testsFetch.log

cd ${workDirectory}
mkdir ${workDirectory}/eclipse-sdktests-${label}-src
mv ${fetchDirectory}/* ${workDirectory}/eclipse-sdktests-${label}-src
tar cjf ${workDirectory}/eclipse-sdktests-${label}-src.tar.bz2 \
 eclipse-sdktests-${label}-src

scriptsDir=org.eclipse.releng.eclipsebuilder/eclipse/buildConfigs/sdk.tests/testScripts
testScripts=eclipse-sdktests-${label}-scripts

# Testing runtests and test.xml scripts which are not in org.eclipse.test
rm -rf org.eclipse.releng.eclipsebuilder/eclipse/buildConfigs/sdk.tests/testScripts/*
cvs -d ${cvsRepo} co -r ${buildID} ${scriptsDir}

mkdir ${testScripts}
mv ${scriptsDir}/runtests ${testScripts}
mv ${scriptsDir}/test.xml ${testScripts}
rm -rf org.eclipse.releng.eclipsebuilder
tar cjf ${workDirectory}/eclipse-sdktests-${label}-scripts.tar.bz2 ${testScripts}

fi

cd "${baseDir}"
