#if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
#if [ -z "$BuildRelease" ] || [ -z "$BuildVersion" ] || [ -z "$BuildEnvironment" ]; then
if [ -z "$BuildRelease" ]  || [ -z "$BuildEnvironment" ]; then
   echo usage ./build.sh "<BuildRelease>" "<BuildVersion>" "<BuildEnvironment>"
   echo example ./build.sh 2.5 2.5.1 qa
   exit 1
fi

#echo      Starting to build .....
#echo      Build Release     :: $1
#echo      Build Version     :: $2
#echo      Code is built for :: $3


echo      Starting to build .....
echo      Build Release     :: $BuildRelease
echo      Build Version     :: $BuildRelease.${BUILD_NUMBER}
echo      Code is built for :: $BuildEnvironment

#BUILDFOLDERPATH="/usr/share/splan"
#BUILDFOLDERPATH="/usr/share/splan"
BUILDFOLDERPATH="/media/NewVolume/splan"
echo "BUILDFOLDERPATH: $BUILDFOLDERPATH"
#PARENT="$BUILDFOLDERPATH/buildfiles/$1"
PARENT="$BUILDFOLDERPATH/buildfiles/$BuildRelease"
echo "PARENT: $PARENT"
#BUILDVERSION="$BUILDFOLDERPATH/buildfiles/$1/$2"
#BUILDVERSION="$BUILDFOLDERPATH/buildfiles/$BuildRelease/$BuildVersion"
BUILDVERSION="$BUILDFOLDERPATH/buildfiles/$BuildRelease/$BuildRelease.${BUILD_NUMBER}"
echo "BUILDVERSION: $BUILDVERSION"
#BUILDENV="$BUILDFOLDERPATH/buildfiles/$1/$2/$3"
BUILDENV="$BUILDFOLDERPATH/buildfiles/$BuildRelease/$BuildRelease.${BUILD_NUMBER}/$BuildEnvironment"
echo "BUILDENV: $BUILDENV"
#SOURCEBRANCH=$SOURCEBRANCH
#echo "SOURCEBRANCH: $SOURCEBRANCH"
#SOURCEFOLDER=$4




if [ -d "$PARENT" ];  then
     echo folder "$PARENT" already exists ...
else
     echo creating the directory .. "$BUILDFOLDERPATH/buildfiles/$BuildRelease"
     mkdir $BUILDFOLDERPATH/buildfiles/$BuildRelease
fi

if [ -d "$BUILDVERSION" ];  then
    echo folder "$BUILDFOLDERPATH/buildfiles/$BuildRelease/$BuildRelease.${BUILD_NUMBER}" already exists
else
    echo creating the directory ... "$BUILDFOLDERPATH/buildfiles/$BuildRelease/$BuildRelease.${BUILD_NUMBER}"
    mkdir $BUILDFOLDERPATH/buildfiles/$BuildRelease/$BuildRelease.${BUILD_NUMBER}
fi

if [ -d "$BUILDENV" ];  then
    echo folder  "$BUILDENV"  exists
else
    echo creating the directory ... "$BUILDENV"
    mkdir $BUILDENV
fi

#if [ -z "$SOURCEBRANCH" ]; then 
   #SOURCEBRANCH="2.0_DEV" 
   #SOURCEFOLDER="2.0"
#fi

#cd 2.0
#cd $SOURCEFOLDER
# check whether to pull the latest code from git
# git pull git@github.com:inopassdev/splan.git 2.0
#echo 'Pull the latest code from git?(yes/no)'
#read pullCode
#    if [ -z "$pullCode" ]; then
#        echo 'No input is provided. Please try building again.'
#        exit 1
#    elif [ "$pullCode" == 'yes' ]; then
#        echo 'Getting the latest code from git.....'
#        git pull git@github.com:inopassdev/splan.git 2.0_DEV
#         git pull git@github.com:inopassdev/splan.git $SOURCEBRANCH
#    elif [ "$pullCode" == 'no'  ]; then
#        echo 'Building the code with previously pulled version'
#    fi
#read pullCode
    
     git pull git@github.com:inopassdev/splan.git $SOURCEBRANCH

   # git pull git@github.com:inopassdev/splan.git $SOURCEBRANCH

cd splan-application


cp splan-comp/src/main/resources/quartz.properties splan-comp/src/main/resources/quartz.properties_bk
cp splan-comp/src/main/resources/quartz_mssql.properties splan-comp/src/main/resources/quartz.properties

sed -i 's/MSSQLDelegate/'StdJDBCDelegate'/g' splan-comp/src/main/resources/quartz.properties 

mvn -e -Dmaven.test.skip=true -DbuildVersion=$BuildRelease.${BUILD_NUMBER} -DbuildRelease=$BuildRelease package

cp splan-comp/src/main/resources/quartz.properties_bk splan-comp/src/main/resources/quartz.properties


