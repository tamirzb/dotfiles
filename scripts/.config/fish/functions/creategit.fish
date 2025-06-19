function creategit -d "Initialize a git repository with given parameters"
    # Check if correct number of arguments is provided
    if test (count $argv) -ne 3
        echo "Usage: creategit <author_name> <author_email> <repo_name>"
        return 1
    end

    # Assign parameters to variables
    set author_name $argv[1]
    set author_email $argv[2]
    set repo_name $argv[3]

    # Create directory and cd into it
    mkdir $repo_name
    cd $repo_name

    # Initialize git repository
    git init

    # Configure git user info
    git config user.name "$author_name"
    git config user.email "$author_email"

    # Create empty .gitignore
    touch .gitignore

    # Stage and commit .gitignore
    git add .gitignore
    git commit -m "Initial commit"

    echo "Repository '$repo_name' created and initialized successfully!"
end
