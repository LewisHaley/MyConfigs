# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin
PATH=$PATH:$HOME/test-dev/uitests/tools

PYTHONPATH=$PYTHONPATH:/usr/libexec/stbt
PYTHONPATH=$PYTHONPATH:$HOME/libexec/stbt
PYTHONPATH=$PYTHONPATH:$HOME/test-dev/uitests/library

export PATH PYTHON
