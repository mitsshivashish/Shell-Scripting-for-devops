name=$(which bash)
#!/$name

# This is a basic shell script that introduces myself and gives info about date and present working directory

read -p "User's Name : " username
echo "User's name is $username"
echo "Current date is $(date)"
echo "Current working directory is $(pwd)"
