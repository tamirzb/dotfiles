function docker -w docker
    if not systemctl is-active docker.service > /dev/null
        echo Starting docker.service...
        sudo systemctl start docker.service
    end
    command docker $argv
end
