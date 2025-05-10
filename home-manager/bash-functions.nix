{
  setPrompt = ''
    function set_prompt () {
      # Color codes for easy prompt building
      COLOR_DIVIDER="\[\e[30;1m\]"
      COLOR_CMDCOUNT="\[\e[34;1m\]"
      COLOR_USERNAME="\[\e[34;1m\]"
      COLOR_USERHOSTAT="\[\e[34;1m\]"
      COLOR_HOSTNAME="\[\e[34;1m\]"
      COLOR_GITBRANCH="\[\e[33;1m\]"
      COLOR_VENV="\[\e[33;1m\]"
      COLOR_NIX="\[\e[36;1m\]"
      COLOR_GREEN="\[\e[32;1m\]"
      COLOR_PATH_OK="\[\e[32;1m\]"
      COLOR_PATH_ERR="\[\e[31;1m\]"
      COLOR_NONE="\[\e[0m\]"

      # Change the path color based on return value.
      if test $? -eq 0 ; then
      	PATH_COLOR=''${COLOR_PATH_OK}
      else
      	PATH_COLOR=''${COLOR_PATH_ERR}
      fi

      # Set the PS1 to be "[workingdirectory:commandcount"
      PS1="''${COLOR_DIVIDER}[''${PATH_COLOR}\w''${COLOR_DIVIDER}"

      # Add git branch portion of the prompt, this adds ":branchname"
      if ! git_loc="''$(type -p "$git_command_name")" || [ -z "$git_loc" ]; then
      	# Git is installed
      	if [ -d .git ] || git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
      		# Inside of a git repository
      		GIT_BRANCH=''$(git symbolic-ref --short HEAD)
      		PS1="''${PS1}:''${COLOR_GITBRANCH}''${GIT_BRANCH}''${COLOR_DIVIDER}"
      	fi
      fi

      # Close out the prompt, this adds "]\n[username@hostname] "
      PS1="[''${COLOR_USERNAME}\u''${COLOR_USERHOSTAT}@''${COLOR_HOSTNAME}\h] ''${COLOR_DIVIDER}''${PS1}]''${COLOR_NONE} "

      # When we're in a nix devShell, annotate the PS1 with the environment's name
      if [ -n "$name" ]; then
        PS1="(nix:''${COLOR_NIX}''${name}''${COLOR_NONE}) ''${PS1}"
      fi

      # Provide Python virtual environment information when one is sourced
      if [ -n "$VIRTUAL_ENV" ]; then
        VENV_NAME="$(basename "$VIRTUAL_ENV")"
        PS1="(venv:''${COLOR_VENV}''${VENV_NAME}''${COLOR_NONE}) ''${PS1}"
      fi
    }
  '';
}
