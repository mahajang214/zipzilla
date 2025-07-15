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
            echo -e "\e[93m⚠️ Detected Windows environment (Git Bash/MSYS2/WSL).\e[0m"

            # Attempt MSYS2 automated installation
            if command -v pacman &>/dev/null; then
            echo -e "\e[94mDetected MSYS2. Installing missing tools via pacman...\e[0m"
            pacman -Sy --noconfirm "${missing_tools[@]}"
            elif grep -qi microsoft /proc/version 2>/dev/null; then
            echo -e "\e[94mDetected WSL (Windows Subsystem for Linux).\e[0m"
            echo -e "➡ Installing using apt..."
            sudo apt-get update && sudo apt-get install -y "${missing_tools[@]}"
            else
            echo -e "\e[91m❌ Automatic installation failed or unsupported Windows shell.\e[0m"
            echo -e "Please install the following tools manually: ${missing_tools[*]}"
            echo -e "💡 Tip: Use MSYS2 from https://www.msys2.org/ and run:\n  pacman -S ${missing_tools[*]}"
            echo -e "Or use Chocolatey (https://chocolatey.org/) if available."
            exit 1
            fi
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

execute_operation(){
    for f in "${file[@]}"; do
        if [[ -z $1 ]];then echo "<missing tool>"; exit 1; fi
        if [[ $1 == "zip" ]]; then
            if [[ -d $f ]]; then
                echo -e "\e[93mCompressing directory: $f\e[0m"
                $1 -r "archive.zip" "$f" 2>/dev/null
                
            else
                echo -e "\e[93mCompressing file: $f\e[0m"
                $1 "archive.zip" "$f" 2>/dev/null
            fi
            
        fi
        $1 "$f"
        if [[ $? -eq 0 ]]; then
            if [[ $2 ]];then
                echo "Your $1 file : $f.$2"
            fi
            echo "Your $1 file : $f"
        else
            echo -e "\e[91mError compressing file with $1.\e[0m"
        fi
    done
}

# $1=tool $2=prefix


while true; do
    echo -e "\e[92m"
    echo "Welcome to Zipzilla! Please choose an option from the menu below:"
    echo "1. gzip for $file"
    echo "2. bzip2 for $file"
    echo "3. compress $file"
    echo "4. zip $file"
    echo "5. extract gzip $file"
    echo "6. extract bzip2 $file"
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
            break
        ;;
        2)
            missing_tools=(bzip2)
            detect_os
            execute_operation bzip2 .bz2
            break
        ;;
        3)
            missing_tools=(compress)
            detect_os
            execute_operation compress .Z
            break
        ;;
        4)
            missing_tools=(zip)
            detect_os
            execute_operation zip archive.zip
            break
        ;;
        5)
            missing_tools=(gzip)
            detect_os
            if [[ $file == *.gz ]]; then
                execute_operation gunzip
            else
                echo -e "\e[91mFile is not a gzip file.\e[0m"
                exit 1;
            fi
            break
        ;;
        6)
            missing_tools=(bzip2)
            detect_os
            if [[ $file == *.bz2 ]]; then
                execute_operation bunzip2
            else
                echo -e "\e[91mFile is not a bzip2 file.\e[0m"
                exit 1;
            fi
            break
        ;;
        7)
            missing_tools=(ncompress)
            detect_os
            if [[ $file == *.Z ]]; then
                execute_operation uncompress
            else
                echo -e "\e[91m$file is not a compressed.\e[0m"
                exit 1;
            fi
            break
        ;;
        8)
            missing_tools=(unzip)
            detect_os
            execute_operation unzip
        break;;
        9)
            echo -e "\e[91mExiting program\e[0m"
        break;;
        *)
            echo -e "\e[31m"
            echo "Invalid choice. Please try again."
            echo -e "\e[0m"
        ;;
    esac
done