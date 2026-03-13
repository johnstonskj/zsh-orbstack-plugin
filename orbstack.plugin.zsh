# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name: orbstack
# @brief: Set the environment for the OrbStack CLI.
# @repository: https://github.com/johnstonskj/zsh-orbstack-plugin
# @version: 0.1.1
# @license: MIT AND Apache-2.0
#
# ### Public Variables
#
# * `ORB_HOME`; if set it does something magical.
#

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

orbstack_plugin_init() {
    builtin emulate -L zsh

    @zplugins_envvar_save orbstack ORB_HOME
    typeset -g ORB_HOME="${ORB_HOME:-${HOME}/.orbstack}"

    @zplugins_add_to_path orbstack "${ORB_HOME}/bin"

    if [[ "${OSTYPE}" == [Dd]arwin* ]] ; then
        @zplugins_add_to_fpath orbstack "/Applications/OrbStack.app/Contents/Resources/completions/zsh"
    fi
}

# @internal
orbstack_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore orbstack ORB_HOME
}
