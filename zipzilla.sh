#!/bin/bash
banner() {
    clear
    local term_width
    term_width=$(tput cols)
    
    # Top border
    printf '%*s\n' "$term_width" '' | tr ' ' '-'
    
    # Fancy title using toilet (with fallback to echo)
    echo -e "\e[92m"
      if command -v toilet &>/dev/null; then
        output=$(toilet -f mono12 --filter border "Zipzilla")
    elif command -v figlet &>/dev/null; then
        output=$(figlet "Zipzilla")
    else
        output="Zipzilla"
    fi

    # Center each line of output
    while IFS= read -r line; do
        padding=$(( (term_width - ${#line}) / 2 ))
        printf "%*s%s\n" "$padding" "" "$line"
    done <<< "$output"
    echo -e "\e[0m"
    
    # Subtitle centered
    subtitle="⚡ Welcome to zipzilla. A Powerful CLI Compression Tool ⚡"
    padding=$(( (term_width - ${#subtitle}) / 2 ))
    printf "%${padding}s%s\n" "" "$subtitle"
    
    # Bottom border
    printf '%*s\n' "$term_width" '' | tr ' ' '-'
}
banner
if [[ $# -eq 0 ]]; then
    clear
    banner
    echo -e "Usage: $0 \e[92m<file1> <file2> ...\e[0m || \e[92m<folder1> <folder2> ...\e[0m"
    echo  # Description block
    echo -e "\e[92m🗜️  Zipzilla is a blazing-fast, cross-platform compression tool for Linux, macOS, and Windows."
    echo "   It supports gzip, bzip2, compress, and zip — all in one place!"
    echo "🌍  Universal Compatibility:"
    echo "   ✔ Auto-detects OS and installs missing tools"
    echo "   ✔ Compresses and extracts files or folders easily"
    echo "   ✔ Ideal for scripting, backups, automation"
    echo "⚡  Built in pure Bash for maximum portability and power."
     echo "💡  100% Open Source | Built with ♥ in Bash"
    echo -e "🔗  GitHub: \e[94mhttps://github.com/mahajang214/zipzilla.git\e[92m"
    echo -e "📦  Contribute, fork, and stay updated with the latest improvements!\e[0m"

    exit 1
fi
file=()
for arg in "$@"; do
    if [[ -e $arg ]]; then
        file+=("$arg")
    else
        echo -e "\e[91mFile does not exist: $arg\e[0m"
        exit 1
    fi
done
# Chck file is valid or not
if [[ ! -e $file ]]; then
    echo -e "\e[91mFile does not exist: $file\e[0m"
    exit 1
fi



# Detect OS
detect_os(){
    OS="$(uname -s)"
    case "$OS" in
        Linux*)
            # Detect Linux distro
            if command -v apt-get &>/dev/null; then
                sudo apt-get install -y "${missing_tools[@]}"
                elif command -v pacman &>/dev/null; then
                sudo pacman -Sy --noconfirm "${missing_tools[@]}"
                elif command -v dnf &>/dev/null; then
                sudo dnf install -y "${missing_tools[@]}"
                elif command -v yum &>/dev/null; then
                sudo yum install -y "${missing_tools[@]}"
                elif command -v zypper &>/dev/null; then
                sudo zypper install -y "${missing_tools[@]}"
            else
                echo -e "\e[91mUnsupported Linux distro or missing package manager.\e[0m"
                exit 1
            fi
        ;;
        MINGW*|MSYS*|CYGWIN*|Windows_NT)
            echo -e "\e[93m⚠️ Detected Windows environment.\e[0m"

            if ! command -v choco &>/dev/null; then
            echo -e "\e[94mInstalling Chocolatey (for Windows package management)...\e[0m"
            powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; \
             [System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'; \
            iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
            else
            echo -e "\e[92mChocolatey already installed.\e[0m"
            fi

            echo -e "\e[94mInstalling compression tools using Chocolatey...\e[0m"
            choco_tools=$(IFS=" "; echo "${missing_tools[*]}")
            powershell -Command "choco install $choco_tools -y"

            echo -e "\e[92m✅ Required tools installed via Chocolatey.\e[0m"
        ;;
        Darwin)
            echo -e "\e[94mDetected macOS. Installing compression tools using Homebrew...\e[0m"

            # Check if Homebrew is already installed
            if ! command -v brew &>/dev/null; then
            echo -e "\e[93mHomebrew not found. Installing...\e[0m"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            # Set up brew environment (Apple Silicon or Intel)
            if [[ -d /opt/homebrew ]]; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -d /usr/local/Homebrew ]]; then
                echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/usr/local/bin/brew shellenv)"
            else
                echo -e "\e[91m❌ Homebrew installation path not found.\e[0m"
                exit 1
            fi
            fi

            # Re-check if brew is working
            if ! command -v brew &>/dev/null; then
            echo -e "\e[91m❌ Homebrew still not available in PATH.\e[0m"
            exit 1
            fi

            echo -e "\e[94mInstalling missing tools using brew...\e[0m"
            brew install "${missing_tools[@]}"
        ;;
        *)
            echo -e "\e[91mUnsupported OS: $OS\e[0m"
            exit 1
        ;;
    esac
    # Final verification
    echo -e "\n✅ Rechecking tool installation..."
    for tool in "${missing_tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            echo "$tool is installed."
        else
            echo "❌ $tool is still missing!"
            exit 1;
        fi
    done
    return 0
}

# execute_operation() {
#     for f in "${file[@]}"; do
#         if [[ -z $1 ]]; then
#             echo -e "\e[91m<Missing tool>\e[0m"
#             exit 1
#         fi

#         # ZIP Handling
#         if [[ $1 == "zip" ]]; then
#             if [[ -d $f ]]; then
#                 echo -e "\e[93mCompressing directory: $f using zip\e[0m"
#                 zip -r "archive.zip" "$f" 2>/dev/null
#             else
#                 echo -e "\e[93mCompressing file: $f using zip\e[0m"
#                 zip "archive.zip" "$f" 2>/dev/null
#             fi
#         else
#             # Other tool handling (gzip, bzip2, compress, etc.)
#             echo -e "\e[93mCompressing with: $1 -> $f\e[0m"
#             $1 "$f" 2>/dev/null
#         fi

#         # Success check
#         if [[ $? -eq 0 ]]; then
#             if [[ -n $2 ]]; then
#                 echo -e "\e[92mYour $1 file: $f.$2\e[0m"
#             else
#                 echo -e "\e[92mYour $1 file: $f\e[0m"
#             fi
#         else
#             echo -e "\e[91mError compressing $f with $1.\e[0m"
#         fi

#         # Optional TAR support (e.g., tar -czf archive.tar.gz folder/)
#         if [[ -n "$3" ]]; then
#     if [[ "$3" == -*c* ]]; then  # Compress
#         if [[ -d $f || -f $f ]]; then
#             tar -"$3" "$f.$2" "$f" 2>/dev/null
#             if [[ $? -ne 0 ]]; then 
#                 echo -e "\e[91m❌ Error: $f could not be compressed to $f.$2.\e[0m"
#             else 
#                 echo -e "\e[92m✅ Success: $f compressed to $f.$2.\e[0m"
#             fi
#         else
#             echo -e "\e[91m❌ Skipped TAR: $f is not a valid file or directory.\e[0m"
#         fi
#     elif [[ "$3" == -*x* ]]; then  # Extract
#         if [[ -f $f ]]; then
#             tar -"$3" "$f" 2>/dev/null
#             if [[ $? -ne 0 ]]; then 
#                 echo -e "\e[91m❌ Error: $f could not be extracted.\e[0m"
#             else 
#                 echo -e "\e[92m✅ Success: $f extracted successfully.\e[0m"
#             fi
#         else
#             echo -e "\e[91m❌ Skipped TAR: $f is not a valid archive file.\e[0m"
#         fi
#     else
#         echo -e "\e[93m⚠️ Unknown TAR operation: $3\e[0m"
#     fi
# fi
#     done
# }
execute_operation() {
    for f in "${file[@]}"; do
        if [[ -z $1 ]]; then
            echo -e "\e[91m<Missing tool>\e[0m"
            exit 1
        fi

        # ZIP Handling
        if [[ "$1" == "zip" ]]; then
            if [[ -d "$f" ]]; then
                echo -e "\e[93m📦 Compressing directory: $f using zip\e[0m"
                zip -r "archive.zip" "$f" 2>/dev/null
            else
                echo -e "\e[93m📦 Compressing file: $f using zip\e[0m"
                zip "archive.zip" "$f" 2>/dev/null
            fi
        else
            # Other tools: gzip, bzip2, compress, etc.
            echo -e "\e[93m📦 Compressing with: $1 -> $f\e[0m"
            $1 "$f" 2>/dev/null
        fi

        # Check success
        if [[ $? -eq 0 ]]; then
            if [[ -n $2 ]]; then
                echo -e "\e[92m✅ Output file: $f.$2\e[0m"
            else
                echo -e "\e[92m✅ Output file: $f\e[0m"
            fi
        else
            echo -e "\e[91m❌ Error compressing $f with $1.\e[0m"
        fi

        # TAR support (compression or extraction)
        if [[ -n "$3" ]]; then
            if [[ "$3" == -*c* ]]; then  # Compress
                if [[ -d "$f" || -f "$f" ]]; then
                    tar $3 "$f.$2" "$f" 2>/dev/null
                    if [[ $? -eq 0 ]]; then
                        echo -e "\e[92m✅ TAR compressed: $f → $f.$2\e[0m"
                    else
                        echo -e "\e[91m❌ TAR compression failed: $f\e[0m"
                    fi
                else
                    echo -e "\e[91m❌ Skipped TAR: $f is not a valid file or directory.\e[0m"
                fi

            elif [[ "$3" == -*x* ]]; then  # Extract
                if [[ -f "$f" ]]; then
                    tar $3 "$f" 2>/dev/null
                    if [[ $? -eq 0 ]]; then
                        echo -e "\e[92m✅ Extracted: $f successfully.\e[0m"
                    else
                        echo -e "\e[91m❌ Extraction failed: $f\e[0m"
                    fi
                else
                    echo -e "\e[91m❌ Skipped TAR: $f is not a valid archive file.\e[0m"
                fi

            else
                echo -e "\e[93m⚠️ Unknown TAR operation: $3\e[0m"
            fi
        fi
    done
}

# $1=tool $2=prefix $3=tar-type
echo -e "\e[92m"
echo "Welcome to Zipzilla! Please choose an option from the menu below:"
echo "1. Files extraction/compression"
echo "2. Folders extraction/compression"
echo "3. Images extraction/compression"
echo "4. Videos extraction/compression"
echo "5. Linux/Android applications extraction/compression"
echo "6. Exit"
read -p "Enter your option : " select_extraction
echo -e "\e[0m"
case $select_extraction in
    1)
        echo -e "\e[91mFile extraction/compression.\e[0m"
        echo
        echo -e "\e[92m"
        echo "Welcome to Zipzilla! Please choose an option from the menu below:"
        echo "1. gzip for $file"
        echo "2. bzip2 for $file"
        echo "3. compress $file"
        echo "4. zip $file"
        echo "5. extract *.gz = $file"
        echo "6. extract *.bz2 = $file"
        echo "7. decompress $file"
        echo "8. unzip $file"
        echo "9. Exit"
        read -p "Enter your choice: " choice
        echo -e "\e[0m"
        case $choice in
        1)
            # here i want to install that particular tool for usecase.
            missing_tools=(gzip)
            detect_os
            execute_operation gzip .gz
            exit 1;;
        2)
            missing_tools=(bzip2)
            detect_os
            execute_operation bzip2 .bz2
            exit 1;;
        3)
            missing_tools=(compress)
            detect_os
            execute_operation compress .Z
            exit 1;;
        4)
            missing_tools=(zip)
            detect_os
            execute_operation zip archive.zip
            exit 1;;
        5)
            missing_tools=(gzip)
            detect_os
            if [[ $file == *.gz ]]; then
                execute_operation gunzip
            else
                echo -e "\e[91mFile is not a gzip file.\e[0m"
                exit 1;
            fi
            exit 1;;
        6)
            missing_tools=(bzip2)
            detect_os
            if [[ $file == *.bz2 ]]; then
                execute_operation bunzip2
            else
                echo -e "\e[91mFile is not a bzip2 file.\e[0m"
                exit 1;
            fi
            exit 1;;
        7)
            missing_tools=(ncompress)
            detect_os
            if [[ $file == *.Z ]]; then
                execute_operation uncompress
            else
                echo -e "\e[91m$file is not a compressed.\e[0m"
                exit 1;
            fi
            exit 1;;
        8)
            missing_tools=(unzip)
            detect_os
            execute_operation unzip
            exit 1;;
        9)  
            echo -e "\e[91mExiting program\e[0m"
            exit 1;;

        *)
            echo -e "\e[31m"
            echo "Invalid choice. Please try again."
            echo -e "\e[0m"
            exit 1;;
        esac
    ;;
    2)  
        echo -e "\e[91mFolder extraction/compression.\e[0m"
        echo
        echo -e "\e[92m"
        echo "Please choose an option from the menu below:" 
        echo "1. zip $file"
        echo "2. tar + gzip $file"
        echo "3. tar + bzip2 $file"
        echo "4. tar + xz $file"
        echo "5. unzip $file"
        echo "6. extract *.tar.gz = $file"
        echo "7. extract *.tar.bz2 = $file"
        echo "8. extract *.tar.xz = $file"
        read -p "Enter your choice : " choice1
        echo -e "\e[0m"
        case $choice1 in
            1)
                missing_tools=(zip)
                detect_os
                execute_operation zip archive.zip
                exit 1;; 
            2)  
                missing_tools=(tar gzip)
                detect_os
                execute_operation tar archive.tar.gz -czvf 
                exit 1;;
            3) 
                missing_tools=(tar bzip2)
                detect_os
                execute_operation tar archive.tar.bz2 -cjvf 
                exit 1;;
            4)
                missing_tools=(tar xz)
                detect_os
                execute_operation tar archive.tar.xz -cJvf 
                exit 1
            ;;
            5)  
                missing_tools=(unzip)
                detect_os
                execute_operation unzip archive.zip
                exit 1
            ;;
            6) 
               missing_tools=(tar)
                detect_os
                execute_operation tar archive.tar.gz -xzvf
                exit 1
            ;; 
            7) 
               missing_tools=(tar)
                detect_os
                execute_operation tar archive.tar.bz2 -xjvf
                exit 1
            ;; 
            8) 
               missing_tools=(tar)
                detect_os
                execute_operation tar archive.tar.xz -xJvf
                exit 1
            ;;
            *)
                echo -e "\e[31m"
                echo "Invalid choice. Please try again."
                echo -e "\e[0m"
                exit 1;;
        esac
    ;;
    3)
        echo -e "\e[91mImages extraction/compression.\e[0m"
        echo -e "\e[92m"
        echo "Only jpg, jpeg, png, and webp files are supported."
        echo "Please choose an option from the menu below:" 
        echo "1. zip $file"
        echo "2. tar + gzip $file"
        echo "3. tar + bzip2 $file"
        echo "4. unzip $file"
        echo "5. extract *.tar.gz = $file"
        echo "6. extract *.tar.bz2 = $file"
        read -p "Enter your choice : " choice2
        echo -e "\e[0m"
        case $choice2 in
            1)
                missing_tools=(zip)
                detect_os
                execute_operation zip archive.zip
                exit 1;; 
            2)  
                missing_tools=(tar gzip)
                detect_os
                execute_operation tar archive.tar.gz -czvf 
                exit 1;;
            3) 
                missing_tools=(tar bzip2)
                detect_os
                execute_operation tar archive.tar.bz2 -cjvf 
                exit 1;;
            4)
                missing_tools=(unzip)
                detect_os
                execute_operation unzip archive.zip
                exit 1
            ;;
            5) 
               missing_tools=(tar)
                detect_os
                execute_operation tar archive.tar.gz -xzvf
                exit 1
            ;; 
            6) 
               missing_tools=(tar)
                detect_os
                execute_operation tar archive.tar.bz2 -xjvf
                exit 1
            ;; 
            *)
                echo -e "\e[31m"
                echo "Invalid choice. Please try again."
                echo -e "\e[0m"
                exit 1;;
        esac
    ;;
    4)
        echo -e "\e[91mVideos extraction/compression.\e[0m"
        echo -e "\e[92m"
        echo "Please choose an option from the menu below:" 
    ;;

    *)
        echo -e "\e[31m"
        echo "Invalid choice. Please try again."
        echo -e "\e[0m"
        exit 1;;
    
esac
