#!/bin/bash
s_version="v1.9"
echo "Java data collection script $s_version started."
date=$(date '+%Y-%m-%d %H:%M:%S')
date_f=$(date '+%Y-%m-%d_%H%M%S')
ComputerName=$(hostname)
JavaLogFolder="/var/log/JavaLog/"
output_file="/var/log/JavaLog/$ComputerName-java-installations_$date_f.log"
os_name=$(uname -s)
os_details=$(uname -a)
java_version=""
java_class_path=$(dirname "$0")
java_class="Info"
scan_option=$1


# Function to get first-level directories from root
get_directories() {
    ls -d -1 /*/ | sed 's:/$::'
}

### Check if a directory does not exist ###
if [[ ! -d "/var/log/JavaLog/" ]] 
then
    #echo "/var/log/JavaLog - CREATING NOW." 
    #create folder structure
    mkdir -p /var/log/JavaLog/

else
    #echo "/var/log/JavaLog already exists"
    rm -rf /var/log/JavaLog/*.log
    # Writes in logs that folders already exist
fi


# Function to search for an executable file in the given directories
search_executable() {
    local executable_name="$1"
    local directories=($(get_directories))

    for dir in "${directories[@]}"; do
	if [[ $dir != "/" && $dir != "/proc" && $dir != "/.snapshots" && $dir != "/dev" ]]; then
		if [[ "$os_name" == "Linux" ]]; then
			find "$dir" -type f -name "$executable_name" -executable 2>/dev/null
		elif [[ "$os_name" == "SunOS" ]]; then
			find "$dir" -name "$executable_name" -type f 2>/dev/null
		else
			find "$dir" -name "$executable_name" -type f
		fi
	fi
    done
}

# Function to search for an executable file in the given directories ver.2
search_executable_v2() {
    local executable_name="$1"
    local directories=($(get_directories))

    for dir in "${directories[@]}"; do
      if [[ "$os_name" == "Darwin" ]]; then
        if [[ $dir != "/" && $dir != "/proc" && $dir != "/.snapshots" && $dir != "/dev" && $dir != "/Network" && $dir != "/etc" && $dir != "/home" && $dir != "/tmp" && $dir != "/var" ]]; then
          #echo "find \"$dir\" \( $executable_name \) -type f 2>/dev/null" >> test.txt # for debug
          find "$dir" \( $executable_name \) -type f 2>/dev/null
          #date >> test.txt # for debug
        fi
      else
        if [[ $dir != "/" && $dir != "/proc" && $dir != "/.snapshots" && $dir != "/dev" ]]; then
          if [[ "$os_name" == "Linux" ]]; then
            #echo "find \"$dir\" \( $executable_name \) -type f -executable 2>/dev/null" >> test.txt # for debug
            find "$dir" \( $executable_name \) -type f -executable 2>/dev/null
            #date >> test.txt # for debug
          elif [[ "$os_name" == "SunOS" ]]; then
            #echo "find \"$dir\" \( $executable_name \) -type f 2>/dev/null" >> test.txt # for debug
            find "$dir" \( $executable_name \) -type f 2>/dev/null
            #date >> test.txt # for debug
          else
            #echo "find \"$dir\" \( $executable_name \) -type f 2>/dev/null" >> test.txt # for debug
            find "$dir" \( $executable_name \) -type f 2>/dev/null
            #date >> test.txt # for debug
          fi
        fi
      fi
    done
}

# Function to search for alljava file in the given directories
search_otherjava() {
    local file_name="$1"
    local directories=($(get_directories))
    for dir in "${directories[@]}"; do
	if [[ $dir != "/" && $dir != "/proc" && $dir != "/.snapshots" && $dir != "/dev" ]]; then
		if [[ "$os_name" == "Linux" ]]; then
			find "$dir" -type f -name "$file_name" 2>/dev/null
		elif [[ "$os_name" == "SunOS" ]]; then
			find "$dir" -name "$file_name" -type f 2>/dev/null
		else
			find "$dir" -name "$file_name" -type f
		fi
	fi
    done
}

# Function to search for alljava file in the given directories ver.2
search_otherjava_v2() {
    local file_name="$1"
    local directories=($(get_directories))
    for dir in "${directories[@]}"; do
      if [[ "$os_name" == "Darwin" ]]; then
        if [[ $dir != "/" && $dir != "/proc" && $dir != "/.snapshots" && $dir != "/dev" && $dir != "/Network" && $dir != "/etc" && $dir != "/home" && $dir != "/tmp" && $dir != "/var" ]]; then
          #echo "find \"$dir\" \( $file_name \) -type f 2>/dev/null" >> test.txt # for debug
          find "$dir" \( $file_name \) -type f 2>/dev/null
          #date >> test.txt # for debug
        fi
      else
        if [[ $dir != "/" && $dir != "/proc" && $dir != "/.snapshots" && $dir != "/dev" ]]; then
          if [[ "$os_name" == "Linux" ]]; then
            #echo "find \"$dir\" \( $file_name \) -type f" >> test.txt # for debug
            find "$dir" \( $file_name \) -type f 2>/dev/null
            #date >> test.txt # for debug
          elif [[ "$os_name" == "SunOS" ]]; then
            #echo "find \"$dir\" \( $file_name \) -type f" >> test.txt # for debug
            find "$dir" \( $file_name \) -type f 2>/dev/null
            #date >> test.txt # for debug
          else
            #echo "find \"$dir\" \( $file_name \) -type f" >> test.txt # for debug
            find "$dir" \( $file_name \) -type f 2>/dev/null
            #date >> test.txt # for debug
          fi
        fi
      fi
    done
}

# A function to collect the "java -version" command output
function getJavaVersion(){
 if [[ -x $java_path ]]; then
    java_version="$("$java_path" -version 2>&1 | tr '\n' ',' | awk '{print substr($0, 1, length($0)-1)}')"
  else
    java_version="File is not an executable!"
  fi
}

# A function to collect the "java Info" class output
function getJavaInfo(){
 if [[ -x $java_path ]]; then
    java_info="$("$java_path" -classpath "$java_class_path" "$java_class")"
  else
    java_info='n/a;n/a;n/a;n/a;n/a;n/a;n/a'
  fi
}

# A function to write output to the file
function writeOutputFile(){
  getJavaVersion
  getJavaInfo
  echo "\"$running_no\";\"$(hostname)\";\"$java_path\";\"$date\";\"$1\";\"$java_version\";$java_info" >> "$output_file"
}

function writeOutputFileNoExecute(){
  echo "\"$running_no\";\"$(hostname)\";\"$java_path\";\"$date\";\"$1\";n/a;n/a;n/a;n/a;n/a;n/a;n/a;n/a" >> "$output_file"
}

echo "Java script version: $s_version" > "$output_file"
echo "Date and Time: $date" >> "$output_file"
echo "Detected OS type: [$os_name]" >> "$output_file"
echo "Detected OS specs: [$os_details]" >> "$output_file"
if [ "$scan_option" != "onlyexec" ]; then
  scan_option="full"
  echo "Scan option: \"Full scan\"" >> "$output_file"
else
  echo "Scan option: \"Only executable scan\"" >> "$output_file"
fi

# determine desktop or server and add osi running no for server
if [ "$os_name" == "Linux" ]; then
  running_no=`ls -ld /image/U???? | grep "^d" | awk -F"/" '{print $NF}'`
elif [ "$os_name" == "SunOS" ]; then
  running_no=`ls -ld /image/U???? | grep "^d" | awk -F"/" '{print $NF}'`
elif [ "$os_name" == "AIX" ]; then
  running_no=`ls -ld /image/U???? | grep "^d" | awk -F"/" '{print $NF}'`
elif [ "$os_name" == "Darwin" ]; then
  running_no="N/A"
else
  running_no=`ls -ld /image/U???? | grep "^d" | awk -F"/" '{print $NF}'`
fi
if [ "$running_no" == "" ]; then
  running_no="U0000"
fi

echo "\"Server_OSI_No\";\"Server_Name\";\"Java_Installation_Path\";\"Collection_Date\";\"Collection_Type\";\"Java_Version\";\"java.vendor\";\"java.version\";\"java.runtime.version\";\"java.vm.name\";\"java.runtime.name\";\"Product Classification\";\"License\"" >> "$output_file"

if [[ "$os_name" == "Linux" ]]; then
  find_option=""
  for java_exec in "java"; do
    if [ "${find_option}" == "" ]; then
        find_option="-name $java_exec"
    else
        find_option="$find_option -o -name $java_exec"
    fi
  done

  while read -r java_path; do
	  date=$(date '+%Y-%m-%d %H:%M:%S:%3N')
	  writeOutputFile "java_exec_scan"
  done < <( search_executable_v2 "$find_option" )

  if [ "$scan_option" == "full" ]; then
    find_option=""
    for java_installer in "jre*.zip" "jdk*.zip" "jdk*.tar.gz" "jdk*.rpm" "graalvm-jdk*.zip" "graalvm-jdk*.tar.gz" "server-jre-*.tar.gz" "java_ee*.zip"; do
      if [ "${find_option}" == "" ]; then
          find_option="-name $java_installer"
      else
          find_option="$find_option -o -name $java_installer"
      fi
    done

      while read -r java_path; do
        date=$(date '+%Y-%m-%d %H:%M:%S:%3N')
        writeOutputFileNoExecute "java_installer_scan"
      done < <( search_otherjava_v2 "$find_option" )
    
    find_option=""
    for java_enterprise in "jmc" "usagetracker.properties"; do
      if [ "${find_option}" == "" ]; then
          find_option="-name $java_enterprise"
      else
          find_option="$find_option -o -name $java_enterprise"
      fi
    done

      while read -r java_path; do
        date=$(date '+%Y-%m-%d %H:%M:%S:%3N')
        writeOutputFileNoExecute "java_enterprise_scan"
      done < <( search_otherjava_v2 "$find_option" )
    
  fi
  
elif [[ "$os_name" == "SunOS" ]]; then
  find_option=""
  for java_exec in "java"; do
    if [ "${find_option}" == "" ]; then
        find_option="-name $java_exec"
    else
        find_option="$find_option -o -name $java_exec"
    fi
  done

  while read -r java_path; do
    if test -x "$java_path"; then
	    date=$(date '+%Y-%m-%d %H:%M:%S:%3N')
	    writeOutputFile "java_exec_scan"
    fi
  done < <( search_executable_v2 "$find_option" )

  if [ "$scan_option" == "full" ]; then
    find_option=""
    for java_installer in "jre*.zip" "jdk*.zip" "jdk*.tar.gz" "jdk*.rpm" "graalvm-jdk*.zip" "graalvm-jdk*.tar.gz" "server-jre-*.tar.gz" "java_ee*.zip"; do
      if [ "${find_option}" == "" ]; then
          find_option="-name $java_installer"
      else
          find_option="$find_option -o -name $java_installer"
      fi
    done

      while read -r java_path; do
      date=$(date '+%Y-%m-%d %H:%M:%S:%3N')
      writeOutputFileNoExecute "java_installer_scan"
      done < <( search_otherjava_v2 "$find_option" )
    
    find_option=""
    for java_enterprise in "jmc" "usagetracker.properties"; do
      if [ "${find_option}" == "" ]; then
          find_option="-name $java_enterprise"
      else
          find_option="$find_option -o -name $java_enterprise"
      fi
    done

      while read -r java_path; do
      date=$(date '+%Y-%m-%d %H:%M:%S:%3N')
      writeOutputFileNoExecute "java_enterprise_scan"
      done < <( search_otherjava_v2 "$find_option" )
  fi
  
else
  echo "Java data collection script was not tested on [$os_name] OS."
  echo "Using default Find parameters to collect the data."
  echo "In case of errors please reach out to us for support."

  find_option=""
  for java_exec in "java"; do
    if [ "${find_option}" == "" ]; then
        find_option="-name $java_exec"
    else
        find_option="$find_option -o -name $java_exec"
    fi
  done

  while read -r java_path; do
	  date=$(date '+%Y-%m-%d %H:%M:%S:%3N')
	  writeOutputFile "java_full_scan"
  done < <( search_executable_v2 "$find_option" )

  if [ "$scan_option" == "full" ]; then
    find_option=""
    for java_installer in "jre*.zip" "jdk*.zip" "jdk*.tar.gz" "jdk*.rpm" "graalvm-jdk*.zip" "graalvm-jdk*.tar.gz" "server-jre-*.tar.gz" "java_ee*.zip"; do
      if [ "${find_option}" == "" ]; then
          find_option="-name $java_installer"
      else
          find_option="$find_option -o -name $java_installer"
      fi
    done

    while read -r java_path; do
      date=$(date '+%Y-%m-%d %H:%M:%S:%3N')
      writeOutputFileNoExecute "java_installer_scan"
    done < <( search_otherjava_v2 "$find_option" )
    
    find_option=""
    for java_enterprise in "jmc" "usagetracker.properties"; do
      if [ "${find_option}" == "" ]; then
          find_option="-name $java_enterprise"
      else
          find_option="$find_option -o -name $java_enterprise"
      fi
    done

    while read -r java_path; do
      date=$(date '+%Y-%m-%d %H:%M:%S:%3N')
      writeOutputFileNoExecute "java_enterprise_scan"
    done < <( search_otherjava_v2 "$find_option" )
  fi
fi

#echo "Java data collected and saved to $output_file"
#echo "Script execution finished"


### Display Java Colloect Log ###
cat $output_file
