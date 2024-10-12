#!/bin/bash

# Function to create a user account with specified settings
create_user() {
  local username=$1
  local home_dir="/home/$username"
  local password=$username
  
  # Create the user with a home directory, bash shell, and add to the wheel group
  useradd -m -d "$home_dir" -s /bin/bash -G wheel "$username"
  
  # Set the user's password to the username
  echo "$username:$password" | chpasswd
  
  # Set the password to expire every 30 days
  chage -M 30 "$username"
  
  # Set the home directory permissions to 700 (owner can read, write, execute)
  chmod 700 "$home_dir"
  
  # Create a notice about password expiration in the user's home directory
  echo "Password for $username will expire in 30 days" > "$home_dir/password_expiration_notice.txt"
  
  # Output a message indicating the user has been created successfully
  echo "Created user: $username"
}

# Error handling: Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Loop to create 100 user accounts with incrementing usernames
for i in {1..100}; do
  username="mycompusr$i"
  create_user "$username"
done

# Output a message indicating all user accounts have been created
echo "All user accounts have been created successfully."