cp splan-web/target/splan-web.war $BUILDENV
cp splan-comp/src/Config/Database/ddl/datamodel.sql  $BUILDENV
cp splan-comp/src/Config/Database/ddl/updatescript.sql $BUILDENV
cp splan-comp/src/Config/Database/seed_data.sql $BUILDENV
cp splan-comp/src/Config/Database/ddl/procedures.sql $BUILDENV
cp splan-comp/src/Config/Database/ddl/utf8.sql $BUILDENV
# cleanup special characters...
perl -p -i -e "s/\r//g" $BUILDENV/datamodel.sql
perl -p -i -e "s/\r//g" $BUILDENV/updatescript.sql
perl -p -i -e "s/\r//g" $BUILDENV/seed_data.sql
perl -p -i -e "s/\r//g" $BUILDENV/procedures.sql


# SQL Server speciific scripts...
cp splan-comp/src/Config/Database/MSSQL/MSSQL_DataModel.sql  $BUILDENV
cp splan-comp/src/Config/Database/MSSQL/MSSQL_UpdateScript.sql $BUILDENV
cp splan-comp/src/Config/Database/MSSQL/MSSQL_SeedData.sql $BUILDENV
cp splan-comp/src/Config/Database/MSSQL/MSSQL_Procedures.sql $BUILDENV
cp splan-comp/src/Config/Database/MSSQL/MSSQL_CreateNewProvider.sql $BUILDENV
cp -r splan-comp/src/Config/Database/customers $BUILDENV


# Oracle specific scripts...
cp splan-comp/src/Config/Database/Oracle/Ora_DataModel.sql  $BUILDENV
cp splan-comp/src/Config/Database/Oracle/Ora_UpdateScript.sql $BUILDENV
cp splan-comp/src/Config/Database/Oracle/Ora_SeedData.sql $BUILDENV
cp splan-comp/src/Config/Database/Oracle/Ora_Procedures.sql $BUILDENV
cp splan-comp/src/Config/Database/Oracle/Ora_CreateNewProvider.sql $BUILDENV
cp -r  splan-comp/src/Config/Database/alertpartner  $BUILDENV

# cleanup sepcial characters.
perl -p -i -e "s/\r//g" $BUILDENV/Ora_DataModel.sql
perl -p -i -e "s/\r//g" $BUILDENV/Ora_UpdateScript.sql
perl -p -i -e "s/\r//g" $BUILDENV/Ora_SeedData.sql
perl -p -i -e "s/\r//g" $BUILDENV/Ora_Procedures.sql
perl -p -i -e "s/\r//g" $BUILDENV/Ora_CreateNewProvider.sql
perl  -p -i -e "s/\r//g" $BUILDENV/alertpartner/*

#inital data load module
cp splan-comp/src/Config/Database/ddl/UpdateScript_DDL.sql $BUILDENV
cp splan-comp/src/Config/Database/ddl/procedures.sql $BUILDENV
cp splan-comp/src/Config/Database/ddl/applProperties.sql $BUILDENV
cp splan-comp/src/Config/Database/ddl/MySQL_ArchivingData.sql $BUILDENV
cp splan-comp/src/Config/Database/ddl/MYSQL_HIBERNATE_UPDATE_DDL.sql $BUILDENV
cp splan-comp/src/Config/Database/ddl/MYSQL_DataPoints.sql $BUILDENV

perl  -p -i -e "s/\r//g" $BUILDENV/*.sql
cd ..

# Gold star project scripts...
#cp splan-imex/src/main/resources/csv/ConntypeDTO.csv  $BUILDENV
#cp splan-imex/src/main/resources/csv/ConntypeParamsDTO.csv  $BUILDENV
#cp splan-imex/src/main/resources/csv/ProviderStatusDTO.csv  $BUILDENV

#echo built and copied the application code to the build folder

d=$(date +%Y-%m-%d )
t=$(date +%I:%M:%S )
cd splan-ui/WebContent
cp ~/splan/config/version.html .
sed -i 's/{build_release}/'"$1"'/g' version.html
sed -i 's/{build_version}/'"$2"'/g' version.html
sed -i 's/{build_date}/'"$d $t"'/g' version.html



grunt $BuildEnvironment
cp dist/splan-webui.tar $BUILDENV
#cd ../../splan-kiosk/WebContent

#cp $BUILDFOLDERPATH/splan/config/version.json .
#sed -i 's/{build_release}/'"$1"'/g' version.json
#sed -i 's/{build_version}/'"$2"'/g' version.json

#grunt $BuildEnvironment
#cp dist/splan-skiosk.tar $BUILDENV
cd ../../

pwd
tar cf $BUILDENV/reportbuild.tar splan-reports/report-content/splan
cd ../../
echo Removing the other customer folders ...

pwd

# sh /usr/share/splan/splan/2.0/cleanCustomerData.sh $BUILDENV
echo build is taken for: $BuildFor

sh /usr/share/splan/splan/2.0/cleanCustomerData.sh $BUILDENV $BuildFor

echo build successful. Files are copied to : $BUILDENV
