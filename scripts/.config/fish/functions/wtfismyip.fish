function wtfismyip
    curl -s wtfismyip.com/json | tail -n +2 | head -n -2 | sed -e 's/YourFucking/Your/'
end
