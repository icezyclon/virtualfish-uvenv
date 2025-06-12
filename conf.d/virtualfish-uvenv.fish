if test -n "$VIRTUALFISH_VERSION"
    set -g UVENV_ECHO_ACTIVATION true
    set -g UVENV_ECHO_DEACTIVATION false

    if functions -q mkvirtualenv
        abbr -a mkvirtualenv mkuvenv
    end
    
    function _uvenv_match_vf_new
        string match --quiet 'vf new ' -- (commandline -j); or return 1
        # commandline -r mkuvenv # TODO: this only replaces the token, NOT the entire commandline, why?
        echo "> /dev/null && mkuvenv"
    end
    abbr -a _uvenv_abbr_vf_new --position anywhere --regex new --function _uvenv_match_vf_new
    

    function _uvenv_vf_activate --on-event virtualenv_did_activate
        if test -f "$VIRTUAL_ENV/pyproject.toml"
            if test "$UVENV_ECHO_ACTIVATION" = true
                echo "uvenv" (set_color cyan)(basename $VIRTUAL_ENV)(set_color normal) "activated"
            end
            set -gx UV_PROJECT $VIRTUAL_ENV
            set -gx UV_PROJECT_ENVIRONMENT .
            if abbr -q pip
                abbr --rename pip _uvenv_old_pip_abbr
            end
            abbr -a pip uv pip
        else if test "$UVENV_ECHO_ACTIVATION" = true
            echo "regular venv" (set_color green)(basename $VIRTUAL_ENV)(set_color normal) "activated"
        end
    end

    function _uvenv_vf_deactivate --on-event virtualenv_did_deactivate
        if test -f "$VIRTUAL_ENV/pyproject.toml"
            if test "$UVENV_ECHO_DEACTIVATION" = true
                echo "uvenv" (set_color cyan)(basename $VIRTUAL_ENV)(set_color normal) "deactivated"
            end
            set -e UV_PROJECT
            set -e UV_PROJECT_ENVIRONMENT
            abbr -e pip
            if abbr -q _uvenv_old_pip_abbr
                abbr --rename _uvenv_old_pip_abbr pip 
            end
        else if test "$UVENV_ECHO_DEACTIVATION" = true
            echo "regular venv" (set_color green)(basename $VIRTUAL_ENV)(set_color normal) "deactivated"
        end
    end

    set -g _UVENV_LOADED true
else
    echo "[plugin: virtualfish-uvenv] Virtualfish is not loaded - install with 'vf install', or this plugin may have been loaded before virtualfish-loader."
    set -g _UVENV_LOADED false
end