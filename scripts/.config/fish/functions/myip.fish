function myip
    set -l args "-4"
    if test "$argv[1]" = "6"
        set args "-6"
    end
    set -l ip (dig $args TXT o-o.myaddr.l.google.com @ns1.google.com +short)
    # Remove the parentheses that Google adds
    echo $ip | string sub -s 2 -e -1
end
