function fish_greeting
    echo -ne '\x1b[38;5;16m'  # Set colour to primary
    echo '    _______         __                         '
    echo '   |_     _|.---.-.|  |--.--.--.--.--.---.-.   '
    echo '     |   |  |  _  ||    <|  |  |  |  |  _  |   '
    echo '     |___|  |___._||__|__|_____|___  |___._|   '
    echo '                               |_____|         '
    set_color normal
    fastfetch --key-padding-left 5
end
